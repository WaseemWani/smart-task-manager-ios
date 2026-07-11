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
}
