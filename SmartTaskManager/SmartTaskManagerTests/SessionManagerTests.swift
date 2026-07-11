//
//  SessionManagerTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class SessionManagerTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "SessionManagerTests")!
        userDefaults.removePersistentDomain(forName: "SessionManagerTests")
        sessionManager = SessionManager(storage: StorageManager(userDefaults: userDefaults))
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "SessionManagerTests")
        sessionManager = nil
        userDefaults = nil
        super.tearDown()
    }

    func testSaveSessionAllowsRestoration() {
        let user = User(id: "1", name: "Demo User", email: "user@email.com")

        sessionManager.saveSession(token: "mock_session_token_123", user: user)

        let restored = sessionManager.restoreSession()
        XCTAssertEqual(restored?.token, "mock_session_token_123")
        XCTAssertEqual(restored?.user, user)
        XCTAssertTrue(sessionManager.isLoggedIn)
    }

    func testRestoreSessionReturnsNilWhenNoSessionExists() {
        XCTAssertNil(sessionManager.restoreSession())
        XCTAssertFalse(sessionManager.isLoggedIn)
    }

    func testClearSessionRemovesPersistedSession() {
        let user = User(id: "1", name: "Demo User", email: "user@email.com")
        sessionManager.saveSession(token: "mock_session_token_123", user: user)

        sessionManager.clearSession()

        XCTAssertNil(sessionManager.restoreSession())
        XCTAssertFalse(sessionManager.isLoggedIn)
    }

    func testRestoreSessionReturnsNilWhenTokenIsEmpty() {
        let user = User(id: "1", name: "Demo User", email: "user@email.com")
        sessionManager.saveSession(token: "", user: user)

        XCTAssertNil(sessionManager.restoreSession())
        XCTAssertFalse(sessionManager.isLoggedIn)
    }
}
