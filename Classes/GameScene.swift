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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private struct NodeCategories {
        let playerCategory: UInt32 = 0x1 << 1
        let evilCategory: UInt32 = 0x1 << 2
        let goodCategory : UInt32 = 0x1 << 3
        let goodEmodjiCategory : UInt32 = 0x1 << 4
    }
    
    // Public
    var gameScore: CGFloat!
    var avatarImage: UIImage!
    var goodEmojiImage: UIImage!
    var badEmojiImage: UIImage!
    var intervalForEvilNodeImpulse: TimeInterval!
    // Parameters
    private let nodeCategories = NodeCategories()
    private lazy var emojiSize: CGFloat = { return self.view!.frame.size.width / 10 }()
    private lazy var emojiNodeSize: CGFloat = { return self.view!.frame.size.width / 6 / 2 }()
    private let backgroundColorForScene = UIColor.red
    private let backgroundColorForAngelNode = UIColor.yellow
    private let backgroundColorForEvilNode = UIColor.blue
    private lazy var playerRadius: CGFloat = { return (self.view!.frame.size.width / 3) / 2 }()
    private var goodNode: SKShapeNode!
    private var evilNode: SKShapeNode!
    
    var isFingerOnPaddle = false
    
    override func didMove(to view: SKView) {
        setupPhysicalWorld()
        setupPlayerNode()
        setupEvilNode()
        setupGoodNode()
        
        sceneSettings()
        setupEvilImpulse()
        
        physicsWorld.contactDelegate = self
    }
    
    private func setupEvilImpulse() {
        Timer.scheduledTimer(
            timeInterval: intervalForEvilNodeImpulse,
            target: self,
            selector: #selector(impulseEvilNode),
            userInfo: nil,
            repeats: true)
    }
    
    private func sceneSettings() {
        self.backgroundColor = backgroundColorForScene
    }
    
    private func setupPhysicalWorld() {
        // TODO: - нужно оттестировать
        let physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = physicsBody
        self.physicsBody!.friction = 0.3
        self.name = "sceneBody"
        self.physicsBody?.categoryBitMask = nodeCategories.goodCategory
        self.physicsBody?.collisionBitMask = nodeCategories.evilCategory
        self.physicsBody?.contactTestBitMask = nodeCategories.playerCategory
        
        // Gravity in center
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.position.x = self.size.width / 2
        gravityField.position.y = self.size.height / 2
        gravityField.strength = 30
        gravityField.minimumRadius = 600
        gravityField.physicsBody?.friction = 0.1
        addChild(gravityField)
        
    }
    
    private func setupPlayerNode() {
        let playerNode = SKShapeNode(circleOfRadius: playerRadius)
        playerNode.name = "playerNode"
        playerNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerNode.fillColor = SKColor.white
        playerNode.strokeColor = SKColor.white
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
        playerNode.physicsBody?.categoryBitMask = nodeCategories.playerCategory
        playerNode.physicsBody?.collisionBitMask = nodeCategories.goodEmodjiCategory
        playerNode.physicsBody?.contactTestBitMask = nodeCategories.goodEmodjiCategory
        playerNode.physicsBody?.friction = 0.7
        playerNode.physicsBody?.isDynamic = false
        let playerAvatarNode = SKShapeNode(circleOfRadius: playerRadius - 5)
        playerAvatarNode.fillTexture = SKTexture(image: avatarImage)
        playerAvatarNode.fillColor = .white
        playerNode.addChild(playerAvatarNode)
        self.addChild(playerNode)
    }
    
    private func setupEvilNode() {
        let evilNodeRadius = NodeSizer.calculateSizesWidthScore(
            viewWidth: self.view!.frame.width, score: gameScore).evilWidth / 2
        
        self.evilNode = SKShapeNode(circleOfRadius: evilNodeRadius)
        evilNode.position = CGPoint(x: self.frame.midX - 100, y: self.frame.midY + 150)
        evilNode.name = "evilNode"
        evilNode.fillColor = backgroundColorForEvilNode
        evilNode.strokeColor = backgroundColorForEvilNode
        evilNode.physicsBody = SKPhysicsBody(circleOfRadius: evilNodeRadius)
        evilNode.physicsBody?.categoryBitMask = nodeCategories.evilCategory
        evilNode.physicsBody?.collisionBitMask = nodeCategories.goodCategory
        evilNode.physicsBody?.contactTestBitMask = nodeCategories.goodCategory
        evilNode.physicsBody?.linearDamping = 0.7
        evilNode.physicsBody?.friction = 0.9
        evilNode.physicsBody?.allowsRotation = false
        evilNode.physicsBody?.restitution = 0.1
        
        let evilEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        evilEmojiNode.fillColor = .white
        
        let evilEmojiSprite = SKSpriteNode(texture: SKTexture(image: badEmojiImage),
                                           size: CGSize(width: emojiSize, height: emojiSize))
        
        evilNode.addChild(evilEmojiNode)
        evilEmojiNode.addChild(evilEmojiSprite)
        self.addChild(evilNode)
    }
    
    private func setupGoodNode() {
        let goodNodeRadius = NodeSizer.calculateSizesWidthScore(
            viewWidth: self.view!.frame.width, score: gameScore).angelWidth / 2
        
        goodNode = SKShapeNode(circleOfRadius: goodNodeRadius)
        goodNode.name = "goodNode"
        goodNode.position = CGPoint(x: self.frame.midX + 30, y: self.frame.midY - 50)
        goodNode.fillColor = backgroundColorForAngelNode
        goodNode.strokeColor = backgroundColorForAngelNode
        let goodBody = SKPhysicsBody(circleOfRadius: goodNodeRadius)
        goodBody.categoryBitMask = nodeCategories.goodCategory
        goodBody.collisionBitMask = nodeCategories.evilCategory
        goodBody.contactTestBitMask = nodeCategories.evilCategory
        goodBody.linearDamping = 0.1
        goodBody.friction = 0.1
        goodBody.allowsRotation = false
        goodNode.physicsBody = goodBody
        goodNode.zPosition = -3
        
        self.addChild(goodNode)
        
        let goodEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        goodEmojiNode.position = goodNode.position
        let goodEmodjiBody  = SKPhysicsBody(circleOfRadius: emojiNodeSize + 1)
        goodEmodjiBody.categoryBitMask = nodeCategories.goodEmodjiCategory
        goodEmodjiBody.collisionBitMask = nodeCategories.playerCategory
        goodEmodjiBody.contactTestBitMask = nodeCategories.playerCategory
        goodEmodjiBody.allowsRotation = false
        goodBody.linearDamping = 0.1
        goodBody.friction = 0.1
        goodEmojiNode.physicsBody = goodEmodjiBody
        
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
    
    var touchLocation = CGPoint()
    var touching = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            touchLocation = location
            
            for node in nodes {
                
                if node.name == "evilNode" {
                    break
                }
                
                if node.name == "goodEmojiNode" {
                    if #available(iOS 10.0, *) {
                        impulseNode(goodNode, to: evilNode)
                    }
                    break
                }
                
                if node.name == "playerNode" {
                    showInfoAlert()
                    break
                }
                
                if node.name == "goodNode" {
                    touchLocation = location
                    touching = true
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchLocation = location
        for node in self.nodes(at: location) {
            if node.name == "goodNode" {
                touching = true
                touchLocation = location
                goodNode.position = location
                isFingerOnPaddle = true
                changeDynamicForNodes([goodNode], value: false)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false
        let touch = touches.first!
        let location = touch.location(in: self)
        changeDynamicForNodes([goodNode], value: true)
        touchLocation = location
        isFingerOnPaddle = false
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    private func showInfoAlert() {
        let alert = UIAlertController(title: "Информация", message: "Аватарка нажата",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.view?.window?.rootViewController?.present(alert, animated: true,
                                                       completion: nil)
    }
    
    private func changeDynamicForNodes(_ nodes: [SKNode], value: Bool) {
        nodes.forEach {  $0.physicsBody!.isDynamic = value }
    }
    
    @objc private func impulseEvilNode() {
        if #available(iOS 10.0, *) {
            impulseNode(evilNode, to: goodNode)
        }
    }
    
    @available(iOS 10.0, *)
    private func impulseNode(_ nodeA: SKNode, to nodeB: SKNode) {
        if !isFingerOnPaddle {
            let scale = SKAction.scale(by: 1.2, duration: 0.2)
            let reScale = SKAction.scale(to: nodeA.frame.size, duration: 0.2)
            nodeA.run(scale, completion: { _ in 
                let playerNode = self.childNode(withName: "playerNode")!
                let impulseVector = CGVector(
                    dx: playerNode.position.x - nodeA.position.x,
                    dy: playerNode.position.y - nodeA.position.y)
                nodeA.physicsBody?.applyImpulse(impulseVector)
                nodeA.run(reScale)
            })
        }
    }
}
