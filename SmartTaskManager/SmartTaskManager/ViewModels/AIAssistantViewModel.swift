//
//  AIAssistantViewModel.swift
//  SmartTaskManager
//

import Foundation

// MARK: - AIAssistantViewState

enum AIAssistantViewState: Equatable {
    case loading
    case loaded(WorkloadInsight)
    case empty
    case error(String)
    case applying(WorkloadInsight)
}

// MARK: - AIAssistantViewModel

final class AIAssistantViewModel {

    // MARK: - Callbacks

    var onStateChange: ((AIAssistantViewState) -> Void)?
    var onApplySuccess: ((String) -> Void)?
    var onApplyError: ((String) -> Void)?
    var onAnalysisError: ((String) -> Void)?
    var onApplyConfirmationRequired: (() -> Void)?

    // MARK: - State

    private(set) var state: AIAssistantViewState = .loading {
        didSet {
            onStateChange?(state)
        }
    }

    let screenTitle = AppConstants.AIAssistant.screenTitle

    private var allTasks: [Task] = []
    private var cachedInsight: WorkloadInsight?
    private var lastAnalyzedFingerprint: String?
    private var analysisGeneration = 0

    // MARK: - Dependencies

    private let taskService: TaskServicing
    private let aiService: AIServicing

    // MARK: - Initialization

    init(
        taskService: TaskServicing = TaskService(),
        aiService: AIServicing = AIService()
    ) {
        self.taskService = taskService
        self.aiService = aiService
        loadInsightsIfNeeded()
    }

    // MARK: - Input

    func loadInsightsIfNeeded() {
        performAnalysis(force: false, showLoading: cachedInsight == nil)
    }

    func regenerate() {
        guard !isApplying else { return }
        performAnalysis(force: true, showLoading: true)
    }

    func applySuggestions() {
        guard let insight = currentInsight else { return }
        guard !isApplying else { return }

        guard let task = recommendedTask(for: insight) else {
            onApplyError?(AppConstants.AIAssistant.recommendedTaskUnavailable)
            return
        }

        guard task.isEditable else {
            onApplyError?(AppConstants.AIAssistant.taskNotEditable)
            return
        }

        if task.subtasks.isEmpty {
            performApply(insight: insight, task: task)
        } else {
            onApplyConfirmationRequired?()
        }
    }

    func confirmApplySuggestions() {
        guard let insight = currentInsight else { return }
        guard let task = recommendedTask(for: insight) else {
            onApplyError?(AppConstants.AIAssistant.recommendedTaskUnavailable)
            return
        }

        performApply(insight: insight, task: task)
    }

    func retry() {
        performAnalysis(force: true, showLoading: true)
    }

    // MARK: - Presentation

    var recommendedTask: Task? {
        guard let insight = currentInsight else { return nil }
        return recommendedTask(for: insight)
    }

    var isApplyEnabled: Bool {
        switch state {
        case .loaded:
            return recommendedTask?.isEditable == true
        case .applying:
            return false
        default:
            return false
        }
    }

    var isRegenerateEnabled: Bool {
        switch state {
        case .loading, .applying:
            return false
        case .empty, .error, .loaded:
            return true
        }
    }

    // MARK: - Private

    private var currentInsight: WorkloadInsight? {
        switch state {
        case .loaded(let insight), .applying(let insight):
            return insight
        case .loading, .empty, .error:
            return nil
        }
    }

    private var isApplying: Bool {
        if case .applying = state {
            return true
        }
        return false
    }

