//
//  AuthService.swift
//  SmartTaskManager
//

import Foundation

// MARK: - AuthServicing

protocol AuthServicing {
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponse, AuthError>) -> Void
    )
    func logout()
}

// MARK: - AuthService

final class AuthService: AuthServicing {

    private let networkManager: NetworkManaging
    private let sessionManager: SessionManaging
    private let tokenGenerator: () -> String

    init(
        networkManager: NetworkManaging = NetworkManager(),
        sessionManager: SessionManaging = SessionManager(),
        tokenGenerator: @escaping () -> String = AuthService.defaultTokenGenerator
    ) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.tokenGenerator = tokenGenerator
    }

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponse, AuthError>) -> Void
    ) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        networkManager.request(
            endpoint: .login,
            responseType: [RemoteUser].self
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let users):
                self.handleUsersResponse(
                    users: users,
                    email: normalizedEmail,
                    password: password,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(self.mapNetworkError(error)))
            }
        }
    }

    // MARK: - Private

    private func handleUsersResponse(
        users: [RemoteUser],
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponse, AuthError>) -> Void
    ) {
        guard let matchedUser = users.first(where: {
            $0.email.lowercased() == email && $0.password == password
        }) else {
            completion(.failure(.invalidCredentials))
            return
        }

        let token = tokenGenerator()
        let user = matchedUser.toUser(fallbackID: email)
        sessionManager.saveSession(token: token, user: user)

        let response = AuthLoginResponse(
            status: true,
            message: AppConstants.Auth.loginSuccess,
            token: token,
            user: user
        )
        completion(.success(response))
    }

    func logout() {
        sessionManager.clearSession()
    }

    private func mapNetworkError(_ error: NetworkError) -> AuthError {
        switch error {
        case .timedOut:
            return .requestTimedOut
        case .networkUnavailable:
            return .networkUnavailable
        case .httpError:
            return .serverError
        default:
            return .unknown
        }
    }

    private static func defaultTokenGenerator() -> String {
        "mock_session_token_\(UUID().uuidString)"
    }
}
