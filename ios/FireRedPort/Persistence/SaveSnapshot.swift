import CryptoKit
import Foundation

/// Synthetic persistence contract. These fields are not reconstructed ROM structures.
struct SaveSnapshot: Codable, Equatable {
    static let currentSchemaVersion = 1

    struct Player: Codable, Equatable {
        var name: String
    }

    struct Position: Codable, Equatable {
        var mapId: String
        var x: Int
        var y: Int
    }

    struct PartyMember: Codable, Equatable {
        var identifier: String
        var level: Int
    }

    struct InventoryEntry: Codable, Equatable {
        var identifier: String
        var quantity: Int
    }

    // Battle state is optional because saving during a battle may not be valid.
    // No battle-save rule has been verified yet.
    struct BattleState: Codable, Equatable {
        var phase: String
    }

    let schemaVersion: Int
    let referenceSha256: String
    let slotId: String
    let revision: Int
    let savedAt: Date
    let integrityDigest: String
    let player: Player
    let position: Position
    let party: [PartyMember]
    let inventory: [InventoryEntry]
    let progressFlags: [String: Bool]
    let worldState: [String: Int]
    let battleState: BattleState?
    let randomState: UInt64?

    /// The digest detects accidental corruption; it is not authentication against a malicious editor.
    init(referenceSha256: String, slotId: String, revision: Int, savedAt: Date,
         player: Player, position: Position, party: [PartyMember],
         inventory: [InventoryEntry], progressFlags: [String: Bool],
         worldState: [String: Int], battleState: BattleState? = nil,
         randomState: UInt64? = nil) throws {
        guard savedAt.timeIntervalSince1970.isFinite,
              (savedAt.timeIntervalSince1970 * 1000).isFinite else {
            throw SaveSnapshotError.invalidSnapshot
        }
        let normalizedDate = Date(timeIntervalSince1970:
            (savedAt.timeIntervalSince1970 * 1000).rounded() / 1000)
        let payload = Payload(schemaVersion: Self.currentSchemaVersion,
                              referenceSha256: referenceSha256, slotId: slotId,
                              revision: revision, savedAt: normalizedDate, player: player,
                              position: position, party: party, inventory: inventory,
                              progressFlags: progressFlags, worldState: worldState,
                              battleState: battleState, randomState: randomState)
        try Self.validate(payload)
        self.schemaVersion = payload.schemaVersion
        self.referenceSha256 = referenceSha256
        self.slotId = slotId
        self.revision = revision
        self.savedAt = normalizedDate
        self.player = player
        self.position = position
        self.party = party
        self.inventory = inventory
        self.progressFlags = progressFlags
        self.worldState = worldState
        self.battleState = battleState
        self.randomState = randomState
        self.integrityDigest = try Self.digest(payload)
    }

    private struct Payload: Encodable {
        let schemaVersion: Int
        let referenceSha256: String
        let slotId: String
        let revision: Int
        let savedAt: Date
        let player: Player
        let position: Position
        let party: [PartyMember]
        let inventory: [InventoryEntry]
        let progressFlags: [String: Bool]
        let worldState: [String: Int]
        let battleState: BattleState?
        let randomState: UInt64?
    }

    private var payload: Payload {
        Payload(schemaVersion: schemaVersion, referenceSha256: referenceSha256,
                slotId: slotId, revision: revision, savedAt: savedAt,
                player: player, position: position, party: party, inventory: inventory,
                progressFlags: progressFlags, worldState: worldState,
                battleState: battleState, randomState: randomState)
    }

    static func validReferenceHash(_ hash: String) -> Bool {
        hash.utf8.count == 64 && hash.utf8.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        }
    }

    static func validSlotId(_ id: String) -> Bool {
        (1...64).contains(id.utf8.count) && id.utf8.allSatisfy {
            (48...57).contains($0) || (65...90).contains($0) ||
            (97...122).contains($0) || $0 == 45 || $0 == 95
        }
    }

    private static func validate(_ value: Payload) throws {
        guard value.schemaVersion == currentSchemaVersion else {
            throw SaveSnapshotError.unsupportedSchema(value.schemaVersion)
        }
        guard validReferenceHash(value.referenceSha256), validSlotId(value.slotId),
              value.revision > 0, value.savedAt.timeIntervalSince1970.isFinite,
              !value.player.name.isEmpty, value.player.name.utf8.count <= 256,
              !value.position.mapId.isEmpty, value.position.mapId.utf8.count <= 256,
              value.party.count <= 256, value.inventory.count <= 4096,
              value.progressFlags.count <= 16384, value.worldState.count <= 16384,
              value.party.allSatisfy({ !$0.identifier.isEmpty && $0.identifier.utf8.count <= 256 && $0.level >= 0 }),
              value.inventory.allSatisfy({ !$0.identifier.isEmpty && $0.identifier.utf8.count <= 256 && $0.quantity >= 0 }),
              value.progressFlags.keys.allSatisfy({ !$0.isEmpty && $0.utf8.count <= 256 }),
              value.worldState.keys.allSatisfy({ !$0.isEmpty && $0.utf8.count <= 256 }),
              value.battleState.map({ !$0.phase.isEmpty && $0.phase.utf8.count <= 256 }) ?? true else {
            throw SaveSnapshotError.invalidSnapshot
        }
    }

    private static func digest(_ value: Payload) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let bytes = try encoder.encode(value)
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    func validate() throws {
        let value = payload
        try Self.validate(value)
        guard integrityDigest == (try Self.digest(value)) else {
            throw SaveSnapshotError.integrityFailure
        }
    }

    // Explicit decoding prevents accepting a tampered digest or an unknown schema.
    init(from decoder: Decoder) throws {
        let fields = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try fields.decode(Int.self, forKey: .schemaVersion)
        guard schemaVersion == Self.currentSchemaVersion else {
            throw SaveSnapshotError.unsupportedSchema(schemaVersion)
        }
        referenceSha256 = try fields.decode(String.self, forKey: .referenceSha256)
        slotId = try fields.decode(String.self, forKey: .slotId)
        revision = try fields.decode(Int.self, forKey: .revision)
        savedAt = try fields.decode(Date.self, forKey: .savedAt)
        integrityDigest = try fields.decode(String.self, forKey: .integrityDigest)
        player = try fields.decode(Player.self, forKey: .player)
        position = try fields.decode(Position.self, forKey: .position)
        party = try fields.decode([PartyMember].self, forKey: .party)
        inventory = try fields.decode([InventoryEntry].self, forKey: .inventory)
        progressFlags = try fields.decode([String: Bool].self, forKey: .progressFlags)
        worldState = try fields.decode([String: Int].self, forKey: .worldState)
        battleState = try fields.decodeIfPresent(BattleState.self, forKey: .battleState)
        randomState = try fields.decodeIfPresent(UInt64.self, forKey: .randomState)
        try validate()
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, referenceSha256, slotId, revision, savedAt, integrityDigest
        case player, position, party, inventory, progressFlags, worldState, battleState, randomState
    }
}

enum SaveSnapshotError: Error, Equatable {
    case unsupportedSchema(Int)
    case invalidSnapshot
    case integrityFailure
}
