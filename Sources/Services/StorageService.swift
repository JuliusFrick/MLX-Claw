import Foundation

final class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let serverURL = "serverURL"
        static let model = "model"
        static let temperature = "temperature"
        static let maxTokens = "maxTokens"
    }

    private init() {}

    func saveServerURL(_ url: String) {
        defaults.set(url, forKey: Keys.serverURL)
    }

    func getServerURL() -> String? {
        defaults.string(forKey: Keys.serverURL)
    }

    func saveModel(_ model: String) {
        defaults.set(model, forKey: Keys.model)
    }

    func getModel() -> String? {
        defaults.string(forKey: Keys.model)
    }

    func saveTemperature(_ temp: Double) {
        defaults.set(temp, forKey: Keys.temperature)
    }

    func getTemperature() -> Double {
        defaults.double(forKey: Keys.temperature)
    }

    func saveMaxTokens(_ tokens: Int) {
        defaults.set(tokens, forKey: Keys.maxTokens)
    }

    func getMaxTokens() -> Int {
        defaults.integer(forKey: Keys.maxTokens)
    }

    func clearAll() {
        defaults.removeObject(forKey: Keys.serverURL)
        defaults.removeObject(forKey: Keys.model)
        defaults.removeObject(forKey: Keys.temperature)
        defaults.removeObject(forKey: Keys.maxTokens)
    }
}
