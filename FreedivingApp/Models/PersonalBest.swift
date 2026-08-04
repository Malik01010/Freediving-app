import Foundation
import SwiftData

@Model
final class PersonalBest {
    var id: UUID
    var seconds: Int
    var date: Date
    var sessionId: UUID?

    init(seconds: Int, sessionId: UUID? = nil) {
        self.id = UUID()
        self.seconds = seconds
        self.date = Date()
        self.sessionId = sessionId
    }
}
