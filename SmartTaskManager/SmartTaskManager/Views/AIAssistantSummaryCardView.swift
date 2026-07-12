//
//  AIAssistantSummaryCardView.swift
//  SmartTaskManager
//

import UIKit

final class AIAssistantSummaryCardView: UIView {

    private let gradientOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.alpha = 0.03
        return view
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = AppConstants.AIAssistant.Layout.stackGap
        return stackView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = AppConstants.AIAssistant.Layout.summaryHeadlineSpacing
        return stackView
    }()

    private let chipContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = AppConstants.TaskList.Layout.filterChipHeight / 2
        return view
    }()

    private let chipStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = AppConstants.AIAssistant.Layout.summaryChipSpacing
        return stackView
    }()

    private let chipIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageView.image = UIImage(systemName: "sparkles", withConfiguration: configuration)
        return imageView
    }()

    private let chipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.footnote()
        label.textColor = .appPrimary
        label.text = AppConstants.AIAssistant.smartSummary
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let boltContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appPrimary
        view.layer.cornerRadius = AppConstants.CreateTask.Layout.aiButtonCornerRadius
        return view
    }()

    private let boltIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appOnPrimary
        let configuration = UIImage.SymbolConfiguration(
            pointSize: AppConstants.AIAssistant.Layout.summaryBoltIconSize,
            weight: .medium
        )
        imageView.image = UIImage(systemName: "bolt.fill", withConfiguration: configuration)
        return imageView
    }()

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
        gradientOverlayView.layer.cornerRadius = AppConstants.AIAssistant.Layout.summaryCardCornerRadius
        gradientOverlayView.layer.masksToBounds = true
    }

    func configure(headline: String, message: String) {
        headlineLabel.text = headline
        messageLabel.text = message
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSurfaceLowest
        layer.cornerRadius = AppConstants.AIAssistant.Layout.summaryCardCornerRadius
        layer.borderWidth = AppConstants.AIAssistant.Layout.cardBorderWidth
        layer.borderColor = UIColor.appPrimaryBorderMuted.cgColor
        applyCardShadow()

        configureGradient()

        addSubview(gradientOverlayView)
        addSubview(contentStackView)

        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(boltContainerView)

        textStackView.addArrangedSubview(chipContainerView)
        textStackView.addArrangedSubview(headlineLabel)
        textStackView.addArrangedSubview(messageLabel)

        chipContainerView.addSubview(chipStackView)
        chipStackView.addArrangedSubview(chipIconView)
        chipStackView.addArrangedSubview(chipLabel)

        boltContainerView.addSubview(boltIconView)

        let padding = AppConstants.AIAssistant.Layout.summaryCardPadding
        let boltSize = AppConstants.AIAssistant.Layout.summaryBoltContainerSize
        let chipPadding = AppConstants.AIAssistant.Layout.stackGap

        textStackView.setCustomSpacing(AppConstants.AIAssistant.Layout.stackGap, after: chipContainerView)

        NSLayoutConstraint.activate([
            gradientOverlayView.topAnchor.constraint(equalTo: topAnchor),
            gradientOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            chipStackView.topAnchor.constraint(equalTo: chipContainerView.topAnchor, constant: chipPadding),
            chipStackView.leadingAnchor.constraint(equalTo: chipContainerView.leadingAnchor, constant: 12),
            chipStackView.trailingAnchor.constraint(equalTo: chipContainerView.trailingAnchor, constant: -12),
            chipStackView.bottomAnchor.constraint(equalTo: chipContainerView.bottomAnchor, constant: -chipPadding),

            boltContainerView.widthAnchor.constraint(equalToConstant: boltSize),
            boltContainerView.heightAnchor.constraint(equalToConstant: boltSize),

            boltIconView.centerXAnchor.constraint(equalTo: boltContainerView.centerXAnchor),
            boltIconView.centerYAnchor.constraint(equalTo: boltContainerView.centerYAnchor)
        ])
    }

    private func configureGradient() {
        gradientLayer.colors = [
            UIColor.appPrimary.cgColor,
            UIColor.appStitchTertiary.cgColor,
            UIColor.appSecondary.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientOverlayView.layer.addSublayer(gradientLayer)
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
