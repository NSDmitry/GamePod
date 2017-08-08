//
//  GameCenter.swift
//  Testable
//
//  Created by Dmtry Serov on 03.08.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import Foundation
import UIKit

struct NodesWidth {
    var angelWidth: CGFloat
    var evilWidth: CGFloat
}

class NodeSizer {
    static func calculateSizesWidthScore(viewWidth: CGFloat, score: CGFloat) -> NodesWidth {
        let viewWidth: CGFloat = viewWidth
        
        let defaultWidthForNode: CGFloat = 42
        
        var angelWidth = defaultWidthForNode
        var evilWidth = defaultWidthForNode
        
        evilWidth = viewWidth * ((100 - score) / 100)
        angelWidth = viewWidth * (score / 100)
        
        if evilWidth <= 40 {
            evilWidth += defaultWidthForNode
        }
        
        if angelWidth <= 40 {
            angelWidth += defaultWidthForNode
        }
        
        if score == 100 {
            angelWidth = viewWidth
            evilWidth = defaultWidthForNode
        }
        
        if score == 0 {
            angelWidth = defaultWidthForNode
            evilWidth = viewWidth - 15
        }
        
        return NodesWidth(angelWidth: angelWidth, evilWidth: evilWidth)
    }
}


