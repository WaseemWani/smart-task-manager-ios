//
//  SubtaskEditViewController.swift
//  SmartTaskManager
//

import UIKit

final class SubtaskEditViewController: UIViewController {

    var onSave: ((String) -> Void)?

    private let initialTitle: String
    private let isNewSubtask: Bool

    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = AppFont.input()
        textView.textColor = .appOnSurface
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .sentences
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textColor = .appOutline
        label.text = AppConstants.CreateTask.subtaskTitlePlaceholder
        label.numberOfLines = 0
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appOutlineVariantMuted
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.button()
        button.setTitle(AppConstants.CreateTask.saveSubtask, for: .normal)
        button.setTitleColor(.appOnPrimary, for: .normal)
        button.backgroundColor = .appPrimary
        button.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        button.contentEdgeInsets = UIEdgeInsets(
            top: AppConstants.CreateTask.Layout.pickerDoneButtonVerticalPadding,
            left: AppConstants.CreateTask.Layout.pickerDoneButtonHorizontalPadding,
            bottom: AppConstants.CreateTask.Layout.pickerDoneButtonVerticalPadding,
            right: AppConstants.CreateTask.Layout.pickerDoneButtonHorizontalPadding
        )
        return button
    }()

    init(title: String, isNewSubtask: Bool) {
        self.initialTitle = title
        self.isNewSubtask = isNewSubtask
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextView.becomeFirstResponder()
    }

    private func setupViews() {
        view.backgroundColor = .appSurfaceLowest

        view.addSubview(titleTextView)
        view.addSubview(placeholderLabel)
        view.addSubview(separatorView)
        view.addSubview(saveButton)

        titleTextView.delegate = self
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: AppConstants.CreateTask.cancel,
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    private func setupConstraints() {
        let margin = AppConstants.TaskList.Layout.marginMain
        let layoutGuide = view.safeAreaLayoutGuide
        let minTextHeight = AppConstants.CreateTask.Layout.subtaskEditMinTextHeight

        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 24),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: minTextHeight),

            placeholderLabel.topAnchor.constraint(equalTo: titleTextView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor),

            separatorView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 16),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            saveButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            saveButton.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor, constant: -margin)
        ])
    }

    private func configureUI() {
        title = isNewSubtask
            ? AppConstants.CreateTask.newSubtaskTitle
            : AppConstants.CreateTask.editSubtaskTitle

        titleTextView.text = initialTitle
        placeholderLabel.isHidden = !initialTitle.isEmpty
        updateSaveButtonState()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let trimmedTitle = titleTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        onSave?(trimmedTitle)
        dismiss(animated: true)
    }

    private func updateSaveButtonState() {
        let trimmedTitle = titleTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        saveButton.isEnabled = !trimmedTitle.isEmpty
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.5
    }
}

extension SubtaskEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateSaveButtonState()
    }
}
