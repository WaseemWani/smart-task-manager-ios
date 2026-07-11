//
//  TaskListCell.swift
//  SmartTaskManager
//

import UIKit

final class TaskListCell: UITableViewCell {

    static let reuseIdentifier = "TaskListCell"

    var onCheckboxTapped: (() -> Void)?

    // MARK: - UI

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appSurfaceLowest
        view.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appTaskCardBorder.cgColor
        return view
    }()

    private let checkboxView = TaskCheckboxView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.numberOfLines = AppConstants.TaskList.Layout.titleMaxLines
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let priorityBadgeView = PriorityBadgeView()

    private let dueDateIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appOutline
        return imageView
    }()

    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.footnote()
        label.textColor = .appOutline
        return label
    }()

    private let dueDateRow = UIView()

    private var cardBottomToDueDateConstraint: NSLayoutConstraint!
    private var cardBottomToTitleConstraint: NSLayoutConstraint!

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
        setupConstraints()
        applyCardShadow()
        checkboxView.onTap = { [weak self] in
            self?.onCheckboxTapped?()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onCheckboxTapped = nil
    }

    // MARK: - Configuration

    func configure(with task: Task) {
        titleLabel.text = task.title
        priorityBadgeView.configure(priority: task.priority)
        checkboxView.configure(isCompleted: task.isCompleted)

        if let dueDatePresentation = TaskDueDatePresenter.presentation(for: task.dueDate) {
            dueDateIconView.image = UIImage(systemName: dueDatePresentation.systemIconName)
            dueDateLabel.text = dueDatePresentation.text
            dueDateRow.isHidden = false
            cardBottomToDueDateConstraint.isActive = true
            cardBottomToTitleConstraint.isActive = false
        } else {
            dueDateRow.isHidden = true
            cardBottomToDueDateConstraint.isActive = false
            cardBottomToTitleConstraint.isActive = true
        }

        contentView.alpha = task.isCompleted ? 0.9 : 1
    }

    // MARK: - Setup

    private func setupViews() {
        dueDateRow.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardView)
        cardView.addSubview(checkboxView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(priorityBadgeView)
        cardView.addSubview(dueDateRow)
        dueDateRow.addSubview(dueDateIconView)
        dueDateRow.addSubview(dueDateLabel)
    }

    private func setupConstraints() {
        let gutter = AppConstants.TaskList.Layout.gutterCard
        let rowGap = AppConstants.TaskList.Layout.cardRowGap
        let stackGap = AppConstants.TaskList.Layout.stackGap
        let titleBadgeGap = AppConstants.TaskList.Layout.titleBadgeGap
        let iconSize = AppConstants.TaskList.Layout.dueDateIconSize

        priorityBadgeView.setContentCompressionResistancePriority(.required, for: .horizontal)
        priorityBadgeView.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -stackGap),

            checkboxView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: gutter),
            checkboxView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: gutter + 4),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: gutter),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxView.trailingAnchor, constant: rowGap),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: priorityBadgeView.leadingAnchor,
                constant: -titleBadgeGap
            ),

            priorityBadgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: gutter),
            priorityBadgeView.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: titleBadgeGap
            ),
            priorityBadgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -gutter),

            dueDateRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: stackGap),
            dueDateRow.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dueDateRow.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -gutter),

            dueDateIconView.leadingAnchor.constraint(equalTo: dueDateRow.leadingAnchor),
            dueDateIconView.centerYAnchor.constraint(equalTo: dueDateRow.centerYAnchor),
            dueDateIconView.widthAnchor.constraint(equalToConstant: iconSize),
            dueDateIconView.heightAnchor.constraint(equalToConstant: iconSize),
            dueDateIconView.topAnchor.constraint(equalTo: dueDateRow.topAnchor),
            dueDateIconView.bottomAnchor.constraint(equalTo: dueDateRow.bottomAnchor),

            dueDateLabel.leadingAnchor.constraint(equalTo: dueDateIconView.trailingAnchor, constant: 4),
            dueDateLabel.trailingAnchor.constraint(equalTo: dueDateRow.trailingAnchor),
            dueDateLabel.centerYAnchor.constraint(equalTo: dueDateRow.centerYAnchor)
        ])

        cardBottomToDueDateConstraint = dueDateRow.bottomAnchor.constraint(
            equalTo: cardView.bottomAnchor,
            constant: -gutter
        )
        cardBottomToTitleConstraint = titleLabel.bottomAnchor.constraint(
            equalTo: cardView.bottomAnchor,
            constant: -gutter
        )
        cardBottomToDueDateConstraint.isActive = true
    }

    private func applyCardShadow() {
        cardView.layer.shadowColor = UIColor.appTaskCardShadow.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = AppConstants.TaskList.Layout.cardShadowRadius
        cardView.layer.shadowOffset = CGSize(
            width: 0,
            height: AppConstants.TaskList.Layout.cardShadowYOffset
        )
        cardView.layer.masksToBounds = false
    }
}
