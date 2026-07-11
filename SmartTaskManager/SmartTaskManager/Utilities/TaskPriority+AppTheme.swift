//
//  TaskPriority+AppTheme.swift
//  SmartTaskManager
//

import UIKit

extension TaskPriority {

    var badgeBackgroundColor: UIColor {
        switch self {
        case .high:
            return .appHighPriorityBadgeBackground
        case .medium:
            return .appMediumPriorityBadgeBackground
        case .low:
            return .appLowPriorityBadgeBackground
        }
    }

    var badgeTextColor: UIColor {
        switch self {
        case .high:
            return .appHighPriorityBadgeText
        case .medium:
            return .appMediumPriorityBadgeText
        case .low:
            return .appLowPriorityBadgeText
        }
    }
}
