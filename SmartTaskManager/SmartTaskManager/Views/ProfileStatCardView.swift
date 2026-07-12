//
//  ProfileStatCardView.swift
//  SmartTaskManager
//

import UIKit

final class ProfileStatCardView: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.footnote()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.headline()
        label.textColor = .appOnSurface
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appSurfaceLowest
        layer.cornerRadius = AppConstants.Profile.Layout.statCardCornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.appTaskCardBorder.cgColor
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(iconName: String, iconTintColor: UIColor, title: String, value: String, isGuest: Bool) {
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconTintColor
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.font = isGuest ? AppFont.footnote() : AppFont.headline()
        valueLabel.textColor = isGuest ? .appOutline : .appOnSurface
    }

    private func setupViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        let iconSize = AppConstants.Profile.Layout.statIconSize

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: AppConstants.Profile.Layout.statCardPadding),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: AppConstants.Profile.Layout.stackGap),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppConstants.Profile.Layout.stackGap),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppConstants.Profile.Layout.stackGap),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AppConstants.Profile.Layout.stackGap),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppConstants.Profile.Layout.stackGap),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppConstants.Profile.Layout.stackGap),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppConstants.Profile.Layout.statCardPadding)
        ])
    }
}
