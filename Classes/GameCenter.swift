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
        
        let defaultWidthForNode: CGFloat = viewWidth / 5.3
        
        var angelWidth = (viewWidth * 1.25) * (score / 100)
        var evilWidth = (viewWidth * 1.25) * ((100 - score) / 100)
        
        if evilWidth <= (viewWidth * 1.25) / 10 + 8 {
            evilWidth += (viewWidth * 1.25) / 10 + 8
        }
        
        if angelWidth <= (viewWidth * 1.25) / 10 + 8 {
            angelWidth += (viewWidth * 1.25) / 10 + 8
        }
        
        if score == 100 {
            angelWidth = viewWidth * 1.25
            evilWidth = defaultWidthForNode - 5
        }
        
        if score == 0 {
            angelWidth = defaultWidthForNode
            evilWidth = (viewWidth - 5) * 1.25 
        }
        
        return NodesWidth(angelWidth: angelWidth, evilWidth: evilWidth)
    }
}
