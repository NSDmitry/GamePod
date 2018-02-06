//
//  GameScene.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import SpriteKit
import Foundation

protocol GameDelegate: class {
    //    func didTapInEmptyPlace()
    func didTapPlayerNode()
    func didTapOnGood()
    func didTapOnEvil()
    func didAppear()
}

private struct PhysicsCategory {
    static let playerCategory: UInt32 = 0x1 << 1
    static let evilCategory: UInt32 = 0x1 << 2
    static let goodCategory: UInt32 = 0x1 << 3
    static let goodEmojiCategory: UInt32 = 0x1 << 4
    static let physicalWorldCategory: UInt32 = 0x1 << 5
}

class GameScene: SKScene {
    
    weak var gameDelegate: GameDelegate?
    var userAvatar: UIImage = #imageLiteral(resourceName: "0027_ava_empty_") {
        didSet {
            playerAvatarNode.fillTexture = SKTexture(image: userAvatar)
        }
    }
    var score: CGFloat = 0
    
    struct Colors {
        static let goodNode = UIColor(red: 0.92, green: 0.14, blue: 0.16, alpha: 1.0)
        static let evilNode = UIColor(red: 0.68, green: 0.31, blue: 0.75, alpha: 1.0)
    }
    // Parameters
    
    private lazy var emojiSize: CGFloat = { self.size.width / 10 }()
    private lazy var emojiNodeSize: CGFloat = { self.size.width / 6 / 2 }()
    
    private var goodNode: SKShapeNode!
    private var evilNode: SKShapeNode!
    private var evilEmojiNode: SKShapeNode!
    private var playerNode: SKShapeNode!
    private var goodEmojiNode: SKShapeNode!
    private var playerAvatarNode: SKShapeNode!
    
    override func didMove(to _: SKView) {
        setupPhysicalWorld()
        setupPlayerNode()
        
    }
    
    func setup(score: CGFloat) {
        self.score = score
        let sizes = NodeSizer.calculate(viewWidth: self.frame.width, score: score)
        setupEvilNode(radius: sizes.evilRadius)
        setupGoodNode(radius: sizes.angelRadius)
        animateNodes()
    }
    
    private func animateNodes() {
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
                    self.gameDelegate?.didAppear()
                }
            })
        }
    }
    
    private func scaleNodes() {
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
        let playerRadius: CGFloat = { (self.size.width / 3) / 2 }()
        playerNode = SKShapeNode(circleOfRadius: playerRadius)
        playerNode.name = "playerNode"
        playerNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerNode.fillColor = SKColor.white
        playerNode.strokeColor = SKColor.white
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius + 1)
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.playerCategory
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.goodEmojiCategory
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.goodEmojiCategory
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.pinned = true
        playerNode.alpha = 0
        playerNode.setScale(0.1)
        
        playerAvatarNode = SKShapeNode(circleOfRadius: playerRadius - 3)
        playerAvatarNode.fillTexture = SKTexture(image: userAvatar)
        playerAvatarNode.fillColor = .white
        playerNode.addChild(playerAvatarNode)
        self.addChild(playerNode)
    }
    
    private func setupEvilNode(radius: CGFloat) {
        self.evilNode = SKShapeNode(circleOfRadius: radius)
        evilNode.position = CGPoint(x: self.frame.midX - 120, y: self.frame.midY)
        evilNode.name = "evilNode"
        evilNode.fillColor = Colors.evilNode
        evilNode.strokeColor = Colors.evilNode
        evilNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        evilNode.physicsBody?.categoryBitMask = PhysicsCategory.evilCategory
        evilNode.physicsBody?.collisionBitMask = PhysicsCategory.goodCategory
        evilNode.physicsBody?.contactTestBitMask = PhysicsCategory.goodCategory
        evilNode.physicsBody?.allowsRotation = false
        evilNode.physicsBody?.restitution = 0.3
        evilNode.alpha = 0
        evilNode.zPosition = -3
        evilNode.setScale(0)
        evilNode.physicsBody?.allowsRotation = true
        
        evilEmojiNode = SKShapeNode(circleOfRadius: emojiNodeSize)
        evilEmojiNode.position = evilNode.position
        evilEmojiNode.lineWidth = 4
        evilEmojiNode.strokeColor = Colors.evilNode
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
            texture: SKTexture(image: #imageLiteral(resourceName: "badEmoji")),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
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
        goodNode.fillColor = Colors.goodNode
        goodNode.strokeColor = Colors.goodNode
        let goodBody = SKPhysicsBody(circleOfRadius: radius)
        goodBody.categoryBitMask = PhysicsCategory.goodCategory
        goodBody.collisionBitMask = PhysicsCategory.evilCategory
        goodBody.contactTestBitMask = PhysicsCategory.evilCategory
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
        goodEmojiNode.strokeColor = Colors.goodNode
        goodEmojiNode.fillColor = .white
        
        let goodEmodjiBody = SKPhysicsBody(circleOfRadius: emojiNodeSize + 3)
        goodEmodjiBody.categoryBitMask = PhysicsCategory.goodEmojiCategory
        goodEmodjiBody.collisionBitMask = PhysicsCategory.playerCategory
        goodEmodjiBody.contactTestBitMask = PhysicsCategory.playerCategory
        goodEmodjiBody.allowsRotation = false
        goodEmodjiBody.restitution = 0.05
        goodEmojiNode.physicsBody = goodEmodjiBody
        goodEmojiNode.alpha = 0
        goodEmojiNode.setScale(0)
        
        let goodEmojiSprite = SKSpriteNode(
            texture: SKTexture(image: #imageLiteral(resourceName: "goodEmoji")),
            size: CGSize(width: emojiSize, height: emojiSize)
        )
        
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
    
    private var movableNode : SKNode?
    private var ballStartX: CGFloat = 0.0
    private var ballStartY: CGFloat = 0.0
    private var isDragged: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name == goodNode.name || node.name == goodEmojiNode.name {
                movableNode = goodNode
                ballStartX =  (movableNode?.position.x)! - location.x
                ballStartY = goodNode.position.y
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        isDragged = true
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            let newPostion = CGPoint(
                x: max(playerNode.frame.maxX + goodEmojiNode.frame.size.width / 2, location.x + ballStartX),
                y: goodNode.position.y)
            let action = SKAction.move(to: newPostion, duration: 0.1)
            goodNode.run(action)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if !isDragged {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node == playerNode {
                    gameDelegate?.didTapPlayerNode()
                    break
                }
                
                if node == goodEmojiNode {
                    gameDelegate?.didTapOnGood()
                    break
                }
                if node == evilEmojiNode {
                    gameDelegate?.didTapOnEvil()
                    break
                }
            }
        }
        isDragged = false
        movableNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            movableNode = nil
        }
    }
}

