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
        
    }
    
}
