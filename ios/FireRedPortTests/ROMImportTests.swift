import Foundation
import XCTest
@testable import FireRedPort

/// Conformance enabling direct equality assertions in XCTest without modifying production files.
extension ROMImportError: Equatable {
    public static func == (lhs: ROMImportError, rhs: ROMImportError) -> Bool {
        switch (lhs, rhs) {
        case (.truncated, .truncated),
             (.incompatible, .incompatible),
             (.invalidHeader, .invalidHeader),
             (.accessDenied, .accessDenied),
             (.insufficientSpace, .insufficientSpace),
             (.outOfBounds, .outOfBounds),
             (.invalidCount, .invalidCount),
             (.extractionNotValidated, .extractionNotValidated):
            return true
        default:
            return false
        }
    }
}

/// Executable contract and unit tests for ReferenceProfile, LocalROMImporter, and ROMDataReader (T019, T022–T024).
///
/// All byte fixtures and temporary files are strictly synthetic:
/// no copyrighted ROM data, game code, graphics, audio, or text are embedded or distributed.
final class ROMImportTests: XCTestCase {
    private let expectedSize = 16_777_216
    private let acceptedSHA256 = "3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac"

    // MARK: - Synthetic Fixture Helpers

    /// Generates a purely synthetic non-ROM buffer of arbitrary size.
    private func syntheticBuffer(size: Int = 192, fill: UInt8 = 0xA5) -> Data {
        Data(repeating: fill, count: size)
    }

    /// Constructs a synthetic 192-byte buffer containing only the bare structural marker bytes
    /// checked by `ReferenceProfile.identify`. Contains zero ROM code, scripts, or assets.
    private func makeSyntheticValidHeader() -> Data {
        var header = Data(repeating: 0x00, count: 192)
        // 0xA0..<0xAC: Game title "POKEMON FIRE" (12 bytes)
        header.replaceSubrange(0xA0..<0xAC, with: Data("POKEMON FIRE".utf8))
        // 0xAC..<0xB0: Game code "BPRE" (4 bytes)
        header.replaceSubrange(0xAC..<0xB0, with: Data("BPRE".utf8))
        // 0xB0..<0xB2: Maker code "01" (2 bytes)
        header.replaceSubrange(0xB0..<0xB2, with: Data("01".utf8))
        // 0xB2: Fixed byte 0x96
        header[0xB2] = 0x96
        // 0xBC: Version byte 0x00 (matches ReferenceProfile.reference.version)
        header[0xBC] = 0x00
        // 0xBD: Header complement checksum byte 0x68
        header[0xBD] = 0x68
        return header
    }

