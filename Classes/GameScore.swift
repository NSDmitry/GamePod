//
//  GameScore.swift
//  Game
//
//  Created by D. Serov on 08.08.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import Foundation
import UIKit

public struct GameScore {
    public var value: CGFloat = 100
    
    mutating func reduceScore() {
        guard value > 0 else { return }
        value -= 5
    }
    
    mutating func addScore() {
        guard value >= 100 else { return }
        value += 5
    }
    
    public init(value: CGFloat) {
        self.value = value
    }
}
