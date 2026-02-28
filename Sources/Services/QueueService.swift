import Foundation
import Combine

/// Service for queuing function calls when offline and syncing when connection is restored
final class QueueService: ObservableObject {
    static let shared = QueueService()
    
    @Published private(set) var pendingCalls: [QueuedFunctionCall] = []
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var isOffline: Bool = false
    
    private let defaults = UserDefaults.standard
    private let queueKey = "offlineFunctionQueue"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadQueue()
        setupConnectionObserver()
    }
    
    private func setupConnectionObserver() {
        // Observe connection state changes
        NotificationCenter.default.publisher(for: .connectionStateChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let state = notification.object as? ConnectionState else { return }
                self?.handleConnectionChange(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleConnectionChange(_ state: ConnectionState) {
        let wasOffline = isOffline
        isOffline = !state.isConnected
        
        // When coming back online, trigger sync
        if wasOffline && state.isConnected {
            Task {
                await syncPendingCalls()
            }
        }
    }
    
    // MARK: - Queue Management
    
    /// Add a function call to the queue
    func enqueue(_ call: QueuedFunctionCall) {
        pendingCalls.append(call)
        saveQueue()
    }
    
    /// Remove and return the oldest queued call
    func dequeue() -> QueuedFunctionCall? {
        guard !pendingCalls.isEmpty else { return nil }
        let call = pendingCalls.removeFirst()
        saveQueue()
        return call
    }
    
    /// Peek at the next call without removing it
    func peek() -> QueuedFunctionCall? {
        pendingCalls.first
    }
    
    /// Get all pending calls
    func getAllPending() -> [QueuedFunctionCall] {
        pendingCalls
    }
    
    /// Clear all pending calls
    func clearQueue() {
        pendingCalls.removeAll()
        saveQueue()
    }
    
    /// Get number of pending calls
    var count: Int {
        pendingCalls.count
    }
    
    // MARK: - Sync
    
    /// Sync all pending calls when connection is restored
    @MainActor
    func syncPendingCalls() async {
        guard !pendingCalls.isEmpty else { return }
        guard let openClawService = OpenClawService.shared else { return }
        
        isSyncing = true
        
        var failedCalls: [QueuedFunctionCall] = []
        
        while let call = dequeue() {
            do {
                try await openClawService.executeQueuedCall(call)
            } catch {
                // Re-queue failed calls
                failedCalls.append(call)
            }
        }
        
        // Re-queue failed calls
        for call in failedCalls {
            enqueue(call)
        }
        
        isSyncing = false
    }
    
    // MARK: - Persistence
    
    private func saveQueue() {
        if let encoded = try? JSONEncoder().encode(pendingCalls) {
            defaults.set(encoded, forKey: queueKey)
        }
    }
    
    private func loadQueue() {
        guard let data = defaults.data(forKey: queueKey),
              let decoded = try? JSONDecoder().decode([QueuedFunctionCall].self, from: data) else {
            return
        }
        pendingCalls = decoded
    }
}

// MARK: - Models

/// A function call that has been queued for later execution
struct QueuedFunctionCall: Codable, Identifiable {
    let id: String
    let name: String
    let parameters: [String: AnyCodable]
    let timestamp: Date
    var retryCount: Int
    
    init(id: String = UUID().uuidString, name: String, parameters: [String: AnyCodable], timestamp: Date = Date(), retryCount: Int = 0) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
        self.retryCount = retryCount
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, parameters, timestamp, retryCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        retryCount = try container.decode(Int.self, forKey: .retryCount)
        
        // Decode parameters as [String: AnyCodable]
        if let data = try? container.decode(Data.self, forKey: .parameters),
           let decoded = try? JSONDecoder().decode([String: AnyCodable].self, from: data) {
            parameters = decoded
        } else {
            parameters = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(retryCount, forKey: .retryCount)
        
        // Encode parameters as JSON data
        if let data = try? JSONEncoder().encode(parameters) {
            try container.encode(data, forKey: .parameters)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let connectionStateChanged = Notification.Name("connectionStateChanged")
    static let queueUpdated = Notification.Name("queueUpdated")
}
