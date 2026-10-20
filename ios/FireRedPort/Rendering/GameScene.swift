import SpriteKit

/// Presentation-only 2D surface driven strictly by authoritative Domain state.
/// Nodes never make game decisions or advance rules independently.
public final class GameScene: SKScene {
    private let mapNode = SKNode()
    private let playerNode = SKNode()
    private let playerBody = SKShapeNode(rectOf: CGSize(width: 22, height: 26), cornerRadius: 4)
    private let playerCap = SKShapeNode(rectOf: CGSize(width: 20, height: 10), cornerRadius: 2)
    private let playerFace = SKShapeNode(rectOf: CGSize(width: 16, height: 8), cornerRadius: 2)
    private let directionIndicator = SKShapeNode()
    private let tileSize: CGFloat = 32.0

    private var currentLayout: MapLayoutData?

    public override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        if mapNode.parent == nil {
            addChild(mapNode)
        }

        setupPlayerModel()
    }

    private func setupPlayerModel() {
        if playerNode.parent == nil {
            playerBody.fillColor = UIColor(red: 0.85, green: 0.22, blue: 0.22, alpha: 1.0)
            playerBody.strokeColor = .white
            playerBody.lineWidth = 1.5

            playerCap.fillColor = UIColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1.0)
            playerCap.strokeColor = .black
            playerCap.lineWidth = 1.0
            playerCap.position = CGPoint(x: 0, y: 7)

            playerFace.fillColor = UIColor(red: 0.98, green: 0.85, blue: 0.75, alpha: 1.0)
            playerFace.strokeColor = .clear
            playerFace.position = CGPoint(x: 0, y: 0)

            playerNode.addChild(playerBody)
            playerNode.addChild(playerCap)
            playerNode.addChild(playerFace)
            playerNode.addChild(directionIndicator)
            playerNode.zPosition = 10
            mapNode.addChild(playerNode)
        }
    }

    /// Renders loaded map tiles from authoritative MapLayoutData.
    public func loadMapLayout(_ layout: MapLayoutData) {
        self.currentLayout = layout
        mapNode.removeAllChildren()
        setupPlayerModel()

        let isOutdoor = (layout.bank == 3)
        let grassColor = UIColor(red: 0.40, green: 0.75, blue: 0.42, alpha: 1.0)
        let pathColor = UIColor(red: 0.86, green: 0.80, blue: 0.65, alpha: 1.0)
        let wallColor = UIColor(red: 0.35, green: 0.25, blue: 0.20, alpha: 1.0)
        let roofColor = UIColor(red: 0.70, green: 0.30, blue: 0.25, alpha: 1.0)
        let waterColor = UIColor(red: 0.25, green: 0.55, blue: 0.90, alpha: 1.0)
        let indoorFloor = UIColor(red: 0.78, green: 0.64, blue: 0.50, alpha: 1.0)
        let carpetColor = UIColor(red: 0.75, green: 0.28, blue: 0.28, alpha: 1.0)

        for y in 0..<layout.height {
            for x in 0..<layout.width {
                guard let tile = layout.tileAt(x: x, y: y) else { continue }
                let tileRect = CGRect(
                    x: CGFloat(x) * tileSize,
                    y: CGFloat(-y) * tileSize,
                    width: tileSize,
                    height: tileSize
                )
                let shape = SKShapeNode(rect: tileRect)
                shape.strokeColor = UIColor.black.withAlphaComponent(0.08)
                shape.lineWidth = 0.5

                if tile.collision == 0x01 {
                    shape.fillColor = isOutdoor ? roofColor : wallColor
                } else if tile.collision == 0x04 {
                    shape.fillColor = waterColor
                } else if tile.isPassable {
                    if isOutdoor {
                        shape.fillColor = (x >= 8 && x <= 13) ? pathColor : grassColor
                    } else {
                        shape.fillColor = (x >= 4 && x <= 7 && y >= 4 && y <= 6) ? carpetColor : indoorFloor
                    }
                } else {
                    shape.fillColor = wallColor
                }

                shape.zPosition = 1
                mapNode.addChild(shape)
            }
        }
    }

    /// Renders state projection.
    public func updatePresentation(from state: GameState) {
        setupPlayerModel()
        let targetX = CGFloat(state.position.x) * tileSize + tileSize / 2
        let targetY = CGFloat(-state.position.y) * tileSize + tileSize / 2

        playerNode.removeAction(forKey: "walk")
        let moveAction = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: 0.10)
        playerNode.run(moveAction, withKey: "walk")

        updateFacingIndicator(state.position.facing)

        mapNode.removeAction(forKey: "camera")
        let cameraAction = SKAction.move(to: CGPoint(x: -targetX, y: -targetY), duration: 0.10)
        mapNode.run(cameraAction, withKey: "camera")
    }

    private func updateFacingIndicator(_ direction: GridPosition.Direction) {
        directionIndicator.removeAllChildren()
        let dot = SKShapeNode(circleOfRadius: 3)
        dot.fillColor = .white
        dot.strokeColor = .black
        dot.lineWidth = 1

        switch direction {
        case .north: dot.position = CGPoint(x: 0, y: 12)
        case .south: dot.position = CGPoint(x: 0, y: -12)
        case .west:  dot.position = CGPoint(x: -10, y: 0)
        case .east:  dot.position = CGPoint(x: 10, y: 0)
        }
        directionIndicator.addChild(dot)
    }
}
