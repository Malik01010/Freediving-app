import SwiftUI

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {

                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color.appTeal.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: type.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.appTeal)
                }

                // Title + subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: 6) {
                        if type.rounds > 0 {
                            Text("\(type.rounds) rounds")
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextSecondary)
                            Text("·")
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextMuted)
                        }
                        if type.totalDurationMinutes > 0 {
                            Text("\(type.totalDurationMinutes) min")
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextSecondary)
                        } else {
                            Text("Tap to test")
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextMuted)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity)
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
