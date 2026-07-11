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
    private let makeLoginViewController: () -> UIViewController
    private let makeHomeViewController: () -> UIViewController

    init(
        delay: TimeInterval = AppConstants.Splash.displayDuration,
        sessionManager: SessionManaging = SessionManager(),
        makeLoginViewController: @escaping () -> UIViewController = { LoginViewController() },
        makeHomeViewController: @escaping () -> UIViewController = { TaskListViewController() }
    ) {
        self.delay = delay
        self.sessionManager = sessionManager
        self.makeLoginViewController = makeLoginViewController
        self.makeHomeViewController = makeHomeViewController
    }

    func schedulePostSplashTransition(from viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak viewController] in
            guard let self, let viewController else { return }

            let destination = self.sessionManager.isLoggedIn
                ? self.makeHomeViewController()
                : self.makeLoginViewController()

            viewController.replaceRoot(with: destination, animated: true)
        }
    }
}
