//
//  PriorityBadgeView.swift
//  SmartTaskManager
//

import UIKit

final class PriorityBadgeView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.priorityBadge()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = AppConstants.TaskList.Layout.priorityBadgeCornerRadius
        layer.masksToBounds = true
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(priority: TaskPriority) {
        titleLabel.text = priority.displayTitle.uppercased()
        titleLabel.textColor = priority.badgeTextColor
        backgroundColor = priority.badgeBackgroundColor
    }

    private func setupViews() {
        addSubview(titleLabel)

        let horizontalPadding = AppConstants.TaskList.Layout.priorityBadgeHorizontalPadding
        let verticalPadding = AppConstants.TaskList.Layout.priorityBadgeVerticalPadding

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ])
    }
}
