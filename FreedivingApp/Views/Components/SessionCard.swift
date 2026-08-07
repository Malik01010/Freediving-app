import SwiftUI

// MARK: - Per-session info descriptions
private let sessionInfo: [SessionType: String] = [
    .co2Training:   "CO₂ table is a series of breath hold sessions that give you less recovery time between each round.",
    .o2Training:    "O₂ table is a series of breath hold sessions that give you more apnea time each round.",
    .emptyLungs:    "Involves breath holding exercises after exhaling fully, increasing your apnea time each round.",
    .squareTable:   "Begin with 5 minutes of square breathing to prepare for the breath hold exercise."
]

private let tileHeight: CGFloat = 168

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int

    @State private var showInfo = false

    var body: some View {
        // Single flat ZStack — NavigationLink fills the entire 168pt tile.
        // ⓘ button is an overlay anchored top-trailing AFTER the frame is set.
        NavigationLink {
            SessionDetailView(sessionType: type, personalBest: personalBest)
        } label: {
            tileContent
                .frame(maxWidth: .infinity, minHeight: tileHeight, maxHeight: tileHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        // ⓘ button floats top-trailing as an overlay — never inside the NavigationLink
        .overlay(alignment: .topTrailing) {
            if sessionInfo[type] != nil {
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(Spacing.md)
            }
        }
        .sheet(isPresented: $showInfo) {
            if let infoText = sessionInfo[type] {
                InfoSheet(title: type.rawValue, description: infoText)
            }
        }
    }

    // MARK: - Tile content (visual only — no tap logic here)
    @ViewBuilder
    private var tileContent: some View {
        switch type {
        case .breathHoldTest:  photoTile(imageName: "breath-hold-hero",  title: "Breath Hold Test", subtitle: "Tap to test")
        case .preBreath:       photoTile(imageName: "prebreath-hero",     title: "Pre Breath",       subtitle: "2 min · Controlled breathing")
        case .co2Training:     photoTile(imageName: "co2-hero",           title: "CO₂ Training",     subtitle: "8 rounds · 10 min")
        case .o2Training:      photoTile(imageName: "o2-hero",            title: "O₂ Training",      subtitle: "8 rounds · 21 min")
        case .emptyLungs:      photoTile(imageName: "empty-lungs-hero",   title: "Empty Lungs",      subtitle: "8 rounds · 18 min")
        case .squareTable:     photoTile(imageName: "square-table-hero",  title: "Square Table",     subtitle: "5 min")
        case .pranayama:       photoTile(imageName: "pranayama-hero",     title: "Pranayama",        subtitle: "Alternate nostril breathing")
        case .diaphragmatic:   photoTile(imageName: "diaphragmatic-hero", title: "Diaphragmatic",    subtitle: "Deep belly breathing")
        }
    }

    // MARK: - Photo tile (pure visuals)
    private func photoTile(imageName: String, title: String, subtitle: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Hero image — fills exactly 168pt, no overflow
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: tileHeight)
                .clipped()

            // Gradient
            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.5), .black.opacity(0.78)],
                startPoint: .top, endPoint: .bottom
            )

            // Title + subtitle
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)

            // Chevron bottom-right
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(Spacing.lg)
            }
        }
        // Tile is exactly tileHeight — nothing can grow it
        .frame(maxWidth: .infinity, maxHeight: tileHeight)
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
                Capsule()
                    .fill(Color.appTextMuted.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, Spacing.md)

                ZStack {
                    Circle()
                        .fill(Color.appTeal.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.appTeal)
                }

                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, Spacing.xl)

                Spacer()

                Button { dismiss() } label: {
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
