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
    // Drives the switch — @State guarantees an immediate redraw when set
    @State private var onboardingDone = false

    var body: some View {
        Group {
            if onboardingDone {
                mainTabView
            } else {
                OnboardingView {
                    // 1. Persist to SwiftData
                    if let p = profiles.first {
                        p.hasCompletedOnboarding = true
                    } else {
                        let p = UserProfile()
                        p.hasCompletedOnboarding = true
                        modelContext.insert(p)
                    }
                    // 2. Flip state → triggers immediate redraw to mainTabView
                    onboardingDone = true
                }
            }
        }
        // On every launch after the first, skip onboarding immediately
        .onAppear {
            if profiles.first?.hasCompletedOnboarding == true {
                onboardingDone = true
            }
        }
        .preferredColorScheme(.dark)
    }

    private var mainTabView: some View {
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
    }
}
