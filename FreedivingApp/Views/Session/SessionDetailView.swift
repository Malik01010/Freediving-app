import SwiftUI

struct SessionDetailView: View {
    let sessionType: SessionType
    let personalBest: Int
    @State private var showingSession = false
    @State private var showingBreathHoldTest = false
    @Environment(\.dismiss) private var dismiss

    private var rounds: [TrainingRound] {
        switch sessionType {
        case .co2Training:  return TableGeneratorService.co2Table(personalBestSeconds: personalBest)
        case .o2Training:   return TableGeneratorService.o2Table(personalBestSeconds: personalBest)
        case .emptyLungs:   return TableGeneratorService.emptyLungsTable(personalBestSeconds: personalBest)
        default:            return []
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Hero header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Image(systemName: sessionType.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(Color.appTeal)
                        Text(sessionType.rawValue)
                            .font(.appTitle)
                            .foregroundStyle(Color.appTextPrimary)
                        Text(sessionDescription)
                            .font(.appBody)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(Spacing.md)

                    // Stats row
                    if sessionType.totalDurationMinutes > 0 {
                        HStack(spacing: Spacing.md) {
                            StatPill(label: "Duration", value: "\(sessionType.totalDurationMinutes)m")
                            if sessionType.rounds > 0 {
                                StatPill(label: "Rounds", value: "\(sessionType.rounds)")
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    // Round table for training tables
                    if !rounds.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("YOUR TABLE")
                                .font(.appCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appTextMuted)
                                .tracking(1.5)
                                .padding(.horizontal, Spacing.md)

                            VStack(spacing: 1) {
                                // Header
                                HStack {
                                    Text("Round").frame(width: 60, alignment: .leading)
                                    Spacer()
                                    Text("Hold").frame(width: 70, alignment: .center)
                                    Text("Rest").frame(width: 70, alignment: .center)
                                }
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextMuted)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)

                                ForEach(rounds, id: \.roundNumber) { round in
                                    HStack {
                                        Text("\(round.roundNumber)")
                                            .frame(width: 60, alignment: .leading)
                                        Spacer()
                                        Text(round.holdSeconds.formattedTime)
                                            .foregroundStyle(Color.holdColour)
                                            .frame(width: 70, alignment: .center)
                                        Text(round.restSeconds.formattedTime)
                                            .foregroundStyle(Color.restColour)
                                            .frame(width: 70, alignment: .center)
                                    }
                                    .font(.appSubheadline)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                    .background(Color.appCard)
                                }
                            }
                        }
                    }

                    // Start button
                    Button {
                        if sessionType == .breathHoldTest {
                            showingBreathHoldTest = true
                        } else {
                            showingSession = true
                        }
                    } label: {
                        ActionButton(title: "Start Session", style: .primary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingBreathHoldTest) {
            BreathHoldTestView {
                // Dismiss the fullScreenCover first, then pop SessionDetailView
                showingBreathHoldTest = false
                dismiss()
            }
        }
        .fullScreenCover(isPresented: $showingSession) {
            if let breathConfig = BreathingSessionFactory.steps(for: sessionType) {
                BreathingExerciseView(
                    sessionType: sessionType,
                    steps: breathConfig.steps,
                    totalDurationSeconds: breathConfig.totalSeconds
                )
            } else {
                ActiveSessionView(sessionType: sessionType, personalBest: personalBest)
            }
        }
    }

    private var sessionDescription: String {
        switch sessionType {
        case .breathHoldTest:
            return "Test your maximum breath hold. Your result sets the difficulty of all training tables."
        case .preBreath:
            return "2 minutes of controlled breathing to balance your oxygen and carbon dioxide levels before a dive."
        case .co2Training:
            return "8 rounds with a fixed hold time and progressively shorter rest periods. Builds CO₂ tolerance."
        case .o2Training:
            return "8 rounds with a fixed rest period and progressively longer hold times. Improves O₂ efficiency."
        case .emptyLungs:
            return "8 rounds of breath holds after a full exhale. Builds tolerance on residual lung volume."
        case .squareTable:
            return "5 minutes of equal-ratio square breathing: inhale, hold, exhale, hold. Prepares your nervous system."
        case .pranayama:
            return "5 minutes of alternate nostril breathing to calm the mind and open the nasal passages."
        case .diaphragmatic:
            return "5 minutes of belly breathing to activate the parasympathetic nervous system and deeply relax."
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.appHeadline)
                .foregroundStyle(Color.appTeal)
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.appTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
