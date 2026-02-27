import Foundation
import Combine

final class OpenClawService: ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var isProcessing = false
    @Published private(set) var lastError: String?

    let webSocketService: WebSocketService
    let mlxService: MLXService
    let functionRegistry: FunctionRegistry

    private var serverURL: URL?
    private var cancellables = Set<AnyCancellable>()

    init(
        webSocketService: WebSocketService = WebSocketService(),
        mlxService: MLXService = MLXService(),
        functionRegistry: FunctionRegistry = .shared
    ) {
        self.webSocketService = webSocketService
        self.mlxService = mlxService
        self.functionRegistry = functionRegistry

        webSocketService.delegate = self
        setupBindings()
    }

    private func setupBindings() {
        webSocketService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)

        mlxService.$isProcessing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] processing in
                self?.isProcessing = processing
            }
            .store(in: &cancellables)

        mlxService.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = error
            }
            .store(in: &cancellables)
    }

    func connect(to url: URL) {
        serverURL = url
        registerDefaultFunctions()
        webSocketService.connect(to: url)
    }

    func connect(to urlString: String) {
        guard let url = URL(string: urlString) else {
            lastError = "Invalid URL: \(urlString)"
            return
        }
        connect(to: url)
    }

    func disconnect() {
        webSocketService.disconnect()
        mlxService.unloadModel()
    }

    func sendMessage(_ text: String) async {
        guard connectionState.isConnected else {
            await MainActor.run {
                lastError = "Not connected to server"
            }
            return
        }

        guard mlxService.isLoaded else {
            await MainActor.run {
                lastError = "MLX model not loaded"
            }
            return
        }

        do {
            let response = try await mlxService.generate(prompt: text)
            let message = OpenClawMessage.functionResult(
                FunctionResultMessage(
                    id: UUID().uuidString,
                    status: "success",
                    result: AnyCodable(response),
                    error: nil
                )
            )
            webSocketService.send(message)
        } catch {
            let errorMessage = OpenClawMessage.functionResult(
                FunctionResultMessage(
                    id: UUID().uuidString,
                    status: "error",
                    result: nil,
                    error: error.localizedDescription
                )
            )
            webSocketService.send(errorMessage)
        }
    }

    func handleFunctionCall(_ call: FunctionCall) async {
        var updatedCall = call
        updatedCall.status = .executing

        let resultMessage = OpenClawMessage.functionResult(
            FunctionResultMessage(
                id: call.id,
                status: "executing",
                result: nil,
                error: nil
            )
        )
        webSocketService.send(resultMessage)

        do {
            let parameters = call.parameters.mapValues { $0.value }
            let result = try await functionRegistry.execute(id: call.name, arguments: parameters)

            let successMessage = OpenClawMessage.functionResult(
                FunctionResultMessage(
                    id: call.id,
                    status: "success",
                    result: AnyCodable(result),
                    error: nil
                )
            )
            webSocketService.send(successMessage)

        } catch {
            let errorMessage = OpenClawMessage.functionResult(
                FunctionResultMessage(
                    id: call.id,
                    status: "error",
                    result: nil,
                    error: error.localizedDescription
                )
            )
            webSocketService.send(errorMessage)
        }
    }

    func sendFunctionResult(_ result: FunctionResultMessage) {
        let message = OpenClawMessage.functionResult(result)
        webSocketService.send(message)
    }

    func sendFunctionResult(id: String, status: String, result: Any?, error: String?) {
        let resultMessage = FunctionResultMessage(
            id: id,
            status: status,
            result: result.map { AnyCodable($0) },
            error: error
        )
        sendFunctionResult(resultMessage)
    }

    func loadModel(_ modelId: String) async throws {
        try await mlxService.loadModel(modelId)
    }

    func getAvailableModels() -> [String] {
        return mlxService.availableModels
    }

    func getRegisteredFunctions() async -> [[String: Any]] {
        return await functionRegistry.list()
    }

    private func registerDefaultFunctions() {
        let functions = FunctionRegistry.createSampleFunctions()
        for function in functions {
            Task {
                await functionRegistry.register(function)
            }
        }
    }
}

extension OpenClawService: WebSocketServiceDelegate {
    func webSocketDidConnect() {
        Task {
            if !mlxService.isLoaded, let defaultModel = mlxService.availableModels.first {
                try? await mlxService.loadModel(defaultModel)
            }
        }
    }

    func webSocketDidDisconnect(error: Error?) {
        if let error = error {
            lastError = error.localizedDescription
        }
    }

    func webSocketDidReceiveMessage(_ message: OpenClawMessage) {
        switch message {
        case .functionCall(let functionCallMessage):
            let call = FunctionCall(
                id: functionCallMessage.id,
                name: functionCallMessage.name,
                parameters: functionCallMessage.parameters,
                status: .pending
            )
            Task {
                await handleFunctionCall(call)
            }

        case .functionResult:
            break

        case .ping:
            webSocketService.send(.pong)

        case .pong:
            break
        }
    }
}
