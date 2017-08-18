//
//  GameScene.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

public protocol GameDelegate: class {
    func didTapInEmptyPlace()
    func didTapPlayerNode()
}

fileprivate struct PhysicsCategory {
    let playerCategory: UInt32 = 0x1 << 1
    let evilCategory: UInt32 = 0x1 << 2
    let goodCategory: UInt32 = 0x1 << 3
    let goodEmojiCategory: UInt32 = 0x1 << 4
    let physicalWorldCategory: UInt32 = 0x1 << 5
}

class GameScene: SKScene {
    
    weak var gameDelegate: GameDelegate?
    
    // Public
    var gameScore: CGFloat!
    var avatarImage: UIImage!
    var goodEmojiImage: UIImage!
    var badEmojiImage: UIImage!
    var intervalForEvilNodeImpulse: TimeInterval!
    // Parameters
    private let physicsCategory = PhysicsCategory()
    private lazy var emojiSize: CGFloat = { self.size.width / 10 }()
    private lazy var emojiNodeSize: CGFloat = { self.size.width / 6 / 2 }()
    private let backgroundColorForScene = SKColor.clear
    private let backgroundColorForAngelNode = UIColor(red: 0.92, green: 0.14, blue: 0.16, alpha: 1.0)
    private let backgroundColorForEvilNode = UIColor(red: 0.68, green: 0.31, blue: 0.75, alpha: 1.0)
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
    
    override func didMove(to _: SKView) {
        setupPhysicalWorld()
        setupLabel()
        setupPlayerNode()
        setupEvilNode()
        setupGoodNode()
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
        if powerTitleHelper < Int(gameScore) {
            powerLabel.text = "\(powerTitleHelper)%"
        } else {
            labelTimer.invalidate()
            powerLabel.text = "\(Int(powerTitleHelper))%"
        }
        powerTitleHelper += 1
    }
    
    private func setupLabel() {
        powerLabel = SKLabelNode(text: "\(Int(gameScore!))%")
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
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.position.x = self.size.width / 2
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
        playerNode.physicsBody?.friction = 0.1
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.pinned = true
        playerNode.alpha = 0
        playerNode.setScale(0.1)
        
        let playerAvatarNode = SKShapeNode(circleOfRadius: playerRadius - 5)
        playerAvatarNode.fillTexture = SKTexture(image: avatarImage)
        playerAvatarNode.fillColor = .white
        playerNode.addChild(playerAvatarNode)
        self.addChild(playerNode)
    }
    
    private func setupEvilNode() {
        let evilNodeRadius = NodeSizer.calculateSizesWidthScore(viewWidth: self.frame.width, score: gameScore).evilWidth / 2
        
        self.evilNode = SKShapeNode(circleOfRadius: evilNodeRadius)
        evilNode.position = CGPoint(x: self.frame.midX - 120, y: self.frame.midY)
        evilNode.name = "evilNode"
        evilNode.fillColor = backgroundColorForEvilNode
        evilNode.strokeColor = backgroundColorForEvilNode
        evilNode.physicsBody = SKPhysicsBody(circleOfRadius: evilNodeRadius)
        evilNode.physicsBody?.categoryBitMask = physicsCategory.evilCategory
        evilNode.physicsBody?.collisionBitMask = physicsCategory.goodCategory
        evilNode.physicsBody?.contactTestBitMask = physicsCategory.goodCategory
        evilNode.physicsBody?.linearDamping = 0.5
        evilNode.physicsBody?.friction = 0.1
        evilNode.physicsBody?.allowsRotation = false
        evilNode.physicsBody?.restitution = 0.5
        evilNode.alpha = 0
        evilNode.zPosition = -3
        evilNode.setScale(0)
        
        evilEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        evilEmojiNode.position = evilNode.position
        evilEmojiNode.lineWidth = 5
        evilEmojiNode.strokeColor = backgroundColorForEvilNode
        let evilEmojiBody = SKPhysicsBody(circleOfRadius: emojiNodeSize)
        evilEmojiBody.allowsRotation = false
        evilEmojiNode.physicsBody = evilEmojiBody
        evilEmojiNode.alpha = 0
        evilEmojiNode.setScale(0)
        evilEmojiNode.zPosition = -3
        
        evilEmojiNode.fillColor = .white
        evilEmojiNode.alpha = 0
        
        let evilEmojiSprite = SKSpriteNode(
            texture: SKTexture(image: badEmojiImage),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
        if gameScore == 50 {
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
    
    private func setupGoodNode() {
        let goodNodeRadius = NodeSizer.calculateSizesWidthScore(viewWidth: self.frame.width, score: gameScore).angelWidth / 2
        
        goodNode = SKShapeNode(circleOfRadius: goodNodeRadius)
        goodNode.name = "goodNode"
        goodNode.position = CGPoint(x: self.frame.midX + 120, y: self.frame.midY)
        goodNode.fillColor = backgroundColorForAngelNode
        goodNode.strokeColor = backgroundColorForAngelNode
        let goodBody = SKPhysicsBody(circleOfRadius: goodNodeRadius)
        goodBody.categoryBitMask = physicsCategory.goodCategory
        goodBody.collisionBitMask = physicsCategory.evilCategory
        goodBody.contactTestBitMask = physicsCategory.evilCategory
        goodBody.linearDamping = 0.5
        goodBody.friction = 0.5
        goodBody.restitution = 0.5
        goodBody.allowsRotation = false
        goodNode.physicsBody = goodBody
        goodNode.zPosition = -3
        goodNode.alpha = 0
        goodNode.setScale(0)
        
        goodEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        goodEmojiNode.position = goodNode.position
        goodEmojiNode.lineWidth = 5
        goodEmojiNode.strokeColor = backgroundColorForAngelNode
        let goodEmodjiBody = SKPhysicsBody(circleOfRadius: emojiNodeSize + 3)
        goodEmodjiBody.categoryBitMask = physicsCategory.goodEmojiCategory
        goodEmodjiBody.collisionBitMask = physicsCategory.playerCategory
        goodEmodjiBody.contactTestBitMask = physicsCategory.playerCategory
        goodEmodjiBody.allowsRotation = false
        goodEmojiNode.physicsBody = goodEmodjiBody
        goodEmojiNode.alpha = 0
        goodEmojiNode.setScale(0)
        
        goodEmojiNode.fillColor = .white
        goodEmojiNode.name = "goodEmojiNode"
        
        let goodEmojiSprite = SKSpriteNode(
            texture: SKTexture(image: goodEmojiImage),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
        if gameScore == 50 {
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
    
    var lastTouch: CGPoint?
    var touching = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            for node in nodes {
                if node == playerNode {
                    gameDelegate?.didTapPlayerNode()
                }
                
                if node.name == goodNode.name || node.name == goodEmojiNode.name {
                    lastTouch = location
                    touching = true
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        for node in self.nodes(at: location) {
            if node == goodNode {
                touching = true
            }
        }
        lastTouch = location
    }
    
    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        touching = false
        lastTouch = nil
        isFingerOnPaddle = false
    }
    
    override func update(_: TimeInterval) {
        if let touch = lastTouch {
            let impulseVector = CGVector(
                dx: touch.x - goodNode.position.x,
                dy: 0
            )
            
            goodNode.physicsBody?.applyImpulse(impulseVector)
        }
    }
}

