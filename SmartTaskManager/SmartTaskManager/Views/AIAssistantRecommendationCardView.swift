//
//  AIAssistantRecommendationCardView.swift
//  SmartTaskManager
//

import UIKit

final class AIAssistantRecommendationCardView: UIView {

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let priorityIconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = AppConstants.AIAssistant.Layout.iconContainerCornerRadius
        return view
    }()

    private let priorityIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let recommendationBadgeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = AppConstants.TaskList.Layout.priorityBadgeCornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    private let recommendationBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.footnote()
        label.textAlignment = .center
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = AppConstants.AIAssistant.Layout.recommendationContentSpacing
        return stackView
    }()

    private let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.numberOfLines = 0
        return label
    }()

    private let priorityLineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.footnote()
        label.textColor = .appOutline
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

    func configure(insight: WorkloadInsight, taskTitle: String) {
        taskTitleLabel.text = taskTitle
        priorityLineLabel.text = "\(AppConstants.AIAssistant.recommendedPriorityPrefix) \(insight.recommendedPriority.displayTitle) Priority"
        reasonLabel.attributedText = NSAttributedString(
            string: insight.recommendationReason,
            attributes: [
                .font: italicFootnoteFont(),
                .foregroundColor: UIColor.appOutline
            ]
        )
        configurePriorityAppearance(priority: insight.recommendedPriority, label: insight.recommendationLabel)
    }

    private func italicFootnoteFont() -> UIFont {
        let baseFont = AppFont.footnote()
        if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: baseFont.pointSize)
        }
        return baseFont
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSurfaceLowest
        layer.cornerRadius = AppConstants.AIAssistant.Layout.glassCardCornerRadius
        layer.borderWidth = AppConstants.AIAssistant.Layout.cardBorderWidth
        layer.borderColor = UIColor.appTaskCardBorder.cgColor
        applyCardShadow()

        addSubview(headerStackView)
        addSubview(contentStackView)

        headerStackView.addArrangedSubview(priorityIconContainerView)
        headerStackView.addArrangedSubview(recommendationBadgeContainerView)

        recommendationBadgeContainerView.addSubview(recommendationBadgeLabel)

        priorityIconContainerView.addSubview(priorityIconView)

        contentStackView.addArrangedSubview(taskTitleLabel)
        contentStackView.addArrangedSubview(priorityLineLabel)
        contentStackView.addArrangedSubview(reasonLabel)

        let padding = AppConstants.AIAssistant.Layout.glassCardPadding
        let iconContainerSize = AppConstants.AIAssistant.Layout.iconContainerSize
        let iconSize = AppConstants.TaskList.Layout.dueDateIconSize
        let badgeHorizontalPadding = AppConstants.TaskList.Layout.priorityBadgeHorizontalPadding
        let badgeVerticalPadding = AppConstants.TaskList.Layout.priorityBadgeVerticalPadding

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AppConstants.AIAssistant.Layout.glassCardMinHeight),

            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            priorityIconContainerView.widthAnchor.constraint(equalToConstant: iconContainerSize),
            priorityIconContainerView.heightAnchor.constraint(equalToConstant: iconContainerSize),

            priorityIconView.centerXAnchor.constraint(equalTo: priorityIconContainerView.centerXAnchor),
            priorityIconView.centerYAnchor.constraint(equalTo: priorityIconContainerView.centerYAnchor),
            priorityIconView.widthAnchor.constraint(equalToConstant: iconSize),
            priorityIconView.heightAnchor.constraint(equalToConstant: iconSize),

            recommendationBadgeLabel.topAnchor.constraint(
                equalTo: recommendationBadgeContainerView.topAnchor,
                constant: badgeVerticalPadding
            ),
            recommendationBadgeLabel.bottomAnchor.constraint(
                equalTo: recommendationBadgeContainerView.bottomAnchor,
                constant: -badgeVerticalPadding
            ),
            recommendationBadgeLabel.leadingAnchor.constraint(
                equalTo: recommendationBadgeContainerView.leadingAnchor,
                constant: badgeHorizontalPadding
            ),
            recommendationBadgeLabel.trailingAnchor.constraint(
                equalTo: recommendationBadgeContainerView.trailingAnchor,
                constant: -badgeHorizontalPadding
            ),

            contentStackView.topAnchor.constraint(
                equalTo: headerStackView.bottomAnchor,
                constant: AppConstants.AIAssistant.Layout.recommendationBadgeSpacing
            ),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }

    private func configurePriorityAppearance(priority: TaskPriority, label: String) {
        let iconConfiguration = UIImage.SymbolConfiguration(
            pointSize: AppConstants.TaskList.Layout.dueDateIconSize,
            weight: .medium
        )

        switch priority {
        case .high:
            priorityIconContainerView.backgroundColor = .appHighPriorityBadgeBackground
            priorityIconView.tintColor = .appHighPriorityBadgeText
            priorityIconView.image = UIImage(systemName: "exclamationmark", withConfiguration: iconConfiguration)
        case .medium:
            priorityIconContainerView.backgroundColor = .appMediumPriorityBadgeBackground
            priorityIconView.tintColor = .appMediumPriorityBadgeText
            priorityIconView.image = UIImage(systemName: "flag.fill", withConfiguration: iconConfiguration)
        case .low:
            priorityIconContainerView.backgroundColor = .appLowPriorityBadgeBackground
            priorityIconView.tintColor = .appLowPriorityBadgeText
            priorityIconView.image = UIImage(systemName: "arrow.down", withConfiguration: iconConfiguration)
        }

        recommendationBadgeLabel.text = label
        recommendationBadgeLabel.textColor = priority.badgeTextColor
        recommendationBadgeContainerView.backgroundColor = priority.badgeBackgroundColor
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
