//
//  TaskServiceTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class TaskServiceTests: XCTestCase {

    private var networkManager: MockTaskNetworkManager!
    private var sessionManager: MockTaskSessionManager!
    private var taskService: TaskService!

    override func setUp() {
        super.setUp()
        networkManager = MockTaskNetworkManager()
        sessionManager = MockTaskSessionManager()
        taskService = TaskService(
            networkManager: networkManager,
            sessionManager: sessionManager
        )
    }

    override func tearDown() {
        taskService = nil
        sessionManager = nil
        networkManager = nil
        super.tearDown()
    }

    func testFetchTasksReturnsMappedTasks() {
        networkManager.fetchTasksResult = .success([
            RemoteTask(
                id: "1",
                userId: "1",
                title: "Prepare AI Demo",
                description: "Demo description",
                priority: "High",
                dueDate: "2026-07-20",
                isCompleted: false,
                createdAt: "2026-07-11T13:00:00Z",
                updatedAt: "2026-07-11T13:00:00Z"
            )
        ])

        let expectation = expectation(description: "Fetch tasks succeeds")
        taskService.fetchTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.id, "1")
                XCTAssertEqual(tasks.first?.title, "Prepare AI Demo")
                XCTAssertEqual(tasks.first?.priority, .high)
            case .failure:
                XCTFail("Expected successful fetch")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(networkManager.requestedEndpoint, .tasks)
    }

    func testFetchTasksMapsNetworkError() {
        networkManager.fetchTasksResult = .failure(.networkUnavailable)

        let expectation = expectation(description: "Fetch tasks fails")
        taskService.fetchTasks { result in
            XCTAssertEqual(result, .failure(.loadFailed))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCreateTaskPostsRequestAndReturnsTask() {
        sessionManager.user = User(id: "1", name: "Demo User", email: "user@email.com")
        networkManager.createTaskResult = .success(
            RemoteTask(
                id: "2",
                userId: "1",
                title: "Test Task",
                description: "Testing API",
                priority: "Medium",
                dueDate: "2026-07-20",
                isCompleted: false,
                createdAt: "2026-07-10T19:03:53.195Z",
                updatedAt: "2026-07-10T20:13:52.292Z"
            )
        )

        let input = CreateTaskInput(
            title: "Test Task",
            description: "Testing API",
            priority: .medium,
            dueDate: APIDateFormatter.parse("2026-07-20")
        )

        let expectation = expectation(description: "Create task succeeds")
        taskService.createTask(input: input) { result in
            switch result {
            case .success(let task):
                XCTAssertEqual(task.id, "2")
                XCTAssertEqual(task.title, "Test Task")
                XCTAssertEqual(task.priority, .medium)
            case .failure:
                XCTFail("Expected successful create")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(networkManager.requestedEndpoint?.method, .post)
        XCTAssertEqual(networkManager.requestedEndpoint?.path, "/tasks")
    }

    func testCreateTaskFailsWhenUserNotLoggedIn() {
        let input = CreateTaskInput(
            title: "Test Task",
            description: nil,
            priority: .low,
            dueDate: nil
        )

        let expectation = expectation(description: "Create task requires login")
        taskService.createTask(input: input) { result in
            XCTAssertEqual(result, .failure(.notLoggedIn))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(networkManager.requestedEndpoint)
    }
}

// MARK: - MockTaskNetworkManager

private final class MockTaskNetworkManager: NetworkManaging {

    var requestedEndpoint: APIEndpoint?
    var fetchTasksResult: Result<[RemoteTask], NetworkError> = .success([])
    var createTaskResult: Result<RemoteTask, NetworkError> = .failure(.noData)

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        requestedEndpoint = endpoint

        if responseType == [RemoteTask].self {
            completion(fetchTasksResult.map { $0 as! T })
            return
        }

        if responseType == RemoteTask.self {
            completion(createTaskResult.map { $0 as! T })
            return
        }

        completion(.failure(.decodingFailed))
    }
}

// MARK: - MockTaskSessionManager

private final class MockTaskSessionManager: SessionManaging {

    var user: User?

    var isLoggedIn: Bool { user != nil }

    var currentSession: UserSession? {
        guard let user else { return nil }
        return UserSession(token: "mock_token", user: user)
    }

    func saveSession(token: String, user: User) {
        self.user = user
    }

    func restoreSession() -> UserSession? {
        currentSession
    }

    func clearSession() {
        user = nil
    }
}
