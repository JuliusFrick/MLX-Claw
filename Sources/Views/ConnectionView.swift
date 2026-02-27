import SwiftUI

struct ConnectionView: View {
    @ObservedObject var viewModel: ConnectionViewModel
    
    @State private var serverURL: String = ""
    @State private var showSecureToggle: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            
            inputSection
            
            connectionButton
            
            statusSection
        }
        .padding(24)
        .onAppear {
            serverURL = viewModel.savedServerURL
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "007AFF"))
            
            Text("Connect to Server")
                .font(.system(size: 28, weight: .bold, design: .default))
            
            Text("Enter your OpenClaw WebSocket URL")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Server URL")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                TextField("ws://localhost:8080", text: $serverURL)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: serverURL) { _, newValue in
                        viewModel.validateURL(newValue)
                    }
                
                Button {
                    showSecureToggle.toggle()
                } label: {
                    Image(systemName: showSecureToggle ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Color(hex: "5856D6"))
                }
            }
            
            if !viewModel.isURLValid && !serverURL.isEmpty {
                Text("Invalid WebSocket URL format")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "FF3B30"))
            }
        }
    }
    
    private var connectionButton: some View {
        Button {
            if viewModel.isConnected {
                viewModel.disconnect()
            } else {
                viewModel.connect(to: serverURL)
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.connectionStatus == .connecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: viewModel.isConnected ? "xmark.circle.fill" : "link.circle.fill")
                }
                
                Text(viewModel.isConnected ? "Disconnect" : (viewModel.connectionStatus == .connecting ? "Connecting..." : "Connect"))
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isConnected ? Color(hex: "FF3B30") : Color(hex: "007AFF"))
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.connectionStatus == .connecting || serverURL.isEmpty)
        .opacity((serverURL.isEmpty && !viewModel.isConnected) ? 0.5 : 1.0)
    }
    
    private var statusSection: some View {
        ConnectionStatusBadge(status: viewModel.connectionStatus)
    }
}

struct ConnectionStatusBadge: View {
    let status: ConnectionStatus
    
    @State private var isPulsing: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
                .scaleEffect(isPulsing && status == .connecting ? 1.3 : 1.0)
                .animation(
                    status == .connecting ?
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                        .default,
                    value: isPulsing
                )
                .onAppear {
                    if status == .connecting {
                        isPulsing = true
                    }
                }
                .onChange(of: status) { _, newStatus in
                    isPulsing = newStatus == .connecting
                }
            
            Text(statusText)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .disconnected:
            return Color(hex: "FF3B30")
        case .connecting:
            return Color(hex: "FFC107")
        case .connected:
            return Color(hex: "34C759")
        }
    }
    
    private var statusText: String {
        switch status {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        }
    }
}

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
}

class ConnectionViewModel: ObservableObject {
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var isURLValid: Bool = false
    @Published var savedServerURL: String = ""
    
    var isConnected: Bool {
        connectionStatus == .connected
    }
    
    init() {
        savedServerURL = UserDefaults.standard.string(forKey: "serverURL") ?? ""
    }
    
    func validateURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            isURLValid = false
            return
        }
        isURLValid = url.scheme == "ws" || url.scheme == "wss"
    }
    
    func connect(to urlString: String) {
        guard isURLValid else { return }
        
        connectionStatus = .connecting
        UserDefaults.standard.set(urlString, forKey: "serverURL")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.connectionStatus = .connected
        }
    }
    
    func disconnect() {
        connectionStatus = .disconnected
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ConnectionView(viewModel: ConnectionViewModel())
}
