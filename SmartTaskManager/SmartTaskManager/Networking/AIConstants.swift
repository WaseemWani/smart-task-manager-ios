//
//  AIConstants.swift
//  SmartTaskManager
//

import Foundation

enum AIConstants {

    static let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    /// `gemini-flash-latest` tracks Google's current free-tier flash model. Older IDs such as
    static let model = "gemini-flash-latest"
    static let requestTimeout: TimeInterval = 30
    static let minimumSubtaskCount = 2
    static let infoPlistAPIKey = "GEMINI_API_KEY"

    enum Prompts {
        static func prioritySuggestion(title: String, description: String?) -> String {
            let details = taskDetails(title: title, description: description)
            return """
            You are a task management assistant. Given the task below, respond with exactly one word: High, Medium, or Low. No other text.

            \(details)
            """
        }

        static func subtaskGeneration(title: String, description: String?) -> String {
            let details = taskDetails(title: title, description: description)
            return """
            You are a task management assistant. Given the task below, break it into actionable subtasks.
            Respond with a JSON array of strings only, with at least \(AIConstants.minimumSubtaskCount) items.
            Example: ["Subtask 1", "Subtask 2"]

            \(details)
            """
        }

        private static func taskDetails(title: String, description: String?) -> String {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDescription = description?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if trimmedDescription.isEmpty {
                return "Title: \(trimmedTitle)"
            }

            return """
            Title: \(trimmedTitle)
            Description: \(trimmedDescription)
            """
        }
    }
}
