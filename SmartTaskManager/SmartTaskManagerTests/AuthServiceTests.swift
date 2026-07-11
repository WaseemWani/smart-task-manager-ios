//
//  AuthServiceTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class AuthServiceTests: XCTestCase {

    private var networkManager: MockNetworkManager!
    private var sessionManager: MockSessionManager!
    private var authService: AuthService!

    override func setUp() {
        super.setUp()
        networkManager = MockNetworkManager()
        sessionManager = MockSessionManager()
        authService = AuthService(
            networkManager: networkManager,
            sessionManager: sessionManager,
            tokenGenerator: { "mock_session_token_test" }
        )
    }

    override func tearDown() {
        authService = nil
        sessionManager = nil
        networkManager = nil
        super.tearDown()
    }

    func testLoginSucceedsWithValidCredentials() {
        networkManager.result = .success([
            RemoteUser(id: "1", name: "Demo User", email: "user@email.com", password: "password123")
        ])

        let expectation = expectation(description: "Login succeeds")
        authService.login(email: "user@email.com", password: "password123") { result in
            switch result {
            case .success(let response):
                XCTAssertTrue(response.status)
                XCTAssertEqual(response.token, "mock_session_token_test")
                XCTAssertEqual(response.user.email, "user@email.com")
                XCTAssertEqual(self.sessionManager.savedToken, "mock_session_token_test")
                XCTAssertEqual(self.sessionManager.savedUser?.email, "user@email.com")
            case .failure:
                XCTFail("Expected successful login")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(networkManager.requestedEndpoint, .login)
    }

    func testLoginFailsWithInvalidCredentials() {
        networkManager.result = .success([
            RemoteUser(id: "1", name: "Demo User", email: "user@email.com", password: "password123")
        ])

        let expectation = expectation(description: "Login fails")
        authService.login(email: "user@email.com", password: "wrong-password") { result in
            switch result {
            case .success:
                XCTFail("Expected login failure")
            case .failure(let error):
                XCTAssertEqual(error, .invalidCredentials)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(sessionManager.savedToken)
    }

    func testLogoutClearsSession() {
        sessionManager.saveSession(
            token: "mock_session_token_test",
            user: User(id: "1", name: "Demo User", email: "user@email.com")
        )

        authService.logout()

        XCTAssertNil(sessionManager.savedToken)
        XCTAssertNil(sessionManager.savedUser)
    }

    func testLoginMapsTimeoutError() {
        networkManager.result = .failure(.timedOut)

        let expectation = expectation(description: "Timeout mapped")
        authService.login(email: "user@email.com", password: "password123") { result in
            XCTAssertEqual(result, .failure(.requestTimedOut))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testLoginMapsNetworkUnavailableError() {
        networkManager.result = .failure(.networkUnavailable)

        let expectation = expectation(description: "Network error mapped")
        authService.login(email: "user@email.com", password: "password123") { result in
            XCTAssertEqual(result, .failure(.networkUnavailable))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - MockNetworkManager

private final class MockNetworkManager: NetworkManaging {

    var requestedEndpoint: APIEndpoint?
    var result: Result<[RemoteUser], NetworkError> = .success([])

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        requestedEndpoint = endpoint

        switch result {
        case .success(let users):
            if let typedUsers = users as? T {
                completion(.success(typedUsers))
            } else {
                completion(.failure(.decodingFailed))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

// MARK: - MockSessionManager

private final class MockSessionManager: SessionManaging {

    var sessionToken: String?
    var currentUser: User?
    var savedToken: String?
    var savedUser: User?

    var isLoggedIn: Bool { restoreSession() != nil }

    var currentSession: UserSession? { restoreSession() }

    func saveSession(token: String, user: User) {
        savedToken = token
        savedUser = user
        sessionToken = token
        currentUser = user
    }

    func restoreSession() -> UserSession? {
        guard let token = sessionToken, let user = currentUser, !token.isEmpty else {
            return nil
        }
        return UserSession(token: token, user: user)
    }

    func clearSession() {
        sessionToken = nil
        currentUser = nil
        savedToken = nil
        savedUser = nil
    }
}
