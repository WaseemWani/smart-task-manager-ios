//
//  Constants.swift
//  SmartTaskManager
//
//  Created by Waseem Wani on 01/07/26.
//

import Foundation

enum AppConstants {

    enum App {
        static let name = "SmartTaskManager"
        static let tagline = "Organize smarter with AI"
        static let versionLabel = "Version 1.0"
    }

    enum Assets {
        static let appLogo = "AppLogo"
    }

    enum Splash {
        static let displayDuration: TimeInterval = 2.0
    }

    enum Login {
        static let welcomeTitle = "Welcome"
        static let subtitle = "Manage your tasks intelligently"
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
        static let forgotPassword = "Forgot password?"
        static let loginButton = "Log In"
        static let orDivider = "or"
        static let continueAsGuest = "Continue as Guest"
        static let privacyPolicy = "Privacy Policy"
        static let termsOfService = "Terms of Service"
    }

    enum Validation {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let minimumPasswordLength = 8
        static let emailRequired = "Email is required"
        static let invalidEmail = "Please enter a valid email address"
        static let passwordRequired = "Password is required"
        static let passwordTooShort = "Password must be at least 8 characters"
    }

    enum Auth {
        static let loginSuccess = "Login successful"
        static let invalidCredentials = "Invalid credentials"
        static let requestTimedOut = "Request timed out. Please try again."
        static let networkUnavailable = "Network unavailable. Check your connection and try again."
        static let serverError = "Something went wrong. Please try again later."
        static let unknownError = "Unable to sign in. Please try again."
    }

    enum SessionKeys {
        static let sessionToken = "stm.session.token"
        static let currentUser = "stm.session.currentUser"
    }

    enum Tabs {
        static let tasksTitle = "Tasks"
        static let aiAssistantTitle = "AI Assistant"
        static let profileTitle = "Profile"
    }

    enum TaskList {
        static let screenTitle = "My Tasks"
        static let highPriority = "High"
        static let mediumPriority = "Medium"
        static let lowPriority = "Low"
        static let loadFailed = "Unable to load tasks. Please try again."
    }
}
