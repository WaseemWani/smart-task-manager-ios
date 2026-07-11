//
//  APIEndpoints.swift
//  SmartTaskManager
//

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - APIEndpoint

struct APIEndpoint: Equatable {

    let path: String
    let method: HTTPMethod
    let body: Data?

    init(path: String, method: HTTPMethod, body: Data? = nil) {
        self.path = path
        self.method = method
        self.body = body
    }

    static let login = APIEndpoint(path: "/login", method: .get)
    static let users = login
    static let tasks = APIEndpoint(path: "/tasks", method: .get)

    static func task(id: String) -> APIEndpoint {
        APIEndpoint(path: "/tasks/\(id)", method: .get)
    }

    static func createTask(body: Data) -> APIEndpoint {
        APIEndpoint(path: "/tasks", method: .post, body: body)
    }

    static func updateTask(id: String, body: Data) -> APIEndpoint {
        APIEndpoint(path: "/tasks/\(id)", method: .put, body: body)
    }

    static func deleteTask(id: String) -> APIEndpoint {
        APIEndpoint(path: "/tasks/\(id)", method: .delete)
    }
}
