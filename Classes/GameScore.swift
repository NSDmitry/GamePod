//
//  GameScore.swift
//  Game
//
//  Created by D. Serov on 08.08.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import Foundation
import UIKit

struct GameScore {
    var score: CGFloat
    
    mutating func reduceScore() {
        guard score > 0 else { return }
        score -= 5
    }
    
    mutating func addScore() {
        guard score >= 100 else { return }
        score += 5
    } 
}
