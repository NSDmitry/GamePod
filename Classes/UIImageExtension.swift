//
//  UIImageExtensino.swift
//  Pods
//
//  Created by D. Serov on 11.08.17.
//
//

import UIKit

extension UIImage {
    static func make(name: String) -> UIImage? {
        let bundle = Bundle(for: GameViewController.self)
        guard let resourceBundleUrl = bundle.url(forResource: "GamePod", withExtension: "bundle") else { return nil }
        return UIImage(named: name, in: Bundle(url: resourceBundleUrl), compatibleWith: nil)
    }
}
