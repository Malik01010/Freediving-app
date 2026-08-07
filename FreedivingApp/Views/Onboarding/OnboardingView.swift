import SwiftUI

// MARK: - Onboarding
// Shown once on first launch. 4 pages:
// 1. Welcome
// 2. How the training works
// 3. How tables are built from your PB
// 4. Go take your breath hold test

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 4

    var body: some View {
        ZStack {
            // Deep ocean background
            LinearGradient(
                colors: [Color(hex: "#050A14"), Color(hex: "#0A1628"), Color(hex: "#0A0F1E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Page content ──
                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    HowItWorksPage().tag(1)
                    TablesPage().tag(2)
                    GetStartedPage().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // ── Dot indicators + Next button ──
                VStack(spacing: Spacing.lg) {

                    // Dots
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.appTeal : Color.appTextMuted.opacity(0.4))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Next / Let's Go! button — always in the same place
                    Button {
                        if currentPage < totalPages - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(currentPage < totalPages - 1 ? "Next" : "Let's Go!")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appTeal)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

// MARK: - Page 1: Welcome
private struct WelcomePage: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Animated breath circle
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.06))
                    .frame(width: 220, height: 220)
                    .scaleEffect(pulse ? 1.15 : 1.0)

                Circle()
                    .fill(Color.appTeal.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse ? 1.1 : 1.0)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appTeal.opacity(0.5), Color.appTeal.opacity(0.15)],
                            center: .center, startRadius: 10, endRadius: 80
                        )
                    )
                    .frame(width: 110, height: 110)

                Image(systemName: "lungs.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.appTeal)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }

            VStack(spacing: Spacing.md) {
                Text("Welcome to\nFreediving")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Train your breath hold, build CO₂ tolerance, and track your progress — all guided, all offline.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 2: How it works
private struct HowItWorksPage: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Text("How it works")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: Spacing.md) {
                StepRow(
                    number: "1",
                    icon: "stopwatch",
                    title: "Take your Breath Hold Test",
                    description: "Hold your breath as long as you can. This sets your Personal Best and builds your custom training tables."
                )
                StepRow(
                    number: "2",
                    icon: "chart.bar.fill",
                    title: "Train with CO₂ & O₂ Tables",
                    description: "Structured rounds that reduce rest time or increase hold time each round — building real apnea capacity."
                )
                StepRow(
                    number: "3",
                    icon: "lungs.fill",
                    title: "Use Breathing Exercises",
                    description: "Pre-session breathing, square table, pranayama and diaphragmatic breathing prepare your body and mind."
                )
            }
            .padding(.horizontal, Spacing.lg)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 3: Tables explained
private struct TablesPage: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "table.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.appTeal)

            VStack(spacing: Spacing.md) {
                Text("Your tables adapt\nto your PB")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Every training table is calculated from your Personal Best. As your PB improves, your tables automatically get harder.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, Spacing.xl)
            }

            // Mini table preview
            VStack(spacing: 2) {
                HStack {
                    Text("Round").frame(width: 60, alignment: .leading)
                    Spacer()
                    Text("Hold").frame(width: 70, alignment: .center)
                    Text("Rest").frame(width: 70, alignment: .center)
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextMuted)
                .padding(.horizontal, Spacing.md)

                ForEach(Array(sampleRows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Text(row.0).frame(width: 60, alignment: .leading)
                        Spacer()
                        Text(row.1)
                            .foregroundStyle(Color.holdColour)
                            .frame(width: 70, alignment: .center)
                        Text(row.2)
                            .foregroundStyle(Color.restColour)
                            .frame(width: 70, alignment: .center)
                    }
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, 6)
                    .background(Color.appCard)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))

            Spacer()
            Spacer()
        }
    }

    private let sampleRows = [
        ("1", "0:45", "2:00"),
        ("2", "0:45", "1:45"),
        ("3", "0:45", "1:30"),
        ("4", "0:45", "1:15"),
    ]
}

// MARK: - Page 4: Get Started
private struct GetStartedPage: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.appTeal)
            }

            VStack(spacing: Spacing.md) {
                Text("You're ready!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Start with the Breath Hold Test to set your Personal Best. Everything else unlocks from there.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Step Row component
private struct StepRow: View {
    let number: String
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.appTeal)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.md)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
