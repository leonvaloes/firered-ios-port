import Foundation
import XCTest
@testable import FireRedPort

final class DiagnosticLogTests: XCTestCase {
    func testExportIncludesOnlyAllowlistedEventsAndTimestamps() async {
        let log = DiagnosticLog()
        await log.record(.importStarted, at: Date(timeIntervalSince1970: 0))
        await log.record(.importVerified, at: Date(timeIntervalSince1970: 1))
        let report = await log.exportText()
        XCTAssertTrue(report.contains("1970-01-01T00:00:00Z IMPORT_STARTED"))
        XCTAssertTrue(report.contains("1970-01-01T00:00:01Z IMPORT_VERIFIED"))
        XCTAssertFalse(report.contains(".gba"))
        XCTAssertFalse(report.contains("Pokemon"))
        await log.clear()
        let cleared = await log.exportText()
        XCTAssertFalse(cleared.contains("IMPORT_STARTED"))
    }

    func testOldestEventsEvictedAtCapacity() async {
        let log = DiagnosticLog()
        await log.record(.appOpened, at: Date(timeIntervalSince1970: 0))
        for second in 1...100 {
            await log.record(.importStarted, at: Date(timeIntervalSince1970: TimeInterval(second)))
        }
        let report = await log.exportText()
        XCTAssertFalse(report.contains("APP_OPENED"))
        XCTAssertEqual(report.components(separatedBy: "IMPORT_STARTED").count - 1, 100)
    }
}
