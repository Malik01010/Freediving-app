import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]

    private var completedSessions: [TrainingSession] {
        sessions.filter { $0.completed }
    }

    private var grouped: [(String, [TrainingSession])] {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        let dict = Dictionary(grouping: completedSessions) { session -> String in
            df.string(from: session.date)
        }
        return dict.sorted { a, b in
            let first = completedSessions.first { df.string(from: $0.date) == a.0 }?.date ?? Date.distantPast
            let second = completedSessions.first { df.string(from: $0.date) == b.0 }?.date ?? Date.distantPast
            return first > second
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                if completedSessions.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.appTextMuted)
                        Text("No sessions yet")
                            .font(.appHeadline)
                            .foregroundStyle(Color.appTextSecondary)
                        Text("Complete your first training session to see your history here.")
                            .font(.appBody)
                            .foregroundStyle(Color.appTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                } else {
                    List {
                        ForEach(grouped, id: \.0) { date, daySessions in
                            Section(header:
                                Text(date)
                                    .font(.appCaption)
                                    .foregroundStyle(Color.appTextMuted)
                                    .textCase(nil)
                            ) {
                                ForEach(daySessions) { session in
                                    HistoryRow(session: session)
                                        .listRowBackground(Color.appCard)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HistoryRow: View {
    let session: TrainingSession
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: session.type.icon)
                .foregroundStyle(Color.appTeal)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(session.type.rawValue)
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextPrimary)
                if session.roundsCompleted > 0 {
                    Text("\(session.roundsCompleted) rounds")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            Spacer()
            Text(session.durationSeconds.shortFormattedTime)
                .font(.appCaption)
                .foregroundStyle(Color.appTextMuted)
        }
        .padding(.vertical, Spacing.xs)
    }
}
