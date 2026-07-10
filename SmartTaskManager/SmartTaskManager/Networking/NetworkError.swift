//
//  NetworkError.swift
//  SmartTaskManager
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case timedOut
    case networkUnavailable
    case cancelled
    case unknown
}
