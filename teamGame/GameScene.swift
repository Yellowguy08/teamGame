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
    var joystickBase: SKSpriteNode!
    var joystickThumb: SKSpriteNode!
    var joystickRadius: CGFloat = 100
    var movementDirection: CGPoint = .zero
    
    override func didMove(to view: SKView) {
        joystickBase = SKSpriteNode(color: .gray, size: CGSize(width: joystickRadius * 2, height: joystickRadius * 2))
        joystickBase.position = CGPoint(x: joystickRadius + 20, y: joystickRadius + 20)
        addChild(joystickBase)
        
        joystickThumb = SKSpriteNode(color: .darkGray, size: CGSize(width: 50, height: 50))
        joystickThumb.position = joystickBase.position
        addChild(joystickThumb)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let distance = hypot(touchLocation.x - joystickBase.position.x, touchLocation.y - joystickBase.position.y)
        
        if distance <= joystickRadius {
            joystickThumb.position = touchLocation
        } else {
            let angle = atan2(touchLocation.y - joystickBase.position.y, touchLocation.x - joystickBase.position.x)
            joystickThumb.position = CGPoint(x: joystickBase.position.x + cos(angle) * joystickRadius, y: joystickBase.position.y + sin(angle) * joystickRadius)
        }
        
        movementDirection = CGPoint(x: joystickThumb.position.x - joystickBase.position.x, y: joystickThumb.position.y - joystickBase.position.y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        print("Movement direction: \(movementDirection)")
    }
}

