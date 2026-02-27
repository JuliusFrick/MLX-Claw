import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("serverURL") private var serverURL: String = "ws://localhost:8080/ws"
    @AppStorage("selectedModel") private var selectedModel: String = "Llama-3.2-3B"
    @AppStorage("temperature") private var temperature: Double = 0.7
    @AppStorage("maxTokens") private var maxTokens: Int = 2048
    
    @State private var showingClearCacheAlert = false
    
    private let models = ["Llama-3.2-3B", "Llama-3.2-1B", "Phi-3.5-Mini", "Mistral-7B", "Qwen-2.5-3B"]
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.l) {
                    serverURLSection
                    modelSelectionSection
                    temperatureSection
                    maxTokensSection
                    clearCacheSection
                    aboutSection
                }
                .padding(AppSpacing.m)
            }
            .background(AppColors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear all cached data. You may need to re-download models.")
        }
    }
    
    private var serverURLSection: some View {
        SettingsSection(title: "Connection") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text("Server URL")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                AppTextField(placeholder: "ws://localhost:8080/ws", text: $serverURL)
            }
        }
    }
    
    private var modelSelectionSection: some View {
        SettingsSection(title: "Model") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                Text("Selected Model")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                Menu {
                    ForEach(models, id: \.self) { model in
                        Button(model) {
                            selectedModel = model
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedModel)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.m)
                    .background(AppColors.surfaceSecondary)
                    .cornerRadius(AppCornerRadius.medium)
                }
            }
        }
    }
    
    private var temperatureSection: some View {
        SettingsSection(title: "Generation") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack {
                    Text("Temperature")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f", temperature))
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.primary)
                }
                
                Slider(value: $temperature, in: 0...2, step: 0.1)
                    .tint(AppColors.primary)
                
                HStack {
                    Text("0.0")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                    Text("2.0")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }
    
    private var maxTokensSection: some View {
        SettingsSection(title: "Generation") {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack {
                    Text("Max Tokens")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(maxTokens)")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.primary)
                }
                
                Stepper("", value: $maxTokens, in: 256...8192, step: 256)
                    .labelsHidden()
                
                HStack {
                    Text("256")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                    Text("8192")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }
    
    private var clearCacheSection: some View {
        SettingsSection(title: "Data") {
            Button {
                showingClearCacheAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(AppColors.error)
                    
                    Text("Clear Cache")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.error)
                    
                    Spacer()
                }
                .padding(AppSpacing.m)
                .background(AppColors.surface)
                .cornerRadius(AppCornerRadius.medium)
            }
        }
    }
    
    private var aboutSection: some View {
        SettingsSection(title: "About") {
            VStack(spacing: AppSpacing.m) {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.primaryGradient)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MLX-Claw")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(AppColors.surfaceTertiary)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Powered by Apple MLX")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text("Local AI inference for iOS")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(AppSpacing.m)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.medium)
        }
    }
    
    private func clearCache() {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? FileManager.default.removeItem(at: cacheURL)
            try? FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text(title.uppercased())
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.xs)
            
            content
        }
    }
}

#Preview {
    SettingsView()
}
