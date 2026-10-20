import Foundation

/// Safe placeholder for local audio subsystem lifecycle without bundling copyrighted assets.
public final class GameAudio {
    public static let shared = GameAudio()

    private(set) public var isMuted: Bool = false
    private(set) public var isInterrupted: Bool = false

    private init() {}

    public func handleAudioInterruption(began: Bool) {
        isInterrupted = began
    }

    public func setMuted(_ muted: Bool) {
        self.isMuted = muted
    }
}
