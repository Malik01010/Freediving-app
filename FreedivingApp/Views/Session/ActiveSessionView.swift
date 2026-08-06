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
    @Query private var profiles: [UserProfile]

    @State private var currentRound = 1
    @State private var phase: SessionPhase = .rest
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var sessionComplete = false
    @State private var currentSession: TrainingSession?
    @State private var showExitConfirm = false

    private let hapticService = HapticService()
    private let audioService = AudioCueService()

    // User preferences from profile
    private var hapticsEnabled: Bool { profiles.first?.hapticsEnabled ?? true }
    private var audioEnabled: Bool   { profiles.first?.audioCuesEnabled ?? true }

    private var rounds: [TrainingRound] {
        switch sessionType {
        case .co2Training:  return TableGeneratorService.co2Table(personalBestSeconds: personalBest)
        case .o2Training:   return TableGeneratorService.o2Table(personalBestSeconds: personalBest)
        case .emptyLungs:   return TableGeneratorService.emptyLungsTable(personalBestSeconds: personalBest)
        default:            return []
        }
    }

    private var totalRounds: Int { max(rounds.count, 1) }

    private var nextRound: TrainingRound? {
        guard phase == .hold, currentRound < rounds.count else { return nil }
        return rounds[currentRound] // index = currentRound (next after current 1-indexed)
    }

    private var progress: Double {
        guard let total = currentPhaseTotal, total > 0 else { return 0 }
        return 1.0 - (Double(secondsRemaining) / Double(total))
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
                ) { dismiss() }
            } else {
                VStack(spacing: 0) {
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

                    // Skip button — directly under timer, centred
                    Button { skipPhase() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 22))
                            Text(phase == .rest ? "Skip Rest" : "Skip Hold")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm + 2)
                        .background(Color.appCard)
                        .clipShape(Capsule())
                    }
                    .padding(.top, Spacing.md)

                    // Next round preview
                    nextRoundPreview
                        .frame(height: 52)
                        .padding(.top, Spacing.sm)

                    Spacer()

                    // Pause / resume — 40% larger than original (77 * 1.2 = 92px)
                    Button {
                        isRunning ? pauseTimer() : startTimer()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(Color.appTeal)
                            .frame(width: 92, height: 92)
                            .background(Color.appCard)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
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

    // MARK: - Next Round Preview
    @ViewBuilder
    private var nextRoundPreview: some View {
        if let next = nextRound {
            HStack(spacing: Spacing.xs) {
                Text("Next →")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextMuted)
                Text("Hold \(next.holdSeconds.formattedTime)")
                    .font(.appCaption)
                    .foregroundStyle(Color.holdColour)
                Text("·")
                    .foregroundStyle(Color.appTextMuted)
                Text("Rest \(next.restSeconds.formattedTime)")
                    .font(.appCaption)
                    .foregroundStyle(Color.restColour)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.appCard)
            .clipShape(Capsule())
        } else {
            // Last round or rest phase — keep layout stable
            Color.clear
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in tick() }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    /// Skip the current phase immediately — jumps straight to next phase
    private func skipPhase() {
        totalSeconds += secondsRemaining
        secondsRemaining = 0
        advancePhase()
    }

    private func tick() {
        totalSeconds += 1
        if secondsRemaining <= 1 {
            advancePhase()
        } else {
            secondsRemaining -= 1
            if secondsRemaining == 5 {
                triggerHaptic { hapticService.playWarning() }
            }
        }
    }

    private func advancePhase() {
        if rounds.isEmpty {
            completeSession()
            return
        }

        if phase == .rest || phase == .breathe {
            phase = .hold
            secondsRemaining = rounds[currentRound - 1].holdSeconds
            triggerHaptic { hapticService.playHoldStart() }
            triggerAudio  { audioService.playHoldCue() }
        } else {
            currentSession?.roundsCompleted = currentRound
            if currentRound >= totalRounds {
                completeSession()
            } else {
                currentRound += 1
                phase = .rest
                secondsRemaining = rounds[currentRound - 1].restSeconds
                triggerHaptic { hapticService.playRestStart() }
                triggerAudio  { audioService.playRestCue() }
            }
        }
    }

    private func completeSession() {
        pauseTimer()
        currentSession?.completed = true
        currentSession?.durationSeconds = totalSeconds
        UIApplication.shared.isIdleTimerDisabled = false
        sessionComplete = true
        triggerHaptic { hapticService.playSessionComplete() }
        triggerAudio  { audioService.playCompleteCue() }
    }

    private func saveAndDismiss() {
        pauseTimer()
        currentSession?.durationSeconds = totalSeconds
        UIApplication.shared.isIdleTimerDisabled = false
        dismiss()
    }

    // MARK: - Preference-gated helpers
    private func triggerHaptic(_ block: () -> Void) {
        if hapticsEnabled { block() }
    }
    private func triggerAudio(_ block: () -> Void) {
        if audioEnabled { block() }
    }
}
