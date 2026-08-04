import SwiftUI

// Reusable large countdown ring used on the timer screen
struct CountdownRing: View {
    let progress: Double   // 0.0 → 1.0
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
}

// Phase label pill (BREATHE / HOLD / REST / EXHALE)
struct PhasePill: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .tracking(2)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// Round badge
struct RoundBadge: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("Round \(current) of \(total)")
            .font(.appSubheadline)
            .foregroundStyle(Color.appTextSecondary)
    }
}
