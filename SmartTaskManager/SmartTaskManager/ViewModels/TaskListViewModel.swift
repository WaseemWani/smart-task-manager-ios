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
    case filteredEmpty(TaskPriorityFilter)
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

    private(set) var selectedPriorityFilter: TaskPriorityFilter = .all

    private var allTasks: [Task] = []

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

    func setPriorityFilter(_ filter: TaskPriorityFilter) {
        selectedPriorityFilter = filter
        publishFilteredTasks()
    }

    func deleteTask(_ task: Task, completion: @escaping (Result<Void, TaskError>) -> Void) {
        taskService.deleteTask(task: task) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                if case .success = result {
                    self.allTasks.removeAll { $0.id == task.id }
                    self.publishFilteredTasks()
                }

                completion(result)
            }
        }
    }

    func toggleCompletion(for taskID: String) {
        guard let index = allTasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        let task = allTasks[index]
        guard task.isEditable else {
            onToggleError?(TaskError.taskNotEditable.message)
            return
        }

        let toggledTask = taskWithToggledCompletion(task)
        allTasks[index] = toggledTask
        publishFilteredTasks()

        let input = CreateTaskInput(
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate,
            subtasks: task.subtasks
        )

        taskService.updateTask(task: toggledTask, input: input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.handleToggleResult(result, originalTask: task)
            }
        }
    }

    // MARK: - Private

    private func publishFilteredTasks() {
        let filteredTasks = TaskFilter.filter(allTasks, by: selectedPriorityFilter)

        if allTasks.isEmpty {
            state = .empty
        } else if filteredTasks.isEmpty {
            state = .filteredEmpty(selectedPriorityFilter)
        } else {
            state = .loaded(filteredTasks)
        }
    }

    private func handleFetchResult(_ result: Result<[Task], TaskError>) {
        switch result {
        case .success(let tasks):
            allTasks = tasks
            publishFilteredTasks()
        case .failure(let error):
            allTasks = []
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
        guard let index = allTasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        allTasks[index] = task
        publishFilteredTasks()
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
            subtasks: task.subtasks,
            createdAt: task.createdAt,
            updatedAt: task.updatedAt
        )
    }
}
