//
//  StorageManager.swift
//  SmartTaskManager
//

import Foundation

// MARK: - SessionStoring

protocol SessionStoring: AnyObject {
    var sessionToken: String? { get }
    var currentUser: User? { get }
    func saveSession(token: String, user: User)
    func clearSession()
}

// MARK: - StorageManager

final class StorageManager: SessionStoring {

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    var sessionToken: String? {
        userDefaults.string(forKey: AppConstants.SessionKeys.sessionToken)
    }

    var currentUser: User? {
        guard let data = userDefaults.data(forKey: AppConstants.SessionKeys.currentUser) else {
            return nil
        }

        return try? decoder.decode(User.self, from: data)
    }

    func saveSession(token: String, user: User) {
        userDefaults.set(token, forKey: AppConstants.SessionKeys.sessionToken)

        if let data = try? encoder.encode(user) {
            userDefaults.set(data, forKey: AppConstants.SessionKeys.currentUser)
        }
    }

    func clearSession() {
        userDefaults.removeObject(forKey: AppConstants.SessionKeys.sessionToken)
        userDefaults.removeObject(forKey: AppConstants.SessionKeys.currentUser)
    }
}
