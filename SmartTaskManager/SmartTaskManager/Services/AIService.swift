//
//  AIService.swift
//  SmartTaskManager
//

import Foundation

// MARK: - AIServicing

protocol AIServicing {
    func suggestPriority(
        title: String,
        description: String?,
        completion: @escaping (Result<TaskPriority, AIError>) -> Void
    )
    func generateSubtasks(
        title: String,
        description: String?,
        completion: @escaping (Result<[String], AIError>) -> Void
    )
}

// MARK: - AIKeyProviding

protocol AIKeyProviding {
    func geminiAPIKey() -> String?
}

struct BundleAIKeyProvider: AIKeyProviding {

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func geminiAPIKey() -> String? {
        guard let rawValue = bundle.object(forInfoDictionaryKey: AIConstants.infoPlistAPIKey) as? String else {
            return nil
        }

        let trimmed = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

        guard !trimmed.isEmpty, !trimmed.contains("$(") else {
            return nil
        }

        return trimmed
    }
}

// MARK: - AIService

final class AIService: AIServicing {

    private let session: URLSession
    private let keyProvider: AIKeyProviding
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        keyProvider: AIKeyProviding = BundleAIKeyProvider(),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.keyProvider = keyProvider
        self.encoder = encoder
        self.decoder = decoder
    }

    func suggestPriority(
        title: String,
        description: String?,
        completion: @escaping (Result<TaskPriority, AIError>) -> Void
    ) {
        let prompt = AIConstants.Prompts.prioritySuggestion(title: title, description: description)

        generateContent(prompt: prompt) { result in
            switch result {
            case .success(let text):
                guard let priority = Self.parsePriority(from: text) else {
                    completion(.failure(.unrecognizedPriority))
                    return
                }
                completion(.success(priority))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func generateSubtasks(
        title: String,
        description: String?,
        completion: @escaping (Result<[String], AIError>) -> Void
    ) {
        let prompt = AIConstants.Prompts.subtaskGeneration(title: title, description: description)

        generateContent(prompt: prompt) { result in
            switch result {
            case .success(let text):
                guard let subtasks = Self.parseSubtasks(from: text) else {
                    completion(.failure(.decodingFailed))
                    return
                }

                guard subtasks.count >= AIConstants.minimumSubtaskCount else {
                    completion(.failure(.insufficientSubtasks))
                    return
                }

                completion(.success(subtasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private func generateContent(
        prompt: String,
        completion: @escaping (Result<String, AIError>) -> Void
    ) {
        guard let apiKey = keyProvider.geminiAPIKey() else {
            completion(.failure(.missingAPIKey))
            return
        }

        guard let urlRequest = makeURLRequest(apiKey: apiKey, prompt: prompt) else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: urlRequest) { [decoder] data, response, error in
            if let error = error as? URLError {
                completion(.failure(Self.mapURLError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(.noData))
                return
            }

            do {
                let geminiResponse = try decoder.decode(GeminiGenerateContentResponse.self, from: data)
                guard let text = Self.extractText(from: geminiResponse) else {
                    completion(.failure(.emptyResponse))
                    return
                }
                completion(.success(text))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }

    private func makeURLRequest(apiKey: String, prompt: String) -> URLRequest? {
        let path = "/models/\(AIConstants.model):generateContent"
        guard var components = URLComponents(string: AIConstants.baseURL + path) else {
            return nil
        }

        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else {
            return nil
        }

        let requestBody = GeminiGenerateContentRequest(
            contents: [
                GeminiContent(parts: [GeminiPart(text: prompt)])
            ]
        )

        guard let body = try? encoder.encode(requestBody) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.timeoutInterval = AIConstants.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }

    private static func extractText(from response: GeminiGenerateContentResponse) -> String? {
        let text = response.candidates?
            .compactMap { $0.content?.parts }
            .flatMap { $0 }
            .compactMap(\.text)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text, !text.isEmpty else {
            return nil
        }

        return text
    }

    private static func parsePriority(from text: String) -> TaskPriority? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".\"'"))
            .lowercased()

        switch normalized {
        case "high":
            return .high
        case "medium":
            return .medium
        case "low":
            return .low
        default:
            return TaskPriority.fromAPIValue(text)
        }
    }

    private static func parseSubtasks(from text: String) -> [String]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if let data = trimmed.data(using: .utf8),
           let subtasks = try? JSONDecoder().decode([String].self, from: data) {
            return sanitizeSubtasks(subtasks)
        }

        if let startIndex = trimmed.firstIndex(of: "["),
           let endIndex = trimmed.lastIndex(of: "]"),
           startIndex < endIndex {
            let jsonSlice = String(trimmed[startIndex...endIndex])
            if let data = jsonSlice.data(using: .utf8),
               let subtasks = try? JSONDecoder().decode([String].self, from: data) {
                return sanitizeSubtasks(subtasks)
            }
        }

        let lineSeparated = trimmed
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { line in
                line.trimmingCharacters(in: CharacterSet(charactersIn: "-*•"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }

        let sanitized = sanitizeSubtasks(lineSeparated)
        return sanitized.isEmpty ? nil : sanitized
    }

    private static func sanitizeSubtasks(_ subtasks: [String]) -> [String] {
        subtasks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func mapURLError(_ error: URLError) -> AIError {
        switch error.code {
        case .timedOut:
            return .timedOut
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return .networkUnavailable
        case .cancelled:
            return .cancelled
        default:
            return .unknown
        }
    }
}
