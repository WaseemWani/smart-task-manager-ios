//
//  WorkloadInsight.swift
//  SmartTaskManager
//

import Foundation

// MARK: - SuggestedSubtaskItem

struct SuggestedSubtaskItem: Equatable {
    let title: String
}

// MARK: - WorkloadInsight

struct WorkloadInsight: Equatable {
    let summaryHeadline: String
    let summaryMessage: String
    let recommendedTaskID: String
    let recommendedPriority: TaskPriority
    let recommendationLabel: String
    let recommendationReason: String
    let suggestedSubtasks: [SuggestedSubtaskItem]
}

// MARK: - AIWorkloadInsightPayload

struct AIWorkloadInsightPayload: Decodable, Equatable {
    let summaryHeadline: String
    let summaryMessage: String
    let recommendedTaskId: String
    let recommendedPriority: String
    let recommendationLabel: String
    let recommendationReason: String
    let suggestedSubtasks: [String]
}
