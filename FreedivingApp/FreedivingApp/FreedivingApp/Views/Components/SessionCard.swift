import SwiftUI

// MARK: - Per-session info descriptions
private let sessionInfo: [SessionType: String] = [
    .co2Training:   "CO₂ table is a series of breath hold sessions that give you less recovery time between each round.",
    .o2Training:    "O₂ table is a series of breath hold sessions that give you more apnea time each round.",
    .emptyLungs:    "Involves breath holding exercises after exhaling fully, increasing your apnea time each round.",
    .squareTable:   "Begin with 5 minutes of square breathing to prepare for the breath hold exercise."
]

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    @State private var showInfo = false

    var body: some View {
        Button(action: onTap) {
            switch type {
            case .breathHoldTest:  photoCard(imageName: "breath-hold-hero",    title: "Breath Hold Test",  subtitle: "Tap to test")
            case .preBreath:       photoCard(imageName: "prebreath-hero",       title: "Pre Breath",        subtitle: "2 min · Controlled breathing")
            case .co2Training:     photoCard(imageName: "co2-hero",             title: "CO₂ Training",      subtitle: "8 rounds · 10 min")
            case .o2Training:      photoCard(imageName: "o2-hero",              title: "O₂ Training",       subtitle: "8 rounds · 21 min")
            case .emptyLungs:      photoCard(imageName: "empty-lungs-hero",     title: "Empty Lungs",       subtitle: "8 rounds · 18 min")
            case .squareTable:     photoCard(imageName: "square-table-hero",    title: "Square Table",      subtitle: "5 min")
            case .pranayama:       photoCard(imageName: "pranayama-hero",       title: "Pranayama",         subtitle: "Alternate nostril breathing")
            case .diaphragmatic:   photoCard(imageName: "diaphragmatic-hero",   title: "Diaphragmatic",     subtitle: "Deep belly breathing")
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Photo hero card
    private func photoCard(imageName: String, title: String, subtitle: String) -> some View {
        let infoText = sessionInfo[type]

        return ZStack(alignment: .bottomLeading) {

            // Background image — fixed 168pt, fills width, crops centre
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .clipped()

            // Dark gradient overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 168)

            // Title + subtitle — bottom left
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)

            // Top-right controls: ⓘ button (if info exists) + chevron
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: Spacing.sm) {
                        // ── Info button ──
                        if infoText != nil {
                            Button {
                                showInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color.white.opacity(0.85))
                                    .frame(width: 36, height: 36)
                                    .background(Color.black.opacity(0.30))
                                    .clipShape(Circle())
                            }
                            // Stop the ⓘ tap propagating to the card's main Button
                            .buttonStyle(.plain)
                            .highPriorityGesture(TapGesture().onEnded { showInfo = true })
                        }

                        // ── Chevron ──
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                    .padding(Spacing.lg)
                }
                Spacer()
            }
            .frame(height: 168)
        }
        .frame(maxWidth: .infinity, minHeight: 168, maxHeight: 168)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        // ── Info sheet ──
        .sheet(isPresented: $showInfo) {
            if let infoText {
                InfoSheet(title: title, description: infoText)
            }
        }
    }

    // MARK: - Standard card (no photo sessions)
    private var standardCard: some View {
        HStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.12))
                    .frame(width: 104, height: 104)
                Image(systemName: type.icon)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.appTeal)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(type.rawValue)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 6) {
                    if type.rounds > 0 {
                        Text("\(type.rounds) rounds")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.appTextSecondary)
                        Text("·")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(Color.appTextMuted)
                    }
                    if type.totalDurationMinutes > 0 {
                        Text("\(type.totalDurationMinutes) min")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.appTextSecondary)
                    } else {
                        Text("Tap to test")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 168, maxHeight: 168)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.appTextMuted.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Info Sheet
struct InfoSheet: View {
    let title: String
    let description: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {

                // Drag handle
                Capsule()
                    .fill(Color.appTextMuted.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, Spacing.md)

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.appTeal.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.appTeal)
                }

                // Title
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                // Description
                Text(description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, Spacing.xl)

                Spacer()

                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Got it")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.appTeal)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        .padding(.horizontal, Spacing.xl)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
