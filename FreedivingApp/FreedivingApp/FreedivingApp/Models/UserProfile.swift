import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var personalBestSeconds: Int
    var hapticsEnabled: Bool
    var audioCuesEnabled: Bool
    var createdAt: Date
    var hasCompletedOnboarding: Bool

    init(
        personalBestSeconds: Int = 0,
        hapticsEnabled: Bool = true,
        audioCuesEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = UUID()
        self.personalBestSeconds = personalBestSeconds
        self.hapticsEnabled = hapticsEnabled
        self.audioCuesEnabled = audioCuesEnabled
        self.createdAt = Date()
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
