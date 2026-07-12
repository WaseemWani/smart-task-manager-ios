//
//  AIError.swift
//  SmartTaskManager
//

import Foundation

enum AIError: Error, Equatable {
    case missingAPIKey
    case invalidURL
    case noData
    case invalidResponse
    case unauthorized
    case quotaExceeded
    case modelUnavailable
    case httpError(statusCode: Int)
    case decodingFailed
    case timedOut
    case networkUnavailable
    case cancelled
    case emptyResponse
    case unrecognizedPriority
    case insufficientSubtasks
    case noEligibleTasks
    case invalidWorkloadInsight
    case unknown

    var message: String {
        switch self {
        case .missingAPIKey:
            return AppConstants.AI.missingAPIKey
        case .invalidURL:
            return AppConstants.AI.invalidURL
        case .noData:
            return AppConstants.AI.noData
        case .invalidResponse:
            return AppConstants.AI.invalidResponse
        case .unauthorized:
            return AppConstants.AI.unauthorized
        case .quotaExceeded:
            return AppConstants.AI.quotaExceeded
        case .modelUnavailable:
            return AppConstants.AI.modelUnavailable
        case .httpError:
            return AppConstants.AI.requestFailed
        case .decodingFailed:
            return AppConstants.AI.decodingFailed
        case .timedOut:
            return AppConstants.AI.timedOut
        case .networkUnavailable:
            return AppConstants.AI.networkUnavailable
        case .cancelled:
            return AppConstants.AI.cancelled
        case .emptyResponse:
            return AppConstants.AI.emptyResponse
        case .unrecognizedPriority:
            return AppConstants.AI.unrecognizedPriority
        case .insufficientSubtasks:
            return AppConstants.AI.insufficientSubtasks
        case .noEligibleTasks:
            return AppConstants.AI.noEligibleTasks
        case .invalidWorkloadInsight:
            return AppConstants.AI.invalidWorkloadInsight
        case .unknown:
            return AppConstants.AI.unknown
        }
    }
}
