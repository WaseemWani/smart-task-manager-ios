//
//  TaskPriorityFilterView.swift
//  SmartTaskManager
//

import UIKit

final class TaskPriorityFilterView: UIView {

    // MARK: - Callbacks

    var onFilterSelected: ((TaskPriorityFilter) -> Void)?

    // MARK: - State

    private var selectedFilter: TaskPriorityFilter = .all
    private var chipButtons: [TaskPriorityFilter: UIButton] = [:]

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private let chipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = AppConstants.TaskList.Layout.stackGap
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        setupViews()
        setupConstraints()
        configureChips()
        setSelectedFilter(.all)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Configuration

    func setSelectedFilter(_ filter: TaskPriorityFilter) {
        selectedFilter = filter

        chipButtons.forEach { priorityFilter, button in
            applyStyle(to: button, isSelected: priorityFilter == filter)
        }
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(chipStackView)
    }

    private func setupConstraints() {
        let layout = AppConstants.TaskList.Layout.self

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            chipStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            chipStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            chipStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            chipStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -layout.filterChipBottomPadding
            ),
            chipStackView.heightAnchor.constraint(equalToConstant: layout.filterChipHeight)
        ])
    }

    private func configureChips() {
        TaskPriorityFilter.allCases.forEach { filter in
            let button = makeChipButton(for: filter)
            chipButtons[filter] = button
            chipStackView.addArrangedSubview(button)
        }
    }

    private func makeChipButton(for filter: TaskPriorityFilter) -> UIButton {
        let layout = AppConstants.TaskList.Layout.self
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(filter.title, for: .normal)
        button.titleLabel?.font = AppFont.filterChip()
        button.contentEdgeInsets = UIEdgeInsets(
            top: layout.filterChipVerticalPadding,
            left: layout.filterChipHorizontalPadding,
            bottom: layout.filterChipVerticalPadding,
            right: layout.filterChipHorizontalPadding
        )
        button.layer.cornerRadius = layout.filterChipHeight / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = filter.title

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: layout.filterChipHeight)
        ])

        return button
    }

    private func applyStyle(to button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .appPrimary
            button.setTitleColor(.appOnPrimary, for: .normal)
        } else {
            button.backgroundColor = .appSurfaceContainer
            button.setTitleColor(.appOnSurfaceVariant, for: .normal)
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        guard let filter = chipButtons.first(where: { $0.value === sender })?.key else {
            return
        }

        setSelectedFilter(filter)
        onFilterSelected?(filter)
    }
}
