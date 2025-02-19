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
    var startedClickInCircle: Bool = false
    
    override func didMove(to view: SKView) {
        addChild(joystickContainer)
        addChild(joystickBall)
        
        joystickContainer.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        joystickBall.position = joystickContainer.position
        
    }//end didmove
     
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
        }
    }//end touches began
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateJoystickBallPosition(touches: touches)
    }//end touches moved
    
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
        
    }//end create enemy
    
    func enemyMove(enemy : SKSpriteNode) {
        let move : SKAction = SKAction.move(to: CGPoint(x: Int.random(in: 0...Int(frame.width)), y: Int.random(in: 0...Int(frame.height))), duration: 1)
        let repeatAction : SKAction = SKAction.repeatForever(move)
        enemy.run(repeatAction)
    }//end enemy move
    
}
