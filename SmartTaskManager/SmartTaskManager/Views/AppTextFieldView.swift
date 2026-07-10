//
//  AppTextFieldView.swift
//  SmartTaskManager
//

import UIKit

final class AppTextFieldView: UIView {

    // MARK: - Types

    enum TrailingControl {
        case none
        case passwordVisibility
    }

    // MARK: - UI

    let textField: UITextField

    private let inputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let trailingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.caption()
        label.textColor = .appError
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let trailingControl: TrailingControl

    // MARK: - Initialization

    init(
        systemIconName: String,
        placeholder: String,
        trailingControl: TrailingControl = .none,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.trailingControl = trailingControl

        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.font = AppFont.input()
        textField.textColor = .appOnSurface
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .none
        textField.keyboardType = keyboardType

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: systemIconName)
        configureTrailingControl()
        setupViews()
        setupConstraints()
        configureAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public

    func setErrorMessage(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
        inputContainer.layer.borderWidth = message == nil ? 0 : 1
        inputContainer.layer.borderColor = message == nil ? nil : UIColor.appError.cgColor
    }

    func applyTheme() {
        iconImageView.tintColor = .appOutline
        trailingButton.tintColor = .appPrimary
        textField.textColor = .appOnSurface
        inputContainer.backgroundColor = .appInputBackground

        guard let placeholder = textField.placeholder else { return }
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.appOutline.withAlphaComponent(0.6)]
        )
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(inputContainer)
        addSubview(errorLabel)
        inputContainer.addSubview(iconImageView)
        inputContainer.addSubview(textField)

        if trailingControl == .passwordVisibility {
            inputContainer.addSubview(trailingButton)
            trailingButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        }
    }

    private func setupConstraints() {
        let inputHeightConstraint = inputContainer.heightAnchor.constraint(equalToConstant: 50)

        var constraints = [
            inputContainer.topAnchor.constraint(equalTo: topAnchor),
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),

            errorLabel.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            inputHeightConstraint
        ]

        if trailingControl == .passwordVisibility {
            constraints += [
                trailingButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
                trailingButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
                trailingButton.widthAnchor.constraint(equalToConstant: 24),
                trailingButton.heightAnchor.constraint(equalToConstant: 24),
                textField.trailingAnchor.constraint(equalTo: trailingButton.leadingAnchor, constant: -12)
            ]
        } else {
            constraints.append(textField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func configureAppearance() {
        inputContainer.layer.cornerRadius = 10
        inputContainer.layer.masksToBounds = true
        applyTheme()
    }

    private func configureTrailingControl() {
        guard trailingControl == .passwordVisibility else { return }
        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        trailingButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Actions

    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()
        configureTrailingControl()
    }
}
