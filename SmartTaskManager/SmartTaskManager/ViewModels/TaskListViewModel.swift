//
//  TaskListViewModel.swift
//  SmartTaskManager
//

import Foundation

// MARK: - TaskListViewState

enum TaskListViewState: Equatable {
    case loading
    case loaded([Task])
    case empty
    case error(String)
}

// MARK: - TaskListViewModel

final class TaskListViewModel {

    // MARK: - Callbacks

    var onStateChange: ((TaskListViewState) -> Void)?

    // MARK: - State

    private(set) var state: TaskListViewState = .loading {
        didSet {
            onStateChange?(state)
        }
    }

    // MARK: - Dependencies

    private let taskService: TaskServicing

    // MARK: - Initialization

    init(taskService: TaskServicing = TaskService()) {
        self.taskService = taskService
        loadTasks()
    }

    // MARK: - Input

    func loadTasks() {
        state = .loading

        taskService.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.handleFetchResult(result)
            }
        }
    }

    func deleteTask(_ task: Task, completion: @escaping (Result<Void, TaskError>) -> Void) {
        taskService.deleteTask(task: task) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                if case .success = result {
                    self.removeTaskFromState(task)
                }

                completion(result)
            }
        }
    }

    // MARK: - Private

    private func removeTaskFromState(_ task: Task) {
        guard case .loaded(var tasks) = state else { return }

        tasks.removeAll { $0.id == task.id }
        state = tasks.isEmpty ? .empty : .loaded(tasks)
    }

    private func handleFetchResult(_ result: Result<[Task], TaskError>) {
        switch result {
        case .success(let tasks):
            state = tasks.isEmpty ? .empty : .loaded(tasks)
        case .failure(let error):
            state = .error(error.message)
        }
    }
}
