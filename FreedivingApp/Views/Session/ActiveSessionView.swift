import SwiftUI
import SwiftData

enum SessionPhase {
    case hold, rest, breathe, exhale, complete
    var label: String {
        switch self {
        case .hold:     return "HOLD"
        case .rest:     return "BREATHE"
        case .breathe:  return "BREATHE"
        case .exhale:   return "EXHALE"
        case .complete: return "DONE"
        }
    }
    var color: Color {
        switch self {
        case .hold:     return .holdColour
        case .rest:     return .restColour
        case .breathe:  return .restColour
        case .exhale:   return .warningColour
        case .complete: return .appTeal
        }
    }
}

struct ActiveSessionView: View {
    let sessionType: SessionType
    let personalBest: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentRound = 1
    @State private var phase: SessionPhase = .rest
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var sessionComplete = false
    @State private var currentSession: TrainingSession?
    @State private var showExitConfirm = false

    private let haptics = HapticService()
    private let audio = AudioCueService()

    private var rounds: [TrainingRound] {
        switch sessionType {
        case .co2Training:  return TableGeneratorService.co2Table(personalBestSeconds: personalBest)
        case .o2Training:   return TableGeneratorService.o2Table(personalBestSeconds: personalBest)
        case .emptyLungs:   return TableGeneratorService.emptyLungsTable(personalBestSeconds: personalBest)
        default:            return []
        }
    }

    private var totalRounds: Int { max(rounds.count, 1) }

    private var progress: Double {
        guard secondsRemaining > 0, let currentPhaseTotal = currentPhaseTotal else { return 0 }
        return 1.0 - (Double(secondsRemaining) / Double(currentPhaseTotal))
    }

    private var currentPhaseTotal: Int? {
        guard currentRound <= rounds.count else { return nil }
        let round = rounds[currentRound - 1]
        return phase == .hold ? round.holdSeconds : round.restSeconds
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if sessionComplete {
                SessionCompleteView(
                    sessionType: sessionType,
                    roundsCompleted: currentRound - 1,
                    totalRounds: totalRounds,
                    totalSeconds: totalSeconds
                ) {
                    dismiss()
                }
            } else {
                VStack(spacing: Spacing.xl) {
                    // Top bar
                    HStack {
                        Button { showExitConfirm = true } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.appTextMuted)
                        }
                        Spacer()
                        if !rounds.isEmpty {
                            RoundBadge(current: min(currentRound, totalRounds), total: totalRounds)
                        }
                        Spacer()
                        // balance
                        Color.clear.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    Spacer()

                    // Timer ring
                    ZStack {
                        CountdownRing(
                            progress: progress,
                            color: phase.color,
                            lineWidth: 12
                        )
                        .frame(width: 260, height: 260)

                        VStack(spacing: Spacing.sm) {
                            PhasePill(label: phase.label, color: phase.color)
                            Text(secondsRemaining.formattedTime)
                                .font(.timerLarge)
                                .foregroundStyle(Color.appTextPrimary)
                                .monospacedDigit()
                        }
                    }

                    Spacer()

                    // Controls
                    HStack(spacing: Spacing.xl) {
                        Button {
                            isRunning ? pauseTimer() : startTimer()
                        } label: {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.appTeal)
                                .frame(width: 64, height: 64)
                                .background(Color.appCard)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .onAppear(perform: setupSession)
        .alert("End Session?", isPresented: $showExitConfirm) {
            Button("End Session", role: .destructive) { saveAndDismiss() }
            Button("Keep Going", role: .cancel) {}
        }
    }

    // MARK: - Session Setup
    private func setupSession() {
        let session = TrainingSession(type: sessionType)
        modelContext.insert(session)
        currentSession = session

        if !rounds.isEmpty {
            secondsRemaining = rounds[0].restSeconds
            phase = .rest
        } else {
            secondsRemaining = sessionType.totalDurationMinutes * 60
            phase = .breathe
        }
        UIApplication.shared.isIdleTimerDisabled = true
        startTimer()
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tick()
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        totalSeconds += 1
        if secondsRemaining <= 1 {
            advancePhase()
        } else {
            secondsRemaining -= 1
            if secondsRemaining == 5 {
                haptics.playWarning()
            }
        }
    }

    private func advancePhase() {
        if rounds.isEmpty {
            // Breathing exercise — single phase, just count down
            completeSession()
            return
        }

        if phase == .rest || phase == .breathe {
            // Move to hold
            phase = .hold
            secondsRemaining = rounds[currentRound - 1].holdSeconds
            haptics.playHoldStart()
            audio.playHoldCue()
        } else {
            // Hold complete — save round
            currentSession?.roundsCompleted = currentRound
            if currentRound >= totalRounds {
                completeSession()
            } else {
                currentRound += 1
                phase = .rest
                secondsRemaining = rounds[currentRound - 1].restSeconds
                haptics.playRestStart()
                audio.playRestCue()
            }
        }
    }

    private func completeSession() {
        pauseTimer()
        currentSession?.completed = true
        currentSession?.durationSeconds = totalSeconds
        UIApplication.shared.isIdleTimerDisabled = false
        sessionComplete = true
        haptics.playSessionComplete()
        audio.playCompleteCue()
    }

    private func saveAndDismiss() {
        pauseTimer()
        currentSession?.durationSeconds = totalSeconds
        UIApplication.shared.isIdleTimerDisabled = false
        dismiss()
    }
}
