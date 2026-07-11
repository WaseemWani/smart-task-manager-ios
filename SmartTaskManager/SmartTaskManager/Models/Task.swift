//
//  Task.swift
//  SmartTaskManager
//

import Foundation

// MARK: - Task

struct Task: Codable, Equatable, Identifiable {
    let id: String
    let serverID: String?
    let title: String
    let description: String?
    let priority: TaskPriority
    let dueDate: Date?
    let isCompleted: Bool
    let createdAt: Date
    let updatedAt: Date

    var isEditable: Bool { serverID != nil }

    var isDeletable: Bool { serverID != nil }
}

// MARK: - TaskPriority

enum TaskPriority: String, Codable, CaseIterable, Equatable {
    case high
    case medium
    case low

    var displayTitle: String {
        switch self {
        case .high:
            return AppConstants.TaskList.highPriority
        case .medium:
            return AppConstants.TaskList.mediumPriority
        case .low:
            return AppConstants.TaskList.lowPriority
        }
    }

    var apiValue: String {
        displayTitle
    }

    static func fromAPIValue(_ value: String) -> TaskPriority {
        switch value {
        case AppConstants.TaskList.highPriority:
            return .high
        case AppConstants.TaskList.mediumPriority:
            return .medium
        case AppConstants.TaskList.lowPriority:
            return .low
        default:
            return .medium
        }
    }
}

// MARK: - CreateTaskInput

struct CreateTaskInput: Equatable {
    let title: String
    let description: String?
    let priority: TaskPriority
    let dueDate: Date?
}

// MARK: - TaskError

enum TaskError: Error, Equatable {
    case loadFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case taskNotEditable
    case taskNotDeletable
    case notLoggedIn

    var message: String {
        switch self {
        case .loadFailed:
            return AppConstants.TaskList.loadFailed
        case .createFailed:
            return AppConstants.TaskList.createFailed
        case .updateFailed:
            return AppConstants.TaskList.updateFailed
        case .deleteFailed:
            return AppConstants.TaskList.deleteFailed
        case .taskNotEditable:
            return AppConstants.TaskList.taskNotEditable
        case .taskNotDeletable:
            return AppConstants.TaskList.taskNotDeletable
        case .notLoggedIn:
            return AppConstants.TaskList.notLoggedIn
        }
    }
}
