//
//  TaskTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class TaskTests: XCTestCase {

    func testTaskPriorityDisplayTitles() {
        XCTAssertEqual(TaskPriority.high.displayTitle, AppConstants.TaskList.highPriority)
        XCTAssertEqual(TaskPriority.medium.displayTitle, AppConstants.TaskList.mediumPriority)
        XCTAssertEqual(TaskPriority.low.displayTitle, AppConstants.TaskList.lowPriority)
    }

    func testTaskEncodesAndDecodes() throws {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let dueDate = Date(timeIntervalSince1970: 1_700_086_400)
        let task = Task(
            id: "1",
            title: "Quarterly review report",
            description: "Prepare Q1 summary",
            priority: .high,
            dueDate: dueDate,
            isCompleted: false,
            createdAt: createdAt,
            updatedAt: createdAt
        )

        let data = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(Task.self, from: data)

        XCTAssertEqual(decoded, task)
    }
}
