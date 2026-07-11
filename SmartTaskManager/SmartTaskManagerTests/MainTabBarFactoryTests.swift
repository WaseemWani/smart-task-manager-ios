//
//  MainTabBarFactoryTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class MainTabBarFactoryTests: XCTestCase {

    func testFactoryCreatesThreeTabsInOrder() {
        let factory = MainTabBarFactory(
            makeTaskListViewController: { UIViewController() },
            makeAIAssistantViewController: { UIViewController() },
            makeProfileViewController: { UIViewController() }
        )

        let tabBarController = factory.makeMainTabBarController()

        XCTAssertEqual(tabBarController.viewControllers?.count, MainTab.allCases.count)
        XCTAssertEqual(tabBarController.currentTab, .tasks)
        XCTAssertTrue(tabBarController.viewControllers?.first is UINavigationController)
    }

    func testFactoryAssignsTabTitlesAndAccessibilityIdentifiers() {
        let factory = MainTabBarFactory()

        let tabBarController = factory.makeMainTabBarController()

        zip(MainTab.allCases, tabBarController.viewControllers ?? []).forEach { tab, viewController in
            XCTAssertEqual(viewController.tabBarItem.title, tab.title)
            XCTAssertEqual(viewController.tabBarItem.accessibilityIdentifier, tab.accessibilityIdentifier)
        }
    }
}
