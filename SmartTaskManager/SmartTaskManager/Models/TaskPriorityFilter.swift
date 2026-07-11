//
//  TaskPriorityFilter.swift
//  SmartTaskManager
//

import Foundation

enum TaskPriorityFilter: Equatable, CaseIterable {
    case all
    case high
    case medium
    case low

    var title: String {
        switch self {
        case .all:
            return AppConstants.TaskList.filterAll
        case .high:
            return AppConstants.TaskList.highPriority
        case .medium:
            return AppConstants.TaskList.mediumPriority
        case .low:
            return AppConstants.TaskList.lowPriority
        }
    }

    var taskPriority: TaskPriority? {
        switch self {
        case .all:
            return nil
        case .high:
            return .high
        case .medium:
            return .medium
        case .low:
            return .low
        }
    }
}

enum TaskFilter {
    static func filter(_ tasks: [Task], by priorityFilter: TaskPriorityFilter) -> [Task] {
        guard let priority = priorityFilter.taskPriority else {
            return tasks
        }

        return tasks.filter { $0.priority == priority }
    }
}
