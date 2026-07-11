//
//  SessionManager.swift
//  SmartTaskManager
//

import Foundation

// MARK: - UserSession

struct UserSession: Equatable {
    let token: String
    let user: User
}

// MARK: - SessionManaging

protocol SessionManaging: AnyObject {
    var isLoggedIn: Bool { get }
    var currentSession: UserSession? { get }
    func saveSession(token: String, user: User)
    func restoreSession() -> UserSession?
    func clearSession()
}

// MARK: - SessionManager

final class SessionManager: SessionManaging {

    private let storage: SessionStoring

    init(storage: SessionStoring = StorageManager()) {
        self.storage = storage
    }

    var isLoggedIn: Bool {
        restoreSession() != nil
    }

    var currentSession: UserSession? {
        restoreSession()
    }

    func saveSession(token: String, user: User) {
        storage.saveSession(token: token, user: user)
    }

    func restoreSession() -> UserSession? {
        guard let token = storage.sessionToken,
              let user = storage.currentUser,
              !token.isEmpty else {
            return nil
        }

        return UserSession(token: token, user: user)
    }

    func clearSession() {
        storage.clearSession()
    }
}
