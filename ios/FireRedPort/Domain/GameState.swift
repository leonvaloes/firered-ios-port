import Foundation

/// Core author-domain types representing reconstructed gameplay concepts.
/// These structures model campaign state deterministically without executing
/// console CPU instructions, relying on verified reference fixtures.
public struct PlayerCharacter: Codable, Equatable, Sendable {
    public var name: String
    public var gender: Gender

    public enum Gender: String, Codable, Sendable {
        case boy
        case girl
    }

    public init(name: String, gender: Gender = .boy) {
        self.name = name
        self.gender = gender
    }
}

public struct GridPosition: Codable, Equatable, Hashable, Sendable {
    public var mapId: String
    public var x: Int
    public var y: Int
    public var facing: Direction

    public enum Direction: String, Codable, Sendable {
        case north, south, east, west
    }

    public init(mapId: String, x: Int, y: Int, facing: Direction = .south) {
        self.mapId = mapId
        self.x = x
        self.y = y
        self.facing = facing
    }
}

public struct PokemonSummary: Codable, Equatable, Sendable {
    public var speciesId: Int
    public var nickname: String
    public var level: Int
    public var currentHP: Int
    public var maxHP: Int

    public init(speciesId: Int, nickname: String, level: Int, currentHP: Int, maxHP: Int) {
        self.speciesId = speciesId
        self.nickname = nickname
        self.level = level
        self.currentHP = currentHP
        self.maxHP = maxHP
    }
}

public struct InventoryBag: Codable, Equatable, Sendable {
    public var items: [String: Int]

    public init(items: [String: Int] = [:]) {
        self.items = items
    }
}

/// Authoritative snapshot of campaign progress, decoupled from rendering frameworks.
public struct GameState: Codable, Equatable, Sendable {
    public var player: PlayerCharacter
    public var position: GridPosition
    public var party: [PokemonSummary]
    public var inventory: InventoryBag
    public var flags: [String: Bool]
    public var worldVariables: [String: Int]
    public var rngSeed: UInt64

    public init(
        player: PlayerCharacter = PlayerCharacter(name: "RED"),
        position: GridPosition = GridPosition(mapId: "PALLET_TOWN_PLAYERS_HOUSE_2F", x: 3, y: 6),
        party: [PokemonSummary] = [],
        inventory: InventoryBag = InventoryBag(),
        flags: [String: Bool] = [:],
        worldVariables: [String: Int] = [:],
        rngSeed: UInt64 = 0x12345678
    ) {
        self.player = player
        self.position = position
        self.party = party
        self.inventory = inventory
        self.flags = flags
        self.worldVariables = worldVariables
        self.rngSeed = rngSeed
    }
}
