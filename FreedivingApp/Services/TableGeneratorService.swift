import Foundation

// MARK: - Table Generator Service
// Dynamically generates CO₂, O₂ and Empty Lungs training tables
// based on the user's personal best (PB) breath hold time.

struct TrainingRound {
    let roundNumber: Int
    let holdSeconds: Int
    let restSeconds: Int
}

struct TableGeneratorService {

    // CO₂ Table — fixed hold at 50% PB, rest decreases by 15s each round
    static func co2Table(personalBestSeconds pb: Int) -> [TrainingRound] {
        let hold = max(20, pb / 2)
        return (1...8).map { round in
            let rest = max(20, pb - (round - 1) * 15)
            return TrainingRound(roundNumber: round, holdSeconds: hold, restSeconds: rest)
        }
    }

    // O₂ Table — rest fixed at 120s, hold increases by 15s each round starting at 50% PB
    static func o2Table(personalBestSeconds pb: Int) -> [TrainingRound] {
        let baseHold = max(20, pb / 2)
        return (1...8).map { round in
            let hold = baseHold + (round - 1) * 15
            return TrainingRound(roundNumber: round, holdSeconds: hold, restSeconds: 120)
        }
    }

    // Empty Lungs Table — rest fixed at 120s, hold increases by 10s each round starting at 30% PB
    static func emptyLungsTable(personalBestSeconds pb: Int) -> [TrainingRound] {
        let baseHold = max(10, Int(Double(pb) * 0.3))
        return (1...8).map { round in
            let hold = baseHold + (round - 1) * 10
            return TrainingRound(roundNumber: round, holdSeconds: hold, restSeconds: 120)
        }
    }

    // Total session duration in seconds for a given table
    static func totalDuration(rounds: [TrainingRound]) -> Int {
        rounds.reduce(0) { $0 + $1.holdSeconds + $1.restSeconds }
    }
}

// MARK: - Time Formatting
extension Int {
    /// Formats seconds as MM:SS
    var formattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formats seconds as "Xm Ys" for display
    var shortFormattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        if minutes == 0 { return "\(seconds)s" }
        if seconds == 0 { return "\(minutes)m" }
        return "\(minutes)m \(seconds)s"
    }
}
