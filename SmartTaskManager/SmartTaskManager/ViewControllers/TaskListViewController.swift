//
//  TaskListViewController.swift
//  SmartTaskManager
//

import UIKit

final class TaskListViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: TaskListViewModel

    // MARK: - State

    private var tasks: [Task] = []

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

    init(viewModel: TaskListViewModel = TaskListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        tableView.dataSource = self
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        let margin = AppConstants.TaskList.Layout.marginMain
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
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
        title = AppConstants.TaskList.screenTitle
        retryButton.setTitleColor(.appPrimary, for: .normal)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.applyState(state)
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
        case .error(let message):
            tasks = []
            showError(message)
        }
    }

    private func showLoading() {
        tableView.isHidden = true
        emptyStateView.isHidden = true
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
        tableView.reloadData()
    }

    private func showEmpty() {
        activityIndicator.stopAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
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

    @objc private func retryTapped() {
        viewModel.loadTasks()
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

        cell.configure(with: tasks[indexPath.row])
        return cell
    }
}
