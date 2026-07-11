//
//  TaskService.swift
//  SmartTaskManager
//

import Foundation

// MARK: - TaskStoreReading

protocol TaskStoreReading {
    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void)
}

// MARK: - EmptyTaskStore

final class EmptyTaskStore: TaskStoreReading {

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        completion(.success([]))
    }
}

// MARK: - TaskServicing

protocol TaskServicing {
    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void)
}

// MARK: - TaskService

final class TaskService: TaskServicing {

    private let taskStore: TaskStoreReading

    init(taskStore: TaskStoreReading = EmptyTaskStore()) {
        self.taskStore = taskStore
    }

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        taskStore.fetchTasks(completion: completion)
    }
}
