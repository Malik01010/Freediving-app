import SwiftUI

// MARK: - Animated Breath Guide Circle
// Expands on inhale, holds, contracts on exhale.
// Drives all four breathing exercise screens.

struct BreathGuideCircle: View {
    let phase: BreathGuidePhase
    let progress: Double  // 0→1 within current phase

    private var scale: CGFloat {
        switch phase {
        case .inhale:         return 0.5 + (0.5 * progress)    // 0.5 → 1.0
        case .holdFull:       return 1.0
        case .exhale:         return 1.0 - (0.5 * progress)    // 1.0 → 0.5
        case .holdEmpty:      return 0.5
        }
    }

    private var opacity: Double {
        switch phase {
        case .inhale:         return 0.3 + (0.4 * progress)
        case .holdFull:       return 0.7
        case .exhale:         return 0.7 - (0.4 * progress)
        case .holdEmpty:      return 0.3
        }
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(phase.color.opacity(opacity * 0.3))
                .frame(width: 220, height: 220)
                .scaleEffect(scale + 0.1)

            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [phase.color.opacity(opacity), phase.color.opacity(opacity * 0.4)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 110
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 0.3), value: scale)
        }
    }
}

enum BreathGuidePhase: Equatable {
    case inhale, holdFull, exhale, holdEmpty

    var label: String {
        switch self {
        case .inhale:    return "INHALE"
        case .holdFull:  return "HOLD"
        case .exhale:    return "EXHALE"
        case .holdEmpty: return "HOLD"
        }
    }

    var color: Color {
        switch self {
        case .inhale:    return .restColour
        case .holdFull:  return .holdColour
        case .exhale:    return .appTeal
        case .holdEmpty: return .warningColour
        }
    }

    var instruction: String {
        switch self {
        case .inhale:    return "Breathe in slowly through your nose"
        case .holdFull:  return "Hold gently, stay relaxed"
        case .exhale:    return "Release slowly through your mouth"
        case .holdEmpty: return "Stay empty, soft belly"
        }
    }
}
