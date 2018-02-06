//
//  GameCenter.swift
//  Testable
//
//  Created by Dmtry Serov on 03.08.17.
//  Copyright © 2017 Dmitry Serov. All rights reserved.
//

import Foundation

class NodeSizer {
    static func calculate(viewWidth: CGFloat, score: CGFloat) -> (angelRadius: CGFloat, evilRadius: CGFloat) {
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
        
        return (angelRadius: angelWidth / 2, evilRadius: evilWidth / 2)
    }
}
