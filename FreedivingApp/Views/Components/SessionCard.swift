import SwiftUI

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            if type == .breathHoldTest {
                heroCard
            } else {
                standardCard
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hero card (Breath Hold Test — full background image)
    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Background photo
            Image("breath-hold-hero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 168)
                .clipped()

            // Dark gradient overlay so text is readable
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Text over image
            VStack(alignment: .leading, spacing: 6) {
                Text("Breath Hold Test")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text("Tap to test")
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
        }
        .frame(maxWidth: .infinity, minHeight: 168)
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
        .padding(.vertical, Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 168)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.appTextMuted.opacity(0.15), lineWidth: 1)
        )
    }
}
