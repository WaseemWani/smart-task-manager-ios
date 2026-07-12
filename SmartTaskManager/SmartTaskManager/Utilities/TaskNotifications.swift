//
//  TaskNotifications.swift
//  SmartTaskManager
//

import Foundation

enum TaskNotifications {

    static let didChange = Notification.Name("stm.tasks.didChange")

    static func postDidChange() {
        NotificationCenter.default.post(name: didChange, object: nil)
    }
}
