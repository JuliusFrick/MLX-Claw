import Foundation

struct FunctionCall: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let parameters: [String: AnyCodable]
    let timestamp: Date
    var status: FunctionCallStatus
    var result: AnyCodable?
    var error: String?

    init(id: String, name: String, parameters: [String: AnyCodable], timestamp: Date = Date(), status: FunctionCallStatus = .pending) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
        self.status = status
        self.result = nil
        self.error = nil
    }

    enum CodingKeys: String, CodingKey {
        case id, name, parameters, timestamp, status, result, error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        status = try container.decode(FunctionCallStatus.self, forKey: .status)
        parameters = try container.decode([String: AnyCodable].self, forKey: .parameters)
        result = try container.decodeIfPresent(AnyCodable.self, forKey: .result)
        error = try container.decodeIfPresent(String.self, forKey: .error)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(result, forKey: .result)
        try container.encodeIfPresent(error, forKey: .error)
    }
}

enum FunctionCallStatus: String, Codable {
    case pending
    case executing
    case success
    case error
    case cancelled
}

struct AnyCodable: Codable, Equatable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable cannot encode value"))
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        return false
    }
}
