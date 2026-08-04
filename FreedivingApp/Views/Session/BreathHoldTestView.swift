import SwiftUI
import SwiftData

// MARK: - Breath Hold Test
// Stopwatch screen. User breathes up, then taps hold.
// On release, time is recorded and optionally saved as PB.

struct BreathHoldTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \PersonalBest.date, order: .reverse) private var allBests: [PersonalBest]

    private var profile: UserProfile {
        if let p = profiles.first { return p }
        let p = UserProfile()
        modelContext.insert(p)
        return p
    }

    // States
    enum TestPhase { case breatheUp, holding, result }

    @State private var testPhase: TestPhase = .breatheUp
    @State private var breatheUpRemaining = 120           // 2-min breathe-up countdown
    @State private var holdSeconds = 0                    // stopwatch during hold
    @State private var timer: Timer?
    @State private var isBreathingUp = false
    @State private var showSavePB = false
    @State private var savedAsPB = false

    private var currentPB: Int { profile.personalBestSeconds }
    private var isNewPB: Bool { holdSeconds > currentPB }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    Text("Breath Hold Test")
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

                Spacer()

                switch testPhase {
                case .breatheUp:
                    breatheUpPhase
                case .holding:
                    holdingPhase
                case .result:
                    resultPhase
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onDisappear { stopTimer() }
    }

    // MARK: - Breathe Up Phase
    private var breatheUpPhase: some View {
        VStack(spacing: Spacing.xl) {
            Text("BREATHE UP")
                .font(.appCaption).fontWeight(.semibold)
                .foregroundStyle(Color.appTextMuted)
                .tracking(2)

            ZStack {
                CountdownRing(
                    progress: isBreathingUp ? 1.0 - (Double(breatheUpRemaining) / 120.0) : 0,
                    color: Color.restColour,
                    lineWidth: 10
                )
                .frame(width: 220, height: 220)

                VStack(spacing: Spacing.xs) {
                    Text(isBreathingUp ? breatheUpRemaining.formattedTime : "2:00")
                        .font(.timerMedium)
                        .foregroundStyle(Color.appTextPrimary)
                        .monospacedDigit()
                    Text(isBreathingUp ? "remaining" : "breathe-up")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextMuted)
                }
            }

            Text("Breathe slowly and deeply to\nrelax and balance your CO₂.")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            // Current PB
            HStack(spacing: Spacing.xs) {
                Image(systemName: "trophy")
                    .foregroundStyle(Color.appTeal)
                Text("Current PB: \(currentPB.formattedTime)")
                    .font(.appBody)
                    .foregroundStyle(Color.appTextSecondary)
            }

            VStack(spacing: Spacing.sm) {
                if !isBreathingUp {
                    Button {
                        startBreatheUp()
                    } label: {
                        ActionButton(title: "Start Breathe-Up", style: .secondary)
                    }
                }

                Button {
                    startHold()
                } label: {
                    ActionButton(title: isBreathingUp ? "Start Hold Now" : "Skip & Start Hold", style: .primary)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Holding Phase
    private var holdingPhase: some View {
        VStack(spacing: Spacing.xl) {
            Text("HOLD")
                .font(.appCaption).fontWeight(.semibold)
                .foregroundStyle(Color.holdColour)
                .tracking(2)

            ZStack {
                // Pulsing ring (no countdown — just elapsed)
                Circle()
                    .stroke(Color.holdColour.opacity(0.15), lineWidth: 10)
                    .frame(width: 260, height: 260)

                Circle()
                    .stroke(Color.holdColour.opacity(0.4), lineWidth: 3)
                    .frame(width: 260, height: 260)

                VStack(spacing: Spacing.sm) {
                    PhasePill(label: "HOLDING", color: Color.holdColour)
                    Text(holdSeconds.formattedTime)
                        .font(.timerLarge)
                        .foregroundStyle(Color.appTextPrimary)
                        .monospacedDigit()
                    if holdSeconds > 0 && holdSeconds >= currentPB {
                        Text("🏆 New PB!")
                            .font(.appSubheadline)
                            .foregroundStyle(Color.appTeal)
                    }
                }
            }

            Text("Tap when you need to breathe")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)

            Button {
                stopHold()
            } label: {
                Text("BREATHE")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appBackground)
                    .frame(width: 140, height: 140)
                    .background(Color.holdColour)
                    .clipShape(Circle())
            }
            .padding(.bottom, Spacing.md)
        }
    }

    // MARK: - Result Phase
    private var resultPhase: some View {
        VStack(spacing: Spacing.xl) {
            if isNewPB {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appTeal)
                    Text("New Personal Best!")
                        .font(.appTitle)
                        .foregroundStyle(Color.appTextPrimary)
                }
            } else {
                Image(systemName: "stopwatch")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.appTextSecondary)
            }

            VStack(spacing: Spacing.xs) {
                Text(holdSeconds.formattedTime)
                    .font(.timerMedium)
                    .foregroundStyle(isNewPB ? Color.appTeal : Color.appTextPrimary)
                    .monospacedDigit()
                Text("hold time")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextMuted)
            }

            HStack(spacing: Spacing.md) {
                StatPill(label: "This Hold", value: holdSeconds.formattedTime)
                StatPill(label: "Current PB", value: (savedAsPB ? holdSeconds : currentPB).formattedTime)
            }
            .padding(.horizontal, Spacing.md)

            VStack(spacing: Spacing.sm) {
                if isNewPB && !savedAsPB {
                    Button { savePB() } label: {
                        ActionButton(title: "Save as Personal Best", style: .primary)
                    }
                } else if savedAsPB {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appTeal)
                        Text("Saved as PB — tables updated!")
                            .font(.appBody)
                            .foregroundStyle(Color.appTeal)
                    }
                }

                Button { resetTest() } label: {
                    ActionButton(title: "Try Again", style: .secondary)
                }

                Button { dismiss() } label: {
                    Text("Done")
                        .font(.appBody)
                        .foregroundStyle(Color.appTextMuted)
                        .padding(.top, Spacing.xs)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - Actions

    private func startBreatheUp() {
        isBreathingUp = true
        breatheUpRemaining = 120
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if breatheUpRemaining > 0 {
                breatheUpRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }

    private func startHold() {
        stopTimer()
        holdSeconds = 0
        testPhase = .holding
        UIApplication.shared.isIdleTimerDisabled = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            holdSeconds += 1
        }
    }

    private func stopHold() {
        stopTimer()
        UIApplication.shared.isIdleTimerDisabled = false
        testPhase = .result

        // Save session record
        let session = TrainingSession(type: .breathHoldTest)
        session.durationSeconds = holdSeconds
        session.completed = true
        modelContext.insert(session)
    }

    private func savePB() {
        let pb = PersonalBest(seconds: holdSeconds)
        modelContext.insert(pb)
        profile.personalBestSeconds = holdSeconds
        savedAsPB = true
    }

    private func resetTest() {
        stopTimer()
        holdSeconds = 0
        breatheUpRemaining = 120
        isBreathingUp = false
        savedAsPB = false
        testPhase = .breatheUp
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
