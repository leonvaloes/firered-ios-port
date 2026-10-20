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
}
