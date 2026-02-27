import Foundation

enum OpenClawMessage: Codable {
    case functionCall(FunctionCallMessage)
    case functionResult(FunctionResultMessage)
    case ping
    case pong

    enum MessageType: String, Codable {
        case functionCall = "function_call"
        case functionResult = "function_result"
        case ping
        case pong
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case name
        case parameters
        case status
        case result
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .functionCall:
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let parameters = try container.decode([String: AnyCodable].self, forKey: .parameters)
            self = .functionCall(FunctionCallMessage(id: id, name: name, parameters: parameters))
        case .functionResult:
            let id = try container.decode(String.self, forKey: .id)
            let status = try container.decode(String.self, forKey: .status)
            let result = try container.decodeIfPresent(AnyCodable.self, forKey: .result)
            let error = try container.decodeIfPresent(String.self, forKey: .error)
            self = .functionResult(FunctionResultMessage(id: id, status: status, result: result, error: error))
        case .ping:
            self = .ping
        case .pong:
            self = .pong
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .functionCall(let message):
            try container.encode(MessageType.functionCall, forKey: .type)
            try container.encode(message.id, forKey: .id)
            try container.encode(message.name, forKey: .name)
            try container.encode(message.parameters, forKey: .parameters)
        case .functionResult(let message):
            try container.encode(MessageType.functionResult, forKey: .type)
            try container.encode(message.id, forKey: .id)
            try container.encode(message.status, forKey: .status)
            try container.encodeIfPresent(message.result, forKey: .result)
            try container.encodeIfPresent(message.error, forKey: .error)
        case .ping:
            try container.encode(MessageType.ping, forKey: .type)
        case .pong:
            try container.encode(MessageType.pong, forKey: .type)
        }
    }
}

struct FunctionCallMessage: Codable {
    let id: String
    let name: String
    let parameters: [String: AnyCodable]
}

struct FunctionResultMessage: Codable {
    let id: String
    let status: String
    let result: AnyCodable?
    let error: String?
}
