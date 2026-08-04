import SwiftUI

struct SessionCard: View {
    let type: SessionType
    let personalBest: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.appTeal)
                    Spacer()
                    if type.totalDurationMinutes > 0 {
                        Text("\(type.totalDurationMinutes)m")
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextMuted)
                    }
                }
                Text(type.rawValue)
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)

                if type.rounds > 0 {
                    Text("\(type.rounds) rounds")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.appTextMuted.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
