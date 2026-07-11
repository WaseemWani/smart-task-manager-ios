//
//  InputValidator.swift
//  SmartTaskManager
//

import Foundation

// MARK: - ValidationField

enum ValidationField: Equatable {
    case email
    case password
    case title
    case priority
    case dueDate
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
    func validateTaskTitle(_ title: String) -> ValidationError?
    func validateTaskPriority(_ priority: TaskPriority?) -> ValidationError?
    func validateTaskDueDate(_ dueDate: Date?, referenceDate: Date) -> ValidationError?
    func validateCreateTask(
        title: String,
        priority: TaskPriority?,
        dueDate: Date?,
        referenceDate: Date
    ) -> ValidationResult
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

    func validateTaskTitle(_ title: String) -> ValidationError? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            return ValidationError(
                field: .title,
                message: AppConstants.Validation.taskTitleRequired
            )
        }

        return nil
    }

    func validateTaskPriority(_ priority: TaskPriority?) -> ValidationError? {
        guard priority != nil else {
            return ValidationError(
                field: .priority,
                message: AppConstants.Validation.taskPriorityRequired
            )
        }

        return nil
    }

    func validateTaskDueDate(_ dueDate: Date?, referenceDate: Date = Date()) -> ValidationError? {
        guard let dueDate else { return nil }

        let calendar = Calendar.current
        let dueDay = calendar.startOfDay(for: dueDate)
        let referenceDay = calendar.startOfDay(for: referenceDate)

        if dueDay < referenceDay {
            return ValidationError(
                field: .dueDate,
                message: AppConstants.Validation.taskInvalidDueDate
            )
        }

        return nil
    }

    func validateCreateTask(
        title: String,
        priority: TaskPriority?,
        dueDate: Date?,
        referenceDate: Date = Date()
    ) -> ValidationResult {
        let errors = [
            validateTaskTitle(title),
            validateTaskPriority(priority),
            validateTaskDueDate(dueDate, referenceDate: referenceDate)
        ].compactMap { $0 }

        guard errors.isEmpty else {
            return ValidationResult(isValid: false, errors: errors)
        }

        return .valid
    }
}
