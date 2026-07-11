//
//  MainTabBarFactory.swift
//  SmartTaskManager
//

import UIKit

// MARK: - MainTabBarBuilding

protocol MainTabBarBuilding {
    func makeMainTabBarController() -> MainTabBarController
}

// MARK: - MainTabBarFactory

struct MainTabBarFactory: MainTabBarBuilding {

    private let makeTaskListViewController: () -> UIViewController
    private let makeAIAssistantViewController: () -> UIViewController
    private let makeProfileViewController: () -> UIViewController

    init(
        makeTaskListViewController: @escaping () -> UIViewController = { TaskListViewController() },
        makeAIAssistantViewController: @escaping () -> UIViewController = { AIAssistantViewController() },
        makeProfileViewController: @escaping () -> UIViewController = { ProfileViewController() }
    ) {
        self.makeTaskListViewController = makeTaskListViewController
        self.makeAIAssistantViewController = makeAIAssistantViewController
        self.makeProfileViewController = makeProfileViewController
    }

    func makeMainTabBarController() -> MainTabBarController {
        let tabBarController = MainTabBarController()
        tabBarController.viewControllers = MainTab.allCases.map { tab in
            makeNavigationController(for: tab)
        }
        tabBarController.selectedIndex = MainTab.tasks.rawValue
        return tabBarController
    }

    // MARK: - Private

    private func makeNavigationController(for tab: MainTab) -> UINavigationController {
        let rootViewController = makeRootViewController(for: tab)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = makeTabBarItem(for: tab)
        navigationController.navigationBar.prefersLargeTitles = true
        configureNavigationBarAppearance(for: navigationController)
        return navigationController
    }

    private func makeRootViewController(for tab: MainTab) -> UIViewController {
        switch tab {
        case .tasks:
            return makeTaskListViewController()
        case .aiAssistant:
            return makeAIAssistantViewController()
        case .profile:
            return makeProfileViewController()
        }
    }

    private func makeTabBarItem(for tab: MainTab) -> UITabBarItem {
        let item = UITabBarItem(
            title: tab.title,
            image: UIImage(systemName: tab.iconName),
            selectedImage: UIImage(systemName: tab.selectedIconName)
        )
        item.accessibilityIdentifier = tab.accessibilityIdentifier
        return item
    }

    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appSurfaceLowest
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.appOnSurface,
            .font: AppFont.button()
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.appOnSurface,
            .font: AppFont.title()
        ]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.tintColor = .appPrimary
    }
}
