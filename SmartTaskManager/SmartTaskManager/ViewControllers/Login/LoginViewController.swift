//
//  LoginViewController.swift
//  SmartTaskManager
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: LoginViewModel
    private let tabBarFactory: MainTabBarBuilding

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = "SmartTaskManager logo"
        return imageView
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let formCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        return view
    }()

    private lazy var emailFieldView = AppTextFieldView(
        systemIconName: "envelope",
        placeholder: AppConstants.Login.emailPlaceholder,
        keyboardType: .emailAddress
    )

    private lazy var passwordFieldView = AppTextFieldView(
        systemIconName: "lock",
        placeholder: AppConstants.Login.passwordPlaceholder,
        trailingControl: .passwordVisibility,
        isSecure: true
    )

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .trailing
        return button
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let loginActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()

    private let loginErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.caption()
        label.textColor = .appError
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var orDividerView = OrDividerView(title: AppConstants.Login.orDivider)

    private let continueAsGuestButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let footerSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()

    private let termsOfServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    // MARK: - Initialization

    init(
        viewModel: LoginViewModel = LoginViewModel(),
        tabBarFactory: MainTabBarBuilding = MainTabBarFactory()
    ) {
        self.viewModel = viewModel
        self.tabBarFactory = tabBarFactory
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

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            logoImageView,
            welcomeLabel,
            subtitleLabel,
            formCardView,
            footerStackView
        ].forEach { contentView.addSubview($0) }

        [
            emailFieldView,
            passwordFieldView,
            forgotPasswordButton,
            loginButton,
            loginActivityIndicator,
            loginErrorLabel,
            orDividerView,
            continueAsGuestButton
        ].forEach { formCardView.addSubview($0) }

        footerStackView.addArrangedSubview(privacyPolicyButton)
        footerStackView.addArrangedSubview(footerSeparatorView)
        footerStackView.addArrangedSubview(termsOfServiceButton)
    }

    private func setupConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        let contentLayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),

            welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),

            formCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            formCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            emailFieldView.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: 32),
            emailFieldView.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: 32),
            emailFieldView.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -32),

            passwordFieldView.topAnchor.constraint(equalTo: emailFieldView.bottomAnchor, constant: 16),
            passwordFieldView.leadingAnchor.constraint(equalTo: emailFieldView.leadingAnchor),
            passwordFieldView.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),

            forgotPasswordButton.topAnchor.constraint(equalTo: passwordFieldView.bottomAnchor, constant: 8),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailFieldView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            loginActivityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loginActivityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            loginErrorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8),
            loginErrorLabel.leadingAnchor.constraint(equalTo: emailFieldView.leadingAnchor),
            loginErrorLabel.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),

            orDividerView.topAnchor.constraint(equalTo: loginErrorLabel.bottomAnchor, constant: 8),
            orDividerView.leadingAnchor.constraint(equalTo: emailFieldView.leadingAnchor),
            orDividerView.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),

            continueAsGuestButton.topAnchor.constraint(equalTo: orDividerView.bottomAnchor, constant: 16),
            continueAsGuestButton.leadingAnchor.constraint(equalTo: emailFieldView.leadingAnchor),
            continueAsGuestButton.trailingAnchor.constraint(equalTo: emailFieldView.trailingAnchor),
            continueAsGuestButton.heightAnchor.constraint(equalToConstant: 50),
            continueAsGuestButton.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -32),

            footerStackView.topAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: 32),
            footerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            footerSeparatorView.widthAnchor.constraint(equalToConstant: 4),
            footerSeparatorView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func configureUI() {
        view.backgroundColor = .appLoginBackground
        scrollView.backgroundColor = .appLoginBackground

        configureFormCard()
        configureBranding()
        configureFormFields()
        configureButtons()
        configureActions()
    }

    private func configureFormCard() {
        formCardView.backgroundColor = .appSurfaceLowest
        formCardView.layer.shadowColor = UIColor.black.cgColor
        formCardView.layer.shadowOpacity = 0.05
        formCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        formCardView.layer.shadowRadius = 10
    }

    private func configureBranding() {
        logoImageView.image = UIImage(named: AppConstants.Assets.appLogo)

        welcomeLabel.text = AppConstants.Login.welcomeTitle
        welcomeLabel.font = AppFont.title()
        welcomeLabel.textColor = .appOnSurface

        subtitleLabel.text = AppConstants.Login.subtitle
        subtitleLabel.font = AppFont.body()
        subtitleLabel.textColor = .appOutline
    }

    private func configureFormFields() {
        emailFieldView.applyTheme()
        passwordFieldView.applyTheme()
        emailFieldView.textField.returnKeyType = .next
        emailFieldView.textField.textContentType = .username
        emailFieldView.textField.delegate = self
        emailFieldView.textField.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)

        passwordFieldView.textField.returnKeyType = .done
        passwordFieldView.textField.textContentType = .password
        passwordFieldView.textField.delegate = self
        passwordFieldView.textField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    }

    private func configureButtons() {
        configurePrimaryLinkButton(forgotPasswordButton, title: AppConstants.Login.forgotPassword)
        configurePrimaryButton(loginButton, title: AppConstants.Login.loginButton)
        configureGuestButton(continueAsGuestButton, title: AppConstants.Login.continueAsGuest)
        configureMutedLinkButton(privacyPolicyButton, title: AppConstants.Login.privacyPolicy)
        configureMutedLinkButton(termsOfServiceButton, title: AppConstants.Login.termsOfService)

        orDividerView.applyTheme()
        footerSeparatorView.backgroundColor = .appOutlineVariant
        loginActivityIndicator.color = .appOnPrimary
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
    }

    private func configureActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        continueAsGuestButton.addTarget(self, action: #selector(continueAsGuestTapped), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        termsOfServiceButton.addTarget(self, action: #selector(termsOfServiceTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
        }

        viewModel.onLoginSuccess = { [weak self] in
            guard let self else { return }
            let mainTabBarController = self.tabBarFactory.makeMainTabBarController()
            self.replaceRoot(with: mainTabBarController, animated: true)
        }
    }

    private func applyState(_ state: LoginViewState) {
        loginButton.isEnabled = state.isLoginEnabled
        loginButton.alpha = state.isLoginEnabled ? 1 : 0.5

        emailFieldView.setErrorMessage(state.emailError)
        passwordFieldView.setErrorMessage(state.passwordError)

        loginErrorLabel.text = state.loginError
        loginErrorLabel.isHidden = state.loginError == nil

        if state.isLoading {
            loginButton.setTitle(nil, for: .normal)
            loginActivityIndicator.startAnimating()
        } else {
            loginButton.setTitle(AppConstants.Login.loginButton, for: .normal)
            loginActivityIndicator.stopAnimating()
        }
    }

    private func configurePrimaryButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.button()
        button.backgroundColor = .appPrimary
        button.setTitleColor(.appOnPrimary, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
    }

    private func configureGuestButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.button()
        button.backgroundColor = .appSurfaceContainer
        button.setTitleColor(.appOnSurface, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.appOutlineVariantMuted.cgColor
    }

    private func configurePrimaryLinkButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.link()
        button.setTitleColor(.appPrimary, for: .normal)
    }

    private func configureMutedLinkButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.link()
        button.setTitleColor(.appOutline, for: .normal)
    }

    // MARK: - Actions

    @objc private func emailDidChange() {
        viewModel.updateEmail(emailFieldView.textField.text ?? "")
    }

    @objc private func passwordDidChange() {
        viewModel.updatePassword(passwordFieldView.textField.text ?? "")
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        viewModel.login()
    }

    @objc private func forgotPasswordTapped() {
        // TODO(STM-101): Navigate to forgot password flow when password recovery is implemented.
    }

    @objc private func continueAsGuestTapped() {
        // TODO(STM-101): Navigate to guest task list when guest mode is implemented.
    }

    @objc private func privacyPolicyTapped() {
        // TODO(STM-101): Open privacy policy URL when legal content endpoints are available.
    }

    @objc private func termsOfServiceTapped() {
        // TODO(STM-101): Open terms of service URL when legal content endpoints are available.
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailFieldView.textField {
            passwordFieldView.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if viewModel.state.isLoginEnabled {
                viewModel.login()
            }
        }
        return true
    }
}
