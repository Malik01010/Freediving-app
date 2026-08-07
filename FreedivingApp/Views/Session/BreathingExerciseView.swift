import SwiftUI
import SwiftData

// MARK: - Breathing Exercise Runner
// Generic view that drives all four breathing exercises:
// Pre Breath, Square Table, Pranayama, Diaphragmatic.
// Accepts a sequence of (phase, duration) steps and loops them.

struct BreathingExerciseStep {
    let phase: BreathGuidePhase
    let durationSeconds: Int
    let label: String         // override label if needed (e.g. "LEFT NOSTRIL")
    init(phase: BreathGuidePhase, durationSeconds: Int, label: String? = nil) {
        self.phase = phase
        self.durationSeconds = durationSeconds
        self.label = label ?? phase.label
    }
}

struct BreathingExerciseView: View {
    let sessionType: SessionType
    let steps: [BreathingExerciseStep]
    let totalDurationSeconds: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var stepIndex = 0
    @State private var secondsInStep = 0
    @State private var totalElapsed = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var sessionComplete = false

    private let audio = AudioCueService()

    private var currentStep: BreathingExerciseStep { steps[stepIndex] }
    private var stepProgress: Double {
        guard currentStep.durationSeconds > 0 else { return 0 }
        return Double(secondsInStep) / Double(currentStep.durationSeconds)
    }
    private var totalProgress: Double {
        guard totalDurationSeconds > 0 else { return 0 }
        return min(1.0, Double(totalElapsed) / Double(totalDurationSeconds))
    }
    private var remainingTotal: Int { max(0, totalDurationSeconds - totalElapsed) }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if sessionComplete {
                SessionCompleteView(
                    sessionType: sessionType,
                    roundsCompleted: 0,
                    totalRounds: 0,
                    totalSeconds: totalElapsed
                ) { dismiss() }
            } else {
                VStack(spacing: 0) {

                    // ── Top bar — identical structure to ActiveSessionView ──
                    HStack {
                        Button { endSession() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.appTextMuted)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(sessionType.rawValue)
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextSecondary)
                            Text(remainingTotal.formattedTime)
                                .font(.appCaption)
                                .foregroundStyle(Color.appTextMuted)
                        }
                        Spacer()
                        Color.clear.frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    // ── Progress bar ──
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appCard).frame(height: 3)
                            Capsule()
                                .fill(currentStep.phase.color)
                                .frame(width: geo.size.width * totalProgress, height: 3)
                                .animation(.linear(duration: 1), value: totalProgress)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)

                    Spacer()

                    // ── Breath circle ──
                    ZStack {
                        BreathGuideCircle(
                            phase: currentStep.phase,
                            progress: stepProgress
                        )
                        .frame(width: 260, height: 260)

                        VStack(spacing: Spacing.sm) {
                            PhasePill(label: currentStep.label, color: currentStep.phase.color)
                            Text("\(currentStep.durationSeconds - secondsInStep)")
                                .font(.timerLarge)
                                .foregroundStyle(Color.appTextPrimary)
                                .monospacedDigit()
                        }
                    }

                    // ── Skip button — directly under circle ──
                    Button { skipPhase() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 22))
                            Text("Skip")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm + 2)
                        .background(Color.appCard)
                        .clipShape(Capsule())
                    }
                    .padding(.top, Spacing.md)

                    // ── Instruction text — fixed height so layout doesn't shift ──
                    Text(currentStep.phase.instruction)
                        .font(.appBody)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                        .frame(height: 44)
                        .padding(.top, Spacing.sm)

                    Spacer()

                    // ── Pause/resume — same size as ActiveSessionView (92pt) ──
                    Button {
                        isRunning ? pause() : resume()
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
        .onAppear { start() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Timer control

    private func start() {
        UIApplication.shared.isIdleTimerDisabled = true
        // Play cue for the very first phase immediately on start
        playCueForCurrentPhase()
        resume()
    }

    private func resume() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in tick() }
    }

    private func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func tick() {
        totalElapsed += 1
        secondsInStep += 1

        if totalElapsed >= totalDurationSeconds {
            finishSession()
            return
        }

        if secondsInStep >= currentStep.durationSeconds {
            secondsInStep = 0
            stepIndex = (stepIndex + 1) % steps.count
            // Play cue for the new phase
            playCueForCurrentPhase()
        }
    }

    private func playCueForCurrentPhase() {
        switch currentStep.phase {
        case .inhale:    audio.playInhaleCue()
        case .exhale:    audio.playExhaleCue()
        case .holdFull:  audio.playHoldCue()
        case .holdEmpty: audio.playHoldCue()
        }
    }

    /// Skip instantly to the start of the next phase step
    private func skipPhase() {
        // Advance elapsed by remaining seconds in this step
        let remaining = currentStep.durationSeconds - secondsInStep
        totalElapsed += remaining

        if totalElapsed >= totalDurationSeconds {
            finishSession()
            return
        }

        // Move to next step
        secondsInStep = 0
        stepIndex = (stepIndex + 1) % steps.count
    }

    private func finishSession() {
        stopTimer()
        let session = TrainingSession(type: sessionType)
        session.durationSeconds = totalElapsed
        session.completed = true
        modelContext.insert(session)
        sessionComplete = true
    }

    private func endSession() {
        stopTimer()
        let session = TrainingSession(type: sessionType)
        session.durationSeconds = totalElapsed
        session.completed = totalElapsed >= totalDurationSeconds
        modelContext.insert(session)
        dismiss()
    }
}
