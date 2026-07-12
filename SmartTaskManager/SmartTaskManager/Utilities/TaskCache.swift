//
//  TaskCache.swift
//  SmartTaskManager
//

import Foundation

// MARK: - TaskCaching

protocol TaskCaching: AnyObject {
    var cachedTasks: [Task] { get }
    func updateTasks(_ tasks: [Task])
}

// MARK: - TaskCache

final class TaskCache: TaskCaching {

    static let shared = TaskCache()

    private(set) var cachedTasks: [Task] = []

    func updateTasks(_ tasks: [Task]) {
        cachedTasks = tasks
    }
}
