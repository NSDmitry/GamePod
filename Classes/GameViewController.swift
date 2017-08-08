//
//  GameViewController.swift
//  Testable
//
//  Created by D. Serov on 31.07.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

open class GameViewController: UIViewController {
    
    public var gameSettings = GameSettings(
        playerImage: UIImage(),
        goodNodeImage: UIImage(),
        evilNodeImage: UIImage(),
        timeInterval: TimeInterval(),
        score: GameScore(score: 30))
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scene = GameScene(size: view.bounds.size)
        scene.gameScore = CGFloat(gameSettings.score.score)
        scene.goodEmojiImage = gameSettings.goodNodeImage
        scene.badEmojiImage = gameSettings.evilNodeImage
        scene.intervalForEvilNodeImpulse = gameSettings.timeInterval
        scene.avatarImage = gameSettings.playerImage
        
        let skView = view as! SKView
        skView.showsFPS = true
        scene.scaleMode = .resizeFill
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.1)
        skView.presentScene(scene)
        
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
}
