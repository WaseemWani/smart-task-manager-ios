//
//  UIViewController+RootTransition.swift
//  SmartTaskManager
//

import UIKit

extension UIViewController {

    func replaceRoot(with viewController: UIViewController, animated: Bool) {
        guard let window = view.window else {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: animated)
            return
        }

        guard animated else {
            window.rootViewController = viewController
            return
        }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = viewController
            }
        )
    }
}
