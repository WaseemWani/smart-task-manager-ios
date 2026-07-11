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
}
