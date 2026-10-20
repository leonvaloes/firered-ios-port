import CryptoKit
import Foundation
import XCTest
@testable import FireRedPort

/// Contract and integration tests for SaveSnapshot and actor SaveStore (T032 / T034 / T035).
/// All state in this file is purely synthetic: no ROM binary data, no copyrighted sprites or
/// assets, and no protected save fixtures are used.
final class SaveStoreTests: XCTestCase {
    private let referenceHash = String(repeating: "a", count: 64)
    private let otherHash = String(repeating: "b", count: 64)
    private let testSlot = "synthetic-slot"

    private var tempDirectory: URL!
    private var store: SaveStore!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SaveStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        store = try SaveStore(directory: tempDirectory)
    }

    override func tearDown() async throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        store = nil
        tempDirectory = nil
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func activeURL(for slotId: String = "synthetic-slot") -> URL {
        tempDirectory.appendingPathComponent("\(slotId).json")
    }

    private func backupURL(for slotId: String = "synthetic-slot") -> URL {
        tempDirectory.appendingPathComponent("\(slotId).backup.json")
    }

    private static func makeSnapshot(
        slotId: String = "synthetic-slot",
        referenceHash: String = String(repeating: "a", count: 64),
        revision: Int = 1,
        savedAt: Date = Date(timeIntervalSince1970: 1_700_000_000),
        playerName: String = "RedTester",
        mapId: String = "pallet_town",
        x: Int = 10,
        y: Int = 12,
        party: [SaveSnapshot.PartyMember] = [SaveSnapshot.PartyMember(identifier: "starter_mon", level: 5)],
        inventory: [SaveSnapshot.InventoryEntry] = [SaveSnapshot.InventoryEntry(identifier: "potion", quantity: 3)],
        progressFlags: [String: Bool] = ["intro_completed": true, "has_pokedex": false],
        worldState: [String: Int] = ["step_count": 120, "badges": 0],
        battleState: SaveSnapshot.BattleState? = nil,
        randomState: UInt64? = 0x1234_5678
    ) throws -> SaveSnapshot {
        try SaveSnapshot(
            referenceSha256: referenceHash,
            slotId: slotId,
            revision: revision,
            savedAt: savedAt,
            player: SaveSnapshot.Player(name: playerName),
            position: SaveSnapshot.Position(mapId: mapId, x: x, y: y),
            party: party,
            inventory: inventory,
            progressFlags: progressFlags,
            worldState: worldState,
            battleState: battleState,
            randomState: randomState
        )
    }

    private func makeSnapshot(
        slotId: String = "synthetic-slot",
        referenceHash: String = String(repeating: "a", count: 64),
        revision: Int = 1,
        savedAt: Date = Date(timeIntervalSince1970: 1_700_000_000),
        playerName: String = "RedTester",
        mapId: String = "pallet_town",
        x: Int = 10,
        y: Int = 12,
        party: [SaveSnapshot.PartyMember] = [SaveSnapshot.PartyMember(identifier: "starter_mon", level: 5)],
        inventory: [SaveSnapshot.InventoryEntry] = [SaveSnapshot.InventoryEntry(identifier: "potion", quantity: 3)],
        progressFlags: [String: Bool] = ["intro_completed": true, "has_pokedex": false],
        worldState: [String: Int] = ["step_count": 120, "badges": 0],
        battleState: SaveSnapshot.BattleState? = nil,
        randomState: UInt64? = 0x1234_5678
    ) throws -> SaveSnapshot {
        try Self.makeSnapshot(
            slotId: slotId,
            referenceHash: referenceHash,
            revision: revision,
            savedAt: savedAt,
            playerName: playerName,
            mapId: mapId,
            x: x,
            y: y,
            party: party,
            inventory: inventory,
            progressFlags: progressFlags,
            worldState: worldState,
            battleState: battleState,
            randomState: randomState
        )
    }

    private func isExpectedStoreError(_ error: Error, matching expected: SaveStore.StoreError) -> Bool {
        guard let storeError = error as? SaveStore.StoreError else { return false }
        switch (storeError, expected) {
        case (.invalidIdentity, .invalidIdentity),
             (.notFound, .notFound),
             (.incompatibleReference, .incompatibleReference),
             (.staleRevision, .staleRevision),
             (.corruptFile, .corruptFile),
             (.oversizedFile, .oversizedFile):
            return true
        case let (.ioFailure(lhs), .ioFailure(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

    private func assertThrowsStoreError<T>(
        expected: SaveStore.StoreError,
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: () async throws -> T
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected StoreError.\(expected) but operation succeeded", file: file, line: line)
        } catch let error as SaveStore.StoreError {
            XCTAssertTrue(
                isExpectedStoreError(error, matching: expected),
                "Expected \(expected) but got \(error)",
                file: file,
                line: line
            )
        } catch {
            XCTFail(
                "Expected SaveStore.StoreError.\(expected) but caught \(type(of: error)): \(error)",
                file: file,
                line: line
            )
        }
    }

    private func assertThrowsSnapshotError<T>(
        expected: SaveSnapshotError,
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: () async throws -> T
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected SaveSnapshotError.\(expected) but operation succeeded", file: file, line: line)
        } catch let error as SaveSnapshotError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail(
                "Expected SaveSnapshotError.\(expected) but caught \(type(of: error)): \(error)",
                file: file,
                line: line
            )
        }
    }

    private func assertThrowsIOFailure<T>(
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: () async throws -> T
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected StoreError.ioFailure but operation succeeded", file: file, line: line)
        } catch let SaveStore.StoreError.ioFailure(message) {
            XCTAssertFalse(message.isEmpty, "ioFailure message should not be empty", file: file, line: line)
        } catch {
            XCTFail(
                "Expected StoreError.ioFailure but caught \(type(of: error)): \(error)",
                file: file,
                line: line
            )
        }
    }

    // MARK: - 1. Round Trip

    func testRoundTripPreservesAllCommittedFields() async throws {
        let expected = try makeSnapshot(revision: 1)
        try await store.save(expected)
        let actual = try await store.load(slotId: expected.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.schemaVersion, SaveSnapshot.currentSchemaVersion)
        XCTAssertEqual(actual.referenceSha256, referenceHash)
        XCTAssertEqual(actual.slotId, expected.slotId)
        XCTAssertEqual(actual.revision, 1)
        XCTAssertEqual(actual.player.name, "RedTester")
        XCTAssertEqual(actual.position.mapId, "pallet_town")
        XCTAssertEqual(actual.position.x, 10)
        XCTAssertEqual(actual.position.y, 12)
        XCTAssertEqual(actual.party.count, 1)
        XCTAssertEqual(actual.party[0].identifier, "starter_mon")
        XCTAssertEqual(actual.party[0].level, 5)
        XCTAssertEqual(actual.inventory.count, 1)
        XCTAssertEqual(actual.inventory[0].identifier, "potion")
        XCTAssertEqual(actual.inventory[0].quantity, 3)
        XCTAssertEqual(actual.progressFlags["intro_completed"], true)
        XCTAssertEqual(actual.worldState["step_count"], 120)
        XCTAssertNil(actual.battleState)
        XCTAssertEqual(actual.randomState, 0x1234_5678)
        XCTAssertEqual(actual.integrityDigest, expected.integrityDigest)
    }

    func testRoundTripWithBattleStatePreservesCommittedFields() async throws {
        let expected = try makeSnapshot(
            revision: 1,
            battleState: SaveSnapshot.BattleState(phase: "player_turn"),
            randomState: 0xCAFE_BABE
        )
        try await store.save(expected)
        let actual = try await store.load(slotId: expected.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.battleState?.phase, "player_turn")
        XCTAssertEqual(actual.randomState, 0xCAFE_BABE)
    }

    // MARK: - 2. Incompatible ROM / Reference

    func testReferenceMismatchDoesNotExposeOrOverwriteExistingSave() async throws {
        let original = try makeSnapshot(revision: 1)
        try await store.save(original)

        // Attempting to load with a different reference hash must fail with incompatibleReference
        await assertThrowsStoreError(expected: .incompatibleReference) {
            _ = try await store.load(slotId: original.slotId, referenceSha256: otherHash)
        }

        // Retained save must still load with the matching reference hash
        let retained = try await store.load(slotId: original.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(retained, original)
    }

    func testReferenceMismatchRejectsSaveOverExistingActive() async throws {
        let original = try makeSnapshot(revision: 1)
        try await store.save(original)

        // Attempting to save rev 2 with a different reference hash to the same slot must fail
        let incompatibleSnapshot = try makeSnapshot(referenceHash: otherHash, revision: 2)
        await assertThrowsStoreError(expected: .incompatibleReference) {
            try await store.save(incompatibleSnapshot)
        }

        // Active save remains the original rev 1
        let retained = try await store.load(slotId: original.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(retained, original)
    }

    func testInvalidIdentityRejectsLoadAndSave() async throws {
        // Reference hash with invalid length or illegal characters
        await assertThrowsStoreError(expected: .invalidIdentity) {
            _ = try await store.load(slotId: testSlot, referenceSha256: "short-hash")
        }
        await assertThrowsStoreError(expected: .invalidIdentity) {
            _ = try await store.load(slotId: testSlot, referenceSha256: String(repeating: "Z", count: 64))
        }

        // Invalid slot IDs (empty, path traversal, illegal characters)
        await assertThrowsStoreError(expected: .invalidIdentity) {
            _ = try await store.load(slotId: "", referenceSha256: referenceHash)
        }
        await assertThrowsStoreError(expected: .invalidIdentity) {
            _ = try await store.load(slotId: "../escape", referenceSha256: referenceHash)
        }
        await assertThrowsStoreError(expected: .invalidIdentity) {
            _ = try await store.load(slotId: "slot/nested", referenceSha256: referenceHash)
        }
    }

    // MARK: - 3. Incompatible / Unknown Schema

    func testUnknownSchemaIsRejectedWithoutDestroyingBackup() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        let rev2 = try makeSnapshot(revision: 2)
        try await store.save(rev1)
        try await store.save(rev2)

        // Tamper with active save to set an unsupported schema version
        let activePath = activeURL(for: rev1.slotId)
        let rawData = try Data(contentsOf: activePath)
        var json = try JSONSerialization.jsonObject(with: rawData) as! [String: Any]
        json["schemaVersion"] = 999
        let tamperedData = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys])
        try tamperedData.write(to: activePath)

        // Loading active file must throw unsupportedSchema(999)
        await assertThrowsSnapshotError(expected: .unsupportedSchema(999)) {
            _ = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        }

        // Backup remains intact and recoverable
        let recovered = try await store.recoverLastIntact(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(recovered, rev1)
    }

    func testSaveRejectsOverwritingActiveFileWithUnknownSchema() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        // Tamper with active save to set unsupported schema version
        let activePath = activeURL(for: rev1.slotId)
        let rawData = try Data(contentsOf: activePath)
        var json = try JSONSerialization.jsonObject(with: rawData) as! [String: Any]
        json["schemaVersion"] = 999
        let tamperedData = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys])
        try tamperedData.write(to: activePath)

        // Attempting to save rev 2 must not blindly overwrite or downgrade the unknown schema
        let rev2 = try makeSnapshot(revision: 2)
        await assertThrowsSnapshotError(expected: .unsupportedSchema(999)) {
            try await store.save(rev2)
        }
    }

    // MARK: - 4. Corruption

    func testCorruptionIsDetectedAndLastIntactSnapshotCanBeRecovered() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        let rev2 = try makeSnapshot(revision: 2)
        try await store.save(rev1)
        try await store.save(rev2)

        // Corrupt active save file with garbage bytes
        let activePath = activeURL(for: rev1.slotId)
        try Data("corrupted-garbage-bytes".utf8).write(to: activePath)

        // Loading corrupted active file must throw corruptFile
        await assertThrowsStoreError(expected: .corruptFile) {
            _ = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        }

        // Last intact snapshot (rev 1) can be recovered from backup
        let recovered = try await store.recoverLastIntact(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(recovered, rev1)
    }

    func testIntegrityDigestMismatchIsRejected() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        let rev2 = try makeSnapshot(revision: 2)
        try await store.save(rev1)
        try await store.save(rev2)

        // Tamper with active payload without updating integrityDigest
        let activePath = activeURL(for: rev1.slotId)
        let rawData = try Data(contentsOf: activePath)
        var json = try JSONSerialization.jsonObject(with: rawData) as! [String: Any]
        var player = json["player"] as! [String: Any]
        player["name"] = "HackedPlayerName"
        json["player"] = player
        let tamperedData = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys])
        try tamperedData.write(to: activePath)

        // Load must reject tampered digest with integrityFailure
        await assertThrowsSnapshotError(expected: .integrityFailure) {
            _ = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        }

        // Backup is intact and recoverable
        let recovered = try await store.recoverLastIntact(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(recovered, rev1)
    }

    func testOversizedFileIsRejected() async throws {
        let activePath = activeURL()
        // Maximum file size in SaveStore is 4MB (4 * 1024 * 1024)
        let oversizedData = Data(count: 4 * 1024 * 1024 + 1)
        try oversizedData.write(to: activePath)

        await assertThrowsStoreError(expected: .oversizedFile) {
            _ = try await store.load(slotId: testSlot, referenceSha256: referenceHash)
        }
    }

    // MARK: - 5. Stale Revision

    func testStaleRevisionIsRejectedWithoutModifyingActiveOrBackup() async throws {
        let rev2 = try makeSnapshot(revision: 2)
        try await store.save(rev2)

        // Attempting to save rev 1 (older)
        let rev1 = try makeSnapshot(revision: 1)
        await assertThrowsStoreError(expected: .staleRevision) {
            try await store.save(rev1)
        }

        // Attempting to save rev 2 again (same revision)
        await assertThrowsStoreError(expected: .staleRevision) {
            try await store.save(rev2)
        }

        // Active save remains rev 2
        let retained = try await store.load(slotId: rev2.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(retained, rev2)

        // Valid newer revision succeeds
        let rev3 = try makeSnapshot(revision: 3)
        try await store.save(rev3)
        let updated = try await store.load(slotId: rev3.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(updated, rev3)
        let backup = try await store.recoverLastIntact(slotId: rev3.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(backup, rev2)
    }

    // MARK: - 6. Backup Recovery

    func testBackupRecoveryLifecycle() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        let rev2 = try makeSnapshot(revision: 2)
        let rev3 = try makeSnapshot(revision: 3)

        // Before any save: not found
        await assertThrowsStoreError(expected: .notFound) {
            _ = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        }
        await assertThrowsStoreError(expected: .notFound) {
            _ = try await store.recoverLastIntact(slotId: rev1.slotId, referenceSha256: referenceHash)
        }

        // Save rev 1: active exists, but no backup yet
        try await store.save(rev1)
        let loaded1 = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded1, rev1)
        await assertThrowsStoreError(expected: .notFound) {
            _ = try await store.recoverLastIntact(slotId: rev1.slotId, referenceSha256: referenceHash)
        }

        // Save rev 2: active is rev 2, backup is rev 1
        try await store.save(rev2)
        let loaded2 = try await store.load(slotId: rev2.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded2, rev2)
        let backup1 = try await store.recoverLastIntact(slotId: rev2.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(backup1, rev1)

        // Non-mutating: recoverLastIntact does not clear or alter active or backup
        let loadedAfterRecovery = try await store.load(slotId: rev2.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loadedAfterRecovery, rev2)

        // Save rev 3: active is rev 3, backup is rev 2
        try await store.save(rev3)
        let loaded3 = try await store.load(slotId: rev3.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded3, rev3)
        let backup2 = try await store.recoverLastIntact(slotId: rev3.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(backup2, rev2)
    }

    func testSaveRefusesToOverwriteUnreadableBackup() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        let rev2 = try makeSnapshot(revision: 2)
        let rev3 = try makeSnapshot(revision: 3)
        try await store.save(rev1)
        try await store.save(rev2)

        // Corrupt backup file
        let backupPath = backupURL(for: rev1.slotId)
        try Data("corrupted-backup-data".utf8).write(to: backupPath)

        // Attempting to save rev 3 must fail before modifying the active save
        await assertThrowsStoreError(expected: .corruptFile) {
            try await store.save(rev3)
        }

        // Active save remains rev 2 intact
        let active = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(active, rev2)
    }

    // MARK: - 7. Interrupted / Failed Writes

    func testInterruptedWriteRetainsLastCommittedSnapshot() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        // Simulate write failure before active activation by placing a non-empty directory
        // at the backup destination, which causes rename() to fail with EISDIR/EEXIST/ENOTEMPTY.
        let backupPath = backupURL(for: rev1.slotId)
        try FileManager.default.createDirectory(at: backupPath, withIntermediateDirectories: true)
        let blocker = backupPath.appendingPathComponent("blocker.tmp")
        try Data("blocker".utf8).write(to: blocker)

        let rev2 = try makeSnapshot(revision: 2)
        await assertThrowsIOFailure {
            try await store.save(rev2)
        }

        // Active save rev 1 must remain completely intact
        let retained = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(retained, rev1)

        // Remove blocking directory
        try FileManager.default.removeItem(at: backupPath)

        // Subsequent write succeeds once obstruction is removed
        try await store.save(rev2)
        let loaded = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded, rev2)
    }

    func testInsufficientSpaceRetainsLastCommittedSnapshot() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        // Insofar as testable without kernel-level ENOSPC injection, verify that when
        // a filesystem write error occurs midway, the previous committed snapshot is preserved.
        let backupPath = backupURL(for: rev1.slotId)
        try FileManager.default.createDirectory(at: backupPath, withIntermediateDirectories: true)
        let blocker = backupPath.appendingPathComponent("blocker.tmp")
        try Data("blocker".utf8).write(to: blocker)

        let rev2 = try makeSnapshot(revision: 2)
        var failed = false
        do {
            try await store.save(rev2)
        } catch {
            failed = true
        }
        XCTAssertTrue(failed, "Filesystem failure must report error to caller")

        // Active save remains rev 1
        let retained = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(retained, rev1)

        try FileManager.default.removeItem(at: backupPath)
    }

    func testLeftoverPendingFilesDoNotAffectSubsequentOperations() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        // Leave orphan staging files as if a previous process was killed mid-write
        let orphanPending = tempDirectory.appendingPathComponent(".\(UUID().uuidString).pending")
        let orphanBackupPending = tempDirectory.appendingPathComponent(".\(UUID().uuidString).backup-pending")
        try Data("stale-pending".utf8).write(to: orphanPending)
        try Data("stale-backup".utf8).write(to: orphanBackupPending)

        // Load must ignore orphan files and read active save
        let loaded = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded, rev1)

        // Subsequent save must succeed without interference
        let rev2 = try makeSnapshot(revision: 2)
        try await store.save(rev2)
        let loaded2 = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(loaded2, rev2)
    }

    // MARK: - 8. Concurrency

    func testConcurrentSavesAreSerializedToOneWholeValidRevision() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        let currentStore = store!
        let currentRefHash = referenceHash
        let currentSlot = testSlot

        // Concurrently attempt to save revisions 2 through 10
        let revisions = Array(2...10)
        let outcomes = await withTaskGroup(of: (Int, Result<Void, Error>).self) { group in
            for rev in revisions {
                group.addTask {
                    do {
                        let snapshot = try SaveStoreTests.makeSnapshot(
                            slotId: currentSlot,
                            referenceHash: currentRefHash,
                            revision: rev
                        )
                        try await currentStore.save(snapshot)
                        return (rev, .success(()))
                    } catch {
                        return (rev, .failure(error))
                    }
                }
            }
            var results = [(Int, Result<Void, Error>)]()
            for await result in group {
                results.append(result)
            }
            return results
        }

        // Every failure must be a known StoreError (such as staleRevision due to out-of-order scheduling)
        for (rev, result) in outcomes {
            if case let .failure(error) = result {
                guard let storeError = error as? SaveStore.StoreError else {
                    XCTFail("Revision \(rev) failed with unexpected non-store error: \(error)")
                    continue
                }
                XCTAssertEqual(storeError, .staleRevision, "Revision \(rev) failed with unexpected error: \(storeError)")
            }
        }

        // Active save must be valid, uncorrupted, and equal to the highest successful revision
        let successfulRevisions = outcomes.compactMap { rev, result -> Int? in
            if case .success = result { return rev }
            return nil
        }
        XCTAssertFalse(successfulRevisions.isEmpty, "At least one concurrent save must succeed")
        let maxSuccessRev = successfulRevisions.max()!

        let restored = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        try restored.validate()
        XCTAssertEqual(restored.revision, maxSuccessRev)
        XCTAssertEqual(restored.referenceSha256, referenceHash)
    }

    func testConcurrentReadsDuringWritesNeverObserveTornData() async throws {
        let rev1 = try makeSnapshot(revision: 1)
        try await store.save(rev1)

        let currentStore = store!
        let currentSlot = testSlot
        let currentRefHash = referenceHash

        // Writer task saves rev 2..6 in sequence while multiple readers read concurrently
        await withTaskGroup(of: Void.self) { group in
            // Writer
            group.addTask {
                for rev in 2...6 {
                    do {
                        let snap = try SaveStoreTests.makeSnapshot(
                            slotId: currentSlot,
                            referenceHash: currentRefHash,
                            revision: rev
                        )
                        try await currentStore.save(snap)
                    } catch {
                        XCTFail("Sequential writer failed at revision \(rev): \(error)")
                    }
                }
            }

            // Readers
            for _ in 0..<4 {
                group.addTask {
                    for _ in 0..<20 {
                        do {
                            let snap = try await currentStore.load(
                                slotId: currentSlot,
                                referenceSha256: currentRefHash
                            )
                            try snap.validate()
                            XCTAssertTrue((1...6).contains(snap.revision))
                        } catch {
                            XCTFail("Reader encountered unexpected error: \(error)")
                        }
                    }
                }
            }
        }

        // Final state must be rev 6
        let finalSnapshot = try await store.load(slotId: rev1.slotId, referenceSha256: referenceHash)
        XCTAssertEqual(finalSnapshot.revision, 6)
    }

    // MARK: - 9. No Protected Fixtures

    func testSyntheticFixturesContainNoProtectedROMData() throws {
        let snap = try makeSnapshot(revision: 1)
        // Verify reference hash is a synthetic dummy string (not a known commercial ROM hash)
        XCTAssertEqual(snap.referenceSha256, String(repeating: "a", count: 64))
        // Verify slot identifier is synthetic
        XCTAssertEqual(snap.slotId, "synthetic-slot")
        // Verify player and party identifiers are generic synthetic strings
        XCTAssertEqual(snap.player.name, "RedTester")
        XCTAssertEqual(snap.party.first?.identifier, "starter_mon")
        XCTAssertEqual(snap.inventory.first?.identifier, "potion")
    }
}
