//
//  TaskServiceTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class TaskServiceTests: XCTestCase {

    private var taskStore: MockTaskStore!
    private var taskService: TaskService!

    override func setUp() {
        super.setUp()
        taskStore = MockTaskStore()
        taskService = TaskService(taskStore: taskStore)
    }

    override func tearDown() {
        taskService = nil
        taskStore = nil
        super.tearDown()
    }

    func testFetchTasksReturnsEmptyListFromEmptyTaskStore() {
        let service = TaskService()

        let expectation = expectation(description: "Fetch tasks returns empty list")
        service.fetchTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertTrue(tasks.isEmpty)
            case .failure:
                XCTFail("Expected successful fetch")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchTasksReturnsTasksFromStore() {
        let sampleTasks = [TaskServiceTests.makeTask(id: "1"), TaskServiceTests.makeTask(id: "2")]
        taskStore.result = .success(sampleTasks)

        let expectation = expectation(description: "Fetch tasks returns stored tasks")
        taskService.fetchTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks, sampleTasks)
            case .failure:
                XCTFail("Expected successful fetch")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(taskStore.fetchTasksCallCount, 1)
    }

    func testFetchTasksPropagatesStoreError() {
        taskStore.result = .failure(.loadFailed)

        let expectation = expectation(description: "Fetch tasks returns error")
        taskService.fetchTasks { result in
            switch result {
            case .success:
                XCTFail("Expected fetch failure")
            case .failure(let error):
                XCTAssertEqual(error, .loadFailed)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private static func makeTask(id: String) -> Task {
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        return Task(
            id: id,
            title: "Sample task",
            description: nil,
            priority: .medium,
            dueDate: nil,
            isCompleted: false,
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }
}

// MARK: - MockTaskStore

private final class MockTaskStore: TaskStoreReading {

    var result: Result<[Task], TaskError> = .success([])
    private(set) var fetchTasksCallCount = 0

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        fetchTasksCallCount += 1
        completion(result)
    }
}
