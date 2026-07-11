//
//  TaskListViewController.swift
//  SmartTaskManager
//
//  Created by Waseem Wani on 01/07/26.
//

import UIKit

final class TaskListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = AppConstants.Tabs.tasksTitle
    }
}
