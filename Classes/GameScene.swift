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
    func didTapEvilNode()
    func didTapGoodNode()
    func didTapPlayerNode()
}

class GameScene: SKScene {
    
    private struct NodeCategories {
        let playerCategory: UInt32 = 0x1 << 1
        let evilCategory: UInt32 = 0x1 << 2
        let goodCategory : UInt32 = 0x1 << 3
        let goodEmodjiCategory : UInt32 = 0x1 << 4
        let physicalWorldCategory: UInt32 = 0x1 << 5
    }
    
    weak var gameDelegate: GameDelegate?
    
    // Public
    var gameScore: CGFloat!
    var avatarImage: UIImage!
    var goodEmojiImage: UIImage!
    var badEmojiImage: UIImage!
    var intervalForEvilNodeImpulse: TimeInterval!
    // Parameters
    private let nodeCategories = NodeCategories()
    private lazy var emojiSize: CGFloat = { return self.size.width / 10 }()
    private lazy var emojiNodeSize: CGFloat = { return self.size.width / 6 / 2 }()
    private let backgroundColorForScene = SKColor.black
    private let backgroundColorForAngelNode = UIColor(red:0.92, green:0.14, blue:0.16, alpha:1.0)
    private let backgroundColorForEvilNode = UIColor(red:0.68, green:0.31, blue:0.75, alpha:1.0)
    private lazy var playerRadius: CGFloat = { return (self.size.width / 3) / 2 }()
    private var goodNode: SKShapeNode!
    private var evilNode: SKShapeNode!
    private var playerNode: SKShapeNode!
    private var goodEmojiNode: SKShapeNode!
    
    var isFingerOnPaddle = false
    
    override func didMove(to view: SKView) {
        setupPhysicalWorld()
        setupPlayerNode()
        setupEvilNode()
        setupGoodNode()
        setupStartAnimations()
    }
    
    private func setupStartAnimations() {        
        startAnimate(nodes: [evilNode, playerNode, goodNode, goodEmojiNode], completion: {
            print("Привет")
        })
    }
    
    private func startAnimate(nodes: [SKNode], completion: @escaping ()->()) {
        let showAnimation = SKAction.fadeAlpha(by: 1.0, duration: 0.5)
        let scaleAnimation = SKAction.scale(to: 1.0, duration: 0.5)
        nodes.forEach { node in 
            node.setScale(0.1)
            node.run(showAnimation)
            node.run(scaleAnimation)
            node.physicsBody?.isDynamic = true
        }
        animateSize()
    }
    
    private func sceneSettings() {
        self.backgroundColor = backgroundColorForScene
    }
    
    private func setupPhysicalWorld() {        
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.position.x = self.size.width / 2
        gravityField.position.y = self.size.height / 2
        gravityField.strength = 30
        gravityField.minimumRadius = 1000
        gravityField.physicsBody?.friction = 0.1
        addChild(gravityField)
        
    }
    
    private func setupPlayerNode() {
        playerNode = SKShapeNode(circleOfRadius: playerRadius)
        playerNode.name = "playerNode"
        playerNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerNode.fillColor = SKColor.white
        playerNode.strokeColor = SKColor.white
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius + 1)
        playerNode.physicsBody?.categoryBitMask = nodeCategories.playerCategory
        playerNode.physicsBody?.collisionBitMask = nodeCategories.goodEmodjiCategory
        playerNode.physicsBody?.contactTestBitMask = nodeCategories.goodEmodjiCategory
        playerNode.physicsBody?.friction = 0.7
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.pinned = true
        playerNode.alpha = 0
        let playerAvatarNode = SKShapeNode(circleOfRadius: playerRadius - 5)
        playerAvatarNode.fillTexture = SKTexture(image: avatarImage)
        playerAvatarNode.fillColor = .white
        playerNode.addChild(playerAvatarNode)
        self.addChild(playerNode)
    }
    
    private func setupEvilNode() {
        let evilNodeRadius = self.frame.width / 10
        
        self.evilNode = SKShapeNode(circleOfRadius: evilNodeRadius)
        evilNode.position = CGPoint(x: self.frame.midX - 120, y: self.frame.midY)
        evilNode.name = "evilNode"
        evilNode.fillColor = backgroundColorForEvilNode
        evilNode.strokeColor = backgroundColorForEvilNode
        evilNode.physicsBody = SKPhysicsBody(circleOfRadius: evilNodeRadius + 1)
        evilNode.physicsBody?.categoryBitMask = nodeCategories.evilCategory
        evilNode.physicsBody?.collisionBitMask = nodeCategories.goodCategory
        evilNode.physicsBody?.contactTestBitMask = nodeCategories.goodCategory
        evilNode.physicsBody?.linearDamping = 0.1
        evilNode.physicsBody?.friction = 0.1
        evilNode.physicsBody?.allowsRotation = false
        evilNode.physicsBody?.restitution = 0.1
        evilNode.physicsBody?.isDynamic = false
        evilNode.alpha = 0
        
        let evilEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        evilEmojiNode.fillColor = .white
        
        let evilEmojiSprite = SKSpriteNode(texture: SKTexture(image: badEmojiImage),
                                           size: CGSize(width: emojiSize, height: emojiSize))
        
        evilNode.addChild(evilEmojiNode)
        evilEmojiNode.addChild(evilEmojiSprite)
        self.addChild(evilNode)
    }
    
    private func setupGoodNode() {
        let goodNodeRadius = self.frame.width / 10
        
        goodNode = SKShapeNode(circleOfRadius: goodNodeRadius)
        goodNode.name = "goodNode"
        goodNode.position = CGPoint(x: self.frame.midX + 120, y: self.frame.midY)
        goodNode.fillColor = backgroundColorForAngelNode
        goodNode.strokeColor = backgroundColorForAngelNode
        let goodBody = SKPhysicsBody(circleOfRadius: goodNodeRadius + 1)
        goodBody.categoryBitMask = nodeCategories.goodCategory
        goodBody.collisionBitMask = nodeCategories.evilCategory
        goodBody.contactTestBitMask = nodeCategories.evilCategory
        goodBody.linearDamping = 0.5
        goodBody.friction = 0.5
        goodBody.restitution = 0.1
        goodBody.allowsRotation = false
        goodBody.isDynamic = false
        goodNode.physicsBody = goodBody
        goodNode.zPosition = -3
        goodNode.alpha = 0
        
        self.addChild(goodNode)
        
        goodEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        goodEmojiNode.position = goodNode.position
        let goodEmodjiBody  = SKPhysicsBody(circleOfRadius: emojiNodeSize + 5)
        goodEmodjiBody.categoryBitMask = nodeCategories.goodEmodjiCategory
        goodEmodjiBody.collisionBitMask = nodeCategories.playerCategory
        goodEmodjiBody.contactTestBitMask = nodeCategories.playerCategory
        goodEmodjiBody.allowsRotation = false
        goodEmojiNode.physicsBody = goodEmodjiBody
        goodEmojiNode.alpha = 0
        
        goodEmojiNode.fillColor = .white
        goodEmojiNode.name = "goodEmojiNode"
        
        let goodEmojiSprite = SKSpriteNode(texture: SKTexture(image: goodEmojiImage),
                                           size: CGSize(width: emojiSize, height: emojiSize))
        
        goodEmojiNode.addChild(goodEmojiSprite)
        self.addChild(goodEmojiNode)
        
        let pin = SKPhysicsJointPin.joint(withBodyA: goodBody, bodyB: goodEmodjiBody,
                                          anchor: goodNode.position)
        self.physicsWorld.add(pin)
    }    
}
