//
//  UIViewController+MainTabBar.swift
//  SmartTaskManager
//

import UIKit

extension UIViewController {

    var mainTabBarController: MainTabBarController? {
        tabBarController as? MainTabBarController
    }

    var mainTabCoordinator: MainTabCoordinating? {
        mainTabBarController
    }
}
