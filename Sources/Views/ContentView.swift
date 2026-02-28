import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var queueService = QueueService.shared
    
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
            
            // Show offline indicator when not connected
            if appViewModel.connectionState != .connected {
                OfflineIndicator(
                    pendingCount: queueService.count,
                    isSyncing: queueService.isSyncing
                )
            }
            
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
                    // Show queued calls count if any
                    if queueService.count > 0 {
                        queuedCallsBanner
                    }
                    
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
    
    private var queuedCallsBanner: some View {
        HStack {
            Image(systemName: "tray.full")
                .foregroundColor(AppColors.offline)
            
            Text("\(queueService.count) call\(queueService.count == 1 ? "" : "s") queued")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.offline)
            
            Spacer()
            
            if queueService.isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.offline))
                    .scaleEffect(0.8)
            }
        }
        .padding(AppSpacing.m)
        .background(AppColors.offline.opacity(0.1))
        .cornerRadius(AppCornerRadius.medium)
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
