import Foundation
import SpriteKit
import GameplayKit
import GameController
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    let cam = SKCameraNode()

    let upgrades : [String] = ["WeaponSpeed", "MovementSpeed"]
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    let shotgun = SKSpriteNode(imageNamed: "Shotgun")
    let bulletLifetime: Double = 1.5

    var startedClickInCircle: Bool = false
    
    var ZombieWalkTextures: [SKTexture] = []
    var gameOver : Bool =  false
    var gameStarted : Bool = false
    let maxEnemies = 50 // change for increased difficulty
    
    var levelBar : SKSpriteNode = SKSpriteNode()
    var levelLabel : SKLabelNode = SKLabelNode()
    var backgroundBar : SKSpriteNode = SKSpriteNode()
    
    var worldBorder : SKSpriteNode = SKSpriteNode()
    
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
    var health: CGFloat = 100
    
    var globalTouchLocation: CGPoint = .zero
    
    var movementDirection: CGPoint = .zero
    var upgradeOptions : [SKSpriteNode] = []
    
    var selectUpgrade : Bool = false
    
    // Upgrades
    var weaponSpeed : Double = 5.00
    var weaponDamage : Double = 10.00
    var movementSpeed : CGFloat = 200
    var spread : Int = 1
    
    var enemies : [SKSpriteNode] = []
    
    
    override func didMove(to view: SKView) {
        addChild(cam)
        self.camera = cam //COMMENT THIS OUT TO TURN CAMERA OFF

        for i in 1...8 {
            ZombieWalkTextures.append(SKTexture(imageNamed: "ZombieWalk\(i)"))
        }
        
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
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
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

        
        backgroundBar = childNode(withName: "backgroundBar") as! SKSpriteNode
        backgroundBar.zPosition = 2
//        levelBar.color = .green
        
        worldBorder = childNode(withName: "WorldBorder") as! SKSpriteNode
        
        levelBar = childNode(withName: "LevelBar") as! SKSpriteNode
        levelBar.zPosition = 3
//        levelBar.color = .green
        
        levelLabel = childNode(withName: "Level") as! SKLabelNode
        levelLabel.text = "Level: \(level)"
        
        
//        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.physicsBody = border
//        self.physicsBody?.categoryBitMask = 8
//        self.physicsBody?.contactTestBitMask = 2
 

        shoot()
        
        let healAction = SKAction.run(healPlayer)
        let waitToHeal = SKAction.wait(forDuration: 20) // time b4 heal
        let healSequence = SKAction.sequence([healAction, waitToHeal])
        let repeatHeal = SKAction.repeatForever(healSequence)
        self.run(repeatHeal)


        physicsWorld.contactDelegate = self
        let spawnAction = SKAction.run(spawnEnemy)
            let waitAction = SKAction.wait(forDuration: 2) // Adjust to control spawn rate
            let spawnSequence = SKAction.sequence([spawnAction, waitAction])
            let repeatSpawn = SKAction.repeatForever(spawnSequence)
            worldNode.run(repeatSpawn)
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
                joystickBall.removeFromParent()
                joystickContainer.removeFromParent()
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
        
        else if (bodyA.categoryBitMask == 8 && bodyB.categoryBitMask == 4) ||
                (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 8) {
            
            print("Bullet-Enemy Contact Detected")
            if bodyA.categoryBitMask == 8 { bodyA.node?.removeFromParent() }
            if bodyB.categoryBitMask == 8 { bodyB.node?.removeFromParent() }
            if bodyA.categoryBitMask == 4 { bodyA.node?.removeFromParent() }
            if bodyB.categoryBitMask == 4 { bodyB.node?.removeFromParent() }
            cleanupEnemies()
            xp += 100
            print("XP Gained: \(xp)")
        }
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
                    let vector = CGVector(dx: joystickBall.position.x - joystickContainer.position.x, dy: joystickBall.position.y - joystickContainer.position.y)
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
            health += 25
        }
        
        _ = CGFloat(currentTime)
