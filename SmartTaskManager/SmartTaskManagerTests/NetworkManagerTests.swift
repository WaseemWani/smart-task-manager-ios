//
//  NetworkManagerTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class NetworkManagerTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testRequestDecodesSuccessfulResponse() {
        let usersJSON = """
        [{"name":"Demo User","email":"user@email.com","password":"password123"}]
        """.data(using: .utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, usersJSON)
        }

        let session = makeMockSession()
        let networkManager = NetworkManager(session: session, maxRetryCount: 0, retryInterval: 0)

        let expectation = expectation(description: "Request succeeds")
        networkManager.request(endpoint: .users, responseType: [RemoteUser].self) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.email, "user@email.com")
            case .failure:
                XCTFail("Expected successful response")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRequestReturnsHTTPError() {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let session = makeMockSession()
        let networkManager = NetworkManager(session: session, maxRetryCount: 0, retryInterval: 0)

        let expectation = expectation(description: "HTTP error returned")
        networkManager.request(endpoint: .users, responseType: [RemoteUser].self) { result in
            XCTAssertEqual(result, .failure(.httpError(statusCode: 500)))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRequestReturnsTimeoutError() {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        let session = makeMockSession()
        let networkManager = NetworkManager(session: session, maxRetryCount: 0, retryInterval: 0)

        let expectation = expectation(description: "Timeout returned")
        networkManager.request(endpoint: .users, responseType: [RemoteUser].self) { result in
            XCTAssertEqual(result, .failure(.timedOut))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func makeMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch let error as URLError {
            client?.urlProtocol(self, didFailWithError: error)
        } catch {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
        }
    }

    override func stopLoading() {}
}
