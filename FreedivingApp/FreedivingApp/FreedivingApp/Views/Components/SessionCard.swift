import SwiftUI

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            switch type {
            case .breathHoldTest:  photoCard(imageName: "breath-hold-hero",    title: "Breath Hold Test",      subtitle: "Tap to test")
            case .preBreath:       photoCard(imageName: "prebreath-hero",       title: "Pre Breath",            subtitle: "2 min · Controlled breathing")
            case .co2Training:     photoCard(imageName: "co2-hero",             title: "CO₂ Training",          subtitle: "8 rounds · 10 min")
            case .o2Training:      photoCard(imageName: "o2-hero",              title: "O₂ Training",           subtitle: "8 rounds · 21 min")
            case .emptyLungs:      photoCard(imageName: "empty-lungs-hero",     title: "Empty Lungs",           subtitle: "8 rounds · 12 min")
            case .squareTable:     photoCard(imageName: "square-table-hero",    title: "Square Table",          subtitle: "8 rounds · 10 min")
            case .pranayama:       photoCard(imageName: "pranayama-hero",       title: "Pranayama",             subtitle: "Alternate nostril breathing")
            case .diaphragmatic:   photoCard(imageName: "diaphragmatic-hero",   title: "Diaphragmatic",         subtitle: "Deep belly breathing")
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Photo hero card
    // Hard-locked to exactly 168pt tall on every tile — no GeometryReader so
    // the ZStack itself drives the height and all cards are identical.
    private func photoCard(imageName: String, title: String, subtitle: String) -> some View {
        ZStack(alignment: .bottomLeading) {

            // Image fills the full width and is clamped to 168pt height.
            // .infinity width + fixed height + scaledToFill + clipped = uniform crop.
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .clipped()

            // Dark gradient — readable text over any photo
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

            // Title + subtitle bottom-left
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

            // Chevron top-right
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
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
    }

    // MARK: - Standard card (all other sessions)
    private var standardCard: some View {
        HStack(spacing: Spacing.lg) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.12))
                    .frame(width: 104, height: 104)
                Image(systemName: type.icon)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.appTeal)
            }

            // Title + subtitle
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

            // Chevron
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
