import Foundation
import Starscream

protocol WebSocketServiceDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveMessage(_ message: OpenClawMessage)
}

final class WebSocketService: NSObject, ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .disconnected
    
    private var socket: WebSocket?
    private var serverURL: URL?
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
    weak var delegate: WebSocketServiceDelegate?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let keychainService = KeychainService.shared
    
    // Keychain keys
    private enum KeychainKeys {
        static let authToken = "websocket_auth_token"
        static let serverURL = "websocket_server_url"
    }
    
    override init() {
        super.init()
    }
    
    func connect(to url: URL) {
        disconnect()
        
        serverURL = url
        reconnectAttempts = 0
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        // Add auth token if available
        if let tokenData = try? keychainService.load(key: KeychainKeys.authToken),
           let token = String(data: tokenData, encoding: .utf8) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        
        connectionState = .connecting
        socket?.connect()
        
        // Save server URL
        if let urlString = url.absoluteString.data(using: .utf8) {
            try? keychainService.save(key: KeychainKeys.serverURL, data: urlString)
        }
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        socket?.disconnect()
        socket = nil
        connectionState = .disconnected
    }
    
    func send(_ message: OpenClawMessage) {
        guard connectionState.isConnected else {
            print("WebSocket not connected, cannot send message")
            return
        }
        
        do {
            let data = try encoder.encode(message)
            if let jsonString = String(data: data, encoding: .utf8) {
                socket?.write(string: jsonString)
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
    
    func sendFunctionCall(id: String, name: String, parameters: [String: AnyCodable]) {
        let message = OpenClawMessage.functionCall(FunctionCallMessage(id: id, name: name, parameters: parameters))
        send(message)
    }
    
    func sendFunctionResult(id: String, status: String, result: AnyCodable?, error: String?) {
        let message = OpenClawMessage.functionResult(FunctionResultMessage(id: id, status: status, result: result, error: error))
        send(message)
    }
    
    func sendPing() {
        send(.ping)
    }
    
    // MARK: - Token Management
    
    func saveAuthToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        try? keychainService.save(key: KeychainKeys.authToken, data: data)
    }
    
    func getAuthToken() -> String? {
        guard let data = try? keychainService.load(key: KeychainKeys.authToken) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteAuthToken() {
        try? keychainService.delete(key: KeychainKeys.authToken)
    }
    
    func getLastServerURL() -> String? {
        guard let data = try? keychainService.load(key: KeychainKeys.serverURL) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Reconnection
    
    private func scheduleReconnect() {
        guard reconnectAttempts < maxReconnectAttempts,
              let url = serverURL else {
            connectionState = .error("Max reconnection attempts reached")
            return
        }
        
        reconnectAttempts += 1
        let delay = Double(min(pow(2.0, Double(reconnectAttempts)), 30.0))
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.connect(to: url)
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            let message = try decoder.decode(OpenClawMessage.self, from: data)
            
            switch message {
            case .ping:
                send(.pong)
            case .pong:
                break
            default:
                delegate?.webSocketDidReceiveMessage(message)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}

extension WebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected:
            connectionState = .connected
            reconnectAttempts = 0
            delegate?.webSocketDidConnect()
            
        case .disconnected(let reason, let code):
            connectionState = .disconnected
            delegate?.webSocketDidDisconnect(error: nil)
            print("WebSocket disconnected: \(reason) (code: \(code))")
            scheduleReconnect()
            
        case .text(let text):
            handleMessage(text)
            
        case .binary(let data):
            if let text = String(data: data, encoding: .utf8) {
                handleMessage(text)
            }
            
        case .error(let error):
            connectionState = .error(error?.localizedDescription ?? "Unknown error")
            delegate?.webSocketDidDisconnect(error: error)
            scheduleReconnect()
            
        case .cancelled:
            connectionState = .disconnected
            delegate?.webSocketDidDisconnect(error: nil)
            
        case .ping, .pong, .viabilityChanged, .reconnectSuggested, .peerClosed:
            break
        }
    }
}
