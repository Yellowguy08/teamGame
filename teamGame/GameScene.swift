import Foundation
import SpriteKit
import GameplayKit
import GameController
//
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let upgrades : [String] = ["WeaponSpeed", "Damage", "MovementSpeed", "Spread"]
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    let shotgun = SKSpriteNode(imageNamed: "Shotgun")

    var startedClickInCircle: Bool = false
    
    var levelBar : SKSpriteNode = SKSpriteNode()
    var levelLabel : SKLabelNode = SKLabelNode()
    
    var xp : Double = 0
    var level : Int = 1
    var player: SKSpriteNode!
    var worldNode : SKNode!
    
    
    var movementDirection: CGPoint = .zero
    var health: CGFloat = 100
    var upgradeOptions : [SKSpriteNode] = []
    
    var selectUpgrade : Bool = false
    
    // Upgrades
    var weaponSpeed : Double = 5.00
    var weaponDamage : Double = 10.00
    var movementSpeed : CGFloat = 200.0
    var spread : Int = 1
    
    var enemies : [SKSpriteNode] = []
    
    
    
    override func didMove(to view: SKView) {
        upgradeOptions = []
        worldNode = childNode(withName: "worldNode")
        
        worldNode.addChild(joystickContainer)
        worldNode.addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
              
        addChild(shotgun)

        shotgun.size = CGSize(width: 105, height: 105)
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        shotgun.position = CGPoint(x: frame.midX, y: frame.midY)

        if let playerNode = worldNode.childNode(withName: "PlayerSprite") as? SKSpriteNode {
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
            worldNode.addChild(player)
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
            if (!worldNode.isPaused) {
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
            } else {
                for upgradeOption in upgradeOptions {
                    if (CGRectContainsPoint(upgradeOption.frame, location)) {
                        selectUpgrade = true
                    }
                }
            }
        }
    }//end touchesbegan
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!worldNode.isPaused) {
            updateJoystickBallPosition(touches: touches)
            if let touch = touches.first {
                let location = touch.location(in: self)
                
                if startedClickInCircle == true {
                    let vector = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
                    movementDirection = CGPoint(x: vector.dx / joystickContainer.size.width, y: vector.dy / joystickContainer.size.height)
                }
                
                
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
        resetJoyStick()
        if let touch = touches.first {
            let location = touch.location(in: self)
            if (worldNode.isPaused) {
                for upgradeOption in upgradeOptions {
                    if (selectUpgrade && CGRectContainsPoint(upgradeOption.frame, location)) {
                        selectUpgrade = false
                        upgrade(upgradeName: (upgradeOption.childNode(withName: "label") as! SKLabelNode).text!)
                        
                        level += 1
                        levelLabel.text = "Level: \(level)"
                        xp = 0
                        worldNode.isPaused = false
                        physicsWorld.speed = 1
                        levelBar.removeAllActions()
                        levelBar.color = .green
                                                
                        for upgradeOption in upgradeOptions {
                            upgradeOption.removeFromParent()
                        }
                        
                        upgradeOptions = []
                        break
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
       // let dTime = CGFloat(currentTime)
        
        let movement = CGVector(dx: (movementDirection.x * movementSpeed)/10, dy: (movementDirection.y * movementSpeed)/10)
      
        if (xp > 1000) {
            xp = 1000
        }
        levelBar.size.width = xp/1000 * 600
        
        if (xp == 1000 && !worldNode.isPaused) {
            levelUp()
        }
        
        let deltaTime = CGFloat(currentTime)
//        let movement = CGVector(dx: movementDirection.x * movementSpeed, dy: movementDirection.y * movementSpeed)

        player.position = CGPoint(x: player.position.x + movement.dx, y: player.position.y + movement.dy)
        
        player.position.x = max(min(player.position.x, frame.maxX - player.size.width / 2), frame.minX + player.size.width / 2)
        player.position.y = max(min(player.position.y, frame.maxY - player.size.height / 2), frame.minY + player.size.height / 2)
        
        
        if movementDirection.x > 0 {
            player.xScale = 0.2
            
            if let playerNode = worldNode.childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSprite")
            }
            
        } else if movementDirection.x < 0 {
            player.xScale = -0.2
            
            if let playerNode = worldNode.childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSprite")
            }
            
        } else {
            player.xScale = 0.25
            
            if let playerNode = worldNode.childNode(withName: "PlayerSprite") as? SKSpriteNode {
                playerNode.texture = SKTexture(imageNamed: "PlayerSpriteForward")
            }
        }
        
       
        shotgun.position = CGPoint(x: player.position.x, y: player.position.y)
        let angle = atan2(movement.dy, movement.dx)
        shotgun.zRotation = angle
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
        
        worldNode.addChild(enemy)
        enemies.append(enemy)
                
        enemyMove(enemy: enemy)
        

    }
    
    func upgrade(upgradeName : String) {
        switch (upgradeName) {
        case "WeaponSpeed":
            weaponSpeed += 1.00
            print(weaponSpeed)
            return
        case "Damage":
            weaponDamage += 2.00
            print(weaponDamage)
            return
        case "Spread":
            spread += 1
            print(spread)
            return
        case "MovementSpeed":
            movementSpeed += 25.00
            print(movementSpeed)
            return
        default:
            return
        }
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
        worldNode.isPaused = true
        physicsWorld.speed = 0
        resetJoyStick()
        rainbowXP()
        viewUpgrades()
    }
    
    func resetJoyStick() {
        startedClickInCircle = false
        joystickBall.position = joystickContainer.position
        movementDirection = .zero
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
        
        let sequence : SKAction = SKAction.sequence([orange, wait, green, wait, blue, wait, red, wait, yellow, wait, pink, wait])
        
        let rpeat : SKAction = SKAction.repeatForever(sequence)
        
        levelBar.run(rpeat)
        
    }
    
    func viewUpgrades() {
                
        var upgrades = self.upgrades
        
        let option1 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        let option2 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        let option3 : SKSpriteNode = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 250))
        
        addChild(option1)
        upgradeOptions.append(option1)
        addChild(option2)
        upgradeOptions.append(option2)
        addChild(option3)
        upgradeOptions.append(option3)
        
        option1.position = CGPoint(x: frame.width / 6 * 1, y: frame.height / 2)
        option1.zPosition = 10
        option2.position = CGPoint(x: frame.width / 6 * 3, y: frame.height / 2)
        option2.zPosition = 10
        option3.position = CGPoint(x: frame.width / 6 * 5, y: frame.height / 2)
        option3.zPosition = 10
        
        for i in 0..<3 {
            let randomNum = Int.random(in: 0..<upgrades.count)
            let label : SKLabelNode = SKLabelNode(text: upgrades[randomNum])
            upgrades.remove(at: randomNum)
            upgradeOptions[i].addChild(label)
//            print(label.text)
            label.fontColor = .black
            label.name = "label"
            label.zPosition = 11
        }
        
    }
}
