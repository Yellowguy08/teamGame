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

class GameScene: SKScene {
    
    let joystickContainer = SKSpriteNode(imageNamed: "joystickContainer")
    let joystickBall = SKSpriteNode(imageNamed: "joystickBall")
    
    override func didMove(to view: SKView) {
        addChild(joystickContainer)
        addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        
    }//end didmove
     
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            joystickBall.position = location
            createEnemy()
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
        
        addChild(enemy)
        enemyMove(enemy: enemy)
        
    }
    
    func enemyMove(enemy : SKSpriteNode) {
        let move : SKAction = SKAction.move(to: CGPoint(x: Int.random(in: 0...Int(frame.width)), y: Int.random(in: 0...Int(frame.height))), duration: 1)
        let repeatAction : SKAction = SKAction.repeatForever(move)
        enemy.run(repeatAction)
    }
    
}
