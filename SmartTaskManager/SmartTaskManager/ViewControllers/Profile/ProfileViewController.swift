//
//  ProfileViewController.swift
//  SmartTaskManager
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: ProfileViewModel
    private let authService: AuthServicing
    private let makeLoginViewController: () -> UIViewController

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.Profile.Layout.sectionSpacing
        return stackView
    }()

    private let totalStatCard = ProfileStatCardView()
    private let completedStatCard = ProfileStatCardView()
    private let pendingStatCard = ProfileStatCardView()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(
        viewModel: ProfileViewModel = ProfileViewModel(),
        authService: AuthServicing = AuthService(),
        makeLoginViewController: (() -> UIViewController)? = nil
    ) {
        self.viewModel = viewModel
        self.authService = authService
        self.makeLoginViewController = makeLoginViewController ?? { LoginViewController() }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = AppConstants.Tabs.profileTitle
        setupViews()
        setupConstraints()
        configureLogoutButton()
        bindViewModel()
        viewModel.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        let informationSection = makeInformationSection()
        contentStackView.addArrangedSubview(makePerformanceSection())
        contentStackView.addArrangedSubview(makePreferencesSection())
        contentStackView.addArrangedSubview(informationSection)
        contentStackView.addArrangedSubview(logoutButton)
        contentStackView.setCustomSpacing(
            AppConstants.Profile.Layout.logoutTopSpacing,
            after: informationSection
        )
    }

    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: AppConstants.Profile.Layout.contentTopSpacing),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppConstants.Profile.Layout.marginMain),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppConstants.Profile.Layout.marginMain),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -AppConstants.Profile.Layout.contentBottomPadding),

            logoutButton.heightAnchor.constraint(equalToConstant: AppConstants.Profile.Layout.logoutButtonHeight)
        ])
    }

    private func configureLogoutButton() {
        logoutButton.setTitle(AppConstants.Profile.logOut, for: .normal)
        logoutButton.titleLabel?.font = AppFont.button()
        logoutButton.setTitleColor(.appStitchError, for: .normal)
        logoutButton.backgroundColor = .appSurfaceLowest
        logoutButton.layer.cornerRadius = AppConstants.Profile.Layout.menuCardCornerRadius
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.appTaskCardBorder.cgColor
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
        }
    }

    // MARK: - Sections

    private func makePerformanceSection() -> UIView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = AppConstants.Profile.Layout.stackGap

        sectionStack.addArrangedSubview(
            ProfileSectionHeaderView(title: AppConstants.Profile.performanceOverview)
        )
        sectionStack.addArrangedSubview(makeStatsRow())

        return sectionStack
    }

    private func makeStatsRow() -> UIStackView {
        let statsStack = UIStackView(arrangedSubviews: [totalStatCard, completedStatCard, pendingStatCard])
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.spacing = AppConstants.Profile.Layout.statCardSpacing
        statsStack.distribution = .fillEqually
        return statsStack
    }

    private func makePreferencesSection() -> UIView {
        makeMenuSection(
            title: AppConstants.Profile.preferences,
            rows: [
                (iconName: "gearshape", title: AppConstants.Profile.appSettings),
                (iconName: "sparkles", title: AppConstants.Profile.aiSettings)
            ]
        )
    }

    private func makeInformationSection() -> UIView {
        makeMenuSection(
            title: AppConstants.Profile.information,
            rows: [
                (iconName: "info.circle", title: AppConstants.Profile.about),
                (iconName: "questionmark.circle", title: AppConstants.Profile.supportHelpdesk)
            ]
        )
    }

    private func makeMenuSection(title: String, rows: [(iconName: String, title: String)]) -> UIView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = AppConstants.Profile.Layout.stackGap

        sectionStack.addArrangedSubview(ProfileSectionHeaderView(title: title))
        sectionStack.addArrangedSubview(makeMenuCard(rows: rows))

        return sectionStack
    }

    private func makeMenuCard(rows: [(iconName: String, title: String)]) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .appSurfaceLowest
        cardView.layer.cornerRadius = AppConstants.Profile.Layout.menuCardCornerRadius
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.appTaskCardBorder.cgColor

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        for (index, row) in rows.enumerated() {
            stackView.addArrangedSubview(ProfileMenuRowView(iconName: row.iconName, title: row.title))

            if index < rows.count - 1 {
                let separator = makeMenuSeparator()
                stackView.addArrangedSubview(separator)
            }
        }

        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        return cardView
    }

    private func makeMenuSeparator() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .appOutlineVariantMuted
        container.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: AppConstants.Profile.Layout.marginMain),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.topAnchor.constraint(equalTo: container.topAnchor),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    // MARK: - State

    private func applyState(_ state: ProfileViewState) {
        switch state {
        case .guest:
            let guestMessage = AppConstants.Profile.guestStatMessage
            totalStatCard.configure(
                iconName: "list.bullet",
                iconTintColor: .appPrimary,
                title: AppConstants.Profile.totalTasks,
                value: guestMessage,
                isGuest: true
            )
            completedStatCard.configure(
                iconName: "checkmark.circle",
                iconTintColor: .appSecondary,
                title: AppConstants.Profile.completed,
                value: guestMessage,
                isGuest: true
            )
            pendingStatCard.configure(
                iconName: "clock",
                iconTintColor: .appStitchTertiary,
                title: AppConstants.Profile.pending,
                value: guestMessage,
                isGuest: true
            )
        case .loaded(let stats):
            totalStatCard.configure(
                iconName: "list.bullet",
                iconTintColor: .appPrimary,
                title: AppConstants.Profile.totalTasks,
                value: "\(stats.total)",
                isGuest: false
            )
            completedStatCard.configure(
                iconName: "checkmark.circle",
                iconTintColor: .appSecondary,
                title: AppConstants.Profile.completed,
                value: "\(stats.completed)",
                isGuest: false
            )
            pendingStatCard.configure(
                iconName: "clock",
                iconTintColor: .appStitchTertiary,
                title: AppConstants.Profile.pending,
                value: "\(stats.pending)",
                isGuest: false
            )
        }
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: AppConstants.Profile.logoutConfirmTitle,
            message: AppConstants.Profile.logoutConfirmMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: AppConstants.Profile.logoutCancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppConstants.Profile.logoutConfirmAction, style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        authService.logout()
        let loginViewController = makeLoginViewController()
        replaceRoot(with: loginViewController, animated: true)
    }
}
