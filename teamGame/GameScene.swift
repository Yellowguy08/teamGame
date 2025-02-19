import Foundation
import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    var player: SKSpriteNode!
    var movementDirection: CGPoint = .zero
    let movementSpeed: CGFloat = 200.0
    
    override func didMove(to view: SKView) {
        addChild(joystickContainer)
        addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        
        if let playerNode = childNode(withName: "Player") as? SKSpriteNode {
            player = playerNode
        } else {
            player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
            player.position = CGPoint(x: frame.midX, y: frame.midY)
            player.name = "Player"
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.isDynamic = true
            player.physicsBody?.categoryBitMask = 2
            player.physicsBody?.contactTestBitMask = 4
            addChild(player)
        }
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        self.physicsBody?.categoryBitMask = 8
        self.physicsBody?.contactTestBitMask = 2
        
        physicsWorld.contactDelegate = self
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4 {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            joystickBall.position = location
            createEnemy()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            joystickBall.position = location
            
            let vector = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
            movementDirection = CGPoint(x: vector.dx / joystickContainer.size.width, y: vector.dy / joystickContainer.size.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystickBall.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        movementDirection = .zero
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = CGFloat(currentTime)
        let movement = CGVector(dx: movementDirection.x * movementSpeed, dy: movementDirection.y * movementSpeed)

        player.position = CGPoint(x: player.position.x + movement.dx, y: player.position.y + movement.dy)
        
        player.position.x = max(min(player.position.x, frame.maxX - player.size.width / 2), frame.minX + player.size.width / 2)
        player.position.y = max(min(player.position.y, frame.maxY - player.size.height / 2), frame.minY + player.size.height / 2)
    }
    
    func createEnemy() {
        let enemy: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        let priority = Int.random(in: 0...1)
        
        var x: Int
        var y: Int
        
        if priority == 1 {
            x = Int.random(in: 0...Int(frame.width))
            y = Int.random(in: 0...1) == 1 ? Int(frame.height + enemy.size.height) : 0 - Int(enemy.size.height)
        } else {
            x = Int.random(in: 0...1) == 1 ? Int(frame.width + enemy.size.width) : 0 - Int(enemy.size.width)
            y = Int.random(in: 0...Int(frame.height))
        }
        
        enemy.position = CGPoint(x: x, y: y)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.frame.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 2
        
        addChild(enemy)
        enemyMove(enemy: enemy)
    }
    
    func enemyMove(enemy: SKSpriteNode) {
        let move: SKAction = SKAction.move(to: player.position, duration: 1)
        let repeatAction: SKAction = SKAction.repeatForever(move)
        enemy.run(repeatAction)
    }
}
