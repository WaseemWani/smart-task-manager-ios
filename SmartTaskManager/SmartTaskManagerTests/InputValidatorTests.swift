//
//  InputValidatorTests.swift
//  SmartTaskManagerTests
//

import XCTest
@testable import SmartTaskManager

final class InputValidatorTests: XCTestCase {

    private var validator: InputValidator!

    override func setUp() {
        super.setUp()
        validator = InputValidator()
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    func testValidateEmailReturnsErrorWhenEmpty() {
        let error = validator.validateEmail("")

        XCTAssertEqual(error?.field, .email)
        XCTAssertEqual(error?.message, AppConstants.Validation.emailRequired)
    }

    func testValidateEmailReturnsErrorWhenInvalidFormat() {
        let error = validator.validateEmail("invalid-email")

        XCTAssertEqual(error?.field, .email)
        XCTAssertEqual(error?.message, AppConstants.Validation.invalidEmail)
    }

    func testValidateEmailReturnsNilForValidEmail() {
        XCTAssertNil(validator.validateEmail("user@example.com"))
    }

    func testValidatePasswordReturnsErrorWhenEmpty() {
        let error = validator.validatePassword("")

        XCTAssertEqual(error?.field, .password)
        XCTAssertEqual(error?.message, AppConstants.Validation.passwordRequired)
    }

    func testValidatePasswordReturnsErrorWhenTooShort() {
        let error = validator.validatePassword("short")

        XCTAssertEqual(error?.field, .password)
        XCTAssertEqual(error?.message, AppConstants.Validation.passwordTooShort)
    }

    func testValidatePasswordReturnsNilForValidPassword() {
        XCTAssertNil(validator.validatePassword("password123"))
    }

    func testValidateLoginReturnsAllErrorsForInvalidInput() {
        let result = validator.validateLogin(email: "", password: "short")

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errors.count, 2)
        XCTAssertTrue(result.errors.contains(where: { $0.field == .email }))
        XCTAssertTrue(result.errors.contains(where: { $0.field == .password }))
    }

    func testValidateLoginReturnsValidForCorrectInput() {
        let result = validator.validateLogin(email: "user@example.com", password: "password123")

        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
}
