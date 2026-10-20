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

    func testMapLayoutDataPassabilityAndBounds() {
        let tiles = [
            MapTileInfo(tileId: 1, collision: 0x01), // (0,0) - impassable wall
            MapTileInfo(tileId: 2, collision: 0x00), // (1,0) - passable grass
            MapTileInfo(tileId: 3, collision: 0x0C), // (0,1) - passable indoor
            MapTileInfo(tileId: 4, collision: 0x04)  // (1,1) - water / obstacle
        ]
        let layout = MapLayoutData(bank: 3, map: 0, name: "TEST_PALLET", width: 2, height: 2, tiles: tiles)
        
        XCTAssertFalse(layout.isPassable(x: 0, y: 0))
        XCTAssertTrue(layout.isPassable(x: 1, y: 0))
        XCTAssertTrue(layout.isPassable(x: 0, y: 1))
        XCTAssertFalse(layout.isPassable(x: 1, y: 1))
        
        // Out of bounds must return false and nil tile
        XCTAssertFalse(layout.isPassable(x: -1, y: 0))
        XCTAssertFalse(layout.isPassable(x: 2, y: 0))
        XCTAssertFalse(layout.isPassable(x: 0, y: 2))
        XCTAssertNil(layout.tileAt(x: -1, y: 0))
        XCTAssertNil(layout.tileAt(x: 5, y: 5))
    }

    func testOverworldWarpTransitions() {
        // Player's house 2F stairs
        let stairs2F = OverworldEngine.checkWarp(mapName: "PLAYERS_HOUSE_2F", x: 10, y: 2)
        XCTAssertNotNil(stairs2F)
        XCTAssertEqual(stairs2F?.bank, 4)
        XCTAssertEqual(stairs2F?.map, 0)
        XCTAssertEqual(stairs2F?.facing, .south)

        // Player's house 1F stairs
        let stairs1F = OverworldEngine.checkWarp(mapName: "PLAYERS_HOUSE_1F", x: 9, y: 2)
        XCTAssertNotNil(stairs1F)
        XCTAssertEqual(stairs1F?.bank, 4)
        XCTAssertEqual(stairs1F?.map, 1)

        // Player's house 1F exit door to Pallet Town
        let door1F = OverworldEngine.checkWarp(mapName: "PLAYERS_HOUSE_1F", x: 5, y: 8)
        XCTAssertNotNil(door1F)
        XCTAssertEqual(door1F?.bank, 3)
        XCTAssertEqual(door1F?.map, 0)
        XCTAssertEqual(door1F?.x, 6)
        XCTAssertEqual(door1F?.y, 8)

        // Pallet Town door to Player's house
        let palletDoor = OverworldEngine.checkWarp(mapName: "PALLET_TOWN", x: 6, y: 7)
        XCTAssertNotNil(palletDoor)
        XCTAssertEqual(palletDoor?.bank, 4)
        XCTAssertEqual(palletDoor?.map, 0)

        // Non-warp tile
        let nonWarp = OverworldEngine.checkWarp(mapName: "PALLET_TOWN", x: 10, y: 10)
        XCTAssertNil(nonWarp)
    }

    func testOverworldFourDirectionStep() {
        let center = GridPosition(mapId: "PALLET_TOWN", x: 10, y: 10, facing: .north)
        
        // North step
        let northMove = OverworldEngine.step(from: center, direction: .north) { _ in true }
        XCTAssertEqual(northMove, .moved(to: GridPosition(mapId: "PALLET_TOWN", x: 10, y: 9, facing: .north)))
        
        // Turn to south
        let turnSouth = OverworldEngine.step(from: center, direction: .south) { _ in true }
        XCTAssertEqual(turnSouth, .changedFacing(to: .south))

        // South step
        let southFacing = GridPosition(mapId: "PALLET_TOWN", x: 10, y: 10, facing: .south)
        let southMove = OverworldEngine.step(from: southFacing, direction: .south) { _ in true }
        XCTAssertEqual(southMove, .moved(to: GridPosition(mapId: "PALLET_TOWN", x: 10, y: 11, facing: .south)))

        // West step
        let westFacing = GridPosition(mapId: "PALLET_TOWN", x: 10, y: 10, facing: .west)
        let westMove = OverworldEngine.step(from: westFacing, direction: .west) { _ in true }
        XCTAssertEqual(westMove, .moved(to: GridPosition(mapId: "PALLET_TOWN", x: 9, y: 10, facing: .west)))

        // East step
        let eastFacing = GridPosition(mapId: "PALLET_TOWN", x: 10, y: 10, facing: .east)
        let eastMove = OverworldEngine.step(from: eastFacing, direction: .east) { _ in true }
        XCTAssertEqual(eastMove, .moved(to: GridPosition(mapId: "PALLET_TOWN", x: 11, y: 10, facing: .east)))
    }
}
