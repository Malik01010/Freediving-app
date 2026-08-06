import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSession: SessionType?

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

                        // ── Header ──
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Freediver")
                                    .font(.appTitle)
                                    .foregroundStyle(Color.appTextPrimary)
                                Text("PB: \(profile.personalBestSeconds.formattedTime)")
                                    .font(.appCaption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                            if streak > 0 {
                                VStack(spacing: 2) {
                                    Text("\(streak)")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.appTeal)
                                    Text("day streak")
                                        .font(.appCaption)
                                        .foregroundStyle(Color.appTextMuted)
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.appCard)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            }
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
                                ) {
                                    selectedSession = type
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
            .navigationDestination(item: $selectedSession) { type in
                SessionDetailView(sessionType: type, personalBest: profile.personalBestSeconds)
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
