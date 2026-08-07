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
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile {
        if let existing = profiles.first { return existing }
        let newProfile = UserProfile()
        modelContext.insert(newProfile)
        return newProfile
    }

    var body: some View {
        if !profile.hasCompletedOnboarding {
            OnboardingView {
                profile.hasCompletedOnboarding = true
            }
        } else {
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
}
