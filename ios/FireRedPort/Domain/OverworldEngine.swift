import Foundation

/// Pure deterministic state transitions for movement and world interactions.
/// Does not depend on SpriteKit, UIKit, or timers.
public enum OverworldEngine {
    public enum MoveResult: Equatable {
        case moved(to: GridPosition)
        case blocked
        case changedFacing(to: GridPosition.Direction)
    }

    /// Evaluates candidate movement given a map boundary or simple collision predicate.
    public static func step(
        from current: GridPosition,
        direction: GridPosition.Direction,
        isPassable: (GridPosition) -> Bool
    ) -> MoveResult {
        if current.facing != direction {
            var turned = current
            turned.facing = direction
            return .changedFacing(to: direction)
        }

        var next = current
        switch direction {
        case .north: next.y -= 1
        case .south: next.y += 1
        case .west:  next.x -= 1
        case .east:  next.x += 1
        }

        guard isPassable(next) else {
            return .blocked
        }

        return .moved(to: next)
    }

    /// Applies flag updates from dialogues or progression triggers.
    public static func setFlag(_ flag: String, value: Bool, in state: inout GameState) {
        state.flags[flag] = value
    }

    public struct WarpDestination: Equatable, Sendable {
        public let bank: Int
        public let map: Int
        public let x: Int
        public let y: Int
        public let facing: GridPosition.Direction

        public init(bank: Int, map: Int, x: Int, y: Int, facing: GridPosition.Direction) {
            self.bank = bank
            self.map = map
            self.x = x
            self.y = y
            self.facing = facing
        }
    }

    /// Evaluates if a given position in a map triggers a transition to another map.
    /// Based on verified GBA FireRed warp tables (Bank 3 Map 0 Pallet Town, Bank 4 Maps 0/1/3).
    public static func checkWarp(mapName: String, x: Int, y: Int) -> WarpDestination? {
        switch mapName {
        case "PLAYERS_HOUSE_2F", "PALLET_TOWN_PLAYERS_HOUSE_2F":
            // Stairs at (10, 2) leads down to House 1F (verified in ROM at 0x3B9760)
            if (x == 10 || x == 9) && y == 2 {
                return WarpDestination(bank: 4, map: 0, x: 9, y: 2, facing: .south)
            }
        case "PLAYERS_HOUSE_1F":
            // Stairs at (10, 2) leads up to House 2F
            if (x == 10 || x == 9) && y == 2 {
                return WarpDestination(bank: 4, map: 1, x: 9, y: 2, facing: .south)
            }
            // Front doors at (4, 8) and (5, 8) exit to Pallet Town
            if (x == 4 || x == 5) && y >= 8 {
                return WarpDestination(bank: 3, map: 0, x: 6, y: 8, facing: .south)
            }
        case "PALLET_TOWN":
            // Door of Player's House at (6, 7)
            if x == 6 && y == 7 {
                return WarpDestination(bank: 4, map: 0, x: 4, y: 7, facing: .north)
            }
            // Door of Oak's Lab at (16, 13)
            if x == 16 && y == 13 {
                return WarpDestination(bank: 4, map: 3, x: 6, y: 12, facing: .north)
            }
        case "OAK_LAB":
            // Exit doors at (6, 13) and (7, 13)
            if (x == 6 || x == 7) && y >= 13 {
                return WarpDestination(bank: 3, map: 0, x: 16, y: 14, facing: .south)
            }
        default:
            break
        }
        return nil
    }
}
