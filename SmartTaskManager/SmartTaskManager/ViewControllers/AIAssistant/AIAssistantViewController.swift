//
//  AIAssistantViewController.swift
//  SmartTaskManager
//

import UIKit

final class AIAssistantViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: AIAssistantViewModel

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isHidden = true
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.AIAssistant.Layout.sectionSpacing
        return stackView
    }()

    private let insightsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.AIAssistant.Layout.sectionSpacing
        return stackView
    }()

    private let summaryCardView = AIAssistantSummaryCardView()
    private let recommendationCardView = AIAssistantRecommendationCardView()
    private let breakdownSectionView = AIAssistantBreakdownSectionView()

    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.AIAssistant.Layout.actionButtonSpacing
        return stackView
    }()

    private lazy var applyButton = makeActionButton(
        title: AppConstants.AIAssistant.applySuggestions,
        iconName: "sparkles",
        style: .primary
    )

    private lazy var regenerateButton = makeActionButton(
        title: AppConstants.AIAssistant.regenerate,
        iconName: "arrow.clockwise",
        style: .secondary
    )

    private let applyActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .appOnPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let loadingContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let loadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = AppConstants.AIAssistant.Layout.loadingSpacing
        return stackView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .appPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.text = AppConstants.AIAssistant.analyzingWorkload
        return label
    }()

    private let emptyStateView = EmptyStateView()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.button()
        button.setTitle(AppConstants.AIAssistant.retryButton, for: .normal)
        button.isHidden = true
        return button
    }()

    // MARK: - Initialization

    init(viewModel: AIAssistantViewModel = AIAssistantViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureUI()
        bindViewModel()
        applyState(viewModel.state)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadInsightsIfNeeded()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        view.addSubview(loadingContainerView)
        view.addSubview(emptyStateView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(insightsContainerStackView)
        contentStackView.addArrangedSubview(actionsStackView)

        insightsContainerStackView.addArrangedSubview(summaryCardView)
        insightsContainerStackView.addArrangedSubview(recommendationCardView)
        insightsContainerStackView.addArrangedSubview(breakdownSectionView)

        actionsStackView.addArrangedSubview(applyButton)
        actionsStackView.addArrangedSubview(regenerateButton)
        applyButton.addSubview(applyActivityIndicator)

        loadingContainerView.addSubview(loadingStackView)
        loadingStackView.addArrangedSubview(loadingIndicator)
        loadingStackView.addArrangedSubview(loadingLabel)

        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateTapped), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        contentStackView.setCustomSpacing(
            AppConstants.AIAssistant.Layout.actionSectionTopSpacing,
            after: insightsContainerStackView
        )
    }

    private func setupConstraints() {
        let margin = AppConstants.AIAssistant.Layout.marginMain
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: AppConstants.AIAssistant.Layout.contentTopSpacing
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: margin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -margin
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -AppConstants.AIAssistant.Layout.contentBottomPadding
            ),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -(margin * 2)
            ),

            applyButton.heightAnchor.constraint(equalToConstant: AppConstants.AIAssistant.Layout.actionButtonHeight),
            regenerateButton.heightAnchor.constraint(equalToConstant: AppConstants.AIAssistant.Layout.actionButtonHeight),

            applyActivityIndicator.centerXAnchor.constraint(equalTo: applyButton.centerXAnchor),
            applyActivityIndicator.centerYAnchor.constraint(equalTo: applyButton.centerYAnchor),

            loadingContainerView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            loadingContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingStackView.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            loadingStackView.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor),
            loadingStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: loadingContainerView.leadingAnchor,
                constant: margin
            ),
            loadingStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: loadingContainerView.trailingAnchor,
                constant: -margin
            ),

            emptyStateView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            retryButton.topAnchor.constraint(
                equalTo: errorLabel.bottomAnchor,
                constant: AppConstants.AIAssistant.Layout.sectionSpacing / 2
            ),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        title = viewModel.screenTitle
        retryButton.setTitleColor(.appPrimary, for: .normal)
        emptyStateView.configure(
            title: AppConstants.AIAssistant.emptyTitle,
            message: AppConstants.AIAssistant.emptyMessage,
            systemImageName: AppConstants.AIAssistant.emptySystemImageName
        )
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
        }

        viewModel.onApplySuccess = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }

        viewModel.onApplyError = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }

        viewModel.onAnalysisError = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }

        viewModel.onApplyConfirmationRequired = { [weak self] in
            self?.presentApplyConfirmation()
        }
    }

    // MARK: - State

    private func applyState(_ state: AIAssistantViewState) {
        switch state {
        case .loading:
            showLoading()
        case .loaded(let insight):
            showContent(isApplying: false, insight: insight)
        case .applying(let insight):
            showContent(isApplying: true, insight: insight)
        case .empty:
            showEmpty()
        case .error(let message):
            showError(message)
        }

        updateActionButtons()
    }

    private func showLoading() {
        scrollView.isHidden = true
        loadingContainerView.isHidden = false
        emptyStateView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func showContent(isApplying: Bool, insight: WorkloadInsight) {
        loadingContainerView.isHidden = true
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
        emptyStateView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true

        configureInsights(with: insight)

        if isApplying {
            applyActivityIndicator.startAnimating()
            applyButton.setTitle(nil, for: .normal)
        } else {
            applyActivityIndicator.stopAnimating()
            applyButton.setTitle(AppConstants.AIAssistant.applySuggestions, for: .normal)
        }
    }

    private func configureInsights(with insight: WorkloadInsight) {
        summaryCardView.configure(
            headline: insight.summaryHeadline,
            message: insight.summaryMessage
        )

        let taskTitle = viewModel.recommendedTask?.title ?? AppConstants.AIAssistant.recommendedTaskUnavailable
        recommendationCardView.configure(insight: insight, taskTitle: taskTitle)
        breakdownSectionView.configure(subtasks: insight.suggestedSubtasks)
    }

    private func showEmpty() {
        scrollView.isHidden = true
        loadingContainerView.isHidden = true
        loadingIndicator.stopAnimating()
        emptyStateView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func showError(_ message: String) {
        scrollView.isHidden = true
        loadingContainerView.isHidden = true
        loadingIndicator.stopAnimating()
        emptyStateView.isHidden = true
        errorLabel.isHidden = false
        retryButton.isHidden = false
        errorLabel.text = message
    }

    private func updateActionButtons() {
        applyButton.isEnabled = viewModel.isApplyEnabled
        applyButton.alpha = viewModel.isApplyEnabled ? 1 : 0.5

        regenerateButton.isEnabled = viewModel.isRegenerateEnabled
        regenerateButton.alpha = viewModel.isRegenerateEnabled ? 1 : 0.5
    }

    // MARK: - Actions

    @objc private func applyTapped() {
        viewModel.applySuggestions()
    }

    @objc private func regenerateTapped() {
        viewModel.regenerate()
    }

    @objc private func retryTapped() {
        viewModel.retry()
    }

    private func presentApplyConfirmation() {
        let alert = UIAlertController(
            title: AppConstants.AIAssistant.replaceSubtasksTitle,
            message: AppConstants.AIAssistant.replaceSubtasksMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppConstants.CreateTask.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppConstants.AIAssistant.replaceAction, style: .destructive) { [weak self] _ in
            self?.viewModel.confirmApplySuggestions()
        })
        present(alert, animated: true)
    }

    // MARK: - Button Factory

    private enum ActionButtonStyle {
        case primary
        case secondary
    }

    private func makeActionButton(
        title: String,
        iconName: String,
        style: ActionButtonStyle
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = AppConstants.CreateTask.Layout.aiButtonCornerRadius

        let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let icon = UIImage(systemName: iconName, withConfiguration: iconConfiguration)

        var configuration = UIButton.Configuration.plain()
        configuration.image = icon
        configuration.title = title
        configuration.imagePadding = AppConstants.TaskList.Layout.stackGap
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.headline()
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: AppConstants.AIAssistant.Layout.marginMain,
            bottom: 0,
            trailing: AppConstants.AIAssistant.Layout.marginMain
        )

        switch style {
        case .primary:
            button.backgroundColor = .appPrimary
            configuration.baseForegroundColor = .appOnPrimary
        case .secondary:
            button.backgroundColor = .appSurfaceContainer
            configuration.baseForegroundColor = .appOnSurface
        }

        button.configuration = configuration
        return button
    }
}
