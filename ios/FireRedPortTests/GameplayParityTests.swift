import Foundation
import XCTest
@testable import FireRedPort

/// Candidate tests for T025–T027 and T047–T049.
/// Tests synthetic deterministic domain logic. Reference parity against official hardware
/// remains pending documented observations in analysis/parity-matrix.md.
final class GameplayParityTests: XCTestCase {

    func testSyntheticOverworldMovementAndFacing() {
        let start = GridPosition(mapId: "TEST_MAP", x: 2, y: 2, facing: .south)
        
        // Turning without moving
        let turnResult = OverworldEngine.step(from: start, direction: .east) { _ in true }
        XCTAssertEqual(turnResult, .changedFacing(to: .east))

        // Moving into passable tile
        let faceEast = GridPosition(mapId: "TEST_MAP", x: 2, y: 2, facing: .east)
        let moveResult = OverworldEngine.step(from: faceEast, direction: .east) { _ in true }
        XCTAssertEqual(moveResult, .moved(to: GridPosition(mapId: "TEST_MAP", x: 3, y: 2, facing: .east)))

        // Blocked tile
        let blockedResult = OverworldEngine.step(from: faceEast, direction: .east) { _ in false }
        XCTAssertEqual(blockedResult, .blocked)
    }

    func testSyntheticBattleCalculationDeterminism() {
        let attacker = BattleEngine.Combatant(name: "Pikachu", level: 5, currentHP: 20, maxHP: 20, attack: 12, defense: 8)
        var defender = BattleEngine.Combatant(name: "Caterpie", level: 3, currentHP: 15, maxHP: 15, attack: 6, defense: 7)

        let damage = BattleEngine.calculateDamage(attacker: attacker, defender: defender, power: 40)
        XCTAssertGreaterThan(damage, 0)

        let outcome = BattleEngine.executeAttack(attacker: attacker, defender: &defender, power: 40)
        switch outcome {
        case .damaged(let dmg, let remainingHP):
            XCTAssertEqual(dmg, damage)
            XCTAssertEqual(remainingHP, defender.currentHP)
        case .fainted:
            XCTAssertEqual(defender.currentHP, 0)
        }
    }

    func testMalformedSyntheticAttackCannotHealOrOverflow() {
        let attacker = BattleEngine.Combatant(name: "synthetic", level: Int.max, currentHP: 1, maxHP: 1, attack: Int.max, defense: 1)
        var defender = BattleEngine.Combatant(name: "synthetic", level: 1, currentHP: 20, maxHP: 20, attack: 1, defense: 0)
        let outcome = BattleEngine.executeAttack(attacker: attacker, defender: &defender, power: -40)
        XCTAssertEqual(outcome, .damaged(damage: 0, remainingHP: 20))
        XCTAssertEqual(defender.currentHP, 20)
        XCTAssertEqual(BattleEngine.calculateDamage(attacker: attacker, defender: defender, power: Int.max), 0)
    }

    func testEventFlagStateMutation() {
        var state = GameState()
        XCTAssertNil(state.flags["GOT_STARTER"])
        OverworldEngine.setFlag("GOT_STARTER", value: true, in: &state)
        XCTAssertEqual(state.flags["GOT_STARTER"], true)
    }
}
