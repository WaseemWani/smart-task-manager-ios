//
//  TaskDueDatePresenterTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class TaskDueDatePresenterTests: XCTestCase {

    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        self.calendar = calendar
    }

    func testPresentationShowsTodayForDueDateToday() {
        let referenceDate = calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 21,
            minute: 3
        ))!
        let dueDate = calendar.startOfDay(for: referenceDate)

        let presentation = TaskDueDatePresenter.presentation(
            for: dueDate,
            referenceDate: referenceDate
        )

        XCTAssertEqual(presentation?.text, AppConstants.CreateTask.todayPrefix)
        XCTAssertEqual(presentation?.systemIconName, "calendar")
    }

    func testPresentationShowsTomorrowForDueDateTomorrow() {
        let referenceDate = calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 21,
            minute: 3
        ))!
        let dueDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate))!

        let presentation = TaskDueDatePresenter.presentation(
            for: dueDate,
            referenceDate: referenceDate
        )

        XCTAssertEqual(presentation?.text, AppConstants.TaskList.tomorrow)
        XCTAssertEqual(presentation?.systemIconName, "calendar")
    }

    func testPresentationDoesNotShowTimeForParsedApiDateOnlyValue() {
        let dueDate = APIDateFormatter.parse("2026-07-11")
        let referenceDate = calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 21,
            minute: 3
        ))!

        let presentation = TaskDueDatePresenter.presentation(
            for: dueDate,
            referenceDate: referenceDate
        )

        XCTAssertEqual(presentation?.text, AppConstants.CreateTask.todayPrefix)
        XCTAssertNotEqual(presentation?.text, "5:30 AM")
    }
}
