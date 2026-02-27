import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ConnectionStatusBadge(state: appViewModel.connectionState)
                
                ServerURLInput(
                    url: $appViewModel.serverURL,
                    isConnecting: appViewModel.connectionState == .connecting
                )
                
                ConnectButton(
                    state: appViewModel.connectionState,
                    action: appViewModel.toggleConnection
                )
                
                Divider()
                
                if appViewModel.connectionState == .connected {
                    MLXStatusIndicator(isReady: appViewModel.isMLXReady)
                    
                    FunctionCallHistory(calls: appViewModel.functionCallHistory)
                } else {
                    Spacer()
                    Text("Connect to OpenClaw to start")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("MLX-Claw")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ConnectionStatusBadge: View {
    let state: ConnectionState
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: 2)
                        .scaleEffect(state == .connecting ? 1.5 : 1)
                        .opacity(state == .connecting ? 0 : 1)
                        .animation(
                            state == .connecting ?
                            .easeInOut(duration: 1).repeatForever(autoreverses: true) :
                            .default,
                            value: state
                        )
                )
            
            Text(statusText)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    var statusColor: Color {
        switch state {
        case .disconnected:
            return .red
        case .connecting:
            return .yellow
        case .connected:
            return .green
        }
    }
    
    var statusText: String {
        switch state {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        }
    }
}

struct ServerURLInput: View {
    @Binding var url: String
    let isConnecting: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OpenClaw Server")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("ws://localhost:8080", text: $url)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .disabled(isConnecting)
        }
    }
}

struct ConnectButton: View {
    let state: ConnectionState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .cornerRadius(12)
        }
        .disabled(state == .connecting)
    }
    
    var buttonText: String {
        switch state {
        case .disconnected, .connecting:
            return "Connect"
        case .connected:
            return "Disconnect"
        }
    }
    
    var buttonColor: Color {
        switch state {
        case .disconnected:
            return .blue
        case .connecting:
            return .orange
        case .connected:
            return .red
        }
    }
}

struct MLXStatusIndicator: View {
    let isReady: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isReady ? "brain" : "brain.slash")
                .foregroundColor(isReady ? .purple : .gray)
            
            Text(isReady ? "MLX Ready" : "MLX Loading...")
                .font(.subheadline)
                .foregroundColor(isReady ? .purple : .secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FunctionCallHistory: View {
    let calls: [FunctionCall]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Calls")
                .font(.headline)
            
            if calls.isEmpty {
                Text("No function calls yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(calls) { call in
                            FunctionCallCard(call: call)
                        }
                    }
                }
            }
        }
    }
}

struct FunctionCallCard: View {
    let call: FunctionCall
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(call.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                statusBadge
            }
            
            Text(call.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    var statusBadge: some View {
        Text(call.status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    var statusColor: Color {
        switch call.status {
        case .pending:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}
