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
        static let updateSuccess = "Task updated successfully"
        static let updateFailed = "Unable to update task. Please try again."
        static let taskNotEditable = "This task can't be edited because it isn't saved on the server yet."
        static let taskNotDeletable = "This task can't be deleted because it isn't saved on the server yet."
        static let deleteSuccess = "Task deleted successfully"
        static let deleteFailed = "Unable to delete task. Please try again."
        static let deleteAction = "Delete"
        static let deleteConfirmTitle = "Delete Task?"
        static let deleteConfirmMessage = "This action cannot be undone."
        static let filterAll = "All"
        static let filteredEmptyTitle = "No matching tasks"
        static let filteredEmptyMessage = "Try another priority filter to see more tasks."
        static let tomorrow = "Tomorrow"
        static let emptyTitle = "No tasks yet"
        static let emptyMessage = "Your tasks will appear here once you create them."
        static let retryButton = "Try Again"
        static let subtaskSingular = "subtask"
        static let subtaskPlural = "subtasks"

        static func subtaskCountLabel(for count: Int) -> String {
            let noun = count == 1 ? subtaskSingular : subtaskPlural
            return "\(count) \(noun)"
        }

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
            static let filterChipHorizontalPadding: CGFloat = 16
            static let filterChipVerticalPadding: CGFloat = 8
            static let filterChipHeight: CGFloat = 34
            static let filterChipBottomPadding: CGFloat = 8
            static let filterSectionHeight: CGFloat = 42
        }
    }

    enum EditTask {
        static let screenTitle = "Edit Task"
        static let saveButton = "Save Changes"
        static let deleteButton = "Delete Task"
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
        static let aiAssistantTitle = "AI Assistant"
        static let suggestPriority = "Suggest Priority"
        static let breakIntoSubtasks = "Break Into Subtasks"
        static let generatingAISuggestions = "Generating AI Suggestions..."
        static let titleRequiredForAI = "Add a title before using AI suggestions."
        static let descriptionRequiredForAI = "Add a description before breaking into subtasks."
        static let aiSuggestedSubtasksTitle = "AI SUGGESTED SUBTASKS"
        static let subtasksSectionTitle = "SUBTASKS"
        static let addSubtask = "Add Subtask"
        static let editSubtaskTitle = "Edit Subtask"
        static let newSubtaskTitle = "New Subtask"
        static let subtaskTitlePlaceholder = "Subtask title"
        static let subtaskUntitledPlaceholder = "Tap to add title"
        static let saveSubtask = "Save"
        static let regenerateSubtasksTitle = "Replace Subtasks?"
        static let regenerateSubtasksMessage = "This will replace your current subtasks with new AI suggestions."
        static let replaceAction = "Replace"

        enum Layout {
            static let pickerHeaderTopPadding: CGFloat = 16
            static let pickerHeaderBottomPadding: CGFloat = 12
            static let pickerDoneButtonHorizontalPadding: CGFloat = 20
            static let pickerDoneButtonVerticalPadding: CGFloat = 10
            static let aiSectionTopSpacing: CGFloat = 32
            static let aiCardCornerRadius: CGFloat = 16
            static let aiCardPadding: CGFloat = 20
            static let aiCardBorderWidth: CGFloat = 1
            static let aiHeaderSpacing: CGFloat = 8
            static let aiHeaderBottomSpacing: CGFloat = 16
            static let aiButtonCornerRadius: CGFloat = 12
            static let aiButtonPadding: CGFloat = 12
            static let aiButtonSpacing: CGFloat = 12
            static let aiButtonIconSpacing: CGFloat = 4
            static let aiLoadingTopSpacing: CGFloat = 24
            static let aiLoadingTopPadding: CGFloat = 16
            static let aiLoadingSpacing: CGFloat = 12
            static let aiSparkIconSize: CGFloat = 20
            static let aiActionIconSize: CGFloat = 24
            static let subtaskRowSpacing: CGFloat = 12
            static let subtaskCheckboxSize: CGFloat = 20
            static let subtaskDeleteIconSize: CGFloat = 18
            static let subtasksSectionTopSpacing: CGFloat = 24
            static let subtasksSectionTopPadding: CGFloat = 16
            static let addSubtaskTopSpacing: CGFloat = 12
            static let subtaskEditMinTextHeight: CGFloat = 120
        }
    }

    enum AI {
        static let missingAPIKey = "AI is not configured. Add your Gemini API key to continue."
        static let invalidURL = "Unable to reach the AI service."
        static let noData = "The AI service returned no data."
        static let invalidResponse = "The AI service returned an invalid response."
        static let unauthorized = "The Gemini API key is invalid or unauthorized."
        static let quotaExceeded = "Gemini free-tier quota exceeded. Wait a minute and try again."
        static let modelUnavailable = "The configured Gemini model is unavailable. Update the model setting and try again."
        static let requestFailed = "The AI request failed. Please try again."
        static let decodingFailed = "Unable to read the AI response."
        static let timedOut = "The AI request timed out. Please try again."
        static let networkUnavailable = "Network unavailable. Check your connection and try again."
        static let cancelled = "The AI request was cancelled."
        static let emptyResponse = "The AI service returned an empty response."
        static let unrecognizedPriority = "Unable to determine a valid priority from the AI response."
        static let insufficientSubtasks = "The AI response did not include enough subtasks."
        static let noEligibleTasks = "Add incomplete tasks to get AI workload insights."
        static let invalidWorkloadInsight = "Unable to read a valid workload insight from the AI response."
        static let unknown = "Something went wrong with the AI request. Please try again."
        static let prioritySuggested = "Priority suggested successfully."
        static let subtasksGenerated = "Subtasks generated successfully."
    }

    enum Profile {
        static let performanceOverview = "Performance Overview"
        static let totalTasks = "Total Tasks"
        static let completed = "Completed"
        static let pending = "Pending"
        static let preferences = "Preferences"
        static let appSettings = "App Settings"
        static let aiSettings = "AI Settings"
        static let information = "Information"
        static let about = "About"
        static let supportHelpdesk = "Support Helpdesk"
        static let logOut = "Log Out"
        static let logoutConfirmTitle = "Log Out?"
        static let logoutConfirmMessage = "You will be signed out of your account. Your tasks will remain saved."
        static let logoutConfirmAction = "Log Out"
        static let logoutCancel = "Cancel"
        static let guestStatMessage = "No tasks"

        enum Layout {
            static let marginMain: CGFloat = 16
            static let sectionSpacing: CGFloat = 24
            static let stackGap: CGFloat = 8
            static let contentTopSpacing: CGFloat = 8
            static let contentBottomPadding: CGFloat = 32
            static let statCardSpacing: CGFloat = 12
            static let statCardCornerRadius: CGFloat = 12
            static let statCardPadding: CGFloat = 12
            static let statIconSize: CGFloat = 24
            static let menuCardCornerRadius: CGFloat = 12
            static let menuRowHeight: CGFloat = 44
            static let menuIconSize: CGFloat = 20
            static let logoutButtonHeight: CGFloat = 50
            static let logoutTopSpacing: CGFloat = 8
        }
    }

    enum AIAssistant {
        static let screenTitle = "AI Assistant"
        static let analyzingWorkload = "Analyzing your workload..."
        static let emptyTitle = "No tasks to analyze"
        static let emptyMessage = "Add incomplete tasks to get AI workload insights."
        static let emptySystemImageName = "sparkles"
        static let applySuccess = "Suggestions applied successfully."
        static let recommendedTaskUnavailable = "The recommended task is no longer available."
        static let taskNotEditable = "This task can't be updated because it isn't saved on the server yet."
        static let replaceSubtasksTitle = "Replace Subtasks?"
        static let replaceSubtasksMessage = "This will replace the existing subtasks on the recommended task."
        static let replaceAction = "Replace"
        static let applySuggestions = "Apply Suggestions"
        static let regenerate = "Regenerate"
        static let smartSummary = "Smart Summary"
        static let suggestedBreakdown = "Suggested Breakdown"
        static let recommendedPriorityPrefix = "Recommended:"
        static let retryButton = "Try Again"

        enum Layout {
            static let marginMain: CGFloat = 16
            static let sectionSpacing: CGFloat = 24
            static let stackGap: CGFloat = 8
            static let contentTopSpacing: CGFloat = 8
            static let contentBottomPadding: CGFloat = 32
            static let actionButtonHeight: CGFloat = 56
            static let actionButtonSpacing: CGFloat = 12
            static let actionSectionTopSpacing: CGFloat = 16
            static let loadingSpacing: CGFloat = 12
            static let summaryCardCornerRadius: CGFloat = 24
            static let summaryCardPadding: CGFloat = 24
            static let summaryChipSpacing: CGFloat = 6
            static let summaryHeadlineSpacing: CGFloat = 4
            static let summaryBoltContainerSize: CGFloat = 64
            static let summaryBoltIconSize: CGFloat = 32
            static let glassCardCornerRadius: CGFloat = 16
            static let glassCardPadding: CGFloat = 20
            static let glassCardMinHeight: CGFloat = 140
            static let iconContainerSize: CGFloat = 36
            static let iconContainerCornerRadius: CGFloat = 8
            static let recommendationBadgeSpacing: CGFloat = 16
            static let recommendationContentSpacing: CGFloat = 8
            static let breakdownHeaderSpacing: CGFloat = 24
            static let breakdownRowSpacing: CGFloat = 20
            static let suggestedSubtaskCheckboxSize: CGFloat = 20
            static let suggestedSubtaskCheckboxBorderWidth: CGFloat = 2
            static let cardBorderWidth: CGFloat = 1
            static let cardShadowRadius: CGFloat = 12
            static let cardShadowYOffset: CGFloat = 4
        }
    }
}
