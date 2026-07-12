//
//  ProfileViewModel.swift
//  SmartTaskManager
//

import Foundation

// MARK: - ProfileTaskStats

struct ProfileTaskStats: Equatable {
    let total: Int
    let completed: Int
    let pending: Int
}

// MARK: - ProfileViewState

enum ProfileViewState: Equatable {
    case guest
    case loaded(ProfileTaskStats)
}

// MARK: - ProfileViewModel

final class ProfileViewModel {

    // MARK: - Callbacks

    var onStateChange: ((ProfileViewState) -> Void)?

    // MARK: - State

    private(set) var state: ProfileViewState = .loaded(ProfileTaskStats(total: 0, completed: 0, pending: 0)) {
        didSet {
            onStateChange?(state)
        }
    }

    // MARK: - Dependencies

    private let sessionManager: SessionManaging
    private let taskCache: TaskCaching

    // MARK: - Initialization

    init(
        sessionManager: SessionManaging = SessionManager(),
        taskCache: TaskCaching = TaskCache.shared
    ) {
        self.sessionManager = sessionManager
        self.taskCache = taskCache
    }

    // MARK: - Input

    func refresh() {
        guard sessionManager.isLoggedIn else {
            state = .guest
            return
        }

        let tasks = taskCache.cachedTasks
        let completedCount = tasks.filter(\.isCompleted).count
        state = .loaded(
            ProfileTaskStats(
                total: tasks.count,
                completed: completedCount,
                pending: tasks.count - completedCount
            )
        )
    }
}