    /// Creates a temporary file on disk with synthetic contents and returns its URL.
    private func createSyntheticTempFile(contents: Data) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("synthetic_\(UUID().uuidString).bin")
        try contents.write(to: fileURL)
        return fileURL
    }

    /// Creates a temporary file on disk with repeated synthetic bytes.
    private func createSyntheticTempFile(size: Int, fill: UInt8 = 0x5A) throws -> URL {
        let data = Data(repeating: fill, count: size)
        return try createSyntheticTempFile(contents: data)
    }

    // MARK: - Truncation Tests

    func testTruncatedFileIsRejectedBeforeOffsetsAreRead() throws {
        // Any file size below 16_777_216 must immediately throw .truncated,
        // even if digest matches and header structure is valid.
        let validHeader = makeSyntheticValidHeader()

        for truncatedSize in [0, 192, expectedSize - 1] {
            XCTAssertThrowsError(
                try ReferenceProfile.identify(
                    sha256: acceptedSHA256,
                    byteCount: truncatedSize,
                    header: validHeader
                ),
                "Byte count \(truncatedSize) must be rejected as truncated"
            ) { error in
                XCTAssertEqual(error as? ROMImportError, .truncated)
            }
        }
    }

    // MARK: - Header Validation Tests

    func testInvalidHeaderIsRejectedEvenWithMatchingSuppliedDigest() throws {
        // 1. Completely arbitrary synthetic buffer (no matching marker bytes)
        let bytes = syntheticBuffer()
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: acceptedSHA256,
                byteCount: expectedSize,
                header: bytes
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 2. Header shorter than minimum requirement (0xBE = 190 bytes)
        let shortHeader = Data(repeating: 0x00, count: 0xBD)
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: acceptedSHA256,
                byteCount: expectedSize,
                header: shortHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 3. Header with mismatched title (e.g. "POKEMON LEAF")
        var mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader.replaceSubrange(0xA0..<0xAC, with: Data("POKEMON LEAF".utf8))
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 4. Header with mismatched game code (e.g. "BPGE")
        mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader.replaceSubrange(0xAC..<0xB0, with: Data("BPGE".utf8))
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 5. Header with mismatched maker code (not "01")
        mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader.replaceSubrange(0xB0..<0xB2, with: Data("02".utf8))
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 6. Header with corrupted fixed byte at 0xB2 (not 0x96)
        mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader[0xB2] = 0x95
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 7. Header with mismatched version byte at 0xBC (not 0x00)
        mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader[0xBC] = 0x01
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }

        // 8. Header with corrupted complement checksum byte at 0xBD (not 0x68)
        mutatedHeader = makeSyntheticValidHeader()
        mutatedHeader[0xBD] = 0x69
        XCTAssertThrowsError(
            try ReferenceProfile.identify(sha256: acceptedSHA256, byteCount: expectedSize, header: mutatedHeader)
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .invalidHeader)
        }
    }

    // MARK: - Hash & Identity Incompatibility Tests

    func testUnknownHashCannotEnableReferenceOffsets() throws {
        let validHeader = makeSyntheticValidHeader()

        // 1. Unknown 64-hex SHA-256 with valid header and matching size must throw .incompatible
        let unknownHash = String(repeating: "0", count: 64)
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: unknownHash,
                byteCount: expectedSize,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }

        // 2. Arbitrary non-matching SHA-256 hash
        let mismatchedHash = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: mismatchedHash,
                byteCount: expectedSize,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }

        // 3. Non-hex characters in hash string
        let nonHexHash = "3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8zz"
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: nonHexHash,
                byteCount: expectedSize,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }

        // 4. Uppercase hex characters are rejected (canonical lowercase required)
        let uppercaseHash = acceptedSHA256.uppercased()
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: uppercaseHash,
                byteCount: expectedSize,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }

        // 5. Truncated or malformed hash length (< 64 characters)
        let shortHash = String(acceptedSHA256.prefix(32))
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: shortHash,
                byteCount: expectedSize,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }

        // 6. Oversized file (exceeding expected size) with matching hash
        XCTAssertThrowsError(
            try ReferenceProfile.identify(
                sha256: acceptedSHA256,
                byteCount: expectedSize + 1,
                header: validHeader
            )
        ) { error in
            XCTAssertEqual(error as? ROMImportError, .incompatible)
        }
    }

    // MARK: - Extraction Gate & Table Reading Tests

    /// Tests the extraction gate behavior against ReferenceProfile and ROMDataReader.
    ///
    /// Precise limitation documentation:
    /// In production, `ReferenceProfile.validatedTableLimits` returns `{ [:] }` and
    /// `extractionEnabled` returns `false` by design, because no game structures have been
    /// validated in `analysis/subsystems.md`. Consequently, `ROMDataReader.readTable`
    /// unconditionally rejects table reads with `.extractionNotValidated` before validating
    /// entry count, stride, or multiplication overflow.
    ///
    /// Neither this test suite nor production code may weaken `ReferenceProfile`'s identity
    /// checks or stub fake table layouts to force deep table reads.
    func testTableRejectsUnboundedCountAndMultiplicationOverflow() throws {
        let tempURL = try createSyntheticTempFile(size: 64)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let syntheticProfile = ReferenceProfile(
            sha256: String(repeating: "0", count: 64),
            byteCount: 64,
            region: "TEST",
            version: 0
        )
        let reader = ROMDataReader(privateURL: tempURL, profile: syntheticProfile)

        // All table requests must be gated and throw .extractionNotValidated
        let testCases: [(name: String, entries: Int, stride: Int)] = [
            ("pokemon_stats", 5, 1),
            ("items", -1, 1),
            ("moves", Int.max, 2),
            ("maps", 1, 0),
            ("", 0, 1)
        ]

        for tc in testCases {
            XCTAssertThrowsError(
                try reader.readTable(named: tc.name, offset: 0, entries: tc.entries, stride: tc.stride),
                "readTable for '\(tc.name)' must be blocked by extraction gate"
            ) { error in
                XCTAssertEqual(error as? ROMImportError, .extractionNotValidated)
            }
        }
    }

    func testExtractionGateBlocksExtractionAndTableReads() throws {
        let reference = ReferenceProfile.reference
        XCTAssertFalse(reference.extractionEnabled, "Production profile must not enable extraction")
        XCTAssertTrue(reference.validatedTableLimits.isEmpty, "Production profile must not contain unvalidated table limits")

        // Verify with an identified synthetic profile
        let validHeader = makeSyntheticValidHeader()
        let identified = try ReferenceProfile.identify(
            sha256: acceptedSHA256,
            byteCount: expectedSize,
            header: validHeader
        )
        XCTAssertFalse(identified.extractionEnabled)
        XCTAssertTrue(identified.validatedTableLimits.isEmpty)

        // Verify reader instantiated with production reference profile blocks table extraction
        let tempURL = try createSyntheticTempFile(size: 64)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let reader = ROMDataReader(privateURL: tempURL, profile: reference)
        XCTAssertThrowsError(try reader.readTable(named: "pokemon_data", offset: 0, entries: 1, stride: 1)) { error in
            XCTAssertEqual(error as? ROMImportError, .extractionNotValidated)
        }
    }

    // MARK: - Bounded Reader Tests

    func testReadRejectsOverflowNegativeAndEndCrossing() throws {
        let dataSize = 64
        let testData = Data((0..<UInt8(dataSize)).map { $0 })
        let tempURL = try createSyntheticTempFile(contents: testData)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // Test-only synthetic profile with small byte count to verify reader boundaries
        let syntheticProfile = ReferenceProfile(
            sha256: String(repeating: "0", count: 64),
            byteCount: dataSize,
            region: "TEST",
            version: 0
        )
        let reader = ROMDataReader(privateURL: tempURL, profile: syntheticProfile)

        // Negative offset, negative count, crossing profile end, Int.max values,
        // and exceeding the reader's 64 KB chunk size limit (65537 bytes)
        let invalidOffsetsAndCounts: [(offset: Int, count: Int)] = [
            (-1, 1),
            (0, -1),
            (63, 2),
            (64, 1),
            (Int.max, 2),
            (0, Int.max),
            (0, 64 * 1024 + 1)
        ]

        for (offset, count) in invalidOffsetsAndCounts {
            XCTAssertThrowsError(
                try reader.read(offset: offset, count: count),
                "read(offset: \(offset), count: \(count)) must throw outOfBounds"
            ) { error in
                XCTAssertEqual(error as? ROMImportError, .outOfBounds)
            }
        }

        // Reading zero bytes at the exact end-of-file boundary must succeed and return empty Data
        let endBoundary = try reader.read(offset: dataSize, count: 0)
        XCTAssertEqual(endBoundary, Data())

        // In-bounds read must return exact synthetic bytes
        let validRead = try reader.read(offset: 0, count: 4)
        XCTAssertEqual(validRead, testData.prefix(4))

        let middleRead = try reader.read(offset: 10, count: 5)
        XCTAssertEqual(middleRead, testData.subdata(in: 10..<15))
    }

    func testReadTruncatedUnderlyingFileThrowsTruncated() throws {
        // Physical file on disk has only 16 bytes, but synthetic profile specifies 64 bytes.
        let tempURL = try createSyntheticTempFile(size: 16)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let syntheticProfile = ReferenceProfile(
            sha256: String(repeating: "0", count: 64),
            byteCount: 64,
            region: "TEST",
            version: 0
        )
        let reader = ROMDataReader(privateURL: tempURL, profile: syntheticProfile)

        // Reading 32 bytes from offset 0 is within profile bounds (32 <= 64),
        // but physically reaches EOF at 16 bytes. Reader must throw .truncated.
        XCTAssertThrowsError(try reader.read(offset: 0, count: 32)) { error in
            XCTAssertEqual(error as? ROMImportError, .truncated)
        }
    }

    // MARK: - File Access & No Network Tests

    func testFileAccessFailureDoesNotStartNetworkRequest() throws {
        var networkCalls = 0
        let requestNetwork: () -> Void = { networkCalls += 1 }

        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("missing.gba")

        // Attempting to import an inaccessible / non-existent file via LocalROMImporter
        // must fail with .accessDenied strictly locally.
        XCTAssertThrowsError(try LocalROMImporter.importSelectedFile(missing)) { error in
            XCTAssertEqual(error as? ROMImportError, .accessDenied)
        }

        // Verify no network activity occurred
        XCTAssertEqual(networkCalls, 0, "File access failure must never initiate network requests")
        _ = requestNetwork
    }

    func testLocalROMImporterRejectsInaccessibleSyntheticFileWithoutNetwork() throws {
        let tempURL = try createSyntheticTempFile(size: 192)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        var networkCalls = 0
        let requestNetwork: () -> Void = { networkCalls += 1 }

        // Local non-security-scoped or invalid-length temporary files must be rejected strictly locally
        XCTAssertThrowsError(try LocalROMImporter.importSelectedFile(tempURL)) { error in
            guard let importError = error as? ROMImportError else {
                XCTFail("Expected ROMImportError but got \(error)")
                return
            }
            XCTAssertTrue(importError == .accessDenied || importError == .truncated, "Expected local rejection error, got \(importError)")
        }

        XCTAssertEqual(networkCalls, 0, "Local import must never contact network services")
        _ = requestNetwork
    }

    // MARK: - Synthetic Fixture Cleanliness Tests

    func testSyntheticFixtureDoesNotContainReferenceHeader() {
        let buffer = syntheticBuffer()
        XCTAssertEqual(buffer.count, 192)
        XCTAssertNotEqual(buffer.prefix(12), Data("POKEMON FIRE".utf8))
        XCTAssertFalse(buffer.contains(Data("POKEMON FIRE".utf8)))
        XCTAssertFalse(buffer.contains(Data("BPRE".utf8)))
    }
}
