import Foundation

/// Identity only. No game structure/table offsets have been validated in
/// analysis/subsystems.md, so a matching ROM cannot enable extraction yet.
struct ReferenceProfile {
    static let reference = ReferenceProfile(
        sha256: "3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac",
        byteCount: 16_777_216,
        region: "USA",
        version: 0
    )

    let sha256: String
    let byteCount: Int
    let region: String
    let version: UInt8

    /// No confirmed table limits or layouts exist. Do not substitute guessed values.
    var validatedTableLimits: [String: Int] { [:] }
    var extractionEnabled: Bool { false }

    static func identify(sha256: String, byteCount: Int, header: Data) throws -> ReferenceProfile {
        let profile = reference
        guard byteCount >= profile.byteCount else { throw ROMImportError.truncated }
        guard byteCount == profile.byteCount else { throw ROMImportError.incompatible }
        guard sha256.count == 64,
              sha256.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              sha256 == profile.sha256 else { throw ROMImportError.incompatible }
        // Header checks are supplementary; only the whole-file digest authorizes identity.
        guard header.count >= 0xBE,
              Data(header[0xA0..<0xAC]) == Data("POKEMON FIRE".utf8),
              Data(header[0xAC..<0xB0]) == Data("BPRE".utf8),
              Data(header[0xB0..<0xB2]) == Data("01".utf8),
              header[0xB2] == 0x96,
              header[0xBC] == profile.version,
              header[0xBD] == 0x68 else { throw ROMImportError.invalidHeader }
        return profile
    }
}

enum ROMImportError: Error {
    case truncated
    case incompatible
    case invalidHeader
    case accessDenied
    case insufficientSpace
    case outOfBounds
    case invalidCount
    case extractionNotValidated
}
