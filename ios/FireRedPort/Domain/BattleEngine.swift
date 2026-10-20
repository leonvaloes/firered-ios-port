import Foundation

/// Pure deterministic battle calculation rules without animation or timer side-effects.
public enum BattleEngine {
    public struct Combatant: Equatable {
        public var name: String
        public var level: Int
        public var currentHP: Int
        public var maxHP: Int
        public var attack: Int
        public var defense: Int

        public init(name: String, level: Int, currentHP: Int, maxHP: Int, attack: Int, defense: Int) {
            self.name = name
            self.level = level
            self.currentHP = currentHP
            self.maxHP = maxHP
            self.attack = attack
            self.defense = defense
        }
    }

    public enum TurnOutcome: Equatable {
        case damaged(damage: Int, remainingHP: Int)
        case fainted
    }

    /// Simplified deterministic base damage calculation for contract tests.
    public static func calculateDamage(attacker: Combatant, defender: Combatant, power: Int) -> Int {
        guard defender.defense > 0 else { return power }
        let base = ((2 * attacker.level / 5 + 2) * power * attacker.attack / defender.defense) / 50 + 2
        return max(1, base)
    }

    /// Applies single attack turn deterministically.
    public static func executeAttack(attacker: Combatant, defender: inout Combatant, power: Int) -> TurnOutcome {
        let dmg = calculateDamage(attacker: attacker, defender: defender, power: power)
        defender.currentHP = max(0, defender.currentHP - dmg)
        if defender.currentHP == 0 {
            return .fainted
        }
        return .damaged(damage: dmg, remainingHP: defender.currentHP)
    }
}
