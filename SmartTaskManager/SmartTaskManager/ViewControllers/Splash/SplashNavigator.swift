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

/// Handles splash-to-login transition timing. Replace this type when auth routing is added.
final class SplashNavigator: SplashNavigating {

    private let delay: TimeInterval
    private let makeLoginViewController: () -> UIViewController

    init(
        delay: TimeInterval = AppConstants.Splash.displayDuration,
        makeLoginViewController: @escaping () -> UIViewController = { LoginViewController() }
    ) {
        self.delay = delay
        self.makeLoginViewController = makeLoginViewController
    }

    func schedulePostSplashTransition(from viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak viewController] in
            guard let viewController, let loginViewController = self?.makeLoginViewController() else { return }
            viewController.replaceRoot(with: loginViewController, animated: true)
        }
    }
}
