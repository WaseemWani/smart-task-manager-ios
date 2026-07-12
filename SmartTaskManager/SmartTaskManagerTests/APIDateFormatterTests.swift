//
//  APIDateFormatterTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class APIDateFormatterTests: XCTestCase {

    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        self.calendar = calendar
    }

    func testParseDateOnlyUsesLocalCalendarDay() {
        let date = APIDateFormatter.parse("2026-07-11")
        let calendar = Calendar.current

        XCTAssertNotNil(date)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 11)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
    }

    func testApiDateStringUsesLocalCalendarDay() {
        let date = calendar.date(from: DateComponents(
            year: 2026,
            month: 7,
            day: 11,
            hour: 21,
            minute: 3
        ))!

        XCTAssertEqual(APIDateFormatter.apiDateString(from: date, calendar: calendar), "2026-07-11")
    }

    func testDateOnlyRoundTrip() {
        let calendar = Calendar.current
        let original = calendar.date(from: DateComponents(year: 2026, month: 7, day: 11))!
        let apiValue = APIDateFormatter.apiDateString(from: original, calendar: calendar)
        let parsed = APIDateFormatter.parse(apiValue)

        XCTAssertEqual(apiValue, "2026-07-11")
        XCTAssertTrue(calendar.isDate(original, inSameDayAs: parsed!))
    }

    func testParseISO8601TimestampPreservesInstant() throws {
        let date = try XCTUnwrap(APIDateFormatter.parse("2026-07-11T13:00:00Z"))

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        XCTAssertEqual(utcCalendar.component(.hour, from: date), 13)
    }
}
