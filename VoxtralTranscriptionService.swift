import Foundation

// MARK: - Response Models

/// Einzelnes Segment einer Transkription (mit optionalem Speaker-Label)
struct TranscriptionSegment: Codable {
    let start: Double
    let end: Double
    let text: String
    let speaker: String?
}

/// API-Antwort von Mistral Voxtral Transcription
struct VoxtralTranscriptionResponse: Codable {
    let text: String
    let segments: [TranscriptionSegment]?

    /// Formatierte Ausgabe mit Speaker-Labels (falls vorhanden)
    var formattedWithSpeakers: String {
        guard let segments = segments, !segments.isEmpty else { return text }

        var output = ""
        var currentSpeaker: String?

        for segment in segments {
            if let speaker = segment.speaker, speaker != currentSpeaker {
                currentSpeaker = speaker
                output += "\n[\(speaker)]\n"
            }
            output += segment.text
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Service

/// Service für die Transkription von Audio via Mistral Voxtral API.
/// Nutzt das gleiche Keychain-Muster wie die übrigen Services.
@MainActor
final class VoxtralTranscriptionService: ObservableObject {

    // MARK: - Singleton

    static let shared = VoxtralTranscriptionService()

    // MARK: - Published

    @Published private(set) var isTranscribing = false
    @Published private(set) var lastTranscription: VoxtralTranscriptionResponse?
    @Published private(set) var lastError: Error?
    /// Fortschritt 0…1 (wird auf "in progress" gesetzt bis Antwort kommt)
    @Published private(set) var progress: Double = 0.0

    // MARK: - Konfiguration

    /// Keychain-Schlüssel für den Mistral API-Key
    private static let apiKeyIdentifier = "voxtral_api_key"

    /// Basis-URL der Mistral Transcription API
    private let baseURL = URL(string: "https://api.mistral.ai/v1/audio/transcriptions")!

    /// Standard-Modell für Transkription
    var model: String = "voxtral-mini-latest"

    // MARK: - Init

    private init() {}

    // MARK: - API-Key Verwaltung

    /// API-Key im Keychain speichern
    func saveAPIKey(_ key: String) throws {
        try KeychainService.shared.save(key, for: Self.apiKeyIdentifier)
    }

    /// API-Key aus dem Keychain laden
    func loadAPIKey() -> String? {
        try? KeychainService.shared.loadString(for: Self.apiKeyIdentifier)
    }

    /// Prüft ob ein API-Key konfiguriert ist
    func hasAPIKey() -> Bool {
        KeychainService.shared.exists(for: Self.apiKeyIdentifier)
    }

    /// API-Key aus dem Keychain löschen
    func deleteAPIKey() throws {
        try KeychainService.shared.delete(for: Self.apiKeyIdentifier)
    }

    // MARK: - Transkription

    /// Transkribiert eine Audio-Datei über die Voxtral API.
    ///
    /// - Parameters:
    ///   - audioURL: Lokaler Pfad zur `.m4a`-Aufnahme (z.B. von `AudioRecordingService`)
    ///   - language: Sprache als ISO 639-1 Code (nil = automatische Erkennung)
    ///   - enableDiarization: Speaker-Erkennung aktivieren
    /// - Returns: Vollständige Transkription mit optionalen Segmenten
    func transcribe(
        audioURL: URL,
        language: String? = nil,
        enableDiarization: Bool = true
    ) async throws -> VoxtralTranscriptionResponse {
        guard let apiKey = loadAPIKey(), !apiKey.isEmpty else {
            throw VoxtralError.apiKeyMissing
        }

        isTranscribing = true
        lastError = nil
        progress = 0.1

        do {
            let response = try await performRequest(
                audioURL: audioURL,
                apiKey: apiKey,
                language: language,
                enableDiarization: enableDiarization
            )
            lastTranscription = response
            progress = 1.0
            isTranscribing = false
            return response
        } catch {
            lastError = error
            isTranscribing = false
            progress = 0.0
            throw error
        }
    }

    // MARK: - Private

    private func performRequest(
        audioURL: URL,
        apiKey: String,
        language: String?,
        enableDiarization: Bool
    ) async throws -> VoxtralTranscriptionResponse {

        // Audio-Datei laden
        let audioData: Data
        do {
            audioData = try Data(contentsOf: audioURL)
        } catch {
            throw VoxtralError.fileReadFailed(audioURL.lastPathComponent)
        }

        progress = 0.2

        // Multipart-Body zusammenbauen
        let boundary = "----VoxtralBoundary\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        var body = Data()

        // --- file
        appendPart(&body, boundary: boundary, name: "file", filename: audioURL.lastPathComponent, contentType: "audio/mp4", data: audioData)

        // --- model
        appendField(&body, boundary: boundary, name: "model", value: model)

        // --- language (optional)
        if let language = language {
            appendField(&body, boundary: boundary, name: "language", value: language)
        }

        // --- diarization (optional)
        if enableDiarization {
            appendField(&body, boundary: boundary, name: "diarization", value: "true")
        }

        // Abschluss-Boundary
        body.append(Data("--\(boundary)--\r\n".utf8))

        progress = 0.3

        // Request aufbauen
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Request ausführen
        let (responseData, httpResponse) = try await URLSession.shared.data(for: request)

        progress = 0.9

        // Status prüfen
        let statusCode = (httpResponse as? HTTPURLResponse)?.statusCode ?? 0
        guard statusCode == 200 else {
            let detail = String(data: responseData, encoding: .utf8) ?? "Keine Details"
            throw VoxtralError.apiError(statusCode, detail)
        }

        // Antwort dekodieren
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(VoxtralTranscriptionResponse.self, from: responseData)
    }

    // MARK: - Multipart Helpers

    /// Fügt ein Datei-Part zum Multipart-Body hinzu
    private func appendPart(_ body: inout Data, boundary: String, name: String, filename: String, contentType: String, data: Data) {
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(contentType)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n".utf8))
    }

    /// Fügt ein Text-Feld zum Multipart-Body hinzu
    private func appendField(_ body: inout Data, boundary: String, name: String, value: String) {
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8))
        body.append(Data(value.utf8))
        body.append(Data("\r\n".utf8))
    }
}

// MARK: - Errors

enum VoxtralError: LocalizedError {
    case apiKeyMissing
    case fileReadFailed(String)
    case apiError(Int, String)

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Mistral API-Key nicht konfiguriert. Bitte in Einstellungen eingeben."
        case .fileReadFailed(let filename):
            return "Audio-Datei \"\(filename)\" konnte nicht gelesen werden."
        case .apiError(let code, let detail):
            return "Voxtral API-Fehler (\(code)): \(detail)"
        }
    }
}
