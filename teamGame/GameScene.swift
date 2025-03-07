import Foundation
import SpriteKit
import GameplayKit
import GameController
//
class GameScene: SKScene, SKPhysicsContactDelegate {
    let cam = SKCameraNode()

    let upgrades : [String] = ["WeaponSpeed", "Damage", "MovementSpeed", "Spread"]
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    let shotgun = SKSpriteNode(imageNamed: "Shotgun")

    var startedClickInCircle: Bool = false
    
    var gameOver : Bool =  false
    var gameStarted : Bool = false
    
    var levelBar : SKSpriteNode = SKSpriteNode()
    var levelLabel : SKLabelNode = SKLabelNode()
    
    var healthBarBackground: SKSpriteNode!
    var healthBar: SKSpriteNode!
    
    var xp : Double = 0
    var level : Int = 1
    var player: SKSpriteNode!
    var enemy: SKSpriteNode!
    var worldNode : SKNode!
    
    var movement : CGVector = CGVector(dx: 0, dy: 0)
    var angle : CGFloat = 0
    
    var death: Bool = false
    var health: CGFloat = 1000
    
    var globalTouchLocation: CGPoint = .zero
    
    var movementDirection: CGPoint = .zero
    var upgradeOptions : [SKSpriteNode] = []
    
    var selectUpgrade : Bool = false
    
    // Upgrades
    var weaponSpeed : Double = 5.00
    var weaponDamage : Double = 10.00
    var movementSpeed : CGFloat = 150.0
    var spread : Int = 1
    
    var enemies : [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        addChild(cam)
        self.camera = cam //COMMENT THIS OUT TO TURN CAMERA OFF

        upgradeOptions = []
        worldNode = childNode(withName: "worldNode")
        
        worldNode.addChild(joystickContainer)
        worldNode.addChild(joystickBall)
        joystickContainer.zPosition = 3
        joystickBall.zPosition = 3
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
              
        worldNode.addChild(shotgun)

        shotgun.size = CGSize(width: 105, height: 105)
        shotgun.zPosition = 5
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        shotgun.position = CGPoint(x: frame.midX, y: frame.midY)

        if let playerNode = worldNode.childNode(withName: "PlayerSprite") as? SKSpriteNode {
            player = playerNode
            if player.physicsBody == nil {
                player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
                player.physicsBody?.categoryBitMask = 2
                player.physicsBody?.contactTestBitMask = 4
                player.physicsBody?.collisionBitMask = 0
                player.physicsBody?.affectedByGravity = false
                player.physicsBody?.isDynamic = true
            }
        } else {
            player = SKSpriteNode(imageNamed: "PlayerSprite")
            player.position = CGPoint(x: frame.midX, y: frame.midY)
            player.name = "Player"
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.isDynamic = true
            player.physicsBody?.categoryBitMask = 2
            player.physicsBody?.contactTestBitMask = 4
            player.physicsBody?.collisionBitMask = 0
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.isDynamic = true
            player.zPosition = 3
            worldNode.addChild(player)
        }
        
        healthBarBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: 100, height: 10))
        healthBarBackground.zPosition = 2
        addChild(healthBarBackground)

        healthBar = SKSpriteNode(color: .green, size: CGSize(width: 100, height: 10))
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.position = CGPoint(x: -50, y: 0)
        healthBarBackground.addChild(healthBar)

        
        levelBar = childNode(withName: "LevelBar") as! SKSpriteNode
        levelBar.color = .green
        
        levelLabel = childNode(withName: "Level") as! SKLabelNode
        levelLabel.text = "Level: \(level)"
        
        shoot()

        physicsWorld.contactDelegate = self
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        print("Collision bodys: \(bodyA.categoryBitMask) - \(bodyB.categoryBitMask)")

        if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 4) || (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 2) {
            
            print("Player-Enemy Contact Detected")
            health -= 5
            print("Health: \(health)")
            
            updateHealthBar()
            
            let flashAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.fadeIn(withDuration: 0.1)
            ])
            player.run(SKAction.repeat(flashAction, count: 2))
            
            if health <= 0 {
                player.removeFromParent()
                healthBarBackground.removeFromParent()
                shotgun.removeFromParent()
                gameOver = true
                death = true
                print("Game Over")
            }
            if (bodyA.categoryBitMask == 8 && bodyB.categoryBitMask == 4) || (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 8) {
                print("Bullet-Enemy Contact Detected")
                if bodyA.categoryBitMask == 4 {
                    bodyA.node?.removeFromParent()
                } else {
                    bodyB.node?.removeFromParent()
                }
            }
        }

                
        if ((contact.bodyA.categoryBitMask == 4 && contact.bodyB.categoryBitMask == 8) || (contact.bodyA.categoryBitMask == 8 && contact.bodyB.categoryBitMask == 4)) {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            xp += 100 - (Double(level) * 0.1)
        }
        
