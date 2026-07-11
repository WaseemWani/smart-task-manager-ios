//
//  MainTabBarControllerTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class MainTabBarControllerTests: XCTestCase {

    func testSelectTabUpdatesSelectedIndex() {
        let tabBarController = MainTabBarFactory().makeMainTabBarController()
        tabBarController.loadViewIfNeeded()

        tabBarController.selectTab(.profile, animated: false)

        XCTAssertEqual(tabBarController.currentTab, .profile)
        XCTAssertEqual(tabBarController.selectedIndex, MainTab.profile.rawValue)
    }

    func testViewControllerForTabReturnsNavigationController() {
        let tabBarController = MainTabBarFactory().makeMainTabBarController()
        tabBarController.loadViewIfNeeded()

        let navigationController = tabBarController.viewController(for: .aiAssistant)

        XCTAssertTrue(navigationController is UINavigationController)
        XCTAssertEqual(navigationController?.tabBarItem.title, MainTab.aiAssistant.title)
    }

    func testSelectingDifferentTabIsAllowed() {
        let tabBarController = MainTabBarFactory().makeMainTabBarController()
        tabBarController.loadViewIfNeeded()
        tabBarController.selectedIndex = MainTab.tasks.rawValue

        guard let profileNavigationController = tabBarController.viewControllers?[MainTab.profile.rawValue] else {
            return XCTFail("Expected profile tab view controller")
        }

        let shouldSelect = tabBarController.tabBarController(
            tabBarController,
            shouldSelect: profileNavigationController
        )

        XCTAssertTrue(shouldSelect)
    }
}
