//
//  ToastBannerView.swift
//  SmartTaskManager
//

import UIKit

enum ToastBannerView {

    private static let displayDuration: TimeInterval = 2.5

    static func show(in view: UIView, message: String) {
        let banner = makeBanner(message: message)
        view.addSubview(banner)

        let margin = AppConstants.TaskList.Layout.marginMain
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])

        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: 0, y: -12)

        UIView.animate(withDuration: 0.25) {
            banner.alpha = 1
            banner.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            UIView.animate(withDuration: 0.25, animations: {
                banner.alpha = 0
                banner.transform = CGAffineTransform(translationX: 0, y: -12)
            }, completion: { _ in
                banner.removeFromSuperview()
            })
        }
    }

    private static func makeBanner(message: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .appOnSurface
        container.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        container.layer.shadowColor = UIColor.appTaskCardShadow.cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = AppConstants.TaskList.Layout.cardShadowRadius
        container.layer.shadowOffset = CGSize(
            width: 0,
            height: AppConstants.TaskList.Layout.cardShadowYOffset
        )

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOnPrimary
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center

        container.addSubview(label)

        let padding = AppConstants.TaskList.Layout.gutterCard
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding)
        ])

        return container
    }
}
