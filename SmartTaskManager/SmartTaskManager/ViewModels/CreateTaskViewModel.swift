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
    var subtasks: [Subtask] = []
    var titleError: String?
    var descriptionError: String?
    var priorityError: String?
    var dueDateError: String?
    var submitError: String?
    var successMessage: String?
    var isLoading: Bool = false
    var isSaveEnabled: Bool = false
    var isSuggestingPriority: Bool = false
    var isGeneratingSubtasks: Bool = false
    var isSuggestPriorityEnabled: Bool = false
    var isBreakIntoSubtasksEnabled: Bool = false

    var isAILoading: Bool {
        isSuggestingPriority || isGeneratingSubtasks
    }
}

// MARK: - CreateTaskViewModel

final class CreateTaskViewModel {

    // MARK: - Callbacks

    var onStateChange: ((CreateTaskViewState) -> Void)?
    var onCreateSuccess: ((Task) -> Void)?
    var onUpdateSuccess: ((Task) -> Void)?
    var onDeleteSuccess: (() -> Void)?
    var onAISuccess: ((String) -> Void)?
    var onAIError: ((String) -> Void)?
    var onRegenerateConfirmationRequired: (() -> Void)?

    // MARK: - State

    private(set) var state = CreateTaskViewState() {
        didSet {
            onStateChange?(state)
        }
    }

    // MARK: - Mode

    private let editingTask: Task?

    var isEditing: Bool { editingTask != nil }

    var screenTitle: String {
        isEditing ? AppConstants.EditTask.screenTitle : AppConstants.CreateTask.screenTitle
    }

    var saveButtonTitle: String {
        isEditing ? AppConstants.EditTask.saveButton : AppConstants.CreateTask.saveButton
    }

    // MARK: - Dependencies

    private let validator: InputValidating
    private let taskService: TaskServicing
    private let aiService: AIServicing

    // MARK: - Initialization

    init(
        taskToEdit: Task? = nil,
        validator: InputValidating = InputValidator(),
        taskService: TaskServicing = TaskService(),
        aiService: AIServicing = AIService()
    ) {
        self.editingTask = taskToEdit
        self.validator = validator
        self.taskService = taskService
        self.aiService = aiService

        if let task = taskToEdit {
            state.title = task.title
            state.description = task.description ?? ""
            state.priority = task.priority
            state.dueDate = task.dueDate
            state.subtasks = task.subtasks
        }

        updateSaveEnabledState()
    }

    func suggestPriority() {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            state.titleError = AppConstants.CreateTask.titleRequiredForAI
            return
        }

        guard !state.isAILoading, !state.isLoading else { return }

