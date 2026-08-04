import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Query(sort: \PersonalBest.date) private var personalBests: [PersonalBest]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]

    private var completedSessions: [TrainingSession] {
        sessions.filter { $0.completed }
    }

    private var thisWeekCount: Int {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return completedSessions.filter { $0.date >= start }.count
    }

    private var totalMinutes: Int {
        completedSessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {

                        // Summary pills
                        HStack(spacing: Spacing.sm) {
                            StatPill(label: "This Week", value: "\(thisWeekCount)")
                            StatPill(label: "Total Sessions", value: "\(completedSessions.count)")
                            StatPill(label: "Total Time", value: "\(totalMinutes)m")
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                        // Personal Best chart
                        if personalBests.count >= 2 {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("PERSONAL BEST OVER TIME")
                                    .font(.appCaption).fontWeight(.semibold)
                                    .foregroundStyle(Color.appTextMuted)
                                    .tracking(1.5)
                                    .padding(.horizontal, Spacing.md)

                                Chart(personalBests) { pb in
                                    LineMark(
                                        x: .value("Date", pb.date),
                                        y: .value("Seconds", pb.seconds)
                                    )
                                    .foregroundStyle(Color.appTeal)
                                    .interpolationMethod(.catmullRom)

                                    AreaMark(
                                        x: .value("Date", pb.date),
                                        y: .value("Seconds", pb.seconds)
                                    )
                                    .foregroundStyle(Color.appTeal.opacity(0.1))
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic) {
                                        AxisValueLabel().foregroundStyle(Color.appTextMuted)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(values: .automatic) { value in
                                        AxisValueLabel {
                                            if let seconds = value.as(Int.self) {
                                                Text(seconds.formattedTime)
                                                    .foregroundStyle(Color.appTextMuted)
                                                    .font(.appCaption)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 180)
                                .padding(Spacing.md)
                                .background(Color.appCard)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .padding(.horizontal, Spacing.md)
                            }
                        } else {
                            EmptyChartPlaceholder(message: "Complete a Breath Hold Test to start tracking your PB")
                        }

                        // Sessions per type
                        if !completedSessions.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("SESSIONS BY TYPE")
                                    .font(.appCaption).fontWeight(.semibold)
                                    .foregroundStyle(Color.appTextMuted)
                                    .tracking(1.5)
                                    .padding(.horizontal, Spacing.md)

                                let grouped = Dictionary(grouping: completedSessions, by: \.type)
                                ForEach(SessionType.allCases, id: \.self) { type in
                                    if let count = grouped[type]?.count, count > 0 {
                                        HStack {
                                            Image(systemName: type.icon)
                                                .foregroundStyle(Color.appTeal)
                                                .frame(width: 24)
                                            Text(type.rawValue)
                                                .font(.appBody)
                                                .foregroundStyle(Color.appTextPrimary)
                                            Spacer()
                                            Text("\(count)")
                                                .font(.appSubheadline)
                                                .foregroundStyle(Color.appTeal)
                                        }
                                        .padding(Spacing.sm)
                                        .background(Color.appCard)
                                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                                        .padding(.horizontal, Spacing.md)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: Spacing.xl)
                    }
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EmptyChartPlaceholder: View {
    let message: String
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundStyle(Color.appTextMuted)
            Text(message)
                .font(.appBody)
                .foregroundStyle(Color.appTextMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .padding(.horizontal, Spacing.md)
    }
}
