import Foundation
import CryptoKit

/// Single tile attribute parsed from ROM map data.
public struct MapTileInfo: Sendable, Equatable {
    public let tileId: Int
    public let collision: Int
    public var isPassable: Bool {
        collision == 0x00 || collision == 0x0C
    }

    public init(tileId: Int, collision: Int) {
        self.tileId = tileId
        self.collision = collision
    }
}

/// Overworld map layout extracted dynamically from private ROM copy.
public struct MapLayoutData: Sendable, Equatable {
    public let bank: Int
    public let map: Int
    public let name: String
    public let width: Int
    public let height: Int
    public let tiles: [MapTileInfo]

    public init(bank: Int, map: Int, name: String, width: Int, height: Int, tiles: [MapTileInfo]) {
        self.bank = bank
        self.map = map
        self.name = name
        self.width = width
        self.height = height
        self.tiles = tiles
    }

    public func tileAt(x: Int, y: Int) -> MapTileInfo? {
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        return tiles[y * width + x]
    }

    public func isPassable(x: Int, y: Int) -> Bool {
        guard let tile = tileAt(x: x, y: y) else { return false }
        return tile.isPassable
    }
}

/// Reads only bytes from an already identified private copy. Does not interpret or execute ARM code.
struct ROMDataReader {
    private static let chunkSize = 64 * 1024
    private let url: URL
    let profile: ReferenceProfile

    init(privateURL: URL, profile: ReferenceProfile) {
        self.url = privateURL
        self.profile = profile
    }

