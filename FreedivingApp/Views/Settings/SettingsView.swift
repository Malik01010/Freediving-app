import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var pbMinutes: Int = 1
    @State private var pbSeconds: Int = 30
    @State private var showPBPicker = false

    private var profile: UserProfile {
        if let existing = profiles.first { return existing }
        let p = UserProfile()
        modelContext.insert(p)
        return p
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                List {
                    // Personal Best
                    Section {
                        HStack {
                            Label("Personal Best", systemImage: "stopwatch")
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(profile.personalBestSeconds.formattedTime)
                                .foregroundStyle(Color.appTeal)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { showPBPicker = true }
                    } header: {
                        Text("Training").foregroundStyle(Color.appTextMuted)
                    }
                    .listRowBackground(Color.appCard)

                    // Preferences
                    Section {
                        Toggle(isOn: Binding(
                            get: { profile.hapticsEnabled },
                            set: { profile.hapticsEnabled = $0 }
                        )) {
                            Label("Haptic Feedback", systemImage: "hand.tap")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .tint(Color.appTeal)

                        Toggle(isOn: Binding(
                            get: { profile.audioCuesEnabled },
                            set: { profile.audioCuesEnabled = $0 }
                        )) {
                            Label("Audio Cues", systemImage: "speaker.wave.2")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .tint(Color.appTeal)
                    } header: {
                        Text("Preferences").foregroundStyle(Color.appTextMuted)
                    }
                    .listRowBackground(Color.appCard)

                    // About
                    Section {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(Bundle.main.appVersion)
                                .foregroundStyle(Color.appTextMuted)
                        }
                        HStack {
                            Label("Build", systemImage: "hammer")
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(Bundle.main.buildNumber)
                                .foregroundStyle(Color.appTextMuted)
                        }
                    } header: {
                        Text("About").foregroundStyle(Color.appTextMuted)
                    }
                    .listRowBackground(Color.appCard)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPBPicker) {
                PBPickerSheet(
                    currentPB: profile.personalBestSeconds,
                    onSave: { newPB in
                        profile.personalBestSeconds = newPB
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
}

struct PBPickerSheet: View {
    let currentPB: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var minutes: Int
    @State private var seconds: Int

    init(currentPB: Int, onSave: @escaping (Int) -> Void) {
        self.currentPB = currentPB
        self.onSave = onSave
        _minutes = State(initialValue: currentPB / 60)
        _seconds = State(initialValue: currentPB % 60)
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Set Personal Best")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, Spacing.lg)

            HStack(spacing: Spacing.lg) {
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<15) { Text("\($0)m").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)

                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60) { Text("\($0)s").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
            }

            Button {
                onSave(minutes * 60 + seconds)
                dismiss()
            } label: {
                Text("Save")
                    .font(.appSubheadline).fontWeight(.semibold)
                    .foregroundStyle(Color.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.appTeal)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
        .background(Color.appSurface)
    }
}
