import CoreHaptics
import UIKit

// MARK: - Haptic Service
// Provides distinct haptic patterns for session phase transitions.

final class HapticService {

    private var engine: CHHapticEngine?

    init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            // Haptics unavailable — silently degrade
        }
    }

    // Heavy single tap — "Hold begins"
    func playHoldStart() {
        playPattern(intensity: 1.0, sharpness: 0.5, count: 1)
    }

    // Two medium taps — "Rest begins"
    func playRestStart() {
        playPattern(intensity: 0.7, sharpness: 0.3, count: 2)
    }

    // Three light taps — "Session complete"
    func playSessionComplete() {
        playPattern(intensity: 0.5, sharpness: 0.2, count: 3)
    }

    // Warning tap — 5 seconds remaining
    func playWarning() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    private func playPattern(intensity: Float, sharpness: Float, count: Int) {
        guard let engine else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        do {
            var events: [CHHapticEvent] = []
            for i in 0..<count {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                    ],
                    relativeTime: Double(i) * 0.15
                )
                events.append(event)
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
