//
//  TaskCheckboxView.swift
//  SmartTaskManager
//

import UIKit

final class TaskCheckboxView: UIView {

    var onTap: (() -> Void)?

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .appOnPrimary
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        setupViews()
        applyTheme(isCompleted: false)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }

    func configure(isCompleted: Bool) {
        applyTheme(isCompleted: isCompleted)
    }

    @objc private func handleTap() {
        onTap?()
    }

    private func setupViews() {
        addSubview(checkmarkImageView)

        let size = AppConstants.TaskList.Layout.checkboxSize
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),

            checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 12),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    private func applyTheme(isCompleted: Bool) {
        layer.borderWidth = AppConstants.TaskList.Layout.checkboxBorderWidth
        checkmarkImageView.isHidden = !isCompleted

        if isCompleted {
            backgroundColor = .appPrimary
            layer.borderColor = UIColor.appPrimary.cgColor
        } else {
            backgroundColor = .clear
            layer.borderColor = UIColor.appOutlineVariant.cgColor
        }
    }
}
