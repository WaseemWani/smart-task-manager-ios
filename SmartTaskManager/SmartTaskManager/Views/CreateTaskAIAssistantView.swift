//
//  CreateTaskAIAssistantView.swift
//  SmartTaskManager
//

import UIKit

final class CreateTaskAIAssistantView: UIView {

    var onSuggestPriorityTapped: (() -> Void)?
    var onBreakIntoSubtasksTapped: (() -> Void)?

    private let gradientOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.alpha = 0.03
        return view
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = AppConstants.CreateTask.Layout.aiHeaderSpacing
        return stackView
    }()

    private let sparkIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        let configuration = UIImage.SymbolConfiguration(pointSize: AppConstants.CreateTask.Layout.aiSparkIconSize, weight: .medium)
        imageView.image = UIImage(systemName: "sparkles", withConfiguration: configuration)
        imageView.preferredSymbolConfiguration = configuration
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.text = AppConstants.CreateTask.aiAssistantTitle
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.CreateTask.Layout.aiLoadingTopSpacing
        return stackView
    }()

    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = AppConstants.CreateTask.Layout.aiButtonSpacing
        return stackView
    }()

    private lazy var suggestPriorityButton = makeActionButton(
        iconName: "chart.bar",
        title: AppConstants.CreateTask.suggestPriority,
        action: #selector(suggestPriorityTapped)
    )

    private lazy var breakIntoSubtasksButton = makeActionButton(
        iconName: "list.bullet.indent",
        title: AppConstants.CreateTask.breakIntoSubtasks,
        action: #selector(breakIntoSubtasksTapped)
    )

    private let loadingContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let loadingSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appOutlineVariantMuted
        return view
    }()

    private let loadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = AppConstants.CreateTask.Layout.aiLoadingSpacing
        return stackView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .appPrimary
        indicator.hidesWhenStopped = false
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.text = AppConstants.CreateTask.generatingAISuggestions
        return label
    }()

    private let gradientLayer = CAGradientLayer()
    private var isLoadingState = false
    private var isSuggestPriorityAllowed = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
    }

    func setLoading(_ isLoading: Bool) {
        isLoadingState = isLoading
        loadingContainerView.isHidden = !isLoading

        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        updateSuggestPriorityButtonState()
    }

    func setSuggestPriorityEnabled(_ isEnabled: Bool) {
        isSuggestPriorityAllowed = isEnabled
        updateSuggestPriorityButtonState()
    }

    private func updateSuggestPriorityButtonState() {
        let enabled = isSuggestPriorityAllowed && !isLoadingState
        suggestPriorityButton.isEnabled = enabled
        suggestPriorityButton.alpha = isSuggestPriorityAllowed ? 1 : 0.5
        breakIntoSubtasksButton.isEnabled = !isLoadingState
    }

    // MARK: - Private

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSurfaceLowest
        layer.cornerRadius = AppConstants.CreateTask.Layout.aiCardCornerRadius
        layer.borderWidth = AppConstants.CreateTask.Layout.aiCardBorderWidth
        layer.borderColor = UIColor.appPrimaryBorderMuted.cgColor
        layer.shadowColor = UIColor.appTaskCardShadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = AppConstants.TaskList.Layout.cardShadowRadius
        layer.shadowOffset = CGSize(
            width: 0,
            height: AppConstants.TaskList.Layout.cardShadowYOffset
        )
        layer.masksToBounds = false
        clipsToBounds = true

        configureGradient()

        addSubview(gradientOverlayView)
        addSubview(contentStackView)

        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(actionsStackView)
        contentStackView.addArrangedSubview(loadingContainerView)

        headerStackView.addArrangedSubview(sparkIconView)
        headerStackView.addArrangedSubview(titleLabel)

        actionsStackView.addArrangedSubview(suggestPriorityButton)
        actionsStackView.addArrangedSubview(breakIntoSubtasksButton)

        loadingContainerView.addSubview(loadingSeparatorView)
        loadingContainerView.addSubview(loadingStackView)
        loadingStackView.addArrangedSubview(loadingIndicator)
        loadingStackView.addArrangedSubview(loadingLabel)

        let padding = AppConstants.CreateTask.Layout.aiCardPadding
        let layout = AppConstants.CreateTask.Layout.self

        NSLayoutConstraint.activate([
            gradientOverlayView.topAnchor.constraint(equalTo: topAnchor),
            gradientOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            sparkIconView.widthAnchor.constraint(equalToConstant: layout.aiSparkIconSize),
            sparkIconView.heightAnchor.constraint(equalToConstant: layout.aiSparkIconSize),

            loadingSeparatorView.topAnchor.constraint(equalTo: loadingContainerView.topAnchor),
            loadingSeparatorView.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor),
            loadingSeparatorView.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor),
            loadingSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            loadingStackView.topAnchor.constraint(
                equalTo: loadingSeparatorView.bottomAnchor,
                constant: layout.aiLoadingTopPadding
            ),
            loadingStackView.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor),
            loadingStackView.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor),
            loadingStackView.bottomAnchor.constraint(equalTo: loadingContainerView.bottomAnchor)
        ])

        contentStackView.setCustomSpacing(layout.aiHeaderBottomSpacing, after: headerStackView)
    }

    private func configureGradient() {
        gradientLayer.colors = [
            UIColor.appPrimary.cgColor,
            UIColor.appStitchTertiary.cgColor,
            UIColor.appSecondary.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientOverlayView.layer.addSublayer(gradientLayer)
    }

    private func makeActionButton(iconName: String, title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appSurfaceContainer
        button.layer.cornerRadius = AppConstants.CreateTask.Layout.aiButtonCornerRadius
        button.tintColor = .appPrimary
        button.addTarget(self, action: action, for: .touchUpInside)

        let iconConfiguration = UIImage.SymbolConfiguration(
            pointSize: AppConstants.CreateTask.Layout.aiActionIconSize,
            weight: .regular
        )
        let icon = UIImage(systemName: iconName, withConfiguration: iconConfiguration)

        var configuration = UIButton.Configuration.plain()
        configuration.image = icon
        configuration.title = title
        configuration.imagePlacement = .top
        configuration.imagePadding = AppConstants.CreateTask.Layout.aiButtonIconSpacing
        configuration.baseForegroundColor = .appPrimary
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.footnote()
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: AppConstants.CreateTask.Layout.aiButtonPadding,
            leading: AppConstants.CreateTask.Layout.aiButtonPadding,
            bottom: AppConstants.CreateTask.Layout.aiButtonPadding,
            trailing: AppConstants.CreateTask.Layout.aiButtonPadding
        )
        button.configuration = configuration

        return button
    }

    @objc private func suggestPriorityTapped() {
        onSuggestPriorityTapped?()
    }

    @objc private func breakIntoSubtasksTapped() {
        onBreakIntoSubtasksTapped?()
    }
}
