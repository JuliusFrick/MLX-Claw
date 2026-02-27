import Foundation
import Combine

@Observable
final class WebSocketViewModel: WebSocketServiceDelegate {
    var connectionState: ConnectionState = .disconnected
    var receivedMessages: [OpenClawMessage] = []
    var lastMessage: OpenClawMessage?
    var pendingFunctionCall: FunctionCallMessage?
    
    private let service: WebSocketService
    
    init(service: WebSocketService) {
        self.service = service
        self.connectionState = service.connectionState
    }
    
    func connect(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        service.connect(to: url)
    }
    
    func disconnect() {
        service.disconnect()
    }
    
    func sendFunctionCall(id: String, name: String, parameters: [String: AnyCodable]) {
        service.sendFunctionCall(id: id, name: name, parameters: parameters)
    }
    
    func sendFunctionResult(id: String, status: String, result: AnyCodable?, error: String?) {
        service.sendFunctionResult(id: id, status: status, result: result, error: error)
    }
    
    func sendPing() {
        service.sendPing()
    }
    
    func webSocketDidConnect() {
        connectionState = .connected
    }
    
    func webSocketDidDisconnect(error: Error?) {
        if let error = error {
            connectionState = .error(error.localizedDescription)
        } else {
            connectionState = .disconnected
        }
    }
    
    func webSocketDidReceiveMessage(_ message: OpenClawMessage) {
        lastMessage = message
        receivedMessages.append(message)
        
        if case .functionCall(let call) = message {
            pendingFunctionCall = call
        }
    }
    
    func clearPendingCall() {
        pendingFunctionCall = nil
    }
    
    func clearMessages() {
        receivedMessages.removeAll()
        lastMessage = nil
    }
}
