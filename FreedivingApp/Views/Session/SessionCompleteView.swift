import SwiftUI

struct SessionCompleteView: View {
    let sessionType: SessionType
    let roundsCompleted: Int
    let totalRounds: Int
    let totalSeconds: Int
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.appTeal)

                VStack(spacing: Spacing.sm) {
                    Text("Session Complete")
                        .font(.appTitle)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(sessionType.rawValue)
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                // Stats
                HStack(spacing: Spacing.md) {
                    if totalRounds > 0 {
                        StatPill(label: "Rounds", value: "\(roundsCompleted)/\(totalRounds)")
                    }
                    StatPill(label: "Time", value: totalSeconds.shortFormattedTime)
                }
                .padding(.horizontal, Spacing.md)

                Spacer()

                Button(action: onDismiss) {
                    Text("Done")
                        .font(.appSubheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.appTeal)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}
