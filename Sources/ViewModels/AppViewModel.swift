import Foundation
import SwiftUI

@Observable
final class AppViewModel {
    var connectionState: ConnectionState = .disconnected
    var serverURL: String = "ws://localhost:8080/ws"
    var isShowingSettings: Bool = false
    var lastError: String?
    var pendingFunctionCalls: [FunctionCallMessage] = []
    
    let webSocketService: WebSocketService
    private(set) var webSocketViewModel: WebSocketViewModel?
    
    init() {
        self.webSocketService = WebSocketService()
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        let wsViewModel = WebSocketViewModel(service: webSocketService)
        self.webSocketViewModel = wsViewModel
        webSocketService.delegate = wsViewModel
    }
    
    func connect() {
        guard let url = URL(string: serverURL) else {
            lastError = "Invalid server URL"
            return
        }
        
        lastError = nil
        webSocketService.connect(to: url)
    }
    
    func disconnect() {
        webSocketService.disconnect()
    }
    
    func toggleConnection() {
        switch connectionState {
        case .connected:
            disconnect()
        case .disconnected, .error:
            connect()
        case .connecting:
            disconnect()
        }
    }
    
    func updateConnectionState(_ state: ConnectionState) {
        connectionState = state
        
        if case .error(let message) = state {
            lastError = message
        }
    }
}
