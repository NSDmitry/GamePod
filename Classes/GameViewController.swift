//
//  GameViewController.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import UIKit
import SpriteKit

open class GameViewController: UIViewController, GameDelegate {
    public var gameSettings = GameSettings(
        playerImage: UIImage.make(name: "emptyavatar")!,
        goodNodeImage: UIImage.make(name: "goodEmoji")!,
        evilNodeImage: UIImage.make(name: "badEmoji")!,
        timeInterval: TimeInterval(exactly: 15)!,
        score: GameScore(score: 100))
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scene = GameScene(size: view.bounds.size)
        scene.gameScore = CGFloat(gameSettings.score.score)
        scene.goodEmojiImage = gameSettings.goodNodeImage
        scene.badEmojiImage = gameSettings.evilNodeImage
        scene.intervalForEvilNodeImpulse = gameSettings.timeInterval
        scene.avatarImage = gameSettings.playerImage
        scene.gameDelegate = self
        
        let skView = view as! SKView
        scene.scaleMode = .resizeFill
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.1)
        skView.presentScene(scene)
    }
    
    open func didTapEvilNode() { }
    open func didTapPlayerNode() { }
    open func didTapGoodNode() { }
}
