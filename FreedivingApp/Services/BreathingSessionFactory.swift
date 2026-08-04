import Foundation

// MARK: - Breathing Session Factory
// Returns the step sequence and total duration for each guided breathing session type.

struct BreathingSessionFactory {

    // Pre Breath — 2 min: slow 4-4-6 breathing (inhale 4s, hold 4s, exhale 6s)
    static func preBreath() -> (steps: [BreathingExerciseStep], totalSeconds: Int) {
        let cycle: [BreathingExerciseStep] = [
            .init(phase: .inhale,   durationSeconds: 4),
            .init(phase: .holdFull, durationSeconds: 4),
            .init(phase: .exhale,   durationSeconds: 6),
        ]
        return (cycle, 120)
    }

    // Square Table — 5 min: 5-5-5-5 box breathing
    static func squareTable() -> (steps: [BreathingExerciseStep], totalSeconds: Int) {
        let cycle: [BreathingExerciseStep] = [
            .init(phase: .inhale,    durationSeconds: 5),
            .init(phase: .holdFull,  durationSeconds: 5),
            .init(phase: .exhale,    durationSeconds: 5),
            .init(phase: .holdEmpty, durationSeconds: 5),
        ]
        return (cycle, 300)
    }

    // Pranayama — 5 min: alternate nostril 4-4-4-4
    // Left nostril inhale, hold, right nostril exhale, right inhale, hold, left exhale
    static func pranayama() -> (steps: [BreathingExerciseStep], totalSeconds: Int) {
        let cycle: [BreathingExerciseStep] = [
            .init(phase: .inhale,    durationSeconds: 4, label: "LEFT NOSTRIL"),
            .init(phase: .holdFull,  durationSeconds: 4, label: "HOLD"),
            .init(phase: .exhale,    durationSeconds: 4, label: "RIGHT NOSTRIL"),
            .init(phase: .inhale,    durationSeconds: 4, label: "RIGHT NOSTRIL"),
            .init(phase: .holdFull,  durationSeconds: 4, label: "HOLD"),
            .init(phase: .exhale,    durationSeconds: 4, label: "LEFT NOSTRIL"),
        ]
        return (cycle, 300)
    }

    // Diaphragmatic — 5 min: belly breathing 4-0-8 (no hold, long exhale)
    static func diaphragmatic() -> (steps: [BreathingExerciseStep], totalSeconds: Int) {
        let cycle: [BreathingExerciseStep] = [
            .init(phase: .inhale, durationSeconds: 4, label: "BELLY IN"),
            .init(phase: .exhale, durationSeconds: 8, label: "BELLY OUT"),
        ]
        return (cycle, 300)
    }

    static func steps(for type: SessionType) -> (steps: [BreathingExerciseStep], totalSeconds: Int)? {
        switch type {
        case .preBreath:       return preBreath()
        case .squareTable:     return squareTable()
        case .pranayama:       return pranayama()
        case .diaphragmatic:   return diaphragmatic()
        default:               return nil
        }
    }
}
