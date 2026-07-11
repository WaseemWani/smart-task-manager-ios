//
//  AppNavigationBarAppearance.swift
//  SmartTaskManager
//

import UIKit

enum AppNavigationBarAppearance {

    /// Applies Stitch top app bar styling: `bg-surface/80` with backdrop blur.
    static func apply(to navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.appBackground.withAlphaComponent(0.8)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.appOnSurface,
            .font: AppFont.headline()
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.appOnSurface,
            .font: AppFont.title()
        ]

        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.appPrimary]
        appearance.buttonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .appPrimary
    }

    static func primaryBarButton(
        systemName: String,
        target: Any?,
        action: Selector
    ) -> UIBarButtonItem {
        let image = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        item.tintColor = .appPrimary
        return item
    }
}
