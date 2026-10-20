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
        // Reject malformed combatants rather than allowing negative damage or integer overflow.
        // This is a safety guard for the synthetic engine, not a FireRed parity claim.
        guard attacker.level > 0, attacker.level <= 100,
              attacker.attack > 0, attacker.attack <= 65_535,
              defender.defense > 0, defender.defense <= 65_535,
              power > 0, power <= 255 else { return 0 }
        let base = ((Int64(2 * attacker.level / 5 + 2) * Int64(power) * Int64(attacker.attack)) / Int64(defender.defense)) / 50 + 2
        return Int(max(Int64(1), base))
    }

    /// Applies single attack turn deterministically.
    public static func executeAttack(attacker: Combatant, defender: inout Combatant, power: Int) -> TurnOutcome {
        let dmg = calculateDamage(attacker: attacker, defender: defender, power: power)
        guard dmg > 0 else { return .damaged(damage: 0, remainingHP: defender.currentHP) }
        defender.currentHP = max(0, defender.currentHP - min(dmg, max(0, defender.currentHP)))
        if defender.currentHP == 0 {
            return .fainted
        }
        return .damaged(damage: dmg, remainingHP: defender.currentHP)
    }
}
