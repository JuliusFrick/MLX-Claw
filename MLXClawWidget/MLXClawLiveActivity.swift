import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

struct MLXActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var connectionState: String
        var isProcessing: Bool
        var pendingQueueCount: Int
        var lastMessage: String?
    }
    
    var serverURL: String
}

// MARK: - Live Activity Widget

@main
struct MLXClawWidgetBundle: WidgetBundle {
    var body: some Widget {
        MLXClawLiveActivity()
    }
}

struct MLXClawLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MLXActivityAttributes.self) { context in
            // Lock screen / banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    connectionIndicator(state: context.state.connectionState)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else if context.state.pendingQueueCount > 0 {
                        Text("\(context.state.pendingQueueCount)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.attributes.serverURL)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    if let message = context.state.lastMessage {
                        Text(message)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            } compactLeading: {
                connectionIndicator(state: context.state.connectionState)
            } compactTrailing: {
                if context.state.isProcessing {
                    ProgressView()
                        .scaleEffect(0.6)
                } else if context.state.pendingQueueCount > 0 {
                    Text("\(context.state.pendingQueueCount)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    Text(context.state.connectionState)
                        .font(.caption2)
                }
            }
        }
    }
    
    @ViewBuilder
    func connectionIndicator(state: String) -> some View {
        let color: Color = {
            switch state {
            case "connected": return .green
            case "connecting": return .orange
            default: return .red
            }
        }()
        
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<MLXActivityAttributes>
    
    var body: some View {
        HStack {
            // Connection status
            HStack(spacing: 8) {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 10, height: 10)
                
                Text(context.state.connectionState)
                    .font(.headline)
            }
            
            Spacer()
            
            // Queue count
            if context.state.pendingQueueCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "tray.full")
                        .font(.caption)
                    Text("\(context.state.pendingQueueCount)")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
            
            // Processing indicator
            if context.state.isProcessing {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    var connectionColor: Color {
        switch context.state.connectionState {
        case "connected": return .green
        case "connecting": return .orange
        default: return .red
        }
    }
}

// MARK: - Live Activity Manager

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<MLXActivityAttributes>?
    
    private init() {}
    
    func startActivity(serverURL: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }
        
        let attributes = MLXActivityAttributes(serverURL: serverURL)
        let initialState = MLXActivityAttributes.ContentState(
            connectionState: "connecting",
            isProcessing: false,
            pendingQueueCount: 0,
            lastMessage: nil
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(connectionState: String, isProcessing: Bool = false, pendingCount: Int = 0, message: String? = nil) {
        guard let activity = currentActivity else { return }
        
        let updatedState = MLXActivityAttributes.ContentState(
            connectionState: connectionState,
            isProcessing: isProcessing,
            pendingQueueCount: pendingCount,
            lastMessage: message
        )
        
        Task {
            await activity.update(
                ActivityContent(state: updatedState, staleDate: nil)
            )
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        let finalState = MLXActivityAttributes.ContentState(
            connectionState: "disconnected",
            isProcessing: false,
            pendingQueueCount: 0,
            lastMessage: nil
        )
        
        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
        }
    }
}
