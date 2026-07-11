//
//  MainTab.swift
//  SmartTaskManager
//

import UIKit

enum MainTab: Int, CaseIterable {

    case tasks
    case aiAssistant
    case profile

    var title: String {
        switch self {
        case .tasks:
            return AppConstants.Tabs.tasksTitle
        case .aiAssistant:
            return AppConstants.Tabs.aiAssistantTitle
        case .profile:
            return AppConstants.Tabs.profileTitle
        }
    }

    var iconName: String {
        switch self {
        case .tasks:
            return "checklist"
        case .aiAssistant:
            return "sparkles"
        case .profile:
            return "person.crop.circle"
        }
    }

    var selectedIconName: String {
        switch self {
        case .tasks:
            return "checklist"
        case .aiAssistant:
            return "sparkles"
        case .profile:
            return "person.crop.circle.fill"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .tasks:
            return "main_tab_tasks"
        case .aiAssistant:
            return "main_tab_ai_assistant"
        case .profile:
            return "main_tab_profile"
        }
    }
}
