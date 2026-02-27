import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if appViewModel.chatHistory.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .background(AppColors.background)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.m) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No chat history")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Your conversations will appear here")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var historyList: some View {
        List {
            ForEach(appViewModel.chatHistory) { message in
                HistoryRow(message: message)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct HistoryRow: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: message.role == .user ? "person.fill" : "pawprint.fill")
                    .foregroundColor(message.role == .user ? AppColors.primary : AppColors.secondary)
                
                Text(message.role == .user ? "You" : "Assistant")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let date = message.timestamp {
                    Text(date, style: .time)
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Text(message.content)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, AppSpacing.s)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppViewModel())
}
