//
//  NetworkManager.swift
//  SmartTaskManager
//

import Foundation

// MARK: - NetworkManaging

protocol NetworkManaging {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

// MARK: - NetworkManager

final class NetworkManager: NetworkManaging {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let maxRetryCount: Int
    private let retryInterval: TimeInterval

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        maxRetryCount: Int = APIConstants.maxRetryCount,
        retryInterval: TimeInterval = APIConstants.retryInterval
    ) {
        self.session = session
        self.decoder = decoder
        self.maxRetryCount = maxRetryCount
        self.retryInterval = retryInterval
    }

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let urlRequest = makeURLRequest(for: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        performRequest(
            urlRequest: urlRequest,
            endpoint: endpoint,
            responseType: responseType,
            attempt: 0,
            completion: completion
        )
    }

    // MARK: - Private

    private func makeURLRequest(for endpoint: APIEndpoint) -> URLRequest? {
        guard let url = URL(string: APIConstants.baseURL + endpoint.path) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = APIConstants.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = endpoint.body
        return request
    }

    private func performRequest<T: Decodable>(
        urlRequest: URLRequest,
        endpoint: APIEndpoint,
        responseType: T.Type,
        attempt: Int,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self else { return }

            if let error = error as? URLError {
                let networkError = self.mapURLError(error)

                if self.shouldRetry(error: networkError, attempt: attempt) {
                    self.scheduleRetry(
                        urlRequest: urlRequest,
                        endpoint: endpoint,
                        responseType: responseType,
                        attempt: attempt + 1,
                        completion: completion
                    )
                    return
                }

                completion(.failure(networkError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let networkError = NetworkError.httpError(statusCode: httpResponse.statusCode)

                if self.shouldRetry(error: networkError, attempt: attempt) {
                    self.scheduleRetry(
                        urlRequest: urlRequest,
                        endpoint: endpoint,
                        responseType: responseType,
                        attempt: attempt + 1,
                        completion: completion
                    )
                    return
                }

                completion(.failure(networkError))
                return
            }

            guard let data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoded = try self.decoder.decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }

    private func scheduleRetry<T: Decodable>(
        urlRequest: URLRequest,
        endpoint: APIEndpoint,
        responseType: T.Type,
        attempt: Int,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            self?.performRequest(
                urlRequest: urlRequest,
                endpoint: endpoint,
                responseType: responseType,
                attempt: attempt,
                completion: completion
            )
        }
    }

    private func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
        guard attempt < maxRetryCount else { return false }

        switch error {
        case .timedOut, .networkUnavailable:
            return true
        case .httpError(let statusCode):
            return statusCode >= 500
        default:
            return false
        }
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timedOut
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return .networkUnavailable
        case .cancelled:
            return .cancelled
        default:
            return .unknown
        }
    }
}
