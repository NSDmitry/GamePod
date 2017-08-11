//
//  GameViewController.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import UIKit
import SpriteKit

open class GameViewController: UIViewController {
    
    public var gameSettings = GameSettings(
        playerImage: #imageLiteral(resourceName: "emptyavatar"),
        goodNodeImage: ,
        evilNodeImage: #imageLiteral(resourceName: "badEmoji"),
        timeInterval: TimeInterval(exactly: 15)!,
//        score: GameScore(score: 100))
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scene = GameScene(size: view.bounds.size)
        scene.gameScore = CGFloat(gameSettings.score.score)
        scene.goodEmojiImage = gameSettings.goodNodeImage
        scene.badEmojiImage = gameSettings.evilNodeImage
        scene.intervalForEvilNodeImpulse = gameSettings.timeInterval
        scene.avatarImage = gameSettings.playerImage
        
        let skView = view as! SKView
//        skView.showsFPS = true
        scene.scaleMode = .resizeFill
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.1)
        skView.presentScene(scene)
        
    }

}
