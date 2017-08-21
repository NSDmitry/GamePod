//
//  GameSettings.swift
//  Game
//
//  Created by D. Serov on 08.08.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import Foundation
import UIKit

public struct GameSettings {
    var playerImage: UIImage
    var goodNodeImage: UIImage
    var evilNodeImage: UIImage
    var score: GameScore
    
    public init(playerImage: UIImage, goodNodeImage: UIImage, evilNodeImage: UIImage, score: GameScore) {
        self.playerImage = playerImage
        self.goodNodeImage = goodNodeImage
        self.evilNodeImage = evilNodeImage
        self.score = score
    }
}
