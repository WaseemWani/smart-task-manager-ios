//
//  EmptyStateView.swift
//  SmartTaskManager
//

import UIKit

final class EmptyStateView: UIView {

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checklist")
        imageView.tintColor = .appOutline
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.textAlignment = .center
        label.text = AppConstants.TaskList.emptyTitle
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = AppConstants.TaskList.emptyMessage
        return label
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppConstants.TaskList.Layout.stackGap
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(contentStack)
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.setCustomSpacing(AppConstants.TaskList.Layout.stackGap * 2, after: iconImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: AppConstants.TaskList.Layout.marginMain),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -AppConstants.TaskList.Layout.marginMain)
        ])
    }

    func configure(title: String, message: String, systemImageName: String = "checklist") {
        titleLabel.text = title
        messageLabel.text = message
        iconImageView.image = UIImage(systemName: systemImageName)
    }

    func resetToDefault() {
        configure(
            title: AppConstants.TaskList.emptyTitle,
            message: AppConstants.TaskList.emptyMessage
        )
    }
}