//        let movement = CGVector(dx: movementDirection.x * movementSpeed, dy: movementDirection.y * movementSpeed)

        player.position = CGPoint(x: player.position.x + movement.dx, y: player.position.y + movement.dy)
        
        //border
        player.position.x = max(min(player.position.x, worldBorder.frame.maxX - player.size.width / 2), worldBorder.frame.minX + player.size.width / 2)
        player.position.y = max(min(player.position.y, worldBorder.frame.maxY - player.size.height / 2), worldBorder.frame.minY + player.size.height / 2)
        
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
       
        if gameOver == true {
            worldNode.isPaused = true
            physicsWorld.speed = 1
        }
        
        shotgun.position = CGPoint(x: player.position.x, y: player.position.y)
        angle = atan2(movement.dy, movement.dx)
                
        if (angle > (Double.pi / 2) || angle < -(Double.pi / 2)) {
            shotgun.yScale = -1
        } else {
            shotgun.yScale = 1
        }
        
        worldNode.enumerateChildNodes(withName: "bullet") { (node, stop) in
                    if let bullet = node as? SKSpriteNode {
                        self.updateBulletTracking(bullet: bullet)
                    }
                }
        
        shotgun.zRotation = angle
        
        healthBarBackground.position = CGPoint(x: player.position.x, y: player.position.y - player.size.height / 2 - 15)
        
        updateHealthBar()

        cam.position = player.position
        
        let xDistance = joystickBall.position.x - joystickContainer.position.x
        let yDistance = joystickBall.position.y - joystickContainer.position.y
               
        joystickContainer.position = CGPoint(x: player.position.x, y: player.position.y - 500)
        joystickBall.position = CGPoint(x: joystickContainer.position.x + xDistance, y: joystickContainer.position.y + yDistance)
        
        levelBar.position = CGPoint(x: player.position.x, y: player.position.y + 600)
        backgroundBar.position = CGPoint(x: player.position.x, y: player.position.y + 600)
        
    }
    
    func cleanupEnemies() {
        enemies = enemies.filter {
            $0.parent != nil  // Only keep enemies still in the scene
        }
    }

    
    func createEnemy() {
        guard enemies.count < maxEnemies else {
                print("Max enemies reached (\(maxEnemies))")
                return
            }
        
        let enemy: SKSpriteNode = SKSpriteNode(imageNamed: "ZombieWalk1")
        
        enemy.size = CGSize(width: player.size.width + 35, height: player.size.height + 20)
        
        let priority = Int.random(in: 0...1)
        
        var x: Int
        var y: Int
        
        let userX : Double = player.position.x - frame.width / 2
        let userY : Double = player.position.y - frame.height / 2
        
        if priority == 1 {
            x = Int.random(in: 0...Int(frame.width))
            y = Int.random(in: 0...1) == 1 ? Int(frame.height + CGFloat(Int(enemy.size.height))) : 0 - Int(enemy.size.height)
        } else {
            x = Int.random(in: 0...1) == 1 ? Int(frame.width + CGFloat(Int(enemy.size.width))) : 0 - Int(enemy.size.width)
            y = Int.random(in: 0...Int(frame.height))
        }
        
        enemy.position = CGPoint(x: userX + Double(x), y: userY + Double(y))
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.frame.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 2
        enemy.physicsBody?.allowsRotation = false
        enemy.zPosition = 3
        
        worldNode.addChild(enemy)
                
        enemyMove(enemy: enemy)
        
        let zombieAnimation = SKAction.animate(withNormalTextures: ZombieWalkTextures, timePerFrame: 0.1)
        enemy.run(SKAction.repeatForever(zombieAnimation))
    }

    
    func createBullet() {
        let bullet : SKSpriteNode = SKSpriteNode(imageNamed: "Bullet")
        
        bullet.size = CGSize(width: 20, height: 40)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = 8
        bullet.physicsBody?.contactTestBitMask = 4
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.linearDamping = 0.5
        bullet.zPosition = 3
        bullet.position = shotgun.position
        bullet.zRotation = shotgun.zRotation
        
        var force : CGVector = CGVector(dx: 0, dy: 0)
        
        force.dx = cos(angle)
        force.dy = sin(angle)
        
//        print("Angle: \(angle)")
        
        force.dx *= movementSpeed * 120
        force.dy *= movementSpeed * 120
        
        worldNode.addChild(bullet)
        bullet.name = "bullet"

        let angle = shotgun.zRotation
        let bulletSpeed: CGFloat = 200
        let bulletVelocity = CGVector(
            dx: cos(angle) * bulletSpeed + movement.dx,
            dy: sin(angle) * bulletSpeed + movement.dy
        )
        bullet.physicsBody?.velocity = bulletVelocity

        bullet.run(SKAction.sequence([
            SKAction.wait(forDuration: bulletLifetime),
            SKAction.removeFromParent()
        ]))
    }


    
    func updateBulletTracking(bullet: SKSpriteNode) {
        guard let closestEnemy = findClosestEnemy(to: bullet.position) else { return }
        
        let distance = bullet.position.distance(to: closestEnemy.position)
        let maxTrackingDistance: CGFloat = 300 // Pixels
        
        if distance < maxTrackingDistance {
            let dx = closestEnemy.position.x - bullet.position.x
            let dy = closestEnemy.position.y - bullet.position.y
            let angle = atan2(dy, dx)
            
            let trackingSpeed: CGFloat = 20
            let forceX = cos(angle) * trackingSpeed
            let forceY = sin(angle) * trackingSpeed
            
            bullet.physicsBody?.applyForce(CGVector(dx: forceX, dy: forceY))
            bullet.zRotation = angle
        }
    }

    func healPlayer() {
        health = min(health + 5, 100)
        updateHealthBar()
    }
    
    func findClosestEnemy(to position: CGPoint) -> SKSpriteNode? {
            var closestEnemy: SKSpriteNode?
            var closestDistance: CGFloat = .infinity

            for node in worldNode.children {
                if let enemy = node as? SKSpriteNode, enemy != player, enemy.physicsBody?.categoryBitMask == 4 { // Check if it's an enemy
                    let distance = position.distance(to: enemy.position)
                    if distance < closestDistance {
                        closestDistance = distance
                        closestEnemy = enemy
                    }
                }
            }
            return closestEnemy
        }

    func upgrade(upgradeName : String) {
        switch (upgradeName) {
        case "WeaponSpeed":
            weaponSpeed += 100.00
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
    
    func spawnEnemy() {
        
        
        let spawn : SKAction = SKAction.run {
            if (!self.gameOver) {
                self.createEnemy()
            }
        }
        
        let wait : SKAction = SKAction.wait(forDuration: 2, withRange: 1)
        
        let sequence : SKAction = SKAction.sequence([wait, spawn])
        
        worldNode.run(SKAction.repeatForever(sequence))
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
        let colorDuration: TimeInterval = 1.0 // Duration for each color transition
        let waitDuration: TimeInterval = 0.1

        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        var actions: [SKAction] = []

        for (index, color) in colors.enumerated() {
            _ = colors[(index + 1) % colors.count]
            let colorize = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: colorDuration)
            let wait = SKAction.wait(forDuration: waitDuration)
            
            actions.append(colorize)
            actions.append(wait)
        }

        let sequence = SKAction.sequence(actions)
        let rpeat = SKAction.repeatForever(sequence)
        
        levelBar.run(rpeat)
    }
    
    func viewUpgrades() {
                
        let upgrades = self.upgrades
        
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
            upgradeOptions[i].addChild(label)
//            print(label.text)
            label.fontColor = .black
            label.name = "label"
            label.zPosition = 11
        }
        
    }
    
    func getWait() -> SKAction{
        let wait : SKAction = SKAction.wait(forDuration: 3 / self.weaponSpeed)
        return wait
    }
    
    func shoot() {
        let shootAction: SKAction = SKAction.run {
            if !self.gameOver && self.startedClickInCircle && self.movementDirection != .zero {
                self.createBullet()
            }
        }
        
        let wait: SKAction = SKAction.wait(forDuration: 3 / weaponSpeed)
        let shootSequence: SKAction = SKAction.sequence([wait, shootAction])
        worldNode.run(SKAction.repeatForever(shootSequence))
    }


}
