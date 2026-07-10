//
//  User.swift
//  SmartTaskManager
//

import Foundation

// MARK: - User

struct User: Codable, Equatable {
    let id: String
    let name: String
    let email: String
}

// MARK: - RemoteUser

struct RemoteUser: Codable, Equatable {
    let id: String?
    let name: String
    let email: String
    let password: String

    func toUser(fallbackID: String) -> User {
        User(
            id: id ?? fallbackID,
            name: name,
            email: email
        )
    }
}

// MARK: - AuthLoginResponse

struct AuthLoginResponse: Equatable {
    let status: Bool
    let message: String
    let token: String
    let user: User
}

// MARK: - AuthError

enum AuthError: Error, Equatable {
    case invalidCredentials
    case requestTimedOut
    case networkUnavailable
    case serverError
    case unknown

    var message: String {
        switch self {
        case .invalidCredentials:
            return AppConstants.Auth.invalidCredentials
        case .requestTimedOut:
            return AppConstants.Auth.requestTimedOut
        case .networkUnavailable:
            return AppConstants.Auth.networkUnavailable
        case .serverError:
            return AppConstants.Auth.serverError
        case .unknown:
            return AppConstants.Auth.unknownError
        }
    }
}
