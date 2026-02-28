import SwiftUI

// MARK: - Design System for MLX-Claw

// MARK: - Colors
enum AppColors {
    // Primary palette
    static let primary = Color(hex: "007AFF")
    static let secondary = Color(hex: "5856D6")
    static let accent = Color(hex: "34C759")
    static let error = Color(hex: "FF3B30")
    static let warning = Color(hex: "FF9500")
    
    // Backgrounds
    static let background = Color(hex: "000000") // Dark mode default
    static let surface = Color(hex: "1C1C1E")
    static let surfaceSecondary = Color(hex: "2C2C2E")
    static let surfaceTertiary = Color(hex: "3A3A3C")
    
    // Text
    static let textPrimary = Color(hex: "FFFFFF")
    static let textSecondary = Color(hex: "8E8E93")
    static let textTertiary = Color(hex: "636366")
    
    // Status
    static let connected = Color(hex: "34C759")
    static let connecting = Color(hex: "FF9500")
    static let disconnected = Color(hex: "FF3B30")
    static let offline = Color(hex: "FF9500")
    
    // Gradient
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
enum AppTypography {
    // Large Title
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    // Title
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    // Headlines
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 15, weight: .semibold, design: .default)
    // Body
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    // Callout
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    // Caption
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    // Monospace (for code)
    static let monospace = Font.system(size: 14, weight: .regular, design: .monospaced)
}

// MARK: - Spacing (8pt grid)
enum AppSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 9999
}

// MARK: - Shadows
enum AppShadows {
    static let small = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let large = ShadowStyle(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation
enum AppAnimation {
    static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
    static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
    static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
}

// MARK: - Component Styles

// Connection Status Badge
struct ConnectionStatusBadge: View {
    let status: ConnectionStatus
    
    enum ConnectionStatus {
        case connected, connecting, disconnected
        
        var color: Color {
            switch self {
            case .connected: return AppColors.connected
            case .connecting: return AppColors.connecting
            case .disconnected: return AppColors.disconnected
            }
        }
        
        var text: String {
            switch self {
            case .connected: return "Connected"
            case .connecting: return "Connecting..."
            case .disconnected: return "Disconnected"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(status.color.opacity(0.3), lineWidth: 2)
                        .scaleEffect(status == .connecting ? 1.5 : 1.0)
                        .opacity(status == .connecting ? 0 : 1)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: status)
                )
            
            Text(status.text)
                .font(AppTypography.caption1)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(status.color.opacity(0.1))
        .cornerRadius(AppCornerRadius.full)
    }
}

// Offline Indicator Badge
struct OfflineIndicator: View {
    let pendingCount: Int
    let isSyncing: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.s) {
            if isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.offline))
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 12, weight: .semibold))
            }
            
            if isSyncing {
                Text("Syncing...")
                    .font(AppTypography.caption1)
            } else if pendingCount > 0 {
                Text("\(pendingCount) pending")
                    .font(AppTypography.caption1)
            } else {
                Text("Offline")
                    .font(AppTypography.caption1)
            }
        }
        .foregroundColor(AppColors.offline)
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(AppColors.offline.opacity(0.1))
        .cornerRadius(AppCornerRadius.full)
    }
}

// Function Call Card
struct FunctionCallCard: View {
    let title: String
    let subtitle: String
    let timestamp: Date
    let status: FunctionStatus
    
    enum FunctionStatus {
        case pending, executing, success, failed, queued
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack {
                Image(systemName: "function")
                    .foregroundColor(AppColors.primary)
                
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                statusBadge
            }
            
            Text(subtitle)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
            
            Text(timeAgo(timestamp))
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(AppSpacing.m)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.large)
    }
    
    @ViewBuilder
    var statusBadge: some View {
        let (color, icon) = {
            switch status {
            case .pending: return (AppColors.warning, "clock")
            case .executing: return (AppColors.primary, "arrow.triangle.2.circlepath")
            case .success: return (AppColors.connected, "checkmark.circle.fill")
            case .failed: return (AppColors.error, "xmark.circle.fill")
            case .queued: return (AppColors.offline, "tray.full")
            }
        }()
        
        Image(systemName: icon)
            .foregroundColor(color)
            .font(.system(size: 14))
    }
    
    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppTypography.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.m)
            .background(AppColors.primaryGradient)
            .cornerRadius(AppCornerRadius.medium)
        }
    }
}

// Input Field
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(AppTypography.body)
            .foregroundColor(AppColors.textPrimary)
            .padding(AppSpacing.m)
            .background(AppColors.surfaceSecondary)
            .cornerRadius(AppCornerRadius.medium)
    }
}

// Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text(title)
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
            
            VStack(spacing: AppSpacing.s) {
                content
            }
            .padding(AppSpacing.m)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.medium)
        }
    }
}
