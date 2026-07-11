//
//  RemoteTask.swift
//  SmartTaskManager
//

import Foundation

// MARK: - CreateTaskRequest

struct CreateTaskRequest: Encodable, Equatable {
    let userId: String
    let title: String
    let description: String
    let priority: String
    let dueDate: String?
    let isCompleted: Bool

    init(userId: String, input: CreateTaskInput) {
        self.userId = userId
        self.title = input.title
        self.description = input.description ?? ""
        self.priority = input.priority.apiValue
        self.dueDate = input.dueDate.map { APIDateFormatter.apiDateString(from: $0) }
        self.isCompleted = false
    }
}

// MARK: - RemoteTask

struct RemoteTask: Decodable {
    let id: String
    let userId: String?
    let title: String
    let description: String?
    let priority: String
    let dueDate: String?
    let isCompleted: Bool
    let createdAt: String?
    let updatedAt: String?

    init(
        id: String,
        userId: String?,
        title: String,
        description: String?,
        priority: String,
        dueDate: String?,
        isCompleted: Bool,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case description
        case priority
        case dueDate
        case isCompleted
        case createdAt
        case updatedAt
        case updateAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        priority = try container.decode(String.self, forKey: .priority)
        dueDate = try container.decodeIfPresent(String.self, forKey: .dueDate)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
            ?? container.decodeIfPresent(String.self, forKey: .updateAt)

        if let stringID = try container.decodeIfPresent(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try container.decodeIfPresent(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = Self.fallbackID(title: title, createdAt: createdAt)
        }
    }

    func toTask(referenceDate: Date = Date()) -> Task? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let created = APIDateFormatter.parse(createdAt) ?? referenceDate
        let updated = APIDateFormatter.parse(updatedAt) ?? created

        return Task(
            id: id,
            title: title,
            description: description,
            priority: TaskPriority.fromAPIValue(priority),
            dueDate: APIDateFormatter.parse(dueDate),
            isCompleted: isCompleted,
            createdAt: created,
            updatedAt: updated
        )
    }

    private static func fallbackID(title: String, createdAt: String?) -> String {
        let timestamp = createdAt ?? ""
        return "task-\(title)-\(timestamp)"
    }
}
