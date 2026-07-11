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
    var onToggleError: ((String) -> Void)?

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

    func toggleCompletion(for taskID: String) {
        guard case .loaded(var tasks) = state,
              let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        let task = tasks[index]
        guard task.isEditable else {
            onToggleError?(TaskError.taskNotEditable.message)
            return
        }

        let toggledTask = taskWithToggledCompletion(task)
        tasks[index] = toggledTask
        state = .loaded(tasks)

        let input = CreateTaskInput(
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate
        )

        taskService.updateTask(task: toggledTask, input: input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.handleToggleResult(result, originalTask: task)
            }
        }
    }

    // MARK: - Private

    private func handleFetchResult(_ result: Result<[Task], TaskError>) {
        switch result {
        case .success(let tasks):
            state = tasks.isEmpty ? .empty : .loaded(tasks)
        case .failure(let error):
            state = .error(error.message)
        }
    }

    private func handleToggleResult(_ result: Result<Task, TaskError>, originalTask: Task) {
        switch result {
        case .success(let updatedTask):
            replaceTask(updatedTask)
        case .failure(let error):
            replaceTask(originalTask)
            onToggleError?(error.message)
        }
    }

    private func replaceTask(_ task: Task) {
        guard case .loaded(var tasks) = state,
              let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        tasks[index] = task
        state = .loaded(tasks)
    }

    private func taskWithToggledCompletion(_ task: Task) -> Task {
        Task(
            id: task.id,
            serverID: task.serverID,
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate,
            isCompleted: !task.isCompleted,
            createdAt: task.createdAt,
            updatedAt: task.updatedAt
        )
    }
}
