import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    var isStreaming: Bool
    var attachments: [String]

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        attachments: [String] = []
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.attachments = attachments
    }
}
