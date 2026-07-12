//
//  CreateTaskViewModelTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class CreateTaskViewModelTests: XCTestCase {

    private var taskService: MockCreateTaskService!
    private var aiService: MockCreateTaskAIService!
    private var validator: InputValidator!

    override func setUp() {
        super.setUp()
        taskService = MockCreateTaskService()
        aiService = MockCreateTaskAIService()
        validator = InputValidator()
    }

    override func tearDown() {
        validator = nil
        aiService = nil
        taskService = nil
        super.tearDown()
    }

    func testEditModePrefillsStateAndDisablesSaveUntilChanged() {
        let subtasks = [Subtask(title: "Review code"), Subtask(title: "Ship build", isCompleted: true)]
        let task = makeTask(title: "Original", priority: .medium, subtasks: subtasks)
        let viewModel = makeViewModel(taskToEdit: task)

        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.screenTitle, AppConstants.EditTask.screenTitle)
        XCTAssertEqual(viewModel.saveButtonTitle, AppConstants.EditTask.saveButton)
        XCTAssertEqual(viewModel.state.title, "Original")
        XCTAssertEqual(viewModel.state.priority, .medium)
        XCTAssertEqual(viewModel.state.subtasks.map(\.title), ["Review code", "Ship build"])
        XCTAssertFalse(viewModel.state.isSaveEnabled)

        viewModel.updateTitle("Updated title")

        XCTAssertTrue(viewModel.state.isSaveEnabled)
    }

    func testEditModeCallsUpdateTaskOnSave() {
        let task = makeTask(title: "Original", priority: .medium)
        let updatedTask = makeTask(id: task.id, title: "Updated title", priority: .high)
        taskService.updateTaskResult = .success(updatedTask)

        let viewModel = makeViewModel(taskToEdit: task)
        let expectation = expectation(description: "Update success callback")

        viewModel.onUpdateSuccess = { task in
            XCTAssertEqual(task.title, "Updated title")
            expectation.fulfill()
        }

        viewModel.updateTitle("Updated title")
        viewModel.updatePriority(.high)
        viewModel.saveTask()

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(taskService.updatedTask?.id, task.id)
        XCTAssertEqual(taskService.updatedInput?.title, "Updated title")
        XCTAssertEqual(taskService.updatedInput?.priority, .high)
    }

    func testEditModeAllowsKeepingPastDueDate() {
        let pastDueDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let task = makeTask(title: "Original", priority: .medium, dueDate: pastDueDate)
        taskService.updateTaskResult = .success(task)

        let viewModel = makeViewModel(taskToEdit: task)
        let expectation = expectation(description: "Update with past due date succeeds")

        viewModel.onUpdateSuccess = { _ in
            expectation.fulfill()
        }

        viewModel.updateTitle("Updated title")
        viewModel.saveTask()

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(viewModel.state.dueDateError)
        XCTAssertEqual(taskService.updatedInput?.title, "Updated title")
    }

    func testSuggestPriorityRequiresTitle() {
        let viewModel = makeViewModel()

        viewModel.suggestPriority()

        XCTAssertEqual(viewModel.state.titleError, AppConstants.CreateTask.titleRequiredForAI)
        XCTAssertFalse(viewModel.state.isSuggestingPriority)
        XCTAssertEqual(aiService.suggestPriorityCallCount, 0)
    }

    func testSuggestPriorityUpdatesPriorityOnSuccess() {
        aiService.suggestPriorityResult = .success(.high)
        let viewModel = makeViewModel()
        let expectation = expectation(description: "AI success callback")

        viewModel.onAISuccess = { message in
            XCTAssertEqual(message, AppConstants.AI.prioritySuggested)
            expectation.fulfill()
        }

        viewModel.updateTitle("Ship release")
        viewModel.updateDescription("Finalize QA")
        viewModel.suggestPriority()

        XCTAssertTrue(viewModel.state.isSuggestingPriority)

        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(viewModel.state.isSuggestingPriority)
        XCTAssertEqual(viewModel.state.priority, .high)
        XCTAssertEqual(aiService.lastSuggestedTitle, "Ship release")
        XCTAssertEqual(aiService.lastSuggestedDescription, "Finalize QA")
        XCTAssertTrue(viewModel.state.isSaveEnabled)
    }

    func testSuggestPrioritySurfacesError() {
        aiService.suggestPriorityResult = .failure(.networkUnavailable)
        let viewModel = makeViewModel()
        let expectation = expectation(description: "AI error callback")

        viewModel.onAIError = { message in
            XCTAssertEqual(message, AppConstants.AI.networkUnavailable)
            expectation.fulfill()
        }

        viewModel.updateTitle("Ship release")
        viewModel.suggestPriority()

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(viewModel.state.priority)
    }

    func testSuggestPriorityDisabledWhenTitleEmpty() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.state.isSuggestPriorityEnabled)

        viewModel.updateTitle("Ship release")

        XCTAssertTrue(viewModel.state.isSuggestPriorityEnabled)
    }

    func testBreakIntoSubtasksRequiresTitleAndDescription() {
        let viewModel = makeViewModel()

        viewModel.breakIntoSubtasks()

        XCTAssertEqual(viewModel.state.titleError, AppConstants.CreateTask.titleRequiredForAI)
        XCTAssertEqual(viewModel.state.descriptionError, AppConstants.CreateTask.descriptionRequiredForAI)
        XCTAssertEqual(aiService.generateSubtasksCallCount, 0)

        viewModel.updateTitle("Ship release")
        viewModel.breakIntoSubtasks()

        XCTAssertNil(viewModel.state.titleError)
        XCTAssertEqual(viewModel.state.descriptionError, AppConstants.CreateTask.descriptionRequiredForAI)
        XCTAssertEqual(aiService.generateSubtasksCallCount, 0)
    }

    func testBreakIntoSubtasksUpdatesStateOnSuccess() {
        aiService.generateSubtasksResult = .success(["Write tests", "Update docs"])
        let viewModel = makeViewModel()
        let expectation = expectation(description: "Subtasks generated")

        viewModel.onAISuccess = { message in
            XCTAssertEqual(message, AppConstants.AI.subtasksGenerated)
            expectation.fulfill()
        }

        viewModel.updateTitle("Release app")
        viewModel.updateDescription("Version 1.0")
        viewModel.breakIntoSubtasks()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.state.subtasks.map(\.title), ["Write tests", "Update docs"])
        XCTAssertFalse(viewModel.state.subtasks[0].isCompleted)
    }

    func testBreakIntoSubtasksRequestsConfirmationWhenSubtasksExist() {
        let viewModel = makeViewModel()
        var confirmationRequested = false

        viewModel.onRegenerateConfirmationRequired = {
            confirmationRequested = true
        }

        viewModel.updateTitle("Release app")
        viewModel.updateDescription("Version 1.0")
        viewModel.addSubtask()
        viewModel.updateSubtaskTitle(id: viewModel.state.subtasks[0].id, title: "Existing subtask")
        viewModel.breakIntoSubtasks()

        XCTAssertTrue(confirmationRequested)
        XCTAssertEqual(aiService.generateSubtasksCallCount, 0)
    }

    func testConfirmRegenerateSubtasksReplacesExistingSubtasks() {
        aiService.generateSubtasksResult = .success(["New step 1", "New step 2"])
        let viewModel = makeViewModel()
        let expectation = expectation(description: "Subtasks regenerated")

        viewModel.onAISuccess = { _ in
            expectation.fulfill()
        }

        viewModel.updateTitle("Release app")
        viewModel.updateDescription("Version 1.0")
        viewModel.addSubtask()
        viewModel.updateSubtaskTitle(id: viewModel.state.subtasks[0].id, title: "Old subtask")
        viewModel.confirmRegenerateSubtasks()

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(viewModel.state.subtasks.map(\.title), ["New step 1", "New step 2"])
    }

    func testSubtaskCRUDUpdatesState() {
        let viewModel = makeViewModel()

        viewModel.addSubtask()
        let subtaskID = viewModel.state.subtasks[0].id

        viewModel.updateSubtaskTitle(id: subtaskID, title: "Draft summary")
        viewModel.toggleSubtask(id: subtaskID)

        XCTAssertEqual(viewModel.state.subtasks[0].title, "Draft summary")
        XCTAssertTrue(viewModel.state.subtasks[0].isCompleted)

        viewModel.deleteSubtask(id: subtaskID)

        XCTAssertTrue(viewModel.state.subtasks.isEmpty)
    }

    func testBreakIntoSubtasksEnabledOnEditMode() {
        let viewModel = makeViewModel(taskToEdit: makeTask(title: "Original", priority: .medium))

        viewModel.updateTitle("Updated")
        viewModel.updateDescription("Updated description")

        XCTAssertTrue(viewModel.state.isBreakIntoSubtasksEnabled)
    }

    func testEditModeSaveEnabledWhenSubtasksChange() {
        let subtasks = [Subtask(title: "Review code")]
        let task = makeTask(title: "Original", priority: .medium, subtasks: subtasks)
        let viewModel = makeViewModel(taskToEdit: task)

        XCTAssertFalse(viewModel.state.isSaveEnabled)

        viewModel.updateSubtaskTitle(id: subtasks[0].id, title: "Review pull request")

        XCTAssertTrue(viewModel.state.isSaveEnabled)
    }

    func testInsertSubtaskAddsTrimmedTitle() {
        let viewModel = makeViewModel()

        viewModel.insertSubtask(title: "  Draft summary  ")

        XCTAssertEqual(viewModel.state.subtasks.map(\.title), ["Draft summary"])
    }

    private func makeViewModel(taskToEdit: Task? = nil) -> CreateTaskViewModel {
        CreateTaskViewModel(
            taskToEdit: taskToEdit,
            validator: validator,
            taskService: taskService,
            aiService: aiService
        )
    }

    private func makeTask(
        id: String = "1",
        title: String,
        priority: TaskPriority,
        dueDate: Date? = nil,
        subtasks: [Subtask] = []
    ) -> Task {
        Task(
            id: id,
            serverID: id,
            title: title,
            description: "Description",
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            subtasks: subtasks,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - MockCreateTaskAIService

private final class MockCreateTaskAIService: AIServicing {

    var suggestPriorityResult: Result<TaskPriority, AIError> = .failure(.unknown)
    var generateSubtasksResult: Result<[String], AIError> = .failure(.unknown)
    var suggestPriorityCallCount = 0
    var generateSubtasksCallCount = 0
    var lastSuggestedTitle: String?
    var lastSuggestedDescription: String?
    var lastGeneratedTitle: String?
    var lastGeneratedDescription: String?

    func suggestPriority(
        title: String,
        description: String?,
        completion: @escaping (Result<TaskPriority, AIError>) -> Void
    ) {
        suggestPriorityCallCount += 1
        lastSuggestedTitle = title
        lastSuggestedDescription = description
        completion(suggestPriorityResult)
    }

    func generateSubtasks(
        title: String,
        description: String?,
        completion: @escaping (Result<[String], AIError>) -> Void
    ) {
        generateSubtasksCallCount += 1
        lastGeneratedTitle = title
        lastGeneratedDescription = description
        completion(generateSubtasksResult)
    }
}

// MARK: - MockCreateTaskService

private final class MockCreateTaskService: TaskServicing {

    var updateTaskResult: Result<Task, TaskError> = .failure(.updateFailed)
    var updatedTask: Task?
    var updatedInput: CreateTaskInput?

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        completion(.success([]))
    }

    func createTask(
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    ) {
        completion(.failure(.createFailed))
    }

    func updateTask(
        task: Task,
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    ) {
        updatedTask = task
        updatedInput = input
        completion(updateTaskResult)
    }

    func deleteTask(
        task: Task,
        completion: @escaping (Result<Void, TaskError>) -> Void
    ) {
        completion(.failure(.deleteFailed))
    }
}
