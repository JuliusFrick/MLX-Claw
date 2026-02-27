import SwiftUI

struct ConnectionView: View {
    @ObservedObject var viewModel: ConnectionViewModel
    
    @State private var serverURL: String = ""
    @State private var isPulsing: Bool = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                headerSection
                
                inputSection
                
                connectButton
                
                statusSection
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.top, AppSpacing.xxl)
        }
        .onAppear {
            serverURL = viewModel.savedServerURL
            if viewModel.connectionStatus == .connecting {
                isPulsing = true
            }
        }
        .onChange(of: viewModel.connectionStatus) { _, newStatus in
            isPulsing = newStatus == .connecting
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.m) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "claw.hammer.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                viewModel.connectionStatus == .connecting ?
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    .default,
                value: isPulsing
            )
            
            VStack(spacing: AppSpacing.xs) {
                Text("MLX-Claw")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Connect to your server")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.top, AppSpacing.xl)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Server URL")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
            
            AppTextField(text: $serverURL, placeholder: "wss://localhost:8080")
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: serverURL) { _, newValue in
                    viewModel.validateURL(newValue)
                }
            
            if !viewModel.isURLValid && !serverURL.isEmpty {
                Text("Invalid WebSocket URL format")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.error)
            }
        }
    }
    
    private var connectButton: some View {
        Button {
            if viewModel.isConnected {
                viewModel.disconnect()
            } else {
                viewModel.connect(to: serverURL)
            }
        } label: {
            HStack(spacing: AppSpacing.s) {
                if viewModel.connectionStatus == .connecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: viewModel.isConnected ? "xmark.circle.fill" : "wifi")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(viewModel.isConnected ? "Disconnect" : (viewModel.connectionStatus == .connecting ? "Connecting..." : "Connect"))
                    .font(AppTypography.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.m)
            .background(
                viewModel.isConnected ?
                    AppColors.error :
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(AppCornerRadius.medium)
            .shadow(
                color: (viewModel.isConnected ? AppColors.error : AppColors.primary).opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(viewModel.connectionStatus == .connecting || serverURL.isEmpty)
        .opacity((serverURL.isEmpty && !viewModel.isConnected) ? 0.5 : 1.0)
    }
    
    private var statusSection: some View {
        ConnectionStatusBadge(status: {
            switch viewModel.connectionStatus {
            case .disconnected: return .disconnected
            case .connecting: return .connecting
            case .connected: return .connected
            }
        }())
    }
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

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
}

#Preview {
    ConnectionView(viewModel: ConnectionViewModel())
}
