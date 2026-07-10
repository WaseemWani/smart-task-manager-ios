//
//  OrDividerView.swift
//  SmartTaskManager
//

import UIKit

final class OrDividerView: UIView {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.divider()
        label.textAlignment = .center
        return label
    }()

    private let leadingLine = OrDividerView.makeLine()
    private let trailingLine = OrDividerView.makeLine()

    // MARK: - Initialization

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title.uppercased()
        setupViews()
        setupConstraints()
        applyTheme()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Theme

    func applyTheme() {
        titleLabel.textColor = .appOutline
        leadingLine.backgroundColor = .appOutlineVariantMuted
        trailingLine.backgroundColor = .appOutlineVariantMuted
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(leadingLine)
        addSubview(titleLabel)
        addSubview(trailingLine)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 20),

            leadingLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingLine.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -12),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            trailingLine.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            trailingLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingLine.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private static func makeLine() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}
