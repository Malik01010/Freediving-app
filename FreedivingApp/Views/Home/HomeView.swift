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

    private var recentSessionCount: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.date >= sevenDaysAgo }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Freediver")
                                .font(.appTitle)
                                .foregroundStyle(Color.appTextPrimary)
                            Text("PB: \(profile.personalBestSeconds.formattedTime)  ·  \(recentSessionCount) sessions this week")
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                        // Preparation
                        SectionHeader(title: "PREPARATION")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                            ForEach([SessionType.breathHoldTest, .preBreath, .squareTable, .pranayama, .diaphragmatic], id: \.self) { type in
                                SessionCard(type: type, personalBest: profile.personalBestSeconds) {
                                    selectedSession = type
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)

                        // Training Tables
                        SectionHeader(title: "TRAINING TABLES")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                            ForEach([SessionType.co2Training, .o2Training, .emptyLungs], id: \.self) { type in
                                SessionCard(type: type, personalBest: profile.personalBestSeconds) {
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
