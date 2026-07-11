//
//  APIDateFormatter.swift
//  SmartTaskManager
//

import Foundation

enum APIDateFormatter {

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let iso8601FractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601Formatter = ISO8601DateFormatter()

    static func parse(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        if let date = iso8601FractionalFormatter.date(from: value) {
            return date
        }

        if let date = iso8601Formatter.date(from: value) {
            return date
        }

        return dateOnlyFormatter.date(from: value)
    }

    static func apiDateString(from date: Date) -> String {
        dateOnlyFormatter.string(from: date)
    }
}
