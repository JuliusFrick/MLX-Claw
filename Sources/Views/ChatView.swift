import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            MessageListView(
                messages: viewModel.messages,
                isTyping: viewModel.isTyping
            )
            
            InputView(
                text: $viewModel.inputText,
                isProcessing: viewModel.isProcessing,
                onSend: {
                    viewModel.sendMessage()
                    isInputFocused = true
                }
            )
            .focused($isInputFocused)
        }
        .background(AppColors.background)
    }
}

struct MessageListView: View {
    let messages: [ChatMessage]
    let isTyping: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppSpacing.m) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if isTyping {
                        TypingIndicatorView()
                            .id("typing")
                    }
                }
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
            }
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isTyping) { _, newValue in
                if newValue {
                    withAnimation(AppAnimation.standard) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        withAnimation(AppAnimation.quick) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    private var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.s) {
            if isUser { Spacer(minLength: 60) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: AppSpacing.xs) {
                Text(message.content)
                    .font(AppTypography.body)
                    .foregroundColor(isUser ? .white : AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.vertical, AppSpacing.s)
                    .background(isUser ? AppColors.primary : AppColors.surface)
                    .cornerRadius(AppCornerRadius.large)
                
                if message.isStreaming {
                    TypingDotsView()
                        .padding(.horizontal, AppSpacing.s)
                }
            }
            
            if !isUser { Spacer(minLength: 60) }
        }
        .animation(AppAnimation.standard, value: message.content)
    }
}

struct TypingDotsView: View {
    @State private var animationPhase: Int = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppColors.textTertiary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .opacity(animationPhase == index ? 1 : 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

struct TypingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.s) {
            HStack(spacing: AppSpacing.s) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppColors.textTertiary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.5)
                }
            }
            .padding(.horizontal, AppSpacing.m)
            .padding(.vertical, AppSpacing.s)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.large)
            
            Spacer(minLength: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct InputView: View {
    @Binding var text: String
    let isProcessing: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing.s) {
            TextField("Type a message...", text: $text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.m)
                .padding(.vertical, AppSpacing.s)
                .background(AppColors.surfaceSecondary)
                .cornerRadius(AppCornerRadius.large)
                .disabled(isProcessing)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing {
                        onSend()
                    }
                }
            
            Button(action: onSend) {
                Group {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColors.textTertiary : AppColors.primary)
                    }
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            .animation(AppAnimation.quick, value: text.isEmpty)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(AppColors.surface.opacity(0.95))
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isProcessing: Bool = false
    @Published var isTyping: Bool = false
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: trimmedText)
        messages.append(userMessage)
        inputText = ""
        
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isTyping = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isTyping = false
            self?.isProcessing = false
            
            let assistantMessage = ChatMessage(
                role: .assistant,
                content: "This is a demo response. The MLX service would generate the actual response here."
            )
            self?.messages.append(assistantMessage)
        }
    }
}

#Preview("Chat View") {
    ChatView()
}
