import Darwin
import Foundation

/// One actor serializes operations performed through this instance. Use one shared instance
/// per app; concurrent processes writing the same directory are not supported.
actor SaveStore {
    enum StoreError: Error, Equatable {
        case invalidIdentity
        case notFound
        case incompatibleReference
        case staleRevision
        case corruptFile
        case oversizedFile
        case ioFailure(String)
    }

    private let directory: URL
    private let files = FileManager.default
    private let maximumFileSize = 4 * 1024 * 1024

    /// Pass a private temporary directory in tests. Default is app-private Application Support.
    init(directory: URL? = nil) throws {
        if let directory {
            self.directory = directory
        } else {
            guard let support = FileManager.default.urls(for: .applicationSupportDirectory,
                                                          in: .userDomainMask).first else {
                throw StoreError.ioFailure("Application Support is unavailable")
            }
            self.directory = support.appendingPathComponent("FireRedPort/Saves", isDirectory: true)
        }
        do {
            try files.createDirectory(at: self.directory, withIntermediateDirectories: true)
        } catch {
            throw StoreError.ioFailure("Could not create save directory: \(error.localizedDescription)")
        }
    }

    private func urls(for slotId: String) throws -> (active: URL, backup: URL) {
        guard SaveSnapshot.validSlotId(slotId) else { throw StoreError.invalidIdentity }
        return (directory.appendingPathComponent("\(slotId).json"),
                directory.appendingPathComponent("\(slotId).backup.json"))
    }

    private func exists(_ url: URL) -> Bool {
        files.fileExists(atPath: url.path)
    }

    private func read(_ url: URL, slotId: String, referenceSha256: String) throws -> SaveSnapshot {
        guard exists(url) else { throw StoreError.notFound }
        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try files.attributesOfItem(atPath: url.path)
        } catch {
            throw StoreError.ioFailure("Cannot inspect save: \(error.localizedDescription)")
        }
        guard let length = attributes[.size] as? NSNumber,
              length.int64Value <= Int64(maximumFileSize) else { throw StoreError.oversizedFile }
        let data: Data
        do {
            data = try Data(contentsOf: url, options: [])
        } catch {
            throw StoreError.ioFailure("Cannot read save: \(error.localizedDescription)")
        }
        guard data.count <= maximumFileSize else { throw StoreError.oversizedFile }
        let snapshot: SaveSnapshot
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            snapshot = try decoder.decode(SaveSnapshot.self, from: data)
        } catch let error as SaveSnapshotError {
            throw error
        } catch {
            throw StoreError.corruptFile
        }
        guard snapshot.slotId == slotId else { throw StoreError.corruptFile }
        guard snapshot.referenceSha256 == referenceSha256 else {
            throw StoreError.incompatibleReference
        }
        return snapshot
    }

    func load(slotId: String, referenceSha256: String) throws -> SaveSnapshot {
        guard SaveSnapshot.validReferenceHash(referenceSha256) else { throw StoreError.invalidIdentity }
        let pair = try urls(for: slotId)
        // Never silently fall back: callers must explicitly request backup recovery.
        return try read(pair.active, slotId: slotId, referenceSha256: referenceSha256)
    }

    func recoverLastIntact(slotId: String, referenceSha256: String) throws -> SaveSnapshot {
        guard SaveSnapshot.validReferenceHash(referenceSha256) else { throw StoreError.invalidIdentity }
        let pair = try urls(for: slotId)
        // Non-mutating recovery keeps both files available for inspection.
        return try read(pair.backup, slotId: slotId, referenceSha256: referenceSha256)
    }

    private func encode(_ snapshot: SaveSnapshot) throws -> Data {
        try snapshot.validate()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(snapshot)
        guard data.count <= maximumFileSize else { throw StoreError.oversizedFile }
        return data
    }

    /// Darwin rename replaces an existing destination atomically on the same filesystem.
    /// Stage each file in the save directory, not the system-wide temporary directory.
    private func activate(_ source: URL, at destination: URL) throws {
        if rename(source.path, destination.path) != 0 {
            let reason = String(cString: strerror(errno))
            throw StoreError.ioFailure("Could not activate save file: \(reason)")
        }
    }

    func save(_ snapshot: SaveSnapshot) throws {
        let pair = try urls(for: snapshot.slotId)
        let bytes = try encode(snapshot)
        var previous: SaveSnapshot?
        if exists(pair.active) {
            previous = try read(pair.active, slotId: snapshot.slotId,
                                referenceSha256: snapshot.referenceSha256)
            guard snapshot.revision > previous!.revision else { throw StoreError.staleRevision }
        }
        // Do not overwrite a backup that cannot be decoded (including a future schema).
        if exists(pair.backup) {
            _ = try read(pair.backup, slotId: snapshot.slotId,
                         referenceSha256: snapshot.referenceSha256)
        }

        let pending = directory.appendingPathComponent(".\(UUID().uuidString).pending")
        let backupPending = directory.appendingPathComponent(".\(UUID().uuidString).backup-pending")
        defer {
            try? files.removeItem(at: pending)
            try? files.removeItem(at: backupPending)
        }
        do {
            // In memory -> temporary -> validated -> active. .atomic writes to a
            // same-directory temporary file before renaming to the staging path.
            try bytes.write(to: pending, options: .atomic)
            let staged = try read(pending, slotId: snapshot.slotId,
                                  referenceSha256: snapshot.referenceSha256)
            guard staged == snapshot else { throw StoreError.corruptFile }
            if let previous {
                let oldBytes = try Data(contentsOf: pair.active)
                guard oldBytes.count <= maximumFileSize else { throw StoreError.oversizedFile }
                try oldBytes.write(to: backupPending, options: .atomic)
                let verifiedBackup = try read(backupPending, slotId: snapshot.slotId,
                                              referenceSha256: snapshot.referenceSha256)
                guard verifiedBackup == previous else { throw StoreError.corruptFile }
                try activate(backupPending, at: pair.backup)
            }
            try activate(pending, at: pair.active)
        } catch let error as SaveSnapshotError {
            throw error
        } catch let error as StoreError {
            throw error
        } catch {
            throw StoreError.ioFailure("Save failed without replacing active snapshot: \(error.localizedDescription)")
        }
    }
}
