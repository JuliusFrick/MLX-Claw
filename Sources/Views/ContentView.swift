import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            messageListArea
            
            inputArea
        }
        .background(AppColors.background)
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: AppSpacing.s) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.primaryGradient)
                
                Text("MLX-Claw")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            ConnectionStatusBadge(status: connectionStatus)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.m)
        .background(AppColors.surface)
    }
    
    private var connectionStatus: ConnectionStatusBadge.ConnectionStatus {
        switch appViewModel.connectionState {
        case .disconnected: return .disconnected
        case .connecting: return .connecting
        case .connected: return .connected
        }
    }
    
    private var messageListArea: some View {
        ScrollView {
            VStack(spacing: AppSpacing.m) {
                if appViewModel.connectionState == .connected {
                    Text("Chat interface coming soon")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, AppSpacing.xxl)
                } else {
                    VStack(spacing: AppSpacing.m) {
                        Image(systemName: "message.badge.circle")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("Connect to start chatting")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, AppSpacing.xxl)
                }
            }
            .padding(.horizontal, AppSpacing.m)
            .padding(.vertical, AppSpacing.l)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var inputArea: some View {
        HStack(spacing: AppSpacing.s) {
            TextField("Type a message...", text: .constant(""))
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
                .background(AppColors.surfaceSecondary)
                .cornerRadius(AppCornerRadius.medium)
                .disabled(appViewModel.connectionState != .connected)
            
            Button {} label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(appViewModel.connectionState == .connected ? AppColors.primary : AppColors.textTertiary)
            }
            .disabled(appViewModel.connectionState != .connected)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.m)
        .background(AppColors.surface)
    }
}
