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

    private var streak: Int {
        StreakService.currentStreak(from: sessions)
    }

    private var weeklyData: [(date: Date, count: Int)] {
        StreakService.lastSevenDays(from: sessions)
    }

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {

                        // Summary stats
                        HStack(spacing: Spacing.sm) {
                            StatPill(label: "Streak", value: streak > 0 ? "\(streak)d" : "–")
                            StatPill(label: "This Week", value: "\(thisWeekCount)")
                            StatPill(label: "Total Time", value: "\(totalMinutes)m")
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                        // Weekly sessions bar chart
                        ChartSection(title: "SESSIONS THIS WEEK") {
                            Chart(weeklyData, id: \.date) { day in
                                BarMark(
                                    x: .value("Day", dayFormatter.string(from: day.date)),
                                    y: .value("Sessions", day.count)
                                )
                                .foregroundStyle(
                                    day.count > 0 ? Color.appTeal : Color.appCard
                                )
                                .cornerRadius(4)
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel()
                                        .foregroundStyle(Color.appTextMuted)
                                        .font(.appCaption)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .stride(by: 1)) { value in
                                    AxisValueLabel {
                                        if let v = value.as(Int.self) {
                                            Text("\(v)")
                                                .foregroundStyle(Color.appTextMuted)
                                                .font(.appCaption)
                                        }
                                    }
                                    AxisGridLine().foregroundStyle(Color.appTextMuted.opacity(0.1))
                                }
                            }
                            .frame(height: 140)
                        }

                        // Personal Best line chart
                        if personalBests.count >= 2 {
                            ChartSection(title: "PERSONAL BEST OVER TIME") {
                                Chart(personalBests) { pb in
                                    LineMark(
                                        x: .value("Date", pb.date),
                                        y: .value("Seconds", pb.seconds)
                                    )
                                    .foregroundStyle(Color.appTeal)
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 2))

                                    AreaMark(
                                        x: .value("Date", pb.date),
                                        y: .value("Seconds", pb.seconds)
                                    )
                                    .foregroundStyle(Color.appTeal.opacity(0.08))

                                    PointMark(
                                        x: .value("Date", pb.date),
                                        y: .value("Seconds", pb.seconds)
                                    )
                                    .foregroundStyle(Color.appTeal)
                                    .symbolSize(30)
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color.appTextMuted)
                                            .font(.appCaption)
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
                                        AxisGridLine().foregroundStyle(Color.appTextMuted.opacity(0.1))
                                    }
                                }
                                .frame(height: 180)
                            }
                        } else {
                            EmptyChartPlaceholder(
                                message: "Complete a Breath Hold Test to start tracking your PB"
                            )
                        }

                        // Sessions by type breakdown
                        if !completedSessions.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                SectionHeader(title: "SESSIONS BY TYPE")

                                let grouped = Dictionary(grouping: completedSessions, by: \.type)
                                ForEach(SessionType.allCases, id: \.self) { type in
                                    if let count = grouped[type]?.count, count > 0 {
                                        HStack(spacing: Spacing.md) {
                                            Image(systemName: type.icon)
                                                .foregroundStyle(Color.appTeal)
                                                .frame(width: 24)
                                            Text(type.rawValue)
                                                .font(.appBody)
                                                .foregroundStyle(Color.appTextPrimary)
                                            Spacer()
                                            // Mini bar
                                            let max = grouped.values.map(\.count).max() ?? 1
                                            GeometryReader { geo in
                                                Capsule()
                                                    .fill(Color.appTeal.opacity(0.2))
                                                    .frame(width: geo.size.width)
                                                Capsule()
                                                    .fill(Color.appTeal)
                                                    .frame(width: geo.size.width * (CGFloat(count) / CGFloat(max)))
                                            }
                                            .frame(width: 60, height: 6)

                                            Text("\(count)")
                                                .font(.appSubheadline)
                                                .foregroundStyle(Color.appTeal)
                                                .frame(width: 24, alignment: .trailing)
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

// MARK: - Chart Section wrapper
struct ChartSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: title)
            content()
                .padding(Spacing.md)
                .background(Color.appCard)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Empty chart placeholder
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
