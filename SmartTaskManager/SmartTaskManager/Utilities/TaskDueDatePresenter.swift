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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func presentation(for dueDate: Date?, referenceDate: Date = Date()) -> TaskDueDatePresentation? {
        guard let dueDate else { return nil }

        let calendar = Calendar.current

        if calendar.isDate(dueDate, inSameDayAs: referenceDate) {
            return TaskDueDatePresentation(
                text: AppConstants.CreateTask.todayPrefix,
                systemIconName: "calendar"
            )
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate)),
           calendar.isDate(dueDate, inSameDayAs: tomorrow) {
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

        if calendar.isDate(dueDate, inSameDayAs: referenceDate) {
            return ("\(AppConstants.CreateTask.todayPrefix), \(monthDay)", false)
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate)),
           calendar.isDate(dueDate, inSameDayAs: tomorrow) {
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
