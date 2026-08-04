import Foundation
import SwiftData

@Model
final class SessionRound {
    var id: UUID
    var roundNumber: Int
    var holdSeconds: Int
    var restSeconds: Int
    var actualHoldSeconds: Int
    var completedHold: Bool

    init(roundNumber: Int, holdSeconds: Int, restSeconds: Int) {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.holdSeconds = holdSeconds
        self.restSeconds = restSeconds
        self.actualHoldSeconds = 0
        self.completedHold = false
    }
}
