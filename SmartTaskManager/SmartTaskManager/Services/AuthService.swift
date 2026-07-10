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
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

// MARK: - AuthService

final class AuthService: AuthServicing {

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // TODO(STM-101): Replace simulated login with NetworkManager + MockAPI authentication endpoint.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            completion(.success(()))
        }
    }
}
