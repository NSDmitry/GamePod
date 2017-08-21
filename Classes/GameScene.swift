//
//  GameScene.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import SpriteKit
import Foundation

public class GameScene: SKScene {
    
    weak public var gameDelegate: GameDelegate?
    
    // Public
    public var settings: GameSettings!
    // Parameters
    private let physicsCategory = PhysicsCategory()
    private lazy var emojiSize: CGFloat = { self.size.width / 10 }()
    private lazy var emojiNodeSize: CGFloat = { self.size.width / 6 / 2 }()
    private let backgroundColorForScene = SKColor.clear
    private let goodNodeColor = UIColor.goodNode
    private let evilNodeColor = UIColor.evilNode
    private lazy var playerRadius: CGFloat = { (self.size.width / 3) / 2 }()
    private var goodNode: SKShapeNode!
    private var evilNode: SKShapeNode!
    private var evilEmojiNode: SKShapeNode!
    private var playerNode: SKShapeNode!
    private var goodEmojiNode: SKShapeNode!
    private var powerLabel: SKLabelNode!
    private var infoLabel: SKLabelNode!
    private var powerTitleHelper: Int = 0
    private var labelTimer: Timer!
    
    var isFingerOnPaddle = false
    
    override public func didMove(to _: SKView) {
        setupPhysicalWorld()
        setupLabel()
        setupPlayerNode()
        let sizes = NodeSizer.calculate(viewWidth: self.frame.width, score: settings.score.value)
        setupEvilNode(radius: sizes.evilRadius)
        setupGoodNode(radius: sizes.angelRadius)
        animateNodes()
    }
    
    func animateNodes() {
        let nodes = [evilEmojiNode, playerNode, goodEmojiNode]
        
        for (index, node) in nodes.enumerated() {
            let delayAction = SKAction.wait(forDuration: TimeInterval(index) * 0.4)
            let showAction = SKAction.fadeAlpha(by: 1.0, duration: 0.5)
            let rescaleAction = SKAction.scale(to: 1.0, duration: 0.4)
            let waitAction = SKAction.wait(forDuration: 0.1)
            
            let actionsSequence = SKAction.sequence([delayAction, rescaleAction, showAction, waitAction])
            node!.run(actionsSequence, completion: {
                if nodes.last! == node {
                    self.scaleNodes()
                }
            })
        }
    }
    
    func scaleNodes() {
        let gravityWorld = self.childNode(withName: "gravityWorld")! as! SKFieldNode
        gravityWorld.isEnabled = true
        
        let nodes = [evilNode, goodNode]
        let showAction = SKAction.fadeAlpha(by: 1.0, duration: 0.3)
        let anotherAction = SKAction.scale(to: 1.3, duration: 0.4)
        let changeSizeAction = SKAction.scale(to: 1.0, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.1)
        
        let group = SKAction.sequence([wait, showAction, anotherAction, changeSizeAction])
        
        nodes.forEach { node in
            node?.run(group)
        }
        
        let showLabel = SKAction.fadeAlpha(by: 1.0, duration: 0.3)
        powerLabel.run(showLabel)
        infoLabel.run(showLabel)
        
        labelTimer = Timer.scheduledTimer(
            timeInterval: 0.02,
            target: self,
            selector: #selector(changePowerTitle),
            userInfo: nil,
            repeats: true
        )
    }
    
    func changePowerTitle() {
        if powerTitleHelper < Int(settings.score.value) {
            powerLabel.text = "\(powerTitleHelper)%"
        } else {
            labelTimer.invalidate()
            powerLabel.text = "\(Int(powerTitleHelper))%"
        }
        powerTitleHelper += 1
    }
    
    private func setupLabel() {
        powerLabel = SKLabelNode(text: "\(Int(settings.score.value))%")
        powerLabel.color = UIColor.white
        powerLabel.name = "powerLabel"
        powerLabel.fontSize = 27
        powerLabel.horizontalAlignmentMode = .center
        powerLabel.position = CGPoint(x: self.frame.width / 2, y: 40)
        powerLabel.alpha = 0
        
        infoLabel = SKLabelNode(text: "ПАТИ-АНГЕЛ")
        infoLabel.color = UIColor.white
        infoLabel.fontSize = 18
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.position = CGPoint(x: self.frame.width / 2, y: powerLabel.position.y - powerLabel.frame.height)
        infoLabel.alpha = 0
        
        self.addChild(infoLabel)
        self.addChild(powerLabel)
    }
    
    private func setupPhysicalWorld() {
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.position.x = self.size.width / 2
        gravityField.name = "gravityField"
        gravityField.position.y = self.size.height / 2
        gravityField.strength = 100
        gravityField.minimumRadius = 1000
        gravityField.physicsBody?.friction = 0.1
        gravityField.name = "gravityWorld"
        gravityField.isEnabled = false
        addChild(gravityField)
        
    }
    
    private func setupPlayerNode() {
        playerNode = SKShapeNode(circleOfRadius: playerRadius)
        playerNode.name = "playerNode"
        playerNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerNode.fillColor = SKColor.white
        playerNode.strokeColor = SKColor.white
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius + 1)
        playerNode.physicsBody?.categoryBitMask = physicsCategory.playerCategory
        playerNode.physicsBody?.collisionBitMask = physicsCategory.goodEmojiCategory
        playerNode.physicsBody?.contactTestBitMask = physicsCategory.goodEmojiCategory
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.pinned = true
        playerNode.alpha = 0
        playerNode.setScale(0.1)
        
