//
//  AIAssistantBreakdownSectionView.swift
//  SmartTaskManager
//

import UIKit

final class AIAssistantBreakdownSectionView: UIView {

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = AppConstants.AIAssistant.Layout.stackGap + 4
        return stackView
    }()

    private let headerIconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appMediumPriorityBadgeBackground
        view.layer.cornerRadius = AppConstants.AIAssistant.Layout.iconContainerCornerRadius
        return view
    }()

    private let headerIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appMediumPriorityBadgeText
        let configuration = UIImage.SymbolConfiguration(
            pointSize: AppConstants.TaskList.Layout.dueDateIconSize,
            weight: .medium
        )
        imageView.image = UIImage(systemName: "arrow.triangle.branch", withConfiguration: configuration)
        return imageView
    }()

    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.text = AppConstants.AIAssistant.suggestedBreakdown
        return label
    }()

    private let rowsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.AIAssistant.Layout.breakdownRowSpacing
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(subtasks: [SuggestedSubtaskItem]) {
        rowsStackView.arrangedSubviews.forEach { view in
            rowsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        subtasks.forEach { subtask in
            let rowView = AIAssistantSuggestedSubtaskRowView()
            rowView.configure(title: subtask.title)
            rowsStackView.addArrangedSubview(rowView)
        }
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSurfaceLowest
        layer.cornerRadius = AppConstants.AIAssistant.Layout.glassCardCornerRadius
        layer.borderWidth = AppConstants.AIAssistant.Layout.cardBorderWidth
        layer.borderColor = UIColor.appTaskCardBorder.cgColor
        applyCardShadow()

        addSubview(headerStackView)
        addSubview(rowsStackView)

        headerStackView.addArrangedSubview(headerIconContainerView)
        headerStackView.addArrangedSubview(headerTitleLabel)

        headerIconContainerView.addSubview(headerIconView)

        let padding = AppConstants.AIAssistant.Layout.glassCardPadding
        let iconContainerSize = AppConstants.AIAssistant.Layout.iconContainerSize
        let iconSize = AppConstants.TaskList.Layout.dueDateIconSize

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headerStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -padding),

            headerIconContainerView.widthAnchor.constraint(equalToConstant: iconContainerSize),
            headerIconContainerView.heightAnchor.constraint(equalToConstant: iconContainerSize),

            headerIconView.centerXAnchor.constraint(equalTo: headerIconContainerView.centerXAnchor),
            headerIconView.centerYAnchor.constraint(equalTo: headerIconContainerView.centerYAnchor),
            headerIconView.widthAnchor.constraint(equalToConstant: iconSize),
            headerIconView.heightAnchor.constraint(equalToConstant: iconSize),

            rowsStackView.topAnchor.constraint(
                equalTo: headerStackView.bottomAnchor,
                constant: AppConstants.AIAssistant.Layout.breakdownHeaderSpacing
            ),
            rowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            rowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            rowsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }

    private func applyCardShadow() {
        layer.shadowColor = UIColor.appTaskCardShadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = AppConstants.AIAssistant.Layout.cardShadowRadius
        layer.shadowOffset = CGSize(
            width: 0,
            height: AppConstants.AIAssistant.Layout.cardShadowYOffset
        )
        layer.masksToBounds = false
    }
}

// MARK: - AIAssistantSuggestedSubtaskRowView

private final class AIAssistantSuggestedSubtaskRowView: UIView {

    private let checkboxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = AppConstants.AIAssistant.Layout.suggestedSubtaskCheckboxSize / 2
        view.layer.borderWidth = AppConstants.AIAssistant.Layout.suggestedSubtaskCheckboxBorderWidth
        view.layer.borderColor = UIColor.appOutlineVariant.cgColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textColor = .appOnSurface
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkboxView)
        addSubview(titleLabel)

        let checkboxSize = AppConstants.AIAssistant.Layout.suggestedSubtaskCheckboxSize
        let rowGap = AppConstants.TaskList.Layout.cardRowGap

        NSLayoutConstraint.activate([
            checkboxView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            checkboxView.widthAnchor.constraint(equalToConstant: checkboxSize),
            checkboxView.heightAnchor.constraint(equalToConstant: checkboxSize),

            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxView.trailingAnchor, constant: rowGap),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
