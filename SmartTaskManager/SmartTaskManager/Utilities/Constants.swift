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
        static let taskTitleRequired = "Title is required"
        static let taskPriorityRequired = "Priority is required"
        static let taskInvalidDueDate = "Due date cannot be in the past"
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
        static let createFailed = "Unable to create task. Please try again."
        static let notLoggedIn = "You must be logged in to manage tasks."
        static let createSuccess = "Task created successfully"
        static let tomorrow = "Tomorrow"
        static let emptyTitle = "No tasks yet"
        static let emptyMessage = "Your tasks will appear here once you create them."
        static let retryButton = "Try Again"

        enum Layout {
            static let marginMain: CGFloat = 16
            static let topBarHeight: CGFloat = 44
            static let headerTopSpacing: CGFloat = 24
            static let headerBottomSpacing: CGFloat = 12
            static let gutterCard: CGFloat = 12
            static let stackGap: CGFloat = 8
            static let titleBadgeGap: CGFloat = 12
            static let titleMaxLines = 2
            static let cardCornerRadius: CGFloat = 12
            static let cardRowGap: CGFloat = 12
            static let checkboxSize: CGFloat = 24
            static let checkboxBorderWidth: CGFloat = 2
            static let priorityBadgeCornerRadius: CGFloat = 6
            static let priorityBadgeHorizontalPadding: CGFloat = 8
            static let priorityBadgeVerticalPadding: CGFloat = 2
            static let dueDateIconSize: CGFloat = 16
            static let cardShadowRadius: CGFloat = 12
            static let cardShadowYOffset: CGFloat = 4
            static let optionRowHeight: CGFloat = 44
            static let saveButtonHeight: CGFloat = 50
        }
    }

    enum CreateTask {
        static let screenTitle = "New Task"
        static let titlePlaceholder = "Title"
        static let descriptionPlaceholder = "Description"
        static let dateLabel = "Date"
        static let priorityLabel = "Priority"
        static let selectDate = "Select date"
        static let selectPriority = "Select priority"
        static let saveButton = "Save Task"
        static let clearDate = "Clear Date"
        static let clearPriority = "Clear Priority"
        static let cancel = "Cancel"
        static let done = "Done"
        static let todayPrefix = "Today"

        enum Layout {
            static let pickerHeaderTopPadding: CGFloat = 16
            static let pickerHeaderBottomPadding: CGFloat = 12
            static let pickerDoneButtonHorizontalPadding: CGFloat = 20
            static let pickerDoneButtonVerticalPadding: CGFloat = 10
        }
    }
}
