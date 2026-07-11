//
//  CreateTaskViewModel.swift
//  SmartTaskManager
//

import Foundation

// MARK: - CreateTaskViewState

struct CreateTaskViewState: Equatable {
    var title: String = ""
    var description: String = ""
    var priority: TaskPriority?
    var dueDate: Date?
    var titleError: String?
    var priorityError: String?
    var dueDateError: String?
    var submitError: String?
    var successMessage: String?
    var isLoading: Bool = false
    var isSaveEnabled: Bool = false
}

// MARK: - CreateTaskViewModel

final class CreateTaskViewModel {

    // MARK: - Callbacks

    var onStateChange: ((CreateTaskViewState) -> Void)?
    var onCreateSuccess: ((Task) -> Void)?

    // MARK: - State

    private(set) var state = CreateTaskViewState() {
        didSet {
            onStateChange?(state)
        }
    }

    // MARK: - Dependencies

    private let validator: InputValidating
    private let taskService: TaskServicing

    // MARK: - Initialization

    init(
        validator: InputValidating = InputValidator(),
        taskService: TaskServicing = TaskService()
    ) {
        self.validator = validator
        self.taskService = taskService
    }

    // MARK: - Input

    func updateTitle(_ title: String) {
        state.title = title
        state.titleError = nil
        state.submitError = nil
        state.successMessage = nil
        updateSaveEnabledState()
    }

    func updateDescription(_ description: String) {
        state.description = description
        state.submitError = nil
        state.successMessage = nil
    }

    func updatePriority(_ priority: TaskPriority?) {
        state.priority = priority
        state.priorityError = nil
        state.submitError = nil
        state.successMessage = nil
        updateSaveEnabledState()
    }

    func updateDueDate(_ dueDate: Date?) {
        state.dueDate = dueDate
        state.dueDateError = nil
        state.submitError = nil
        state.successMessage = nil
    }

    func saveTask() {
        let validationResult = validator.validateCreateTask(
            title: state.title,
            priority: state.priority,
            dueDate: state.dueDate,
            referenceDate: Date()
        )

        guard validationResult.isValid else {
            applyValidationErrors(validationResult.errors)
            return
        }

        guard let priority = state.priority else { return }

        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)

        let input = CreateTaskInput(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            priority: priority,
            dueDate: state.dueDate
        )

        state.isLoading = true
        state.isSaveEnabled = false
        state.submitError = nil
        state.successMessage = nil

        taskService.createTask(input: input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isLoading = false
                self.updateSaveEnabledState()

                switch result {
                case .success(let task):
                    self.state.successMessage = AppConstants.TaskList.createSuccess
                    self.onCreateSuccess?(task)
                case .failure(let error):
                    self.state.submitError = error.message
                }
            }
        }
    }

    // MARK: - Private

    private func updateSaveEnabledState() {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        state.isSaveEnabled = !trimmedTitle.isEmpty && state.priority != nil && !state.isLoading
    }

    private func applyValidationErrors(_ errors: [ValidationError]) {
        state.titleError = errors.first(where: { $0.field == .title })?.message
        state.priorityError = errors.first(where: { $0.field == .priority })?.message
        state.dueDateError = errors.first(where: { $0.field == .dueDate })?.message
    }
}
