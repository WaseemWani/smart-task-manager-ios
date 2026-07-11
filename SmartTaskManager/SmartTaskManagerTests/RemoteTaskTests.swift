//
//  RemoteTaskTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class RemoteTaskTests: XCTestCase {

    func testRemoteTaskDecodesUpdateAtFallback() throws {
        let json = """
        {
          "id": "1",
          "title": "Sample Task",
          "priority": "High",
          "isCompleted": false,
          "createdAt": "2026-07-11T13:00:00Z",
          "updateAt": "2026-07-11T13:10:00Z"
        }
        """.data(using: .utf8)!

        let remoteTask = try JSONDecoder().decode(RemoteTask.self, from: json)

        XCTAssertEqual(remoteTask.updatedAt, "2026-07-11T13:10:00Z")
        XCTAssertEqual(remoteTask.toTask()?.priority, .high)
    }

    func testRemoteTaskDecodesMissingID() throws {
        let json = """
        {
          "userId": "1",
          "title": "Prepare AI Demo",
          "priority": "High",
          "dueDate": "2026-07-20",
          "isCompleted": false,
          "createdAt": "2026-07-11T13:00:00Z",
          "updatedAt": "2026-07-11T13:00:00Z"
        }
        """.data(using: .utf8)!

        let remoteTask = try JSONDecoder().decode(RemoteTask.self, from: json)

        XCTAssertFalse(remoteTask.id.isEmpty)
        XCTAssertNil(remoteTask.serverID)
        XCTAssertEqual(remoteTask.toTask()?.title, "Prepare AI Demo")
        XCTAssertFalse(remoteTask.toTask()?.isEditable ?? true)
    }

    func testRemoteTaskArrayDecodesMockAPIPayload() throws {
        let json = """
        [
          {
            "userId": "1",
            "title": "Prepare AI Demo",
            "priority": "High",
            "createdAt": "2026-07-11T13:00:00Z",
            "updatedAt": "2026-07-11T13:00:00Z"
          },
          {
            "id": "2",
            "title": "Test Task",
            "priority": "Medium",
            "createdAt": "2026-07-10T19:03:53.195Z",
            "updateAt": "2026-07-10T20:13:52.292Z"
          }
        ]
        """.data(using: .utf8)!

        let remoteTasks = try JSONDecoder().decode([RemoteTask].self, from: json)

        XCTAssertEqual(remoteTasks.count, 2)
        XCTAssertEqual(remoteTasks.compactMap { $0.toTask() }.count, 2)
    }

    func testCreateTaskRequestEncodesExpectedPayload() throws {
        let request = CreateTaskRequest(
            userId: "1",
            input: CreateTaskInput(
                title: "Test Task",
                description: "Testing API",
                priority: .medium,
                dueDate: APIDateFormatter.parse("2026-07-20")
            )
        )

        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["userId"] as? String, "1")
        XCTAssertEqual(json["title"] as? String, "Test Task")
        XCTAssertEqual(json["description"] as? String, "Testing API")
        XCTAssertEqual(json["priority"] as? String, "Medium")
        XCTAssertEqual(json["dueDate"] as? String, "2026-07-20")
        XCTAssertEqual(json["isCompleted"] as? Bool, false)
    }

    func testUpdateTaskRequestEncodesExpectedPayload() throws {
        let task = Task(
            id: "2",
            serverID: "2",
            title: "Original Task",
            description: "Original description",
            priority: .medium,
            dueDate: APIDateFormatter.parse("2026-07-20"),
            isCompleted: true,
            createdAt: APIDateFormatter.parse("2026-07-10T19:03:53.195Z")!,
            updatedAt: APIDateFormatter.parse("2026-07-10T20:13:52.292Z")!
        )

        let request = UpdateTaskRequest(
            userId: "1",
            task: task,
            input: CreateTaskInput(
                title: "Updated Task",
                description: "Updated description",
                priority: .high,
                dueDate: APIDateFormatter.parse("2026-07-25")
            )
        )

        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["userId"] as? String, "1")
        XCTAssertEqual(json["title"] as? String, "Updated Task")
        XCTAssertEqual(json["description"] as? String, "Updated description")
        XCTAssertEqual(json["priority"] as? String, "High")
        XCTAssertEqual(json["dueDate"] as? String, "2026-07-25")
        XCTAssertEqual(json["isCompleted"] as? Bool, true)
    }
}
