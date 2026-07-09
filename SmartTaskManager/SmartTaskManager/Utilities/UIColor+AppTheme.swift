//
//  UIColor+AppTheme.swift
//  SmartTaskManager
//

import UIKit

extension UIColor {

    /// Stitch light surface (#FAF9FE) with a dark-mode equivalent.
    static let appSplashBackground = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 26 / 255, green: 27 / 255, blue: 31 / 255, alpha: 1)
        }
        return UIColor(red: 250 / 255, green: 249 / 255, blue: 254 / 255, alpha: 1)
    }
}
