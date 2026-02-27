import Foundation

actor FunctionRegistry {
    static let shared = FunctionRegistry()
    
    private var functions: [String: FunctionDefinition] = [:]
    
    private init() {}
    
    func register(_ function: FunctionDefinition) {
        functions[function.id] = function
    }
    
    func unregister(id: String) {
        functions.removeValue(forKey: id)
    }
    
    func get(id: String) -> FunctionDefinition? {
        return functions[id]
    }
    
    func getAll() -> [FunctionDefinition] {
        return Array(functions.values)
    }
    
    func list() -> [[String: Any]] {
        return functions.values.map { $0.schema }
    }
    
    func execute(id: String, arguments: [String: Any]) async throws -> Any? {
        guard let function = functions[id] else {
            throw RegistryError.functionNotFound(id)
        }
        return try await function.executor(arguments)
    }
}

enum RegistryError: Error, LocalizedError {
    case functionNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .functionNotFound(let id):
            return "Function with id '\(id)' not found"
        }
    }
}

extension FunctionRegistry {
    static func createSampleFunctions() -> [FunctionDefinition] {
        return [
            FunctionDefinition(
                id: "create_calendar_event",
                name: "CreateCalendarEvent",
                description: "Create a new calendar event",
                parameters: [
                    "title": ParameterSchema(type: "string", description: "Event title"),
                    "date": ParameterSchema(type: "string", description: "Event date in ISO 8601 format"),
                    "duration": ParameterSchema(type: "integer", description: "Duration in minutes", required: false)
                ],
                executor: { arguments in
                    let title = arguments["title"] as? String ?? "Untitled"
                    let date = arguments["date"] as? String ?? ""
                    let duration = arguments["duration"] as? Int ?? 60
                    return ["success": true, "eventId": UUID().uuidString, "title": title, "date": date, "duration": duration]
                }
            ),
            FunctionDefinition(
                id: "get_calendar_events",
                name: "GetCalendarEvents",
                description: "Retrieve calendar events for a date range",
                parameters: [
                    "startDate": ParameterSchema(type: "string", description: "Start date in ISO 8601 format"),
                    "endDate": ParameterSchema(type: "string", description: "End date in ISO 8601 format")
                ],
                executor: { arguments in
                    return ["events": [], "count": 0]
                }
            ),
            FunctionDefinition(
                id: "create_task",
                name: "CreateTask",
                description: "Create a new task",
                parameters: [
                    "title": ParameterSchema(type: "string", description: "Task title"),
                    "dueDate": ParameterSchema(type: "string", description: "Due date in ISO 8601 format", required: false),
                    "priority": ParameterSchema(type: "string", description: "Priority: low, medium, high", required: false)
                ],
                executor: { arguments in
                    let title = arguments["title"] as? String ?? "Untitled"
                    let priority = arguments["priority"] as? String ?? "medium"
                    return ["success": true, "taskId": UUID().uuidString, "title": title, "priority": priority]
                }
            ),
            FunctionDefinition(
                id: "list_tasks",
                name: "ListTasks",
                description: "List all tasks with optional filtering",
                parameters: [
                    "status": ParameterSchema(type: "string", description: "Filter by status: all, pending, completed", required: false),
                    "priority": ParameterSchema(type: "string", description: "Filter by priority: low, medium, high", required: false)
                ],
                executor: { arguments in
                    return ["tasks": [], "count": 0]
                }
            ),
            FunctionDefinition(
                id: "complete_task",
                name: "CompleteTask",
                description: "Mark a task as completed",
                parameters: [
                    "taskId": ParameterSchema(type: "string", description: "The task ID to complete")
                ],
                executor: { arguments in
                    let taskId = arguments["taskId"] as? String ?? ""
                    return ["success": true, "taskId": taskId, "completed": true]
                }
            )
        ]
    }
}
