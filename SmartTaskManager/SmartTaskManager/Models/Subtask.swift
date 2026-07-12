//
//  Subtask.swift
//  SmartTaskManager
//

import Foundation

struct Subtask: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var isCompleted: Bool

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct RemoteSubtask: Codable, Equatable {
    let title: String
    let isCompleted: Bool

    init(subtask: Subtask) {
        title = subtask.title
        isCompleted = subtask.isCompleted
    }

    func toSubtask() -> Subtask? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return nil }
        return Subtask(title: trimmedTitle, isCompleted: isCompleted)
    }
}
