import Foundation

struct ParameterSchema: Codable, Equatable {
    let type: String
    let description: String
    let required: Bool
    let properties: [String: ParameterSchema]?

    init(type: String, description: String, required: Bool = true, properties: [String: ParameterSchema]? = nil) {
        self.type = type
        self.description = description
        self.required = required
        self.properties = properties
    }
}

struct FunctionDefinition: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let parameters: [String: ParameterSchema]
    let executor: ([String: Any]) async throws -> Any?

    init(id: String, name: String, description: String, parameters: [String: ParameterSchema], executor: @escaping ([String: Any]) async throws -> Any?) {
        self.id = id
        self.name = name
        self.description = description
        self.parameters = parameters
        self.executor = executor
    }

    var schema: [String: Any] {
        var schema: [String: Any] = [
            "id": id,
            "name": name,
            "description": description,
            "parameters": [
                "type": "object",
                "properties": parameters.mapValues { param -> [String: Any] in
                    var paramSchema: [String: Any] = [
                        "type": param.type,
                        "description": param.description
                    ]
                    if let properties = param.properties {
                        paramSchema["properties"] = properties.mapValues { p -> [String: Any] in
                            ["type": p.type, "description": p.description]
                        }
                    }
                    return paramSchema
                }
            ]
        ]
        return schema
    }
}
