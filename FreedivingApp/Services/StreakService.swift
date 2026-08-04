import SwiftUI
import SwiftData

// MARK: - StreakService
// Computes the current consecutive training-day streak from session history.

struct StreakService {

    /// Returns the number of consecutive calendar days ending today (or yesterday)
    /// on which at least one completed session was recorded.
    static func currentStreak(from sessions: [TrainingSession]) -> Int {
        let completed = sessions.filter { $0.completed }
        guard !completed.isEmpty else { return 0 }

        let calendar = Calendar.current
        // Get unique training days as start-of-day Date values
        let days = Set(completed.map { calendar.startOfDay(for: $0.date) })

        let today = calendar.startOfDay(for: Date())

        // Streak can start from today or yesterday (to not penalise mid-day checks)
        var cursor = days.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today)!

        // If neither today nor yesterday has a session, streak is 0
        guard days.contains(cursor) else { return 0 }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }

    /// Returns session counts bucketed into the last 7 calendar days (index 0 = oldest)
    static func lastSevenDays(from sessions: [TrainingSession]) -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let completed = sessions.filter { $0.completed }
        return (0..<7).reversed().map { offset -> (Date, Int) in
            let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: Date())!)
            let count = completed.filter { calendar.startOfDay(for: $0.date) == day }.count
            return (day, count)
        }
    }
}
