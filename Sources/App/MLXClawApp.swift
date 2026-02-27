import SwiftUI

@main
struct MLXClawApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(0)
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(AppColors.primary)
            .environmentObject(appViewModel)
        }
    }
}
