//
//  TaskListViewController.swift
//  SmartTaskManager
//

import UIKit

final class TaskListViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: TaskListViewModel
    private let makeCreateTaskViewController: () -> CreateTaskViewController
    private let makeEditTaskViewController: (Task) -> CreateTaskViewController

    // MARK: - State

    private var tasks: [Task] = []
    private var tasksDidChangeObserver: NSObjectProtocol?

    // MARK: - UI

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .appPrimary
        return indicator
    }()

    private let emptyStateView = EmptyStateView()

    private let filterView = TaskPriorityFilterView()

    private let filterContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "plus", withConfiguration: configuration), for: .normal)
        button.tintColor = .appPrimary
        return button
    }()

    private let screenHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.largeTitleMobile()
        label.textColor = .appOnSurface
        label.text = AppConstants.TaskList.screenTitle
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.subheadline()
        label.textColor = .appOutline
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFont.button()
        button.setTitle(AppConstants.TaskList.retryButton, for: .normal)
        button.isHidden = true
        return button
    }()

    // MARK: - Initialization

    init(
        viewModel: TaskListViewModel = TaskListViewModel(),
        makeCreateTaskViewController: @escaping () -> CreateTaskViewController = { CreateTaskViewController() },
        makeEditTaskViewController: @escaping (Task) -> CreateTaskViewController = {
            CreateTaskViewController(viewModel: CreateTaskViewModel(taskToEdit: $0))
        }
    ) {
        self.viewModel = viewModel
        self.makeCreateTaskViewController = makeCreateTaskViewController
        self.makeEditTaskViewController = makeEditTaskViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        if let tasksDidChangeObserver {
            NotificationCenter.default.removeObserver(tasksDidChangeObserver)
        }
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(topBarView)
        topBarView.addSubview(addButton)
        view.addSubview(screenHeaderView)
        screenHeaderView.addSubview(screenTitleLabel)
        view.addSubview(filterContainerView)
        filterContainerView.addSubview(filterView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)

        filterView.onFilterSelected = { [weak self] filter in
            self?.viewModel.setPriorityFilter(filter)
        }
    }

    private func setupConstraints() {
        let margin = AppConstants.TaskList.Layout.marginMain
        let layout = AppConstants.TaskList.Layout.self
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: layout.topBarHeight),

            addButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -margin),
            addButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),

            screenHeaderView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: layout.headerTopSpacing),
            screenHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            screenHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            screenTitleLabel.topAnchor.constraint(equalTo: screenHeaderView.topAnchor),
            screenTitleLabel.leadingAnchor.constraint(equalTo: screenHeaderView.leadingAnchor),
            screenTitleLabel.trailingAnchor.constraint(equalTo: screenHeaderView.trailingAnchor),
            screenTitleLabel.bottomAnchor.constraint(equalTo: screenHeaderView.bottomAnchor, constant: -layout.headerBottomSpacing),

            filterContainerView.topAnchor.constraint(equalTo: screenHeaderView.bottomAnchor, constant: layout.stackGap),
            filterContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            filterContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            filterContainerView.heightAnchor.constraint(equalToConstant: layout.filterSectionHeight),

            filterView.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.topAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: AppConstants.TaskList.Layout.stackGap * 2),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        retryButton.setTitleColor(.appPrimary, for: .normal)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
        }
        viewModel.onToggleError = { [weak self] message in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: message)
        }

        tasksDidChangeObserver = NotificationCenter.default.addObserver(
            forName: TaskNotifications.didChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModel.refreshTasks()
        }
    }

    // MARK: - State

    private func applyState(_ state: TaskListViewState) {
        switch state {
        case .loading:
            showLoading()
        case .loaded(let tasks):
            self.tasks = tasks
            showTasks()
        case .empty:
            tasks = []
            showEmpty()
        case .filteredEmpty:
            tasks = []
            showFilteredEmpty()
        case .error(let message):
            tasks = []
            showError(message)
        }

        if case .loading = state {
            return
        }

        if case .error = state {
            filterContainerView.isHidden = true
            return
        }

        filterContainerView.isHidden = false
        filterView.setSelectedFilter(viewModel.selectedPriorityFilter)
    }

    private func showLoading() {
        tableView.isHidden = true
        emptyStateView.isHidden = true
        filterContainerView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        activityIndicator.startAnimating()
    }

    private func showTasks() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
        emptyStateView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        emptyStateView.resetToDefault()
        tableView.reloadData()
    }

    private func showEmpty() {
        activityIndicator.stopAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
        emptyStateView.resetToDefault()
    }

    private func showFilteredEmpty() {
        activityIndicator.stopAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
        emptyStateView.configure(
            title: AppConstants.TaskList.filteredEmptyTitle,
            message: AppConstants.TaskList.filteredEmptyMessage
        )
    }

    private func showError(_ message: String) {
        activityIndicator.stopAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
        errorLabel.isHidden = false
        retryButton.isHidden = false
        errorLabel.text = message
    }

    // MARK: - Actions

    @objc private func addTaskTapped() {
        presentTaskForm(makeCreateTaskViewController()) { [weak self] in
            guard let self else { return }
            ToastBannerView.show(in: self.view, message: AppConstants.TaskList.createSuccess)
            self.viewModel.loadTasks()
        }
    }

    @objc private func retryTapped() {
        viewModel.loadTasks()
    }

    private func toggleCompletion(for task: Task) {
        viewModel.toggleCompletion(for: task.id)
    }

    private func presentTaskForm(
        _ viewController: CreateTaskViewController,
        onSuccess: @escaping () -> Void
    ) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.prefersLargeTitles = false
        AppNavigationBarAppearance.apply(to: navigationController.navigationBar)

        viewController.onTaskCreated = { [weak navigationController] _ in
            navigationController?.dismiss(animated: true, completion: onSuccess)
        }
        viewController.onTaskUpdated = { [weak navigationController] _ in
            navigationController?.dismiss(animated: true, completion: onSuccess)
        }

        present(navigationController, animated: true)
    }

    private func presentEditTask(_ task: Task) {
        let editTaskViewController = makeEditTaskViewController(task)
        let navigationController = UINavigationController(rootViewController: editTaskViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.prefersLargeTitles = false
        AppNavigationBarAppearance.apply(to: navigationController.navigationBar)

        editTaskViewController.onTaskUpdated = { [weak navigationController, weak self] _ in
            navigationController?.dismiss(animated: true) {
                guard let self else { return }
                ToastBannerView.show(in: self.view, message: AppConstants.TaskList.updateSuccess)
                self.viewModel.loadTasks()
            }
        }
        editTaskViewController.onTaskDeleted = { [weak navigationController, weak self] in
            navigationController?.dismiss(animated: true) {
                guard let self else { return }
                ToastBannerView.show(in: self.view, message: AppConstants.TaskList.deleteSuccess)
                self.viewModel.loadTasks()
            }
        }

        present(navigationController, animated: true)
    }

    private func deleteTask(_ task: Task) {
        viewModel.deleteTask(task) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                ToastBannerView.show(in: self.view, message: AppConstants.TaskList.deleteSuccess)
            case .failure(let error):
                ToastBannerView.show(in: self.view, message: error.message)
            }
        }
    }

    private func presentDeleteConfirmation(
        for task: Task,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: AppConstants.TaskList.deleteConfirmTitle,
            message: AppConstants.TaskList.deleteConfirmMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppConstants.CreateTask.cancel, style: .cancel) { _ in
            onCancel?()
        })
        alert.addAction(UIAlertAction(title: AppConstants.TaskList.deleteAction, style: .destructive) { _ in
            onConfirm()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskListCell.reuseIdentifier,
            for: indexPath
        ) as? TaskListCell else {
            return UITableViewCell()
        }

        let task = tasks[indexPath.row]
        cell.configure(with: task)
        cell.onCheckboxTapped = { [weak self] in
            self?.toggleCompletion(for: task)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]

        guard task.isEditable else {
            ToastBannerView.show(in: view, message: AppConstants.TaskList.taskNotEditable)
            return
        }

        presentEditTask(task)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: AppConstants.TaskList.deleteAction
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            guard task.isDeletable else {
                ToastBannerView.show(in: self.view, message: AppConstants.TaskList.taskNotDeletable)
                completion(false)
                return
            }

            self.presentDeleteConfirmation(
                for: task,
                onConfirm: { [weak self] in
                    self?.deleteTask(task)
                    completion(true)
                },
                onCancel: {
                    completion(false)
                }
            )
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
