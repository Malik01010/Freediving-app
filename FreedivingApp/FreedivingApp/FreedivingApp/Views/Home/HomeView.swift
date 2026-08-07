import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile {
        if let existing = profiles.first { return existing }
        let newProfile = UserProfile()
        modelContext.insert(newProfile)
        return newProfile
    }

    private var streak: Int {
        StreakService.currentStreak(from: sessions)
    }

    // Ordered exactly as requested
    private let sessionOrder: [SessionType] = [
        .breathHoldTest,
        .preBreath,
        .co2Training,
        .o2Training,
        .emptyLungs,
        .squareTable,
        .pranayama,
        .diaphragmatic
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {

                        // ── Header: PB + Streak side by side ──
                        HStack(spacing: Spacing.md) {

                            // Personal Best card
                            VStack(spacing: 4) {
                                Text(profile.personalBestSeconds > 0
                                     ? profile.personalBestSeconds.formattedTime
                                     : "--:--")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.appTeal)
                                    .monospacedDigit()
                                Text("Personal Best")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.appTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.appCard)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))

                            // Daily streak card
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Text(streak > 0 ? "\(streak)" : "0")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(streak > 0 ? Color.appTeal : Color.appTextMuted)
                                    if streak > 0 {
                                        Text("🔥")
                                            .font(.system(size: 22))
                                    }
                                }
                                Text("Day Streak")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.appTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.appCard)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                        // ── Weekly dots ──
                        WeeklyActivityRow(sessions: sessions)
                            .padding(.horizontal, Spacing.md)

                        // ── Full-width stacked session tiles ──
                        VStack(spacing: Spacing.sm) {
                            ForEach(sessionOrder, id: \.self) { type in
                                SessionCard(
                                    type: type,
                                    personalBest: profile.personalBestSeconds
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
        }
    }
}

// MARK: - Weekly Activity Row
struct WeeklyActivityRow: View {
    let sessions: [TrainingSession]

    private var days: [(date: Date, count: Int)] {
        StreakService.lastSevenDays(from: sessions)
    }

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.date) { day in
                VStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(day.count > 0 ? Color.appTeal : Color.appCard)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle().stroke(
                                day.count > 0 ? Color.appTeal : Color.appTextMuted.opacity(0.3),
                                lineWidth: 1
                            )
                        )
                    Text(dayFormatter.string(from: day.date))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(day.count > 0 ? Color.appTextSecondary : Color.appTextMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.md)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.appCaption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.appTextMuted)
            .tracking(1.5)
            .padding(.horizontal, Spacing.md)
    }
}
