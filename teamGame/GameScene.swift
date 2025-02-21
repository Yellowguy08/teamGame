import Foundation
import SpriteKit
import GameplayKit
import GameController
//
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    var startedClickInCircle: Bool = false
    
    var levelBar : SKSpriteNode = SKSpriteNode()
    var levelLabel : SKLabelNode = SKLabelNode()
    
    var xp : Double = 0
    var level : Int = 1
    var player: SKSpriteNode!
    var movementDirection: CGPoint = .zero
    let movementSpeed: CGFloat = 200.0
    var health: CGFloat = 100
    
    override func didMove(to view: SKView) {
        addChild(joystickContainer)
        addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        
        if let playerNode = childNode(withName: "PlayerSprite") as? SKSpriteNode {
            player = playerNode
        } else {
            player = SKSpriteNode(imageNamed: "PlayerSprite")
            player.position = CGPoint(x: frame.midX, y: frame.midY)
            player.name = "Player"
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.isDynamic = true
            player.physicsBody?.categoryBitMask = 2
            player.physicsBody?.contactTestBitMask = 4
            addChild(player)
        }
        
        levelBar = childNode(withName: "LevelBar") as! SKSpriteNode
        levelBar.color = .green
        
        levelLabel = childNode(withName: "Level") as! SKLabelNode
        levelLabel.text = "Level: \(level)"
        
//        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.physicsBody = border
//        self.physicsBody?.categoryBitMask = 8
//        self.physicsBody?.contactTestBitMask = 2
//        
//        physicsWorld.contactDelegate = self
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4 {
            contact.bodyB.node?.removeFromParent()
            health = health - 10
            let waitAction = SKAction.wait(forDuration: 2.0)
            print(health)
            if health == 0 {
                contact.bodyA.node?.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            createEnemy()
            
            if (CGRectContainsPoint(joystickContainer.frame, location)) {
                startedClickInCircle = true
                joystickBall.position = location
            } else {
                startedClickInCircle = false
            }
            xp += 100 - (Double(level) * 0.1)
            
            if startedClickInCircle == true {
                let vector = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
                movementDirection = CGPoint(x: vector.dx / joystickContainer.size.width, y: vector.dy / joystickContainer.size.height)
            }
        }
    }//end touchesbegan
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateJoystickBallPosition(touches: touches)
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            if startedClickInCircle == true {
                let vector = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
                movementDirection = CGPoint(x: vector.dx / joystickContainer.size.width, y: vector.dy / joystickContainer.size.height)
            }
            
           
        }
    }
    
    func updateJoystickBallPosition(touches: Set<UITouch>) {
        if startedClickInCircle == true {
            if let touch = touches.first {
                let location = touch.location(in: self)
                
                let v = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
                let angle = atan2(v.dy, v.dx)
                
                let deg = angle * CGFloat(180/Double.pi)
                
                let length:CGFloat = joystickContainer.frame.height/2
                
                let xDistance:CGFloat = sin(angle - 1.57079633) * length
                let yDistance:CGFloat = cos(angle - 1.57079633) * length
                
                if (CGRectContainsPoint(joystickContainer.frame, location)) {
                    joystickBall.position = location
                } else {
                    joystickBall.position = CGPointMake(joystickContainer.position.x - xDistance, joystickContainer.position.y + yDistance)
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystickBall.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        startedClickInCircle = false
        movementDirection = .zero
    }
    
    override func update(_ currentTime: TimeInterval) {
       // let dTime = CGFloat(currentTime)
        let movement = CGVector(dx: (movementDirection.x * movementSpeed)/10, dy: (movementDirection.y * movementSpeed)/10)
      
        if (xp > 1000) {
            xp = 1000
        }
        levelBar.size.width = xp/1000 * 600
        
        if (xp == 1000) {
            levelUp()
            level += 1
            levelLabel.text = "Level: \(level)"
            xp = 0
        }
        
        let deltaTime = CGFloat(currentTime)
//        let movement = CGVector(dx: movementDirection.x * movementSpeed, dy: movementDirection.y * movementSpeed)

        player.position = CGPoint(x: player.position.x + movement.dx, y: player.position.y + movement.dy)
        
        player.position.x = max(min(player.position.x, frame.maxX - player.size.width / 2), frame.minX + player.size.width / 2)
        player.position.y = max(min(player.position.y, frame.maxY - player.size.height / 2), frame.minY + player.size.height / 2)
        
        
        if movementDirection.x > 0 {
            player.xScale = 0.2
            
            if let playerNode = childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSprite")           
            }
            
        } else if movementDirection.x < 0 {
            player.xScale = -0.2
            
            if let playerNode = childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSprite")
            }
            
        } else {
            player.xScale = 0.25
            
            if let playerNode = childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSpriteForward")
            }
        }
        
       
        
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
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 2
        enemy.physicsBody?.allowsRotation = false
        
        addChild(enemy)
                
        enemyMove(enemy: enemy)
        

    }
    
    func enemyMove(enemy: SKSpriteNode) {
        
        let move : SKAction = SKAction.run {
            let angle = CGFloat.pi + atan2(enemy.position.y - self.player.position.y,
                                           enemy.position.x - self.player.position.x)
                        
            let velocityX = 250 * cos(angle)
            let velocityY = 250 * sin(angle)
                                  
            let newVelocity = CGVector(dx: velocityX, dy: velocityY)
                        
            enemy.physicsBody?.velocity = newVelocity
        }
        
        let wait : SKAction = SKAction.wait(forDuration: Double.random(in: 0.1 ..< 0.5))
        
        let sequence : SKAction = SKAction.sequence([move, wait])
                
        enemy.run(SKAction.repeatForever(sequence))
        
        
    }
    
    func levelUp() {
        rainbowXP()
        viewUpgrades()
//        pause()
    }
    
    func rainbowXP() {
        let wait : SKAction = SKAction.wait(forDuration: 0.3)
        
        let red : SKAction = SKAction.run {
            self.levelBar.color = .red
        }
        
        let orange : SKAction = SKAction.run {
            self.levelBar.color = .orange
        }
        
        let yellow : SKAction = SKAction.run {
            self.levelBar.color = .yellow
        }
        
        let green : SKAction = SKAction.run {
            self.levelBar.color = .green
        }
        
        let blue : SKAction = SKAction.run {
            self.levelBar.color = .blue
        }
        
        let pink : SKAction = SKAction.run {
            self.levelBar.color = .magenta
        }
        
        let sequence : SKAction = SKAction.sequence([red, wait, orange, wait, yellow, wait, green, wait, blue, wait, pink, wait])
        
        let rpeat : SKAction = SKAction.repeatForever(sequence)
        
        levelBar.run(rpeat)
        
    }
    
    func viewUpgrades() {
        
        let option1 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        let option2 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        let option3 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        
        addChild(option1)
        addChild(option2)
        addChild(option3)
        
        option1.position = CGPoint(x: frame.width / 6 * 1, y: frame.height / 2)
        option2.position = CGPoint(x: frame.width / 6 * 3, y: frame.height / 2)
        option3.position = CGPoint(x: frame.width / 6 * 5, y: frame.height / 2)
        
    }
}
