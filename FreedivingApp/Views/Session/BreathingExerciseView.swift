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
                    // Top bar
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
                        Color.clear.frame(width: 24)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    // Overall progress bar
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

                    // Breath circle
                    ZStack {
                        BreathGuideCircle(
                            phase: currentStep.phase,
                            progress: stepProgress
                        )
                        .frame(width: 220, height: 220)

                        VStack(spacing: Spacing.sm) {
                            PhasePill(label: currentStep.label, color: currentStep.phase.color)
                            Text("\(currentStep.durationSeconds - secondsInStep)")
                                .font(.timerMedium)
                                .foregroundStyle(Color.appTextPrimary)
                                .monospacedDigit()
                        }
                    }

                    Spacer()

                    // Instruction text
                    Text(currentStep.phase.instruction)
                        .font(.appBody)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                        .frame(minHeight: 44)

                    Spacer()

                    // Play/pause
                    Button {
                        isRunning ? pause() : resume()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.appTeal)
                            .frame(width: 56, height: 56)
                            .background(Color.appCard)
                            .clipShape(Circle())
                    }
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
        }
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
