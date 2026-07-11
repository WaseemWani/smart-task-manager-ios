//
//  CreateTaskOptionRowView.swift
//  SmartTaskManager
//

import UIKit

final class CreateTaskOptionRowView: UIControl {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textColor = .appOnSurface
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textAlignment = .right
        return label
    }()

    private let priorityBadgeView = PriorityBadgeView()

    init(iconName: String, title: String, iconTintColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconTintColor
        titleLabel.text = title
        priorityBadgeView.isHidden = true
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func setValueText(_ text: String, isPlaceholder: Bool) {
        valueLabel.isHidden = false
        priorityBadgeView.isHidden = true
        valueLabel.text = text
        valueLabel.textColor = isPlaceholder ? .appOutline : .appPrimary
    }

    func setPriority(_ priority: TaskPriority?) {
        guard let priority else {
            setValueText(AppConstants.CreateTask.selectPriority, isPlaceholder: true)
            return
        }

        valueLabel.isHidden = true
        priorityBadgeView.isHidden = false
        priorityBadgeView.configure(priority: priority)
    }

    private func setupViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(priorityBadgeView)

        let iconSize = AppConstants.TaskList.Layout.dueDateIconSize

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AppConstants.TaskList.Layout.optionRowHeight),

            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            priorityBadgeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            priorityBadgeView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
