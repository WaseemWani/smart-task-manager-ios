//
//  CreateTaskSubtaskRowView.swift
//  SmartTaskManager
//

import UIKit

final class CreateTaskSubtaskRowView: UIView {

    var onToggle: (() -> Void)?
    var onTitleTap: (() -> Void)?
    var onDelete: (() -> Void)?

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = AppFont.input()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(
            pointSize: AppConstants.CreateTask.Layout.subtaskDeleteIconSize,
            weight: .regular
        )
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .appOutline
        return button
    }()

    private var isCompleted = false
    private var title = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(title: String, isCompleted: Bool) {
        self.title = title
        self.isCompleted = isCompleted
        updateAppearance()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkboxButton)
        addSubview(titleButton)
        addSubview(deleteButton)

        checkboxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        titleButton.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let checkboxSize = AppConstants.CreateTask.Layout.subtaskCheckboxSize

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AppConstants.TaskList.Layout.optionRowHeight),

            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: checkboxSize),
            checkboxButton.heightAnchor.constraint(equalToConstant: checkboxSize),

            titleButton.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            titleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),

            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func updateAppearance() {
        let checkboxSize = AppConstants.CreateTask.Layout.subtaskCheckboxSize
        let symbolName = isCompleted ? "checkmark.circle.fill" : "circle"
        let configuration = UIImage.SymbolConfiguration(pointSize: checkboxSize, weight: .regular)
        checkboxButton.setImage(UIImage(systemName: symbolName, withConfiguration: configuration), for: .normal)
        checkboxButton.tintColor = isCompleted ? .appPrimary : .appOutlineVariant

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayTitle = trimmedTitle.isEmpty
            ? AppConstants.CreateTask.subtaskUntitledPlaceholder
            : trimmedTitle

        var attributes: [NSAttributedString.Key: Any] = [
            .font: AppFont.input()
        ]

        if trimmedTitle.isEmpty {
            attributes[.foregroundColor] = UIColor.appOutline
        } else if isCompleted {
            attributes[.foregroundColor] = UIColor.appOutline
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        } else {
            attributes[.foregroundColor] = UIColor.appOnSurface
        }

        let attributedTitle = NSAttributedString(string: displayTitle, attributes: attributes)
        titleButton.setAttributedTitle(attributedTitle, for: .normal)
    }

    @objc private func toggleTapped() {
        isCompleted.toggle()
        updateAppearance()
        onToggle?()
    }

    @objc private func titleTapped() {
        onTitleTap?()
    }

    @objc private func deleteTapped() {
        onDelete?()
    }
}
