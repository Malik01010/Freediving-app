import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var personalBestSeconds: Int
    var hapticsEnabled: Bool
    var audioCuesEnabled: Bool
    var createdAt: Date

    init(
        personalBestSeconds: Int = 90,
        hapticsEnabled: Bool = true,
        audioCuesEnabled: Bool = true
    ) {
        self.id = UUID()
        self.personalBestSeconds = personalBestSeconds
        self.hapticsEnabled = hapticsEnabled
        self.audioCuesEnabled = audioCuesEnabled
        self.createdAt = Date()
    }
}
