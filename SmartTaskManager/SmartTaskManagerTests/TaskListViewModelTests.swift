//
//  TaskListViewModelTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class TaskListViewModelTests: XCTestCase {

    private var taskService: MockTaskListService!

    override func setUp() {
        super.setUp()
        taskService = MockTaskListService()
    }

    override func tearDown() {
        taskService = nil
        super.tearDown()
    }

    func testToggleCompletionOptimisticallyUpdatesState() {
        let task = makeTask(isCompleted: false)
        taskService.fetchResult = .success([task])
        taskService.updateTaskResult = .success(makeTask(isCompleted: true))

        let viewModel = TaskListViewModel(taskService: taskService)
        waitForLoadedState(viewModel)

        viewModel.toggleCompletion(for: task.id)

        guard case .loaded(let tasks) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertTrue(tasks[0].isCompleted)
        XCTAssertTrue(taskService.updatedTask?.isCompleted ?? false)
    }

    func testToggleCompletionRevertsStateOnFailure() {
        let task = makeTask(isCompleted: false)
        taskService.fetchResult = .success([task])
        taskService.updateTaskResult = .failure(.updateFailed)

        let viewModel = TaskListViewModel(taskService: taskService)
        waitForLoadedState(viewModel)

        let errorExpectation = expectation(description: "Toggle error callback")
        viewModel.onToggleError = { message in
            XCTAssertEqual(message, AppConstants.TaskList.updateFailed)
            errorExpectation.fulfill()
        }

        viewModel.toggleCompletion(for: task.id)

        wait(for: [errorExpectation], timeout: 1)

        guard case .loaded(let tasks) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertFalse(tasks[0].isCompleted)
    }

    func testToggleCompletionReportsNonEditableTask() {
        let task = makeTask(serverID: nil, isCompleted: false)
        taskService.fetchResult = .success([task])

        let viewModel = TaskListViewModel(taskService: taskService)
        waitForLoadedState(viewModel)

        let errorExpectation = expectation(description: "Non-editable error callback")
        viewModel.onToggleError = { message in
            XCTAssertEqual(message, AppConstants.TaskList.taskNotEditable)
            errorExpectation.fulfill()
        }

        viewModel.toggleCompletion(for: task.id)

        wait(for: [errorExpectation], timeout: 1)
        XCTAssertNil(taskService.updatedTask)
    }

    private func waitForLoadedState(_ viewModel: TaskListViewModel, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Tasks loaded")

        viewModel.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)

        guard case .loaded = viewModel.state else {
            XCTFail("Expected loaded state", file: file, line: line)
            return
        }
    }

    private func makeTask(
        id: String = "1",
        serverID: String? = "1",
        isCompleted: Bool
    ) -> Task {
        Task(
            id: id,
            serverID: serverID,
            title: "Test Task",
            description: "Description",
            priority: .medium,
            dueDate: nil,
            isCompleted: isCompleted,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - MockTaskListService

private final class MockTaskListService: TaskServicing {

    var fetchResult: Result<[Task], TaskError> = .success([])
    var updateTaskResult: Result<Task, TaskError> = .failure(.updateFailed)
    var updatedTask: Task?

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        completion(fetchResult)
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
        completion(updateTaskResult)
    }
}
