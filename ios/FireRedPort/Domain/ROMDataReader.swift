import Foundation
import CryptoKit

/// Reads only bytes from an already identified private copy. Does not interpret or execute ARM code.
struct ROMDataReader {
    private static let chunkSize = 64 * 1024
    private let url: URL
    let profile: ReferenceProfile

    init(privateURL: URL, profile: ReferenceProfile) {
        self.url = privateURL
        self.profile = profile
    }

    func read(offset: Int, count: Int) throws -> Data {
        guard offset >= 0, count >= 0, count <= Self.chunkSize,
              offset <= profile.byteCount, count <= profile.byteCount - offset else {
            throw ROMImportError.outOfBounds
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(offset))
        var result = Data()
        while result.count < count {
            guard let part = try handle.read(upToCount: count - result.count), !part.isEmpty else {
                throw ROMImportError.truncated
            }
            result.append(part)
        }
        return result
    }

    /// A verified layout and maximum count are required before table reads can be enabled.
    func readTable(named name: String, offset: Int, entries: Int, stride: Int) throws -> Data {
        guard let maximum = profile.validatedTableLimits[name] else {
            throw ROMImportError.extractionNotValidated
        }
        guard entries >= 0, entries <= maximum, stride > 0 else { throw ROMImportError.invalidCount }
        let (size, overflow) = entries.multipliedReportingOverflow(by: stride)
        guard !overflow, size <= Self.chunkSize else { throw ROMImportError.invalidCount }
        return try read(offset: offset, count: size)
    }
}

/// Performs identity verification before any persistent copy. No networking or ROM assets in the app bundle.
enum LocalROMImporter {
    static func importSelectedFile(_ source: URL) throws -> ROMDataReader {
        guard source.startAccessingSecurityScopedResource() else { throw ROMImportError.accessDenied }
        defer { source.stopAccessingSecurityScopedResource() }

        let fm = FileManager.default
        let attributes: [FileAttributeKey: Any]
        do { attributes = try fm.attributesOfItem(atPath: source.path) }
        catch { throw ROMImportError.accessDenied }
        guard let size = attributes[.size] as? NSNumber else { throw ROMImportError.accessDenied }
        guard size.int64Value >= Int64(ReferenceProfile.reference.byteCount) else { throw ROMImportError.truncated }
        guard size.int64Value == Int64(ReferenceProfile.reference.byteCount),
              attributes[.type] as? FileAttributeType == .typeRegular else { throw ROMImportError.incompatible }

        let firstDigest = try digestAndHeader(source)
        let profile = try ReferenceProfile.identify(sha256: firstDigest.digest, byteCount: firstDigest.count, header: firstDigest.header)

        let directory = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        if let available = try? directory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage,
           available < Int64(profile.byteCount) + 1_048_576 { throw ROMImportError.insufficientSpace }

        let destination = directory.appendingPathComponent("reference.gba", isDirectory: false)
        let temporary = directory.appendingPathComponent(UUID().uuidString + ".tmp", isDirectory: false)
        defer { try? fm.removeItem(at: temporary) }
        do {
            let input = try FileHandle(forReadingFrom: source)
            defer { try? input.close() }
            guard fm.createFile(atPath: temporary.path, contents: nil) else { throw ROMImportError.insufficientSpace }
            var privateFile = temporary
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try privateFile.setResourceValues(values)
            let output = try FileHandle(forWritingTo: temporary)
            defer { try? output.close() }
            var hasher = SHA256()
            var copied = 0
            while let bytes = try input.read(upToCount: 64 * 1024), !bytes.isEmpty {
                copied += bytes.count
                guard copied <= profile.byteCount else { throw ROMImportError.incompatible }
                hasher.update(data: bytes)
                try output.write(contentsOf: bytes)
            }
            guard copied == profile.byteCount else { throw ROMImportError.truncated }
            let copiedDigest = hasher.finalize().map { String(format: "%02x", $0) }.joined()
            guard copiedDigest == profile.sha256 else { throw ROMImportError.incompatible }
            try output.synchronize()
            // Never remove an existing valid copy until the replacement is complete.
            if fm.fileExists(atPath: destination.path) {
                _ = try fm.replaceItemAt(destination, withItemAt: temporary)
            } else {
                try fm.moveItem(at: temporary, to: destination)
            }
            return ROMDataReader(privateURL: destination, profile: profile)
        } catch let error as ROMImportError {
            throw error
        } catch {
            throw ROMImportError.insufficientSpace
        }
    }

    private static func digestAndHeader(_ url: URL) throws -> (digest: String, count: Int, header: Data) {
        let input: FileHandle
        do { input = try FileHandle(forReadingFrom: url) }
        catch { throw ROMImportError.accessDenied }
        defer { try? input.close() }
        var hasher = SHA256()
        var header = Data()
        var count = 0
        do {
            while let bytes = try input.read(upToCount: 64 * 1024), !bytes.isEmpty {
                count += bytes.count
                guard count <= ReferenceProfile.reference.byteCount else { throw ROMImportError.incompatible }
                if header.count < 0xBE { header.append(bytes.prefix(0xBE - header.count)) }
                hasher.update(data: bytes)
            }
        } catch let error as ROMImportError { throw error }
        catch { throw ROMImportError.accessDenied }
        return (hasher.finalize().map { String(format: "%02x", $0) }.joined(), count, header)
    }
}