    /// Revalidate the private copy before exposing it to the app session. A
    /// supplied profile alone is never proof that the file still matches it.
    func verifyIdentity() throws {
        guard profile.sha256 == ReferenceProfile.reference.sha256,
              profile.byteCount == ReferenceProfile.reference.byteCount else {
            throw ROMImportError.incompatible
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var digest = SHA256()
        var header = Data()
        var count = 0
        while let chunk = try handle.read(upToCount: Self.chunkSize), !chunk.isEmpty {
            count += chunk.count
            guard count <= profile.byteCount else { throw ROMImportError.incompatible }
            if header.count < 0xBE { header.append(chunk.prefix(0xBE - header.count)) }
            digest.update(data: chunk)
        }
        guard count == profile.byteCount else { throw ROMImportError.truncated }
        let hash = digest.finalize().map { String(format: "%02x", $0) }.joined()
        _ = try ReferenceProfile.identify(sha256: hash, byteCount: count, header: header)
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

    /// Only expose the bounded structural probe after rechecking the private
    /// file itself, not merely a caller-supplied profile or a previously valid copy.
    func verifiedTextPointer(at index: Int) throws -> Int {
        guard profile.sha256 == ReferenceProfile.reference.sha256,
              profile.byteCount == ReferenceProfile.reference.byteCount else {
            throw ROMImportError.extractionNotValidated
        }
        guard (0..<109).contains(index) else { throw ROMImportError.invalidCount }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var digest = SHA256()
        var size = 0
        while let chunk = try handle.read(upToCount: Self.chunkSize), !chunk.isEmpty {
            size += chunk.count
            guard size <= profile.byteCount else { throw ROMImportError.incompatible }
            digest.update(data: chunk)
        }
        let actual = digest.finalize().map { String(format: "%02x", $0) }.joined()
        guard size == profile.byteCount, actual == profile.sha256 else {
            throw ROMImportError.incompatible
        }
        // Inspect through the same descriptor that was hashed, so replacing
        // the path between verification and inspection cannot switch files.
        let tableOffset = 0x3f1cac + index * 4
        try handle.seek(toOffset: UInt64(tableOffset))
        let word = try Self.readExactly(4, from: handle)
        let address = word.enumerated().reduce(UInt32(0)) { result, element in
            result | (UInt32(element.element) << (element.offset * 8))
        }
        guard (0x083eecfc...0x083ef23b).contains(address) else {
            throw ROMImportError.outOfBounds
        }
        let offset = Int(address - 0x08000000)
        try handle.seek(toOffset: UInt64(offset))
        let window = try Self.readExactly(min(100, 0x3ef23c - offset), from: handle)
        guard window.contains(0xff) else { throw ROMImportError.outOfBounds }
        return offset
    }

    private static func readExactly(_ count: Int, from handle: FileHandle) throws -> Data {
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

    private func readUInt32(from handle: FileHandle, offset: Int) throws -> UInt32 {
        guard offset >= 0, offset + 4 <= profile.byteCount else { throw ROMImportError.outOfBounds }
        try handle.seek(toOffset: UInt64(offset))
        let data = try Self.readExactly(4, from: handle)
        return UInt32(data[0]) | (UInt32(data[1]) << 8) | (UInt32(data[2]) << 16) | (UInt32(data[3]) << 24)
    }

    /// Loads statically verified map layout directly from the private ROM copy at runtime.
    /// Does not execute or emulate ARM CPU instructions.
    func loadMapLayout(bank: Int, map: Int) throws -> MapLayoutData {
        guard profile.sha256 == ReferenceProfile.reference.sha256,
              profile.byteCount == ReferenceProfile.reference.byteCount else {
            throw ROMImportError.extractionNotValidated
        }
        guard bank >= 0, bank < 35, map >= 0, map < 150 else {
            throw ROMImportError.invalidCount
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        // BPRE v1.0 gMapGroups table statically verified at 0x3526A8
        let gMapGroupsOffset = 0x3526A8
        let bankPtr = try readUInt32(from: handle, offset: gMapGroupsOffset + bank * 4)
        guard bankPtr >= 0x08000000, bankPtr < 0x09000000 else { throw ROMImportError.outOfBounds }
        let bankOffset = Int(bankPtr - 0x08000000)

        let headerPtr = try readUInt32(from: handle, offset: bankOffset + map * 4)
        guard headerPtr >= 0x08000000, headerPtr < 0x09000000 else { throw ROMImportError.outOfBounds }
        let headerOffset = Int(headerPtr - 0x08000000)

        let mapDataPtr = try readUInt32(from: handle, offset: headerOffset)
        guard mapDataPtr >= 0x08000000, mapDataPtr < 0x09000000 else { throw ROMImportError.outOfBounds }
        let mapDataOffset = Int(mapDataPtr - 0x08000000)

        let width = Int(try readUInt32(from: handle, offset: mapDataOffset))
        let height = Int(try readUInt32(from: handle, offset: mapDataOffset + 4))
        guard width > 0, width <= 200, height > 0, height <= 200 else { throw ROMImportError.outOfBounds }

        let tilesPtr = try readUInt32(from: handle, offset: mapDataOffset + 12)
        guard tilesPtr >= 0x08000000, tilesPtr < 0x09000000 else { throw ROMImportError.outOfBounds }
        let tilesOffset = Int(tilesPtr - 0x08000000)

        let tileCount = width * height
        let byteCount = tileCount * 2
        guard tilesOffset + byteCount <= profile.byteCount else { throw ROMImportError.outOfBounds }

        try handle.seek(toOffset: UInt64(tilesOffset))
        let rawData = try Self.readExactly(byteCount, from: handle)

        var tiles: [MapTileInfo] = []
        tiles.reserveCapacity(tileCount)
        for i in 0..<tileCount {
            let b0 = Int(rawData[i * 2])
            let b1 = Int(rawData[i * 2 + 1])
            let rawWord = b0 | (b1 << 8)
            let tileId = rawWord & 0x03FF
            let collision = (rawWord >> 10) & 0x3F
            tiles.append(MapTileInfo(tileId: tileId, collision: collision))
        }

        let mapName: String
        if bank == 3 && map == 0 {
            mapName = "PALLET_TOWN"
        } else if bank == 4 && map == 1 {
            mapName = "PLAYERS_HOUSE_2F"
        } else if bank == 4 && map == 0 {
            mapName = "PLAYERS_HOUSE_1F"
        } else if bank == 4 && map == 3 {
            mapName = "OAK_LAB"
        } else {
            mapName = "MAP_\(bank)_\(map)"
        }

        return MapLayoutData(bank: bank, map: map, name: mapName, width: width, height: height, tiles: tiles)
    }
}

/// Performs identity verification before any persistent copy. No networking or ROM assets in the app bundle.
enum LocalROMImporter {
    /// A restarted app must not treat the presence of reference.gba as proof
    /// of identity. No extraction is enabled by restoring the reader.
    static func restoreVerifiedCopy() throws -> ROMDataReader? {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let destination = directory.appendingPathComponent("reference.gba", isDirectory: false)
        guard FileManager.default.fileExists(atPath: destination.path) else { return nil }
        let reader = ROMDataReader(privateURL: destination, profile: .reference)
        try reader.verifyIdentity()
        return reader
    }

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
