//
//  PhysicsCategory.swift
//  GamePod
//
//  Created by D. Serov on 20.08.17.
//

import Foundation

struct PhysicsCategory {
    let playerCategory: UInt32 = 0x1 << 1
    let evilCategory: UInt32 = 0x1 << 2
    let goodCategory: UInt32 = 0x1 << 3
    let goodEmojiCategory: UInt32 = 0x1 << 4
    let physicalWorldCategory: UInt32 = 0x1 << 5
}
