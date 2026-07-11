//
//  AIServiceTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class AIServiceTests: XCTestCase {

    private var aiService: AIService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil
    }

    override func tearDown() {
        aiService = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSuggestPriorityReturnsHigh() {
        aiService = makeService(apiKey: "test-api-key")
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("generateContent") == true)
            XCTAssertEqual(request.httpMethod, HTTPMethod.post.rawValue)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Self.geminiResponseJSON(text: "High")
            return (response, data)
        }

        let expectation = expectation(description: "Priority suggested")
        aiService.suggestPriority(title: "Ship release", description: "Finalize QA and deploy") { result in
            XCTAssertEqual(result, .success(.high))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSuggestPriorityFailsWhenAPIKeyMissing() {
        aiService = makeService(apiKey: nil)

        let expectation = expectation(description: "Missing API key")
        aiService.suggestPriority(title: "Ship release", description: nil) { result in
            XCTAssertEqual(result, .failure(.missingAPIKey))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSuggestPriorityFailsForUnrecognizedResponse() {
        aiService = makeService(apiKey: "test-api-key")
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Self.geminiResponseJSON(text: "Urgent")
            return (response, data)
        }

        let expectation = expectation(description: "Unrecognized priority")
        aiService.suggestPriority(title: "Ship release", description: nil) { result in
            XCTAssertEqual(result, .failure(.unrecognizedPriority))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testGenerateSubtasksReturnsParsedArray() {
        aiService = makeService(apiKey: "test-api-key")
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Self.geminiResponseJSON(
                text: "[\"Write tests\", \"Update docs\"]"
            )
            return (response, data)
        }

        let expectation = expectation(description: "Subtasks generated")
        aiService.generateSubtasks(title: "Release app", description: "Version 1.0") { result in
            XCTAssertEqual(result, .success(["Write tests", "Update docs"]))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testGenerateSubtasksFailsWhenFewerThanMinimumReturned() {
        aiService = makeService(apiKey: "test-api-key")
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Self.geminiResponseJSON(text: "[\"Only one subtask\"]")
            return (response, data)
        }

        let expectation = expectation(description: "Insufficient subtasks")
        aiService.generateSubtasks(title: "Release app", description: nil) { result in
            XCTAssertEqual(result, .failure(.insufficientSubtasks))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testGenerateSubtasksReturnsHTTPError() {
        aiService = makeService(apiKey: "test-api-key")
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 429,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let expectation = expectation(description: "HTTP error")
        aiService.generateSubtasks(title: "Release app", description: nil) { result in
            XCTAssertEqual(result, .failure(.httpError(statusCode: 429)))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private func makeService(apiKey: String?) -> AIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return AIService(session: session, keyProvider: MockAIKeyProvider(apiKey: apiKey))
    }

    private static func geminiResponseJSON(text: String) -> Data {
        """
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  { "text": "\(text)" }
                ]
              }
            }
          ]
        }
        """.data(using: .utf8)!
    }
}

// MARK: - MockAIKeyProvider

private final class MockAIKeyProvider: AIKeyProviding {
    private let apiKey: String?

    init(apiKey: String?) {
        self.apiKey = apiKey
    }

    func geminiAPIKey() -> String? {
        apiKey
    }
}
