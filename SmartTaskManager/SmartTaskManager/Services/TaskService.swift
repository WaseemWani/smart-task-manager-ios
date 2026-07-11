//
//  TaskService.swift
//  SmartTaskManager
//

import Foundation

// MARK: - TaskServicing

protocol TaskServicing {
    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void)
    func createTask(
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    )
    func updateTask(
        task: Task,
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    )
}

// MARK: - TaskService

final class TaskService: TaskServicing {

    private let networkManager: NetworkManaging
    private let sessionManager: SessionManaging
    private let encoder: JSONEncoder

    init(
        networkManager: NetworkManaging = NetworkManager(),
        sessionManager: SessionManaging = SessionManager(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.encoder = encoder
    }

    func fetchTasks(completion: @escaping (Result<[Task], TaskError>) -> Void) {
        networkManager.request(
            endpoint: .tasks,
            responseType: [RemoteTask].self
        ) { result in
            switch result {
            case .success(let remoteTasks):
                let tasks = remoteTasks.compactMap { $0.toTask() }
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(Self.mapNetworkError(error, fallback: .loadFailed)))
            }
        }
    }

    func createTask(
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    ) {
        guard let userId = sessionManager.currentSession?.user.id else {
            completion(.failure(.notLoggedIn))
            return
        }

        let request = CreateTaskRequest(userId: userId, input: input)

        guard let body = try? encoder.encode(request) else {
            completion(.failure(.createFailed))
            return
        }

        networkManager.request(
            endpoint: .createTask(body: body),
            responseType: RemoteTask.self
        ) { result in
            switch result {
            case .success(let remoteTask):
                guard let task = remoteTask.toTask() else {
                    completion(.failure(.createFailed))
                    return
                }
                completion(.success(task))
            case .failure(let error):
                completion(.failure(Self.mapNetworkError(error, fallback: .createFailed)))
            }
        }
    }

    func updateTask(
        task: Task,
        input: CreateTaskInput,
        completion: @escaping (Result<Task, TaskError>) -> Void
    ) {
        guard let serverID = task.serverID else {
            completion(.failure(.taskNotEditable))
            return
        }

        guard let userId = sessionManager.currentSession?.user.id else {
            completion(.failure(.notLoggedIn))
            return
        }

        let request = UpdateTaskRequest(userId: userId, task: task, input: input)

        guard let body = try? encoder.encode(request) else {
            completion(.failure(.updateFailed))
            return
        }

        networkManager.request(
            endpoint: .updateTask(id: serverID, body: body),
            responseType: RemoteTask.self
        ) { result in
            switch result {
            case .success(let remoteTask):
                guard let updatedTask = remoteTask.toTask() else {
                    completion(.failure(.updateFailed))
                    return
                }
                completion(.success(updatedTask))
            case .failure(let error):
                completion(.failure(Self.mapNetworkError(error, fallback: .updateFailed)))
            }
        }
    }

    // MARK: - Private

    private static func mapNetworkError(_ error: NetworkError, fallback: TaskError) -> TaskError {
        switch error {
        case .timedOut, .networkUnavailable, .httpError:
            return fallback
        default:
            return fallback
        }
    }
}