        state.isSuggestingPriority = true
        state.titleError = nil
        state.submitError = nil
        updateAIEnabledStates()

        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)

        aiService.suggestPriority(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isSuggestingPriority = false
                self.updateAIEnabledStates()

                switch result {
                case .success(let priority):
                    self.state.priority = priority
                    self.state.priorityError = nil
                    self.updateSaveEnabledState()
                    self.onAISuccess?(AppConstants.AI.prioritySuggested)
                case .failure(let error):
                    self.onAIError?(error.message)
                }
            }
        }
    }

    func breakIntoSubtasks() {
        guard validateBreakdownInput() else { return }
        guard !state.subtasks.isEmpty else {
            performBreakIntoSubtasks()
            return
        }
        onRegenerateConfirmationRequired?()
    }

    func confirmRegenerateSubtasks() {
        guard validateBreakdownInput() else { return }
        performBreakIntoSubtasks()
    }

    func addSubtask(title: String = "") {
        state.subtasks.append(Subtask(title: title))
        updateSaveEnabledState()
    }

    func insertSubtask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        state.subtasks.append(Subtask(title: trimmedTitle))
        updateSaveEnabledState()
    }

    func toggleSubtask(id: String) {
        guard let index = state.subtasks.firstIndex(where: { $0.id == id }) else { return }
        state.subtasks[index].isCompleted.toggle()
        updateSaveEnabledState()
    }

    func updateSubtaskTitle(id: String, title: String) {
        guard let index = state.subtasks.firstIndex(where: { $0.id == id }) else { return }
        state.subtasks[index].title = title
        updateSaveEnabledState()
    }

    func deleteSubtask(id: String) {
        state.subtasks.removeAll { $0.id == id }
        updateSaveEnabledState()
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
        state.descriptionError = nil
        state.submitError = nil
        state.successMessage = nil
        updateSaveEnabledState()
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
        updateSaveEnabledState()
    }

    func saveTask() {
        let validationResult = validator.validateCreateTask(
            title: state.title,
            priority: state.priority,
            dueDate: state.dueDate,
            referenceDate: Date()
        )

        if let editingTask, let dueDateError = dueDateValidationError(
            for: state.dueDate,
            originalDueDate: editingTask.dueDate,
            validationResult: validationResult
        ) {
            state.dueDateError = dueDateError.message
            return
        }

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
            dueDate: state.dueDate,
            subtasks: sanitizedSubtasks()
        )

        state.isLoading = true
        state.isSaveEnabled = false
        state.submitError = nil
        state.successMessage = nil

        if let editingTask {
            updateTask(editingTask, input: input)
        } else {
            createTask(input: input)
        }
    }

    func deleteTask() {
        guard let editingTask else { return }

        state.isLoading = true
        state.isSaveEnabled = false
        state.submitError = nil
        state.successMessage = nil

        taskService.deleteTask(task: editingTask) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isLoading = false
                self.updateSaveEnabledState()

                switch result {
                case .success:
                    self.onDeleteSuccess?()
                case .failure(let error):
                    self.state.submitError = error.message
                }
            }
        }
    }

    // MARK: - Private

    private func performBreakIntoSubtasks() {
        guard !state.isAILoading, !state.isLoading else { return }

        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)

        state.isGeneratingSubtasks = true
        state.titleError = nil
        state.descriptionError = nil
        state.submitError = nil
        updateAIEnabledStates()

        aiService.generateSubtasks(
            title: trimmedTitle,
            description: trimmedDescription
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isGeneratingSubtasks = false
                self.updateAIEnabledStates()

                switch result {
                case .success(let titles):
                    self.state.subtasks = titles.map { Subtask(title: $0) }
                    self.updateSaveEnabledState()
                    self.onAISuccess?(AppConstants.AI.subtasksGenerated)
                case .failure(let error):
                    self.onAIError?(error.message)
                }
            }
        }
    }

    private func validateBreakdownInput() -> Bool {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)

        var isValid = true

        if trimmedTitle.isEmpty {
            state.titleError = AppConstants.CreateTask.titleRequiredForAI
            isValid = false
        } else {
            state.titleError = nil
        }

        if trimmedDescription.isEmpty {
            state.descriptionError = AppConstants.CreateTask.descriptionRequiredForAI
            isValid = false
        } else {
            state.descriptionError = nil
        }

        return isValid
    }

    private func sanitizedSubtasks() -> [Subtask] {
        state.subtasks
            .map { subtask in
                Subtask(
                    id: subtask.id,
                    title: subtask.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    isCompleted: subtask.isCompleted
                )
            }
            .filter { !$0.title.isEmpty }
    }

    private func createTask(input: CreateTaskInput) {
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

    private func updateTask(_ task: Task, input: CreateTaskInput) {
        taskService.updateTask(task: task, input: input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isLoading = false
                self.updateSaveEnabledState()

                switch result {
                case .success(let updatedTask):
                    self.state.successMessage = AppConstants.TaskList.updateSuccess
                    self.onUpdateSuccess?(updatedTask)
                case .failure(let error):
                    self.state.submitError = error.message
                }
            }
        }
    }

    private func updateSaveEnabledState() {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasRequiredFields = !trimmedTitle.isEmpty && state.priority != nil && !state.isLoading

        if let editingTask {
            state.isSaveEnabled = hasRequiredFields && hasChanges(from: editingTask)
        } else {
            state.isSaveEnabled = hasRequiredFields
        }

        updateAIEnabledStates()
    }

    private func updateAIEnabledStates() {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)

        state.isSuggestPriorityEnabled = !trimmedTitle.isEmpty
            && !state.isLoading
            && !state.isAILoading

        state.isBreakIntoSubtasksEnabled = !trimmedTitle.isEmpty
            && !trimmedDescription.isEmpty
            && !state.isLoading
            && !state.isAILoading
    }

    private func hasChanges(from task: Task) -> Bool {
        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = state.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalDescription = task.description ?? ""

        return trimmedTitle != task.title
            || trimmedDescription != originalDescription
            || state.priority != task.priority
            || !Self.datesEqual(state.dueDate, task.dueDate)
            || !Self.subtasksEqual(sanitizedSubtasks(), sanitizedSubtasks(from: task.subtasks))
    }

    private func dueDateValidationError(
        for dueDate: Date?,
        originalDueDate: Date?,
        validationResult: ValidationResult
    ) -> ValidationError? {
        guard Self.datesEqual(dueDate, originalDueDate) else {
            return validationResult.errors.first(where: { $0.field == .dueDate })
        }

        return nil
    }

    private func applyValidationErrors(_ errors: [ValidationError]) {
        state.titleError = errors.first(where: { $0.field == .title })?.message
        state.priorityError = errors.first(where: { $0.field == .priority })?.message
        state.dueDateError = errors.first(where: { $0.field == .dueDate })?.message
    }

    private static func datesEqual(_ lhs: Date?, _ rhs: Date?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case let (left?, right?):
            return Calendar.current.isDate(left, inSameDayAs: right)
        default:
            return false
        }
    }

    private static func subtasksEqual(_ lhs: [Subtask], _ rhs: [Subtask]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy { $0.title == $1.title && $0.isCompleted == $1.isCompleted }
    }

    private func sanitizedSubtasks(from subtasks: [Subtask]) -> [Subtask] {
        subtasks
            .map { subtask in
                Subtask(
                    id: subtask.id,
                    title: subtask.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    isCompleted: subtask.isCompleted
                )
            }
            .filter { !$0.title.isEmpty }
    }
}