//        if contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4 {
//            contact.bodyB.node?.removeFromParent()
//            health = health - 10
//            let waitAction = SKAction.wait(forDuration: 2.0)
//            print(health)
//            if health == 0 {
//                contact.bodyA.node?.removeFromParent()
//            }
//        }
    }
    
    func updateHealthBar() {
            let healthPercentage = max(health / 100, 0)
            healthBar.size.width = 100 * healthPercentage

            healthBar.position.x = -50

            if healthPercentage > 0.5 {
                healthBar.color = .green
            } else if healthPercentage > 0.2 {
                healthBar.color = .yellow
            } else {
                healthBar.color = .red
            }
    //        print("Health Bar: \(healthBar.size.width)")
        }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        for touch in touches {
            
            let location = touch.location(in: self)
     globalTouchLocation = location

            if (!worldNode.isPaused) {
                createEnemy()
                
                if (CGRectContainsPoint(joystickContainer.frame, location)) {
                    startedClickInCircle = true
                    joystickBall.position = location
                } else {
                    startedClickInCircle = false
                }
                
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
            updateJoystickBallPosition()
            if let touch = touches.first {
                let location = touch.location(in: self)

         globalTouchLocation = location
                updateJoystickBallPosition()
                
                if startedClickInCircle == true {
                    let vector = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
                    movementDirection = CGPoint(x: vector.dx / joystickContainer.size.width, y: vector.dy / joystickContainer.size.height)
                }
                
                
            }
        }
    } //updates joystick




   func updateJoystickBallPosition() {
        if startedClickInCircle == true {
            let location = globalTouchLocation
            let v = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
            let angle = atan2(v.dy, v.dx)
            
//                let deg = angle * CGFloat(180/Double.pi)
            
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
        
        movement = CGVector(dx: (movementDirection.x * movementSpeed)/10, dy: (movementDirection.y * movementSpeed)/10)
      
        if (xp > 1000) {
            xp = 1000
        }
        levelBar.size.width = xp/1000 * 600
        
        if (xp == 1000 && !worldNode.isPaused) {
            levelUp()
        }
        
        _ = CGFloat(currentTime)
//        let movement = CGVector(dx: movementDirection.x * movementSpeed, dy: movementDirection.y * movementSpeed)

        player.position = CGPoint(x: player.position.x + movement.dx, y: player.position.y + movement.dy)
        
//        player.position.x = max(min(player.position.x, frame.maxX - player.size.width / 2), frame.minX + player.size.width / 2)
//        player.position.y = max(min(player.position.y, frame.maxY - player.size.height / 2), frame.minY + player.size.height / 2)
        
        
       
        
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
        angle = atan2(movement.dy, movement.dx)
        var newAngle : CGFloat = angle
        print(angle)
        if (angle > (Double.pi / 2) || angle < -(Double.pi / 2)) {
            print("Flip")
            shotgun.yScale = -1
//            newAngle =
        } else {
            shotgun.yScale = 1
        }
        
        shotgun.zRotation = newAngle
        
        healthBarBackground.position = CGPoint(x: player.position.x, y: player.position.y - player.size.height / 2 - 15)
        
        updateHealthBar()

        cam.position = player.position
        
        let xDistance = joystickBall.position.x - joystickContainer.position.x
        let yDistance = joystickBall.position.y - joystickContainer.position.y
               
        joystickContainer.position = CGPoint(x: player.position.x, y: player.position.y - 500)
        joystickBall.position = CGPoint(x: joystickContainer.position.x + xDistance, y: joystickContainer.position.y + yDistance)
        
    }
    
    func createEnemy() {
        enemy = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 100))
        let priority = Int.random(in: 0...1)
        
        var x: Int
        var y: Int
        
        if priority == 1 {
            x = Int.random(in: 0...Int(frame.width))
            y = Int.random(in: 0...1) == 1 ? Int(frame.height + CGFloat(Int(enemy.size.height))) : 0 - Int(enemy.size.height)
        } else {
            x = Int.random(in: 0...1) == 1 ? Int(frame.width + CGFloat(Int(enemy.size.width))) : 0 - Int(enemy.size.width)
            y = Int.random(in: 0...Int(frame.height))
        }
        
        enemy.position = CGPoint(x: x, y: y)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.frame.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 2
        enemy.physicsBody?.allowsRotation = false
        enemy.zPosition = 3
        
        worldNode.addChild(enemy)
                
        enemyMove(enemy: enemy)
        

    }
    
    func createBullet() {
        let bullet : SKSpriteNode = SKSpriteNode(color: .orange, size: CGSize(width: 20, height: 20))
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = 8
        bullet.physicsBody?.contactTestBitMask = 4
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.allowsRotation = false
        bullet.zPosition = 3
        
        bullet.position = shotgun.position
        
        var force : CGVector = CGVector(dx: 0, dy: 0)
        
        force.dx = cos(angle)
        force.dy = sin(angle)
        
//        print("Angle: \(angle)")
        
        force.dx *= movementSpeed * 2
        force.dy *= movementSpeed * 2
        
        worldNode.addChild(bullet)
                
        bullet.physicsBody?.applyForce(force)
        
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
        
        //hi
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
        
        option1.position = CGPoint(x: (player.position.x - frame.width / 2) + frame.width / 6 * 1, y: (player.position.y - frame.height / 2) + frame.height / 2)
        option1.zPosition = 10
        option2.position = CGPoint(x: (player.position.x - frame.width / 2) + frame.width / 6 * 3, y: (player.position.y - frame.height / 2) + frame.height / 2)
        option2.zPosition = 10
        option3.position = CGPoint(x: (player.position.x - frame.width / 2) + frame.width / 6 * 5, y: (player.position.y - frame.height / 2) + frame.height / 2)
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
    
    func shoot() {
        let shootAction : SKAction = SKAction.run {
            if self.gameOver == false {
                self.createBullet()
            }
        }
        
        let wait : SKAction = SKAction.wait(forDuration: 3/weaponSpeed)
        
        let shootSequence : SKAction = SKAction.sequence([wait, shootAction])
        
        worldNode.run(SKAction.repeatForever(shootSequence))
    }
}
