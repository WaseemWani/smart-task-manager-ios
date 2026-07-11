//
//  UIColor+AppTheme.swift
//  SmartTaskManager
//

import UIKit

extension UIColor {

    // MARK: - Stitch Design Tokens (Light Mode)

    /// Login screen background (#F2F2F7).
    static let appLoginBackground = UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)

    /// Primary brand color (#0058BC).
    static let appPrimary = UIColor(red: 0 / 255, green: 88 / 255, blue: 188 / 255, alpha: 1)

    /// Text on primary button (#FFFFFF).
    static let appOnPrimary = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)

    /// Primary body text (#1A1B1F).
    static let appOnSurface = UIColor(red: 26 / 255, green: 27 / 255, blue: 31 / 255, alpha: 1)

    /// Secondary / muted text (#717786).
    static let appOutline = UIColor(red: 113 / 255, green: 119 / 255, blue: 134 / 255, alpha: 1)

    /// Borders and dividers (#C1C6D7).
    static let appOutlineVariant = UIColor(red: 193 / 255, green: 198 / 255, blue: 215 / 255, alpha: 1)

    /// Guest button background (#EEEDF3).
    static let appSurfaceContainer = UIColor(red: 238 / 255, green: 237 / 255, blue: 243 / 255, alpha: 1)

    /// Form card background (#FFFFFF).
    static let appSurfaceLowest = UIColor.white

    /// Splash / general app background (#FAF9FE).
    static let appBackground = UIColor(red: 250 / 255, green: 249 / 255, blue: 254 / 255, alpha: 1)

    /// Input field background (#E9E9EB).
    static let appInputBackground = UIColor(red: 233 / 255, green: 233 / 255, blue: 235 / 255, alpha: 1)

    /// Outline variant at 30% opacity for borders and dividers.
    static let appOutlineVariantMuted = UIColor(red: 193 / 255, green: 198 / 255, blue: 215 / 255, alpha: 0.3)

    /// Validation error text and borders (#D32F2F).
    static let appError = UIColor(red: 211 / 255, green: 47 / 255, blue: 47 / 255, alpha: 1)

    /// Secondary surface text (#414755).
    static let appOnSurfaceVariant = UIColor(red: 65 / 255, green: 71 / 255, blue: 85 / 255, alpha: 1)

    /// High priority badge background — error at 10% (#BA1A1A).
    static let appHighPriorityBadgeBackground = UIColor(red: 186 / 255, green: 26 / 255, blue: 26 / 255, alpha: 0.1)

    /// High priority badge text (#BA1A1A).
    static let appHighPriorityBadgeText = UIColor(red: 186 / 255, green: 26 / 255, blue: 26 / 255, alpha: 1)

    /// Medium priority badge background — tertiary container at 20% (#AC6300).
    static let appMediumPriorityBadgeBackground = UIColor(red: 172 / 255, green: 99 / 255, blue: 0 / 255, alpha: 0.2)

    /// Medium priority badge text (#894D00).
    static let appMediumPriorityBadgeText = UIColor(red: 137 / 255, green: 77 / 255, blue: 0 / 255, alpha: 1)

    /// Low priority badge background — primary at 10% (#0058BC).
    static let appLowPriorityBadgeBackground = UIColor(red: 0 / 255, green: 88 / 255, blue: 188 / 255, alpha: 0.1)

    /// Low priority badge text (#0058BC).
    static let appLowPriorityBadgeText = UIColor(red: 0 / 255, green: 88 / 255, blue: 188 / 255, alpha: 1)

    /// Task card border (black at 5% opacity).
    static let appTaskCardBorder = UIColor.black.withAlphaComponent(0.05)

    /// Task card shadow color.
    static let appTaskCardShadow = UIColor.black.withAlphaComponent(0.08)

    @available(*, deprecated, renamed: "appBackground")
    static let appSplashBackground = appBackground
}
