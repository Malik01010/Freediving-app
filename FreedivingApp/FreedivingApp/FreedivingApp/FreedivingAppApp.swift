import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// MARK: - App Entry Point
// ─────────────────────────────────────────────

@main
struct FreedivingAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            TrainingSession.self,
            SessionRound.self,
            PersonalBest.self
        ])
    }
}

// ─────────────────────────────────────────────
// MARK: - Root / Tab Navigation
// ─────────────────────────────────────────────

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Train",    systemImage: "lungs.fill") }
            TrainingProgressView()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
            HistoryView()
                .tabItem { Label("History",  systemImage: "calendar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.appTeal)
        .preferredColorScheme(.dark)
    }
}
