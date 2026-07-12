//
//  CreateTaskViewController.swift
//  SmartTaskManager
//

import UIKit

final class CreateTaskViewController: UIViewController {

    // MARK: - Callbacks

    var onTaskCreated: ((Task) -> Void)?
    var onTaskUpdated: ((Task) -> Void)?
    var onTaskDeleted: (() -> Void)?

    // MARK: - Dependencies

    private let viewModel: CreateTaskViewModel

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let detailsCardView = UIView()
    private let optionsCardView = UIView()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = AppFont.headline()
        textField.textColor = .appOnSurface
        textField.placeholder = AppConstants.CreateTask.titlePlaceholder
        textField.borderStyle = .none
        textField.returnKeyType = .next
        return textField
    }()

    private let titleSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = AppFont.input()
        textView.textColor = .appOnSurface
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.input()
        label.textColor = .appOutline
        label.text = AppConstants.CreateTask.descriptionPlaceholder
        return label
    }()

    private let titleErrorLabel = CreateTaskViewController.makeErrorLabel()
    private let dueDateErrorLabel = CreateTaskViewController.makeErrorLabel()
    private let priorityErrorLabel = CreateTaskViewController.makeErrorLabel()
    private let submitErrorLabel = CreateTaskViewController.makeErrorLabel()

    private lazy var dateRowView = CreateTaskOptionRowView(
        iconName: "calendar",
        title: AppConstants.CreateTask.dateLabel,
        iconTintColor: .appStitchError
    )

    private lazy var priorityRowView = CreateTaskOptionRowView(
        iconName: "exclamationmark",
        title: AppConstants.CreateTask.priorityLabel,
        iconTintColor: .appStitchTertiary
    )

    private let aiAssistantView = CreateTaskAIAssistantView()

    private let optionsSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.button()
        button.setTitle(AppConstants.CreateTask.saveButton, for: .normal)
        button.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        button.isEnabled = false
        return button
    }()

    private let saveActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .appOnPrimary
        return indicator
    }()

    private var activeDatePicker: UIDatePicker?

    // MARK: - Initialization

    init(viewModel: CreateTaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(viewModel: CreateTaskViewModel())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureUI()
        bindViewModel()
        applyState(viewModel.state)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationBar = navigationController?.navigationBar {
            AppNavigationBarAppearance.apply(to: navigationBar)
        }
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [detailsCardView, optionsCardView, aiAssistantView, saveButton].forEach { contentView.addSubview($0) }

        detailsCardView.addSubview(titleTextField)
        detailsCardView.addSubview(titleSeparatorView)
        detailsCardView.addSubview(descriptionTextView)
        detailsCardView.addSubview(descriptionPlaceholderLabel)

        optionsCardView.addSubview(dateRowView)
        optionsCardView.addSubview(optionsSeparatorView)
        optionsCardView.addSubview(priorityRowView)

        [
            titleErrorLabel,
            dueDateErrorLabel,
            priorityErrorLabel,
            submitErrorLabel
        ].forEach { contentView.addSubview($0) }

        saveButton.addSubview(saveActivityIndicator)

        titleTextField.delegate = self
        descriptionTextView.delegate = self

        dateRowView.addTarget(self, action: #selector(dateRowTapped), for: .touchUpInside)
        priorityRowView.addTarget(self, action: #selector(priorityRowTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        aiAssistantView.onSuggestPriorityTapped = { [weak self] in
            self?.view.endEditing(true)
            self?.viewModel.suggestPriority()
        }

        styleCard(detailsCardView)
        styleCard(optionsCardView)
    }

    private func setupConstraints() {
        let margin = AppConstants.TaskList.Layout.marginMain
        let gutter = AppConstants.TaskList.Layout.gutterCard
        let stackGap = AppConstants.TaskList.Layout.stackGap
        let layoutGuide = view.safeAreaLayoutGuide
        let contentLayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),

            detailsCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            detailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            detailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            titleTextField.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: gutter),
            titleTextField.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: gutter),
            titleTextField.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -gutter),

            titleSeparatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: gutter),
            titleSeparatorView.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: gutter),
            titleSeparatorView.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -gutter),
            titleSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            descriptionTextView.topAnchor.constraint(equalTo: titleSeparatorView.bottomAnchor, constant: gutter),
            descriptionTextView.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: gutter),
            descriptionTextView.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -gutter),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            descriptionTextView.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: -gutter),

            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),

            titleErrorLabel.topAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: 4),
            titleErrorLabel.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor),
            titleErrorLabel.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor),

            optionsCardView.topAnchor.constraint(equalTo: titleErrorLabel.bottomAnchor, constant: stackGap * 2),
            optionsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            optionsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            dateRowView.topAnchor.constraint(equalTo: optionsCardView.topAnchor),
            dateRowView.leadingAnchor.constraint(equalTo: optionsCardView.leadingAnchor, constant: gutter),
            dateRowView.trailingAnchor.constraint(equalTo: optionsCardView.trailingAnchor, constant: -gutter),

            optionsSeparatorView.topAnchor.constraint(equalTo: dateRowView.bottomAnchor),
            optionsSeparatorView.leadingAnchor.constraint(equalTo: optionsCardView.leadingAnchor, constant: gutter),
            optionsSeparatorView.trailingAnchor.constraint(equalTo: optionsCardView.trailingAnchor, constant: -gutter),
            optionsSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            priorityRowView.topAnchor.constraint(equalTo: optionsSeparatorView.bottomAnchor),
            priorityRowView.leadingAnchor.constraint(equalTo: optionsCardView.leadingAnchor, constant: gutter),
            priorityRowView.trailingAnchor.constraint(equalTo: optionsCardView.trailingAnchor, constant: -gutter),
            priorityRowView.bottomAnchor.constraint(equalTo: optionsCardView.bottomAnchor),

            dueDateErrorLabel.topAnchor.constraint(equalTo: optionsCardView.bottomAnchor, constant: 4),
            dueDateErrorLabel.leadingAnchor.constraint(equalTo: optionsCardView.leadingAnchor),
            dueDateErrorLabel.trailingAnchor.constraint(equalTo: optionsCardView.trailingAnchor),

            priorityErrorLabel.topAnchor.constraint(equalTo: dueDateErrorLabel.bottomAnchor, constant: 2),
            priorityErrorLabel.leadingAnchor.constraint(equalTo: optionsCardView.leadingAnchor),
            priorityErrorLabel.trailingAnchor.constraint(equalTo: optionsCardView.trailingAnchor),

            aiAssistantView.topAnchor.constraint(
                equalTo: priorityErrorLabel.bottomAnchor,
                constant: AppConstants.CreateTask.Layout.aiSectionTopSpacing
            ),
            aiAssistantView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            aiAssistantView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            submitErrorLabel.topAnchor.constraint(equalTo: aiAssistantView.bottomAnchor, constant: stackGap),
            submitErrorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            submitErrorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),

            saveButton.topAnchor.constraint(equalTo: submitErrorLabel.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            saveButton.heightAnchor.constraint(equalToConstant: AppConstants.TaskList.Layout.saveButtonHeight),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),

            saveActivityIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            saveActivityIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        title = viewModel.screenTitle

        navigationItem.rightBarButtonItem = AppNavigationBarAppearance.primaryBarButton(
            systemName: "xmark",
            target: self,
            action: #selector(closeTapped)
        )

        if viewModel.isEditing {
            let deleteItem = UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .plain,
                target: self,
                action: #selector(deleteTapped)
            )
            deleteItem.tintColor = .appError
            navigationItem.leftBarButtonItem = deleteItem
        }

        titleSeparatorView.backgroundColor = .appOutlineVariantMuted
        optionsSeparatorView.backgroundColor = .appOutlineVariantMuted

        saveButton.backgroundColor = .appPrimary
        saveButton.setTitleColor(.appOnPrimary, for: .normal)
        saveButton.setTitleColor(.appOnPrimary.withAlphaComponent(0.6), for: .disabled)
        saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)

        configurePlaceholder(for: titleTextField)

        updateDateRow(date: viewModel.state.dueDate)
        priorityRowView.setPriority(viewModel.state.priority)
        descriptionPlaceholderLabel.isHidden = !viewModel.state.description.isEmpty
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
        }

        viewModel.onCreateSuccess = { [weak self] task in
            self?.onTaskCreated?(task)
        }

        viewModel.onUpdateSuccess = { [weak self] task in
            self?.onTaskUpdated?(task)
        }

        viewModel.onDeleteSuccess = { [weak self] in
            self?.onTaskDeleted?()
        }

        viewModel.onAISuccess = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }

        viewModel.onAIError = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }
    }

    // MARK: - State

    private func applyState(_ state: CreateTaskViewState) {
        if titleTextField.text != state.title {
            titleTextField.text = state.title
        }

        if descriptionTextView.text != state.description {
            descriptionTextView.text = state.description
        }
        descriptionPlaceholderLabel.isHidden = !state.description.isEmpty

        updateDateRow(date: state.dueDate)
        priorityRowView.setPriority(state.priority)

        titleErrorLabel.text = state.titleError
        titleErrorLabel.isHidden = state.titleError == nil

        dueDateErrorLabel.text = state.dueDateError
        dueDateErrorLabel.isHidden = state.dueDateError == nil

        priorityErrorLabel.text = state.priorityError
        priorityErrorLabel.isHidden = state.priorityError == nil

        submitErrorLabel.text = state.submitError
        submitErrorLabel.isHidden = state.submitError == nil

        aiAssistantView.setLoading(state.isSuggestingPriority)
        aiAssistantView.setSuggestPriorityEnabled(state.isSuggestPriorityEnabled)

        saveButton.isEnabled = state.isSaveEnabled

        if state.isLoading {
            saveActivityIndicator.startAnimating()
            saveButton.setTitle(nil, for: .normal)
        } else {
            saveActivityIndicator.stopAnimating()
            saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        presentDeleteConfirmation { [weak self] in
            self?.viewModel.deleteTask()
        }
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        viewModel.saveTask()
    }

    @objc private func dateRowTapped() {
        view.endEditing(true)
        presentDatePicker()
    }

    @objc private func priorityRowTapped() {
        view.endEditing(true)
        presentPriorityPicker()
    }

    // MARK: - Pickers

    private func presentDatePicker() {
        let pickerViewController = UIViewController()
        pickerViewController.view.backgroundColor = .appSurfaceLowest

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle(AppConstants.CreateTask.clearDate, for: .normal)
        clearButton.titleLabel?.font = AppFont.body()
        clearButton.setTitleColor(.appPrimary, for: .normal)
        clearButton.addTarget(self, action: #selector(clearDateSelection), for: .touchUpInside)

        let doneButton = UIButton(type: .system)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(AppConstants.CreateTask.done, for: .normal)
        doneButton.titleLabel?.font = AppFont.button()
        doneButton.setTitleColor(.appOnPrimary, for: .normal)
        doneButton.backgroundColor = .appPrimary
        doneButton.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        doneButton.contentEdgeInsets = UIEdgeInsets(
            top: AppConstants.CreateTask.Layout.pickerDoneButtonVerticalPadding,
            left: AppConstants.CreateTask.Layout.pickerDoneButtonHorizontalPadding,
            bottom: AppConstants.CreateTask.Layout.pickerDoneButtonVerticalPadding,
            right: AppConstants.CreateTask.Layout.pickerDoneButtonHorizontalPadding
        )
        doneButton.addTarget(self, action: #selector(confirmDateSelection), for: .touchUpInside)

        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        if let dueDate = viewModel.state.dueDate {
            datePicker.date = dueDate
            let today = Calendar.current.startOfDay(for: Date())
            if dueDate < today {
                datePicker.minimumDate = nil
            } else {
                datePicker.minimumDate = today
            }
        } else {
            datePicker.minimumDate = Calendar.current.startOfDay(for: Date())
        }
        activeDatePicker = datePicker

        headerView.addSubview(clearButton)
        headerView.addSubview(doneButton)
        pickerViewController.view.addSubview(headerView)
        pickerViewController.view.addSubview(datePicker)

        let margin = AppConstants.TaskList.Layout.marginMain
        let layout = AppConstants.CreateTask.Layout.self

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: pickerViewController.view.safeAreaLayoutGuide.topAnchor,
                constant: layout.pickerHeaderTopPadding
            ),
            headerView.leadingAnchor.constraint(equalTo: pickerViewController.view.leadingAnchor, constant: margin),
            headerView.trailingAnchor.constraint(equalTo: pickerViewController.view.trailingAnchor, constant: -margin),
            headerView.heightAnchor.constraint(equalToConstant: AppConstants.TaskList.Layout.optionRowHeight),

            clearButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            clearButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            datePicker.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: layout.pickerHeaderBottomPadding),
            datePicker.leadingAnchor.constraint(equalTo: pickerViewController.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: pickerViewController.view.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: pickerViewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        pickerViewController.modalPresentationStyle = .pageSheet
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        present(pickerViewController, animated: true)
    }

    private func presentPriorityPicker() {
        let alert = UIAlertController(title: AppConstants.CreateTask.priorityLabel, message: nil, preferredStyle: .actionSheet)

        TaskPriority.allCases.forEach { priority in
            alert.addAction(UIAlertAction(title: priority.displayTitle, style: .default) { [weak self] _ in
                self?.viewModel.updatePriority(priority)
            })
        }

        alert.addAction(UIAlertAction(title: AppConstants.CreateTask.clearPriority, style: .destructive) { [weak self] _ in
            self?.viewModel.updatePriority(nil)
        })

        alert.addAction(UIAlertAction(title: AppConstants.CreateTask.cancel, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = priorityRowView
            popover.sourceRect = priorityRowView.bounds
        }

        present(alert, animated: true)
    }

    @objc private func confirmDateSelection() {
        if let picker = activeDatePicker {
            viewModel.updateDueDate(picker.date)
        }
        activeDatePicker = nil
        dismiss(animated: true)
    }

    @objc private func clearDateSelection() {
        viewModel.updateDueDate(nil)
        activeDatePicker = nil
        dismiss(animated: true)
    }

    // MARK: - Helpers

    private func presentDeleteConfirmation(handler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: AppConstants.TaskList.deleteConfirmTitle,
            message: AppConstants.TaskList.deleteConfirmMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppConstants.CreateTask.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppConstants.TaskList.deleteAction, style: .destructive) { _ in
            handler()
        })
        present(alert, animated: true)
    }

    private func updateDateRow(date: Date?) {
        let display = TaskDueDatePresenter.formDisplay(for: date)
        dateRowView.setValueText(display.text, isPlaceholder: display.isPlaceholder)
    }

    private func styleCard(_ cardView: UIView) {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .appSurfaceLowest
        cardView.layer.cornerRadius = AppConstants.TaskList.Layout.cardCornerRadius
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.appTaskCardBorder.cgColor
        cardView.layer.shadowColor = UIColor.appTaskCardShadow.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = AppConstants.TaskList.Layout.cardShadowRadius
        cardView.layer.shadowOffset = CGSize(
            width: 0,
            height: AppConstants.TaskList.Layout.cardShadowYOffset
        )
        cardView.layer.masksToBounds = false
    }

    private func configurePlaceholder(for textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(
            string: AppConstants.CreateTask.titlePlaceholder,
            attributes: [.foregroundColor: UIColor.appOutline]
        )
    }

    private static func makeErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.caption()
        label.textColor = .appError
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }
}

// MARK: - UITextFieldDelegate

extension CreateTaskViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.updateTitle(textField.text ?? "")
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        viewModel.updateTitle(updatedText)
        return false
    }
}

// MARK: - UITextViewDelegate

extension CreateTaskViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateDescription(textView.text)
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}
