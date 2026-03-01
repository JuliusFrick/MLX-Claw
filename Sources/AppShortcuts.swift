import Foundation
import AppIntents

// MARK: - App Shortcuts Provider

struct MLXClawShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConnectToServerIntent(),
            phrases: [
                "Connect \(.applicationName) to server",
                "Connect \(.applicationName)",
                "Open \(.applicationName) connection"
            ],
            shortTitle: "Connect to Server",
            systemImageName: "wifi"
        )
        
        AppShortcut(
            intent: DisconnectIntent(),
            phrases: [
                "Disconnect \(.applicationName)",
                "Disconnect from server in \(.applicationName)"
            ],
            shortTitle: "Disconnect",
            systemImageName: "wifi.slash"
        )
        
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send message in \(.applicationName)",
                "Message to \(.applicationName)"
            ],
            shortTitle: "Send Message",
            systemImageName: "message"
        )
        
        AppShortcut(
            intent: GetConnectionStatusIntent(),
            phrases: [
                "Check \(.applicationName) status",
                "Is \(.applicationName) connected",
                "Connection status of \(.applicationName)"
            ],
            shortTitle: "Check Status",
            systemImageName: "antenna.radiowaves.left.and.right"
        )
    }
}

// MARK: - Connect to Server Intent

struct ConnectToServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Connect to Server"
    static var description = IntentDescription("Connect MLX-Claw to your OpenClaw server")
    
    @Parameter(title: "Server URL")
    var serverURL: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Connect to \(\.$serverURL)")
    }
    
    func perform() async throws -> some IntentResult {
        let service = OpenClawService.shared
        
        let urlString = serverURL ?? "ws://localhost:8080/ws"
        
        guard let url = URL(string: urlString) else {
            return .result()
        }
        
        service.connect(to: url)
        
        return .result()
    }
}

// MARK: - Disconnect Intent

struct DisconnectIntent: AppIntent {
    static var title: LocalizedStringResource = "Disconnect from Server"
    static var description = IntentDescription("Disconnect MLX-Claw from the OpenClaw server")
    
    func perform() async throws -> some IntentResult {
        OpenClawService.shared?.disconnect()
        return .result()
    }
}

// MARK: - Send Message Intent

struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Message"
    static var description = IntentDescription("Send a message through MLX-Claw")
    
    @Parameter(title: "Message")
    var message: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Send \(\.$message)")
    }
    
    func perform() async throws -> some IntentResult {
        guard let service = OpenClawService.shared else {
            return .result()
        }
        
        await service.sendMessage(message)
        
        return .result()
    }
}

// MARK: - Get Connection Status Intent

struct GetConnectionStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Connection Status"
    static var description = IntentDescription("Get the current connection status of MLX-Claw")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let service = OpenClawService.shared else {
            return .result(dialog: "MLX-Claw is not available")
        }
        
        let status: String
        switch service.connectionState {
        case .connected:
            status = "Connected to server"
        case .connecting:
            status = "Connecting to server..."
        case .disconnected:
            status = "Disconnected"
        case .error(let message):
            status = "Error: \(message)"
        }
        
        return .result(dialog: IntentDialog(stringLiteral: status))
    }
}

// MARK: - App Entity for Shortcuts

struct ServerEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    
    static var defaultQuery = ServerEntityQuery()
    
    var id: String
    var name: String
    var url: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(url)")
    }
}

struct ServerEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ServerEntity] {
        // Return saved servers
        let savedURL = UserDefaults.standard.string(forKey: "serverURL") ?? "ws://localhost:8080/ws"
        
        return [ServerEntity(id: "default", name: "Default Server", url: savedURL)]
    }
    
    func suggestedEntities() async throws -> [ServerEntity] {
        return try await entities(for: [])
    }
    
    func defaultResult() async -> ServerEntity? {
        let savedURL = UserDefaults.standard.string(forKey: "serverURL") ?? "ws://localhost:8080/ws"
        return ServerEntity(id: "default", name: "Default Server", url: savedURL)
    }
}
