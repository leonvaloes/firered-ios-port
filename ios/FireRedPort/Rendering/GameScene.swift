import SpriteKit

/// Presentation-only 2D surface driven strictly by authoritative Domain state.
/// Nodes never make game decisions or advance rules independently.
public final class GameScene: SKScene {
    private let playerNode = SKShapeNode(rectOf: CGSize(width: 24, height: 24))
    private let tileSize: CGFloat = 32.0

    public override func didMove(to view: SKView) {
        backgroundColor = .black
        playerNode.fillColor = .red
        playerNode.strokeColor = .white
        playerNode.lineWidth = 2
        addChild(playerNode)
    }

    /// Renders state projection.
    public func updatePresentation(from state: GameState) {
        let px = CGFloat(state.position.x) * tileSize
        let py = CGFloat(-state.position.y) * tileSize
        playerNode.position = CGPoint(x: px + size.width / 2, y: py + size.height / 2)
    }
}
