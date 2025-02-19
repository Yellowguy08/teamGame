//
//  GameScene.swift
//  teamGame
//
//  Created by Benjamin Scotti on 2/13/25.
//

import Foundation
import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    
    var player : SKSpriteNode = SKSpriteNode()
    var levelBar : SKSpriteNode = SKSpriteNode()
    var levelLabel : SKLabelNode = SKLabelNode()
    
    var xp : Double = 0
    var level : Int = 1
    
    override func didMove(to view: SKView) {
        addChild(joystickContainer)
        addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        
        player = childNode(withName: "Player") as! SKSpriteNode
        
        levelBar = childNode(withName: "LevelBar") as! SKSpriteNode
        levelBar.color = .green
        
        levelLabel = childNode(withName: "Level") as! SKLabelNode
        levelLabel.text = "Level: \(level)"
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        self.physicsBody?.categoryBitMask = 8
        self.physicsBody?.contactTestBitMask = 2
        
        physicsWorld.contactDelegate = self
        
    }//end didmove
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == 4) {
            contact.bodyA.node?.removeFromParent()
        } else {
            contact.bodyB.node?.removeFromParent()
        }
    }
     
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            joystickBall.position = location
            createEnemy()
            xp += 100 - (Double(level) * 0.1)
        }
    }//end touches began
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            joystickBall.position = location
            
            let v = CGVector(dx: location.x - joystickContainer.position.x, dy: location.y - joystickContainer.position.y)
//            let angle =
            
        }
    }//end touches moved
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystickBall.position = CGPoint(x: frame.midX, y: frame.midY - 500)
    }//end touches ended
    
    override func update(_ currentTime: TimeInterval) {
        if (xp > 1000) {
            xp = 1000
        }
        levelBar.size.width = xp/1000 * 600
        
        if (xp == 1000) {
            level += 1
            levelLabel.text = "Level: \(level)"
            xp = 0
        }
        
    }//end update

    
    func createEnemy() {
        
        let enemy : SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        let priority = Int.random(in: 0...1)
        
        var x : Int
        var y : Int
        
        if (priority == 1) {
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
        enemy.physicsBody?.pinned = true
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 2
        
        addChild(enemy)
        enemyMove(enemy: enemy)
        
    }
    
    func enemyMove(enemy : SKSpriteNode) {
        let move : SKAction = SKAction.move(to: CGPoint(x: player.position.x, y: player.position.y), duration: 1)
        let repeatAction : SKAction = SKAction.repeatForever(move)
        enemy.run(repeatAction)
    }
    
}
