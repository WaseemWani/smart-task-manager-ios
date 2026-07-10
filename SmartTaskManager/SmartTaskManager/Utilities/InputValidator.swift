//
//  InputValidator.swift
//  SmartTaskManager
//

import Foundation

// MARK: - ValidationField

enum ValidationField: Equatable {
    case email
    case password
}

// MARK: - ValidationError

struct ValidationError: Equatable {
    let field: ValidationField
    let message: String
}

// MARK: - ValidationResult

struct ValidationResult: Equatable {
    let isValid: Bool
    let errors: [ValidationError]

    static let valid = ValidationResult(isValid: true, errors: [])
}

// MARK: - InputValidating

protocol InputValidating {
    func validateEmail(_ email: String) -> ValidationError?
    func validatePassword(_ password: String) -> ValidationError?
    func validateLogin(email: String, password: String) -> ValidationResult
}

// MARK: - InputValidator

final class InputValidator: InputValidating {

    private let emailPredicate: NSPredicate

    init() {
        emailPredicate = NSPredicate(
            format: "SELF MATCHES %@",
            AppConstants.Validation.emailRegex
        )
    }

    func validateEmail(_ email: String) -> ValidationError? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            return ValidationError(
                field: .email,
                message: AppConstants.Validation.emailRequired
            )
        }

        if !emailPredicate.evaluate(with: trimmedEmail) {
            return ValidationError(
                field: .email,
                message: AppConstants.Validation.invalidEmail
            )
        }

        return nil
    }

    func validatePassword(_ password: String) -> ValidationError? {
        if password.isEmpty {
            return ValidationError(
                field: .password,
                message: AppConstants.Validation.passwordRequired
            )
        }

        if password.count < AppConstants.Validation.minimumPasswordLength {
            return ValidationError(
                field: .password,
                message: AppConstants.Validation.passwordTooShort
            )
        }

        return nil
    }

    func validateLogin(email: String, password: String) -> ValidationResult {
        let errors = [validateEmail(email), validatePassword(password)].compactMap { $0 }

        guard errors.isEmpty else {
            return ValidationResult(isValid: false, errors: errors)
        }

        return .valid
    }
}
