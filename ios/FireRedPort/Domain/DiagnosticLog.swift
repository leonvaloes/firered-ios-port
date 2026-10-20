import Foundation

/// Allowlisted diagnostics only. No arbitrary strings, ROM bytes, save data, paths or credentials.
actor DiagnosticLog {
    static let shared = DiagnosticLog()

    enum Event: String, Codable, CaseIterable {
        case appOpened = "APP_OPENED"
        case importStarted = "IMPORT_STARTED"
        case importVerified = "IMPORT_VERIFIED"
        case importTruncated = "IMPORT_TRUNCATED"
        case importIncompatible = "IMPORT_INCOMPATIBLE"
        case importInvalidHeader = "IMPORT_INVALID_HEADER"
        case importInsufficientSpace = "IMPORT_INSUFFICIENT_SPACE"
        case importAccessFailed = "IMPORT_ACCESS_FAILED"
    }

    private struct Entry {
        let timestamp: Date
        let event: Event
    }

    private var entries: [Entry] = []
    private let limit = 100

    func record(_ event: Event, at timestamp: Date = Date()) {
        entries.append(Entry(timestamp: timestamp, event: event))
        if entries.count > limit {
            entries.removeFirst(entries.count - limit)
        }
    }

    func clear() {
        entries.removeAll()
    }

    /// Export on user request only; no automatic upload, file persistence or OSLog output.
    func exportText() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let header = "FireRedPort diagnostics v1\nNo ROM, saves, paths or account data are collected.\n"
        return header + entries.map { "\(formatter.string(from: $0.timestamp)) \($0.event.rawValue)" }.joined(separator: "\n")
    }
}
