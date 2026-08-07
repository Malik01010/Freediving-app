import Foundation
import SwiftData

enum SessionType: String, Codable, CaseIterable {
    case breathHoldTest    = "Breath Hold Test"
    case preBreath         = "Pre Breath"
    case co2Training       = "CO₂ Training"
    case o2Training        = "O₂ Training"
    case emptyLungs        = "Empty Lungs"
    case squareTable       = "Square Table"
    case pranayama         = "Pranayama"
    case diaphragmatic     = "Diaphragmatic"

    var icon: String {
        switch self {
        case .breathHoldTest:  return "stopwatch"
        case .preBreath:       return "wind"
        case .co2Training:     return "lungs"
        case .o2Training:      return "arrow.up.circle"
        case .emptyLungs:      return "arrow.down.circle"
        case .squareTable:     return "square"
        case .pranayama:       return "nose"
        case .diaphragmatic:   return "figure.mind.and.body"
        }
    }

    var totalDurationMinutes: Int {
        switch self {
        case .breathHoldTest:  return 0
        case .preBreath:       return 2
        case .co2Training:     return 10
        case .o2Training:      return 21
        case .emptyLungs:      return 18
        case .squareTable:     return 5
        case .pranayama:       return 5
        case .diaphragmatic:   return 5
        }
    }

    var rounds: Int {
        switch self {
        case .co2Training, .o2Training, .emptyLungs: return 8
        default: return 0
        }
    }
}

@Model
final class TrainingSession {
    var id: UUID
    var type: SessionType
    var date: Date
    var durationSeconds: Int
    var roundsCompleted: Int
    var completed: Bool
    @Relationship(deleteRule: .cascade) var sessionRounds: [SessionRound]

    init(type: SessionType) {
        self.id = UUID()
        self.type = type
        self.date = Date()
        self.durationSeconds = 0
        self.roundsCompleted = 0
        self.completed = false
        self.sessionRounds = []
    }
}
