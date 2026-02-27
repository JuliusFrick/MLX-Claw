import Foundation
import MLX

struct MLXConfiguration: Sendable {
    var temperature: Double = 0.7
    var maxTokens: Int = 512
    
    static let `default` = MLXConfiguration()
}

final class MLXService: ObservableObject {
    @Published private(set) var isLoaded = false
    @Published private(set) var isProcessing = false
    @Published private(set) var lastError: String?
    
    @Published private(set) var loadedModel: String?
    @Published private(set) var availableModels: [String] = []
    
    private var model: MLXModel?
    private let modelPath: String = "gemma-2b-it"
    private var configuration: MLXConfiguration = .default
    
    init() {
        loadAvailableModels()
    }
    
    private func loadAvailableModels() {
        availableModels = [
            "mlx-community/Llama-3.2-1B-Instruct-4bit",
            "mlx-community/Llama-3.2-3B-Instruct-4bit",
            "mlx-community/Qwen2.5-0.5B-Instruct-4bit"
        ]
    }
    
    func loadModel(_ modelId: String) async throws {
        await MainActor.run {
            isProcessing = true
            lastError = nil
        }
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                loadedModel = modelId
                isLoaded = true
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                lastError = error.localizedDescription
                isProcessing = false
            }
            throw error
        }
    }
    
    func unloadModel() {
        model = nil
        loadedModel = nil
        isLoaded = false
    }
    
    func generate(prompt: String, parameters: [String: Any] = [:]) async throws -> String {
        try await generate(prompt: prompt, configuration: configuration)
    }
    
    func generate(prompt: String, configuration: MLXConfiguration) async throws -> String {
        guard isLoaded else {
            throw MLXError.modelNotLoaded
        }
        
        await MainActor.run {
            isProcessing = true
            lastError = nil
        }
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let result = "Generated response for: \(prompt) (temp: \(configuration.temperature), max: \(configuration.maxTokens))"
            
            await MainActor.run {
                isProcessing = false
            }
            
            return result
        } catch {
            await MainActor.run {
                lastError = error.localizedDescription
                isProcessing = false
            }
            throw error
        }
    }
    
    func streamGenerate(prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            guard isLoaded else {
                continuation.finish(throwing: MLXError.modelNotLoaded)
                return
            }
            
            Task {
                await MainActor.run {
                    isProcessing = true
                    lastError = nil
                }
                
                let words = prompt.split(separator: " ")
                for (index, word) in words.enumerated() {
                    let token = "Token \(index): \(word) "
                    continuation.yield(token)
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                
                let finalToken = "[EOS]"
                continuation.yield(finalToken)
                continuation.finish()
                
                await MainActor.run {
                    isProcessing = false
                }
            }
        }
    }
    
    func executeFunctionCall(_ functionCall: FunctionCall) async throws -> AnyCodable {
        guard isLoaded else {
            throw MLXError.modelNotLoaded
        }
        
        await MainActor.run {
            isProcessing = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        let result = "Executed \(functionCall.name) with parameters: \(functionCall.parameters)"
        return AnyCodable(result)
    }
}

enum MLXError: LocalizedError {
    case modelNotLoaded
    case generationFailed(String)
    case invalidParameters(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "No model is currently loaded"
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        case .invalidParameters(let reason):
            return "Invalid parameters: \(reason)"
        }
    }
}
