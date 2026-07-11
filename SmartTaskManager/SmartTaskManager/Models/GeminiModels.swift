//
//  GeminiModels.swift
//  SmartTaskManager
//

import Foundation

// MARK: - Request

struct GeminiGenerateContentRequest: Encodable, Equatable {
    let contents: [GeminiContent]
}

struct GeminiContent: Encodable, Equatable {
    let parts: [GeminiPart]
}

struct GeminiPart: Encodable, Equatable {
    let text: String
}

// MARK: - Response

struct GeminiGenerateContentResponse: Decodable, Equatable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Decodable, Equatable {
    let content: GeminiResponseContent?
}

struct GeminiResponseContent: Decodable, Equatable {
    let parts: [GeminiResponsePart]?
}

struct GeminiResponsePart: Decodable, Equatable {
    let text: String?
}
