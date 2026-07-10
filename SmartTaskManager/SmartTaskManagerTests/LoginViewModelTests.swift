//
//  LoginViewModelTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class LoginViewModelTests: XCTestCase {

    private var validator: MockInputValidator!
    private var authService: MockAuthService!
    private var viewModel: LoginViewModel!

    override func setUp() {
        super.setUp()
        validator = MockInputValidator()
        authService = MockAuthService()
        viewModel = LoginViewModel(validator: validator, authService: authService)
    }

    override func tearDown() {
        viewModel = nil
        authService = nil
        validator = nil
        super.tearDown()
    }

    func testLoginButtonDisabledWhenFieldsAreEmpty() {
        XCTAssertFalse(viewModel.state.isLoginEnabled)

        viewModel.updateEmail("user@example.com")
        XCTAssertFalse(viewModel.state.isLoginEnabled)

        viewModel.updatePassword("password123")
        XCTAssertTrue(viewModel.state.isLoginEnabled)
    }

    func testLoginShowsValidationErrorsForInvalidInput() {
        validator.loginResult = ValidationResult(
            isValid: false,
            errors: [
                ValidationError(field: .email, message: AppConstants.Validation.invalidEmail),
                ValidationError(field: .password, message: AppConstants.Validation.passwordTooShort)
            ]
        )

        viewModel.updateEmail("bad-email")
        viewModel.updatePassword("short")
        viewModel.login()

        XCTAssertEqual(viewModel.state.emailError, AppConstants.Validation.invalidEmail)
        XCTAssertEqual(viewModel.state.passwordError, AppConstants.Validation.passwordTooShort)
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(authService.loginCallCount, 0)
    }

    func testLoginStartsLoadingForValidInput() {
        validator.loginResult = .valid
        authService.shouldCompleteImmediately = false

        viewModel.updateEmail("user@example.com")
        viewModel.updatePassword("password123")
        viewModel.login()

        XCTAssertTrue(viewModel.state.isLoading)
        XCTAssertFalse(viewModel.state.isLoginEnabled)
        XCTAssertEqual(authService.loginCallCount, 1)
    }

    func testLoginStopsLoadingAfterAuthServiceCompletes() {
        validator.loginResult = .valid

        viewModel.updateEmail("user@example.com")
        viewModel.updatePassword("password123")
        viewModel.login()

        let expectation = expectation(description: "Auth completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertTrue(viewModel.state.isLoginEnabled)
    }

    func testUpdatingFieldClearsValidationError() {
        validator.loginResult = ValidationResult(
            isValid: false,
            errors: [ValidationError(field: .email, message: AppConstants.Validation.invalidEmail)]
        )

        viewModel.updateEmail("bad-email")
        viewModel.updatePassword("password123")
        viewModel.login()
        XCTAssertNotNil(viewModel.state.emailError)

        viewModel.updateEmail("user@example.com")
        XCTAssertNil(viewModel.state.emailError)
    }

    func testLoginShowsAuthErrorMessage() {
        validator.loginResult = .valid
        authService.loginResult = .failure(.invalidCredentials)

        viewModel.updateEmail("user@example.com")
        viewModel.updatePassword("password123")
        viewModel.login()

        let expectation = expectation(description: "Auth failure handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.state.loginError, AppConstants.Auth.invalidCredentials)
            XCTAssertFalse(self.viewModel.state.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

// MARK: - MockInputValidator

private final class MockInputValidator: InputValidating {

    var loginResult = ValidationResult.valid

    func validateEmail(_ email: String) -> ValidationError? {
        loginResult.errors.first(where: { $0.field == .email })
    }

    func validatePassword(_ password: String) -> ValidationError? {
        loginResult.errors.first(where: { $0.field == .password })
    }

    func validateLogin(email: String, password: String) -> ValidationResult {
        loginResult
    }
}

// MARK: - MockAuthService

private final class MockAuthService: AuthServicing {

    var loginCallCount = 0
    var shouldCompleteImmediately = true
    var loginResult: Result<AuthLoginResponse, AuthError> = .success(
        AuthLoginResponse(
            status: true,
            message: AppConstants.Auth.loginSuccess,
            token: "mock_session_token_test",
            user: User(id: "1", name: "Demo User", email: "user@example.com")
        )
    )

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponse, AuthError>) -> Void
    ) {
        loginCallCount += 1

        guard shouldCompleteImmediately else { return }

        DispatchQueue.main.async {
            completion(self.loginResult)
        }
    }
}
