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

        static func workloadAnalysis(tasks: [Task]) -> String {
            let taskLines = tasks.map(workloadTaskLine).joined(separator: "\n")
            return """
            You are a proactive task management assistant. Analyze the user's incomplete task workload and provide a smart daily summary.

            Respond with a JSON object only, no markdown or extra text, using this exact schema:
            {
              "summaryHeadline": "short focus headline",
              "summaryMessage": "1-2 sentence summary of how to optimize the day",
              "recommendedTaskId": "id from the task list",
              "recommendedPriority": "High" or "Medium" or "Low",
              "recommendationLabel": "e.g. High Recommendation",
              "recommendationReason": "brief rationale",
              "suggestedSubtasks": ["actionable subtask 1", "actionable subtask 2"]
            }

            Rules:
            - recommendedTaskId MUST be one of the provided task ids exactly
            - suggestedSubtasks must have at least \(AIConstants.minimumSubtaskCount) items for the recommended task
            - Prioritize overdue and due-today tasks, then high priority
            - suggestedSubtasks should help complete the recommended task only

            Tasks:
            \(taskLines)
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

        private static func workloadTaskLine(_ task: Task) -> String {
            let dueDate = task.dueDate.map { APIDateFormatter.apiDateString(from: $0) } ?? "none"
            let description = task.description?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if description.isEmpty {
                return "id: \(task.id) | title: \(task.title) | priority: \(task.priority.displayTitle) | due: \(dueDate) | subtasks: \(task.subtasks.count)"
            }

            return "id: \(task.id) | title: \(task.title) | priority: \(task.priority.displayTitle) | due: \(dueDate) | subtasks: \(task.subtasks.count) | description: \(description)"
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
