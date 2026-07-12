//
//  CreateTaskViewModelTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class CreateTaskViewModelTests: XCTestCase {

    private var taskService: MockCreateTaskService!
    private var validator: InputValidator!

    override func setUp() {
        super.setUp()
        taskService = MockCreateTaskService()
        validator = InputValidator()
    }

    override func tearDown() {
        validator = nil
        taskService = nil
        super.tearDown()
    }

    func testEditModePrefillsStateAndDisablesSaveUntilChanged() {
        let task = makeTask(title: "Original", priority: .medium)
        let viewModel = CreateTaskViewModel(taskToEdit: task, validator: validator, taskService: taskService)

        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.screenTitle, AppConstants.EditTask.screenTitle)
        XCTAssertEqual(viewModel.saveButtonTitle, AppConstants.EditTask.saveButton)
        XCTAssertEqual(viewModel.state.title, "Original")
        XCTAssertEqual(viewModel.state.priority, .medium)
        XCTAssertFalse(viewModel.state.isSaveEnabled)

        viewModel.updateTitle("Updated title")

        XCTAssertTrue(viewModel.state.isSaveEnabled)
    }

    func testEditModeCallsUpdateTaskOnSave() {
        let task = makeTask(title: "Original", priority: .medium)
        let updatedTask = makeTask(id: task.id, title: "Updated title", priority: .high)
        taskService.updateTaskResult = .success(updatedTask)

        let viewModel = CreateTaskViewModel(taskToEdit: task, validator: validator, taskService: taskService)
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

        let viewModel = CreateTaskViewModel(taskToEdit: task, validator: validator, taskService: taskService)
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

    private func makeTask(
        id: String = "1",
        title: String,
        priority: TaskPriority,
        dueDate: Date? = nil
    ) -> Task {
        Task(
            id: id,
            serverID: id,
            title: title,
            description: "Description",
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
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
}
