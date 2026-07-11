//
//  SplashNavigatorTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class SplashNavigatorTests: XCTestCase {

    func testNavigatorRoutesToHomeWhenSessionExists() {
        let sessionManager = MockSessionManager()
        sessionManager.isLoggedInValue = true
        var didRouteToMainTabs = false

        let navigator = SplashNavigator(
            delay: 0,
            sessionManager: sessionManager,
            tabBarFactory: MockTabBarFactory {
                didRouteToMainTabs = true
                return MainTabBarController()
            },
            makeLoginViewController: { UIViewController() }
        )

        let splashViewController = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()

        let expectation = expectation(description: "Routes to home")
        navigator.schedulePostSplashTransition(from: splashViewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(didRouteToMainTabs)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNavigatorRoutesToLoginWhenSessionMissing() {
        let sessionManager = MockSessionManager()
        sessionManager.isLoggedInValue = false
        var didRouteToLogin = false

        let navigator = SplashNavigator(
            delay: 0,
            sessionManager: sessionManager,
            tabBarFactory: MockTabBarFactory { MainTabBarController() },
            makeLoginViewController: {
                didRouteToLogin = true
                return UIViewController()
            }
        )

        let splashViewController = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()

        let expectation = expectation(description: "Routes to login")
        navigator.schedulePostSplashTransition(from: splashViewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(didRouteToLogin)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - MockSessionManager

private final class MockSessionManager: SessionManaging {

    var isLoggedInValue = false
    var currentSession: UserSession?

    var isLoggedIn: Bool { isLoggedInValue }

    func saveSession(token: String, user: User) {
        currentSession = UserSession(token: token, user: user)
        isLoggedInValue = true
    }

    func restoreSession() -> UserSession? {
        currentSession
    }

    func clearSession() {
        currentSession = nil
        isLoggedInValue = false
    }
}

// MARK: - MockTabBarFactory

private struct MockTabBarFactory: MainTabBarBuilding {

    let onMake: () -> MainTabBarController

    func makeMainTabBarController() -> MainTabBarController {
        onMake()
    }
}
