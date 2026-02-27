import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var serverURL: String = "ws://localhost:8080/ws"
    @State private var notificationGranted: Bool = false
    @State private var calendarGranted: Bool = false
    @State private var isRequestingPermissions: Bool = false
    
    private let pushNotificationService = PushNotificationService.shared
    private let calendarService = CalendarService()
    private let storageService = StorageService.shared
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case serverURL = 1
        case notifications = 2
        case calendar = 3
        case complete = 4
        
        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .serverURL: return "Server Setup"
            case .notifications: return "Notifications"
            case .calendar: return "Calendar"
            case .complete: return "Complete"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            progressIndicator
            
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    stepContent
                }
                .padding(.horizontal, AppSpacing.l)
                .padding(.top, AppSpacing.xl)
            }
            
            bottomButton
        }
        .background(AppColors.background)
    }
    
    private var progressIndicator: some View {
        HStack(spacing: AppSpacing.s) {
            ForEach(OnboardingStep.allCases.dropLast(), id: \.rawValue) { step in
                Rectangle()
                    .fill(currentStep.rawValue >= step.rawValue ? AppColors.primary : AppColors.surfaceSecondary)
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal, AppSpacing.l)
        .padding(.top, AppSpacing.m)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .welcome:
            welcomeStep
        case .serverURL:
            serverURLStep
        case .notifications:
            notificationsStep
        case .calendar:
            calendarStep
        case .complete:
            completeStep
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer()
            
            Image(systemName: "pawprint.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primaryGradient)
            
            Text("MLX-Claw")
                .font(AppTypography.largeTitle)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Your AI-powered assistant that connects to your server to help manage tasks, calendars, and more.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.m)
            
            Spacer()
        }
    }
    
    private var serverURLStep: some View {
        VStack(spacing: AppSpacing.l) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)
                .padding(.top, AppSpacing.xl)
            
            Text("Connect to Your Server")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Enter your WebSocket server URL to connect.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            AppTextField(placeholder: "ws://localhost:8080/ws", text: $serverURL)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
            
            Text("You can change this later in Settings.")
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
            
            Spacer()
        }
    }
    
    private var notificationsStep: some View {
        VStack(spacing: AppSpacing.l) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)
                .padding(.top, AppSpacing.xl)
            
            Text("Enable Notifications")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Stay informed with push notifications for important updates and messages.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if notificationGranted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.connected)
                    Text("Notifications enabled")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.connected)
                }
                .padding(AppSpacing.m)
                .background(AppColors.connected.opacity(0.1))
                .cornerRadius(AppCornerRadius.medium)
            }
        }
    }
    
    private var calendarStep: some View {
        VStack(spacing: AppSpacing.l) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)
                .padding(.top, AppSpacing.xl)
            
            Text("Access Your Calendar")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Allow calendar access to create events and manage your schedule.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if calendarGranted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.connected)
                    Text("Calendar access enabled")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.connected)
                }
                .padding(AppSpacing.m)
                .background(AppColors.connected.opacity(0.1))
                .cornerRadius(AppCornerRadius.medium)
            }
        }
    }
    
    private var completeStep: some View {
        VStack(spacing: AppSpacing.l) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.connected)
            
            Text("You're All Set!")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)
            
            Text("MLX-Claw is ready to help you get things done.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    private var bottomButton: some View {
        VStack(spacing: AppSpacing.m) {
            if currentStep == .notifications && !notificationGranted {
                PrimaryButton("Enable Notifications", icon: "bell.fill") {
                    requestNotificationPermission()
                }
            } else if currentStep == .calendar && !calendarGranted {
                PrimaryButton("Enable Calendar Access", icon: "calendar") {
                    requestCalendarPermission()
                }
            } else if currentStep != .complete {
                PrimaryButton(buttonTitle) {
                    proceedToNextStep()
                }
            } else {
                PrimaryButton("Get Started", icon: "arrow.right") {
                    completeOnboarding()
                }
            }
            
            if currentStep != .welcome && currentStep != .complete {
                Button("Skip") {
                    skipCurrentStep()
                }
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.l)
        .padding(.bottom, AppSpacing.l)
    }
    
    private var buttonTitle: String {
        switch currentStep {
        case .welcome: return "Get Started"
        case .serverURL: return "Continue"
        case .notifications: return "Continue"
        case .calendar: return "Continue"
        case .complete: return "Get Started"
        }
    }
    
    private func proceedToNextStep() {
        withAnimation(AppAnimation.standard) {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    private func skipCurrentStep() {
        withAnimation(AppAnimation.standard) {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            isRequestingPermissions = true
            notificationGranted = await pushNotificationService.requestAuthorization()
            if notificationGranted {
                pushNotificationService.registerForRemoteNotifications()
            }
            isRequestingPermissions = false
        }
    }
    
    private func requestCalendarPermission() {
        Task {
            isRequestingPermissions = true
            do {
                calendarGranted = try await calendarService.requestAccess()
            } catch {
                calendarGranted = false
            }
            isRequestingPermissions = false
        }
    }
    
    private func completeOnboarding() {
        storageService.saveServerURL(serverURL)
        hasCompletedOnboarding = true
    }
}

#Preview("Onboarding") {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
