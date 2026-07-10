//
//  LoginViewModel.swift
//  SmartTaskManager
//
//  Created by Waseem Wani on 01/07/26.
//

import Foundation

// MARK: - LoginViewState

struct LoginViewState: Equatable {
    var email: String = ""
    var password: String = ""
    var isLoginEnabled: Bool = false
    var emailError: String?
    var passwordError: String?
    var isLoading: Bool = false
}

// MARK: - LoginViewModel

final class LoginViewModel {

    // MARK: - Callbacks

    var onStateChange: ((LoginViewState) -> Void)?

    // MARK: - State

    private(set) var state = LoginViewState() {
        didSet {
            onStateChange?(state)
        }
    }

    // MARK: - Dependencies

    private let validator: InputValidating
    private let authService: AuthServicing

    // MARK: - Initialization

    init(
        validator: InputValidating = InputValidator(),
        authService: AuthServicing = AuthService()
    ) {
        self.validator = validator
        self.authService = authService
    }

    // MARK: - Input

    func updateEmail(_ email: String) {
        state.email = email
        state.emailError = nil
        updateLoginEnabledState()
    }

    func updatePassword(_ password: String) {
        state.password = password
        state.passwordError = nil
        updateLoginEnabledState()
    }

    func login() {
        let validationResult = validator.validateLogin(
            email: state.email,
            password: state.password
        )

        guard validationResult.isValid else {
            applyValidationErrors(validationResult.errors)
            return
        }

        state.isLoading = true
        state.isLoginEnabled = false

        authService.login(email: state.email, password: state.password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.state.isLoading = false
                self.updateLoginEnabledState()

                switch result {
                case .success:
                    // TODO(STM-101): Navigate to task list after successful authentication.
                    break
                case .failure:
                    // TODO(STM-101): Surface authentication failure message to the UI.
                    break
                }
            }
        }
    }

    // MARK: - Private

    private func updateLoginEnabledState() {
        let trimmedEmail = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
        state.isLoginEnabled = !trimmedEmail.isEmpty && !state.password.isEmpty && !state.isLoading
    }

    private func applyValidationErrors(_ errors: [ValidationError]) {
        state.emailError = errors.first(where: { $0.field == .email })?.message
        state.passwordError = errors.first(where: { $0.field == .password })?.message
    }
}
