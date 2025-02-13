//
//  GameScene.swift
//  teamGame
//
//  Created by Benjamin Scotti on 2/13/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        createEnemy()
    }
    
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
