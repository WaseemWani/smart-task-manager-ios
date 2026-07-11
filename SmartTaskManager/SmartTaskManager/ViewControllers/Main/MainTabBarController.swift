//
//  MainTabBarController.swift
//  SmartTaskManager
//

import UIKit

// MARK: - MainTabCoordinating

protocol MainTabCoordinating: AnyObject {
    var currentTab: MainTab { get }
    func selectTab(_ tab: MainTab, animated: Bool)
    func viewController(for tab: MainTab) -> UIViewController?
}

// MARK: - MainTabBarController

final class MainTabBarController: UITabBarController, MainTabCoordinating {

    // MARK: - MainTabCoordinating

    var currentTab: MainTab {
        MainTab(rawValue: selectedIndex) ?? .tasks
    }

    func selectTab(_ tab: MainTab, animated: Bool) {
        guard tab.rawValue < (viewControllers?.count ?? 0) else { return }
        selectedIndex = tab.rawValue

        guard animated, let window = view.window else { return }

        UIView.transition(
            with: window,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    func viewController(for tab: MainTab) -> UIViewController? {
        guard let viewControllers, tab.rawValue < viewControllers.count else {
            return nil
        }
        return viewControllers[tab.rawValue]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
    }

    // MARK: - Setup

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appSurfaceLowest
        appearance.shadowColor = .appOutlineVariantMuted

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .appOutline
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.appOutline,
            .font: AppFont.caption()
        ]
        itemAppearance.selected.iconColor = .appPrimary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.appPrimary,
            .font: AppFont.caption()
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .appPrimary
        tabBar.unselectedItemTintColor = .appOutline
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let viewControllers = tabBarController.viewControllers,
              let targetIndex = viewControllers.firstIndex(where: { $0 === viewController }),
              targetIndex == tabBarController.selectedIndex,
              let navigationController = viewController as? UINavigationController,
              navigationController.viewControllers.count > 1 else {
            return true
        }

        navigationController.popToRootViewController(animated: true)
        return false
    }
}