        let playerAvatarNode = SKShapeNode(circleOfRadius: playerRadius - 5)
        playerAvatarNode.fillTexture = SKTexture(image: settings.playerImage)
        playerAvatarNode.fillColor = .white
        playerNode.addChild(playerAvatarNode)
        self.addChild(playerNode)
    }
    
    private func setupEvilNode(radius: CGFloat) {        
        self.evilNode = SKShapeNode(circleOfRadius: radius)
        evilNode.position = CGPoint(x: self.frame.midX - 120, y: self.frame.midY)
        evilNode.name = "evilNode"
        evilNode.fillColor = evilNodeColor
        evilNode.strokeColor = evilNodeColor
        evilNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        evilNode.physicsBody?.categoryBitMask = physicsCategory.evilCategory
        evilNode.physicsBody?.collisionBitMask = physicsCategory.goodCategory
        evilNode.physicsBody?.contactTestBitMask = physicsCategory.goodCategory
        evilNode.physicsBody?.allowsRotation = false
        evilNode.physicsBody?.restitution = 0.3
        evilNode.alpha = 0
        evilNode.zPosition = -3
        evilNode.setScale(0)
        evilNode.physicsBody?.allowsRotation = true
        
        evilEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        evilEmojiNode.position = evilNode.position
        evilEmojiNode.lineWidth = 4
        evilEmojiNode.strokeColor = evilNodeColor
        let evilEmojiBody = SKPhysicsBody(circleOfRadius: emojiNodeSize + 3)
        evilEmojiBody.allowsRotation = false
        evilEmojiNode.physicsBody = evilEmojiBody
        evilEmojiNode.alpha = 0
        evilEmojiNode.setScale(0)
        evilEmojiNode.zPosition = -3
        evilEmojiBody.restitution = 0.1
        
        evilEmojiNode.fillColor = .white
        evilEmojiNode.alpha = 0
        
        let evilEmojiSprite = SKSpriteNode(
            texture: SKTexture(image: settings.evilNodeImage),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
        if settings.score.value == 50 {
            evilNode.physicsBody?.mass = 2
            evilEmojiNode.physicsBody?.mass = 2
        }
        
        self.addChild(evilNode)
        evilEmojiNode.addChild(evilEmojiSprite)
        self.addChild(evilEmojiNode)
        
        let pin = SKPhysicsJointPin.joint(
            withBodyA: evilNode.physicsBody!,
            bodyB: evilEmojiBody,
            anchor: evilNode.position
        )
        
        self.physicsWorld.add(pin)
    }
    
    private func setupGoodNode(radius: CGFloat) {
        goodNode = SKShapeNode(circleOfRadius: radius)
        goodNode.name = "goodNode"
        goodNode.position = CGPoint(x: self.frame.midX + 120, y: self.frame.midY)
        goodNode.fillColor = goodNodeColor
        goodNode.strokeColor = goodNodeColor
        let goodBody = SKPhysicsBody(circleOfRadius: radius)
        goodBody.categoryBitMask = physicsCategory.goodCategory
        goodBody.collisionBitMask = physicsCategory.evilCategory
        goodBody.contactTestBitMask = physicsCategory.evilCategory
        goodBody.restitution = 0.3
        goodBody.allowsRotation = false
        goodNode.physicsBody = goodBody
        goodNode.zPosition = -3
        goodNode.alpha = 0
        goodNode.setScale(0)
        
        goodEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        goodEmojiNode.position = goodNode.position
        goodEmojiNode.lineWidth = 4
        goodEmojiNode.name = "goodEmojiNode"
        goodEmojiNode.strokeColor = goodNodeColor
        let goodEmodjiBody = SKPhysicsBody(circleOfRadius: emojiNodeSize + 3)
        goodEmodjiBody.categoryBitMask = physicsCategory.goodEmojiCategory
        goodEmodjiBody.collisionBitMask = physicsCategory.playerCategory
        goodEmodjiBody.contactTestBitMask = physicsCategory.playerCategory
        goodEmodjiBody.allowsRotation = false
        goodEmodjiBody.restitution = 0.05
        goodEmojiNode.physicsBody = goodEmodjiBody
        goodEmojiNode.alpha = 0
        goodEmojiNode.setScale(0)
        
        goodEmojiNode.fillColor = .white
        goodEmojiNode.name = "goodEmojiNode"
        
        let goodEmojiSprite = SKSpriteNode(
            texture: SKTexture(image: settings.goodNodeImage),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
        if settings.score.value == 50 {
            goodNode.physicsBody?.mass = 2
            goodEmojiNode.physicsBody?.mass = 2
        }
        
        self.addChild(goodNode)
        goodEmojiNode.addChild(goodEmojiSprite)
        self.addChild(goodEmojiNode)
        
        let pin = SKPhysicsJointPin.joint(
            withBodyA: goodBody,
            bodyB: goodEmodjiBody,
            anchor: goodNode.position
        )
        self.physicsWorld.add(pin)
    }
    
    var movableNode : SKNode?
    var ballStartX: CGFloat = 0.0
    var ballStartY: CGFloat = 0.0
    
    override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node == playerNode {
                    gameDelegate?.didTapPlayerNode()
                    break
                }
                
                if node.name == goodNode.name || node.name == goodEmojiNode.name {
                    movableNode = goodNode
                    ballStartX =  (movableNode?.position.x)! - location.x
                    ballStartY = goodNode.position.y      
                    return
                } 
            }
            gameDelegate?.didTapInEmptyPlace()
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            let newPostion = CGPoint(
                x: max(playerNode.frame.maxX + goodEmojiNode.frame.size.width / 2, location.x + ballStartX), 
                y: goodNode.position.y)
            let action = SKAction.move(to: newPostion, duration: 0.1)
            goodNode.run(action)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first, movableNode != nil {
            movableNode = nil
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            movableNode = nil
        }
    }
}
