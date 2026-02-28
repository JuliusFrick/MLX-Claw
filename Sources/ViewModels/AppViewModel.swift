import Foundation
import SwiftUI
import Combine

@Observable
final class AppViewModel {
    var connectionState: ConnectionState = .disconnected
    var serverURL: String = "ws://localhost:8080/ws"
    var isShowingSettings: Bool = false
    var lastError: String?
    var pendingFunctionCalls: [FunctionCallMessage] = []
    var chatHistory: [ChatMessage] = []
    var pendingQueueCount: Int = 0
    var isSyncing: Bool = false
    
    // Use OpenClawService for proper integration
    let openClawService: OpenClawService
    let queueService = QueueService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.openClawService = OpenClawService()
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind connection state from OpenClawService
        openClawService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)
        
        // Bind errors
        openClawService.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = error
            }
            .store(in: &cancellables)
        
        // Bind queue count
        queueService.$pendingCalls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calls in
                self?.pendingQueueCount = calls.count
            }
            .store(in: &cancellables)
        
        // Bind syncing state
        queueService.$isSyncing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] syncing in
                self?.isSyncing = syncing
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        guard let url = URL(string: serverURL) else {
            lastError = "Invalid server URL"
            return
        }
        
        lastError = nil
        openClawService.connect(to: url)
    }
    
    func disconnect() {
        openClawService.disconnect()
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
