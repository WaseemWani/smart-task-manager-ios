//
//  StorageManagerTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class StorageManagerTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var storageManager: StorageManager!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "StorageManagerTests")!
        userDefaults.removePersistentDomain(forName: "StorageManagerTests")
        storageManager = StorageManager(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "StorageManagerTests")
        storageManager = nil
        userDefaults = nil
        super.tearDown()
    }

    func testSaveSessionPersistsTokenAndUser() {
        let user = User(id: "1", name: "Demo User", email: "user@email.com")

        storageManager.saveSession(token: "mock_session_token_123", user: user)

        XCTAssertEqual(storageManager.sessionToken, "mock_session_token_123")
        XCTAssertEqual(storageManager.currentUser, user)
    }

    func testClearSessionRemovesPersistedValues() {
        let user = User(id: "1", name: "Demo User", email: "user@email.com")
        storageManager.saveSession(token: "mock_session_token_123", user: user)

        storageManager.clearSession()

        XCTAssertNil(storageManager.sessionToken)
        XCTAssertNil(storageManager.currentUser)
    }
}
