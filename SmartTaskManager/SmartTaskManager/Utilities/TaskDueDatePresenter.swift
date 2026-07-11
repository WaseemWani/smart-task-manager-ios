//
//  TaskDueDatePresenter.swift
//  SmartTaskManager
//

import Foundation

struct TaskDueDatePresentation: Equatable {
    let text: String
    let systemIconName: String
}

enum TaskDueDatePresenter {

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func presentation(for dueDate: Date?, referenceDate: Date = Date()) -> TaskDueDatePresentation? {
        guard let dueDate else { return nil }

        let calendar = Calendar.current

        if calendar.isDateInToday(dueDate) {
            return TaskDueDatePresentation(
                text: timeFormatter.string(from: dueDate),
                systemIconName: "clock"
            )
        }

        if calendar.isDateInTomorrow(dueDate) {
            return TaskDueDatePresentation(
                text: AppConstants.TaskList.tomorrow,
                systemIconName: "calendar"
            )
        }

        return TaskDueDatePresentation(
            text: dateFormatter.string(from: dueDate),
            systemIconName: "calendar"
        )
    }

    static func formDisplay(for dueDate: Date?, referenceDate: Date = Date()) -> (text: String, isPlaceholder: Bool) {
        guard let dueDate else {
            return (AppConstants.CreateTask.selectDate, true)
        }

        let calendar = Calendar.current
        let monthDay = monthDayFormatter.string(from: dueDate)

        if calendar.isDateInToday(dueDate) {
            return ("\(AppConstants.CreateTask.todayPrefix), \(monthDay)", false)
        }

        if calendar.isDateInTomorrow(dueDate) {
            return ("\(AppConstants.TaskList.tomorrow), \(monthDay)", false)
        }

        return (monthDayFormatter.string(from: dueDate), false)
    }

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter
    }()
}
