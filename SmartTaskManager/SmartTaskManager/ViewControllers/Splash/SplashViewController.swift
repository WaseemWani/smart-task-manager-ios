//
//  SplashViewController.swift
//  SmartTaskManager
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Dependencies

    private let navigator: SplashNavigating

    // MARK: - UI

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = "SmartTaskManager logo"
        return imageView
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = false
        return indicator
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let brandingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    // MARK: - Initialization

    init(navigator: SplashNavigating = SplashNavigator()) {
        self.navigator = navigator
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingIndicator.startAnimating()
        navigator.schedulePostSplashTransition(from: self)
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(brandingStackView)
        view.addSubview(loadingIndicator)
        view.addSubview(versionLabel)

        brandingStackView.addArrangedSubview(logoImageView)
        brandingStackView.addArrangedSubview(appNameLabel)
        brandingStackView.addArrangedSubview(taglineLabel)

        brandingStackView.setCustomSpacing(20, after: logoImageView)
        brandingStackView.setCustomSpacing(4, after: appNameLabel)
    }

    private func setupConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 96),
            logoImageView.heightAnchor.constraint(equalToConstant: 96),

            brandingStackView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            brandingStackView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor, constant: -40),
            brandingStackView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor, constant: 24),
            brandingStackView.trailingAnchor.constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor, constant: -24),

            versionLabel.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -24),
            versionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor, constant: 24),
            versionLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor, constant: -24),

            loadingIndicator.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -20)
        ])
    }

    private func configureUI() {
        view.backgroundColor = .appBackground

        logoImageView.image = UIImage(named: AppConstants.Assets.appLogo)

        appNameLabel.text = AppConstants.App.name
        appNameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        appNameLabel.textColor = .appOnSurface

        taglineLabel.text = AppConstants.App.tagline
        taglineLabel.font = .systemFont(ofSize: 17, weight: .regular)
        taglineLabel.textColor = .appOutline

        versionLabel.text = AppConstants.App.versionLabel
        versionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        versionLabel.textColor = .appOutline

        loadingIndicator.color = .appPrimary
    }
}
