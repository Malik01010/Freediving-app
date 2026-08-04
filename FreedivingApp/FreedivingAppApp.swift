import SwiftUI
import SwiftData

@main
struct FreedivingAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            TrainingSession.self,
            SessionRound.self,
            PersonalBest.self
        ])
    }
}
