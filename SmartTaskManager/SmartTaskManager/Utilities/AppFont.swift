//
//  AppFont.swift
//  SmartTaskManager
//

import UIKit

enum AppFont {

    static func title() -> UIFont {
        .systemFont(ofSize: 28, weight: .bold)
    }

    static func body() -> UIFont {
        .systemFont(ofSize: 15, weight: .regular)
    }

    static func input() -> UIFont {
        .systemFont(ofSize: 17, weight: .regular)
    }

    static func button() -> UIFont {
        .systemFont(ofSize: 17, weight: .semibold)
    }

    static func link() -> UIFont {
        .systemFont(ofSize: 13, weight: .regular)
    }

    static func caption() -> UIFont {
        .systemFont(ofSize: 12, weight: .regular)
    }

    static func divider() -> UIFont {
        .systemFont(ofSize: 13, weight: .regular)
    }
}
