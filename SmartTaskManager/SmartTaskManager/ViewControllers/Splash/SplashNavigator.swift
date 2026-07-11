//
//  SplashNavigator.swift
//  SmartTaskManager
//

import UIKit

// MARK: - SplashNavigating

protocol SplashNavigating: AnyObject {
    func schedulePostSplashTransition(from viewController: UIViewController)
}

// MARK: - SplashNavigator

final class SplashNavigator: SplashNavigating {

    private let delay: TimeInterval
    private let sessionManager: SessionManaging
    private let tabBarFactory: MainTabBarBuilding
    private let makeLoginViewController: () -> UIViewController

    init(
        delay: TimeInterval = AppConstants.Splash.displayDuration,
        sessionManager: SessionManaging = SessionManager(),
        tabBarFactory: MainTabBarBuilding = MainTabBarFactory(),
        makeLoginViewController: @escaping () -> UIViewController = { LoginViewController() }
    ) {
        self.delay = delay
        self.sessionManager = sessionManager
        self.tabBarFactory = tabBarFactory
        self.makeLoginViewController = makeLoginViewController
    }

    func schedulePostSplashTransition(from viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak viewController] in
            guard let self, let viewController else { return }

            let destination = self.sessionManager.isLoggedIn
                ? self.tabBarFactory.makeMainTabBarController()
                : self.makeLoginViewController()

            viewController.replaceRoot(with: destination, animated: true)
        }
    }
}
