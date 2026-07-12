//
//  ProfileMenuRowView.swift
//  SmartTaskManager
//

import UIKit

final class ProfileMenuRowView: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textColor = .appOnSurface
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .appOutline
        return imageView
    }()

    init(iconName: String, title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = title
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(chevronImageView)

        let iconSize = AppConstants.Profile.Layout.menuIconSize

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AppConstants.Profile.Layout.menuRowHeight),

            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppConstants.Profile.Layout.marginMain),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppConstants.Profile.Layout.marginMain),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