    private func performAnalysis(force: Bool, showLoading: Bool) {
        analysisGeneration += 1
        let generation = analysisGeneration

        if showLoading {
            state = .loading
        }

        taskService.fetchTasks { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.handleFetchResult(
                    result,
                    force: force,
                    generation: generation,
                    notifyOnAnalysisFailure: force
                )
            }
        }
    }

    private func handleFetchResult(
        _ result: Result<[Task], TaskError>,
        force: Bool,
        generation: Int,
        notifyOnAnalysisFailure: Bool
    ) {
        guard generation == analysisGeneration else { return }

        switch result {
        case .success(let tasks):
            allTasks = tasks

            let eligibleTasks = tasks.filter { !$0.isCompleted }
            guard !eligibleTasks.isEmpty else {
                cachedInsight = nil
                lastAnalyzedFingerprint = nil
                state = .empty
                return
            }

            let fingerprint = Self.workloadFingerprint(for: tasks)

            if !force,
               fingerprint == lastAnalyzedFingerprint,
               let cachedInsight {
                state = .loaded(cachedInsight)
                return
            }

            state = .loading
            requestWorkloadAnalysis(
                tasks: tasks,
                fingerprint: fingerprint,
                generation: generation,
                notifyOnFailure: notifyOnAnalysisFailure
            )

        case .failure(let error):
            if let cachedInsight {
                state = .loaded(cachedInsight)
            } else {
                state = .error(error.message)
            }
        }
    }

    private func requestWorkloadAnalysis(
        tasks: [Task],
        fingerprint: String,
        generation: Int,
        notifyOnFailure: Bool
    ) {
        aiService.analyzeWorkload(tasks: tasks) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                guard generation == self.analysisGeneration else { return }

                switch result {
                case .success(let insight):
                    self.cachedInsight = insight
                    self.lastAnalyzedFingerprint = fingerprint
                    self.state = .loaded(insight)
                case .failure(let error):
                    if error == .noEligibleTasks {
                        self.cachedInsight = nil
                        self.lastAnalyzedFingerprint = nil
                        self.state = .empty
                    } else if let cachedInsight = self.cachedInsight {
                        self.state = .loaded(cachedInsight)
                        if notifyOnFailure {
                            self.onAnalysisError?(error.message)
                        }
                    } else {
                        self.state = .error(error.message)
                    }
                }
            }
        }
    }

    private func performApply(insight: WorkloadInsight, task: Task) {
        state = .applying(insight)

        let subtasks = insight.suggestedSubtasks.map { Subtask(title: $0.title) }
        let input = CreateTaskInput(
            title: task.title,
            description: task.description,
            priority: insight.recommendedPriority,
            dueDate: task.dueDate,
            subtasks: subtasks
        )

        taskService.updateTask(task: task, input: input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let updatedTask):
                    self.replaceTask(updatedTask)
                    TaskNotifications.postDidChange()
                    self.state = .loaded(insight)
                    self.onApplySuccess?(AppConstants.AIAssistant.applySuccess)
                    self.refreshInsightInBackground()
                case .failure(let error):
                    self.state = .loaded(insight)
                    self.onApplyError?(error.message)
                }
            }
        }
    }

    private func recommendedTask(for insight: WorkloadInsight) -> Task? {
        allTasks.first { $0.id == insight.recommendedTaskID }
    }

    private func replaceTask(_ task: Task) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index] = task
        }
    }

    private func refreshInsightInBackground() {
        let eligibleTasks = allTasks.filter { !$0.isCompleted }
        guard !eligibleTasks.isEmpty else {
            cachedInsight = nil
            lastAnalyzedFingerprint = nil
            state = .empty
            return
        }

        analysisGeneration += 1
        let generation = analysisGeneration
        let fingerprint = Self.workloadFingerprint(for: allTasks)
        lastAnalyzedFingerprint = nil

        aiService.analyzeWorkload(tasks: allTasks) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                guard generation == self.analysisGeneration else { return }

                switch result {
                case .success(let insight):
                    self.cachedInsight = insight
                    self.lastAnalyzedFingerprint = fingerprint
                    if case .loaded = self.state {
                        self.state = .loaded(insight)
                    }
                case .failure(let error):
                    if error == .noEligibleTasks {
                        self.cachedInsight = nil
                        self.lastAnalyzedFingerprint = nil
                        self.state = .empty
                    }
                }
            }
        }
    }

    private static func workloadFingerprint(for tasks: [Task]) -> String {
        tasks
            .sorted { $0.id < $1.id }
            .map { task in
                let dueDate = task.dueDate.map { APIDateFormatter.apiDateString(from: $0) } ?? "none"
                return [
                    task.id,
                    task.title,
                    task.priority.rawValue,
                    dueDate,
                    task.isCompleted ? "1" : "0",
                    String(task.subtasks.count),
                    String(task.updatedAt.timeIntervalSince1970)
                ].joined(separator: "|")
            }
            .joined(separator: ";")
    }
}
