import SwiftUI

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {

                // Icon circle — doubled
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
        .buttonStyle(.plain)
    }
}
