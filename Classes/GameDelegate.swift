//
//  GameDelegate.swift
//  GamePod
//
//  Created by D. Serov on 20.08.17.
//

import Foundation

public protocol GameDelegate: class {
    func didTapInEmptyPlace()
    func didTapPlayerNode()
}
