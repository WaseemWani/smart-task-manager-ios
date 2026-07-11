//
//  AppFont.swift
//  SmartTaskManager
//

import UIKit

enum AppFont {

    static func title() -> UIFont {
        font(size: 28, weight: .bold)
    }

    static func largeTitleMobile() -> UIFont {
        font(size: 28, weight: .bold)
    }

    static func headline() -> UIFont {
        font(size: 17, weight: .semibold)
    }

    static func body() -> UIFont {
        font(size: 15, weight: .regular)
    }

    static func subheadline() -> UIFont {
        font(size: 15, weight: .regular)
    }

    static func input() -> UIFont {
        font(size: 17, weight: .regular)
    }

    static func button() -> UIFont {
        font(size: 17, weight: .semibold)
    }

    static func link() -> UIFont {
        font(size: 13, weight: .regular)
    }

    static func caption() -> UIFont {
        font(size: 12, weight: .regular)
    }

    static func footnote() -> UIFont {
        font(size: 13, weight: .regular)
    }

    static func priorityBadge() -> UIFont {
        font(size: 10, weight: .semibold)
    }

    static func divider() -> UIFont {
        font(size: 13, weight: .regular)
    }

    private static func font(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: weight]
            ])
        return UIFont(descriptor: descriptor, size: size)
    }
}
