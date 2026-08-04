# 📓 DEVLOG — Freediving Breath Training App

> A living record of design decisions, architecture choices, and build progress.  
> Started: August 2026 · Platform: iOS (SwiftUI) · Repo: [Malik01010/Freediving-app](https://github.com/Malik01010/Freediving-app)

---

## 🧭 Project Origin

The idea came from a real training need: freedivers need structured, guided sessions to safely
improve their breath-hold times. Most existing apps are either too generic (generic meditation
timers) or too complex (full dive computers). This app sits in the middle — purpose-built for
breath-hold training on the phone you already have in your bag at the pool.

**Core goal:** A calm, distraction-free iOS app that guides a freediver through every major
training modality, adapts difficulty to their personal best, and tracks progress over time —
with zero accounts, zero cloud, zero friction.

---

## 📐 Key Design Decisions

### Why SwiftUI + SwiftData?
- **SwiftUI** gives native iOS performance critical for precise 1-second timer accuracy.
  A React Native or web app would introduce a JS runtime between the timer and the UI — unacceptable
  for breath-hold sessions where a second matters.
- **SwiftData** (iOS 17+) is the simplest path to local persistence with no external dependencies.
  All data lives on-device. No server, no login, no privacy risk.
- **Swift Charts** (also iOS 17+) provides native chart rendering — no third-party chart library needed.

### Why iOS 17 minimum?
SwiftData and Swift Charts were both introduced at iOS 16/17. Setting the minimum to iOS 17
lets us use both without workarounds and keeps the codebase clean.

### Why fully offline?
Freedivers train at pools, open water, and boats — connectivity is unreliable. More importantly,
there is no data that *needs* to leave the device. Local-first is the right default here.
Cloud sync can be added later (CloudKit + SwiftData is a one-line change) without any
architecture rework.

### Why a dark ocean theme?
- Reduces eye strain in outdoor / poolside conditions
- Aesthetically appropriate for the sport — deep navy and teal evoke the underwater environment
- Dark backgrounds make the large countdown timer easier to read at a glance

### Colour palette rationale
| Colour | Hex | Used for |
|---|---|---|
| Deep Navy | `#0A0F1E` | App background |
| Card Navy | `#1A2640` | Cards, surfaces |
| Teal | `#0ECDCD` | Primary accent, rest phase, CTAs |
| Blue | `#1E6FDB` | Hold phase indicator |
| Orange | `#F5A623` | Warnings, exhale phase |

---

## 🏗️ Architecture

```
FreedivingApp/
├── FreedivingAppApp.swift         App entry, SwiftData model container
├── Models/
│   ├── UserProfile.swift          Singleton user prefs: PB, haptics, audio
│   ├── TrainingSession.swift      Session record + SessionType enum
│   ├── SessionRound.swift         Per-round hold/rest actuals
│   └── PersonalBest.swift         PB history log (each save = new entry)
├── Services/
│   ├── TableGeneratorService.swift  Dynamic CO₂/O₂/EmptyLungs table maths
│   ├── BreathingSessionFactory.swift  Step sequences for all breathing exercises
│   ├── HapticService.swift          CoreHaptics phase-transition patterns
│   ├── AudioCueService.swift        AVFoundation system sound cues
│   └── StreakService.swift          Consecutive-day streak + 7-day bucketing
├── Views/
│   ├── ContentView.swift            Tab bar: Train / Progress / History / Settings
│   ├── Home/
│   │   └── HomeView.swift           Session grid, streak badge, 7-day activity row
│   ├── Session/
│   │   ├── SessionDetailView.swift  Pre-session info + round table + routing
│   │   ├── ActiveSessionView.swift  CO₂/O₂/EmptyLungs timer engine
│   │   ├── BreathHoldTestView.swift 3-phase: breathe-up → stopwatch → result/PB save
│   │   ├── BreathingExerciseView.swift  Generic breathing guide engine
│   │   └── SessionCompleteView.swift    Post-session summary
│   ├── Progress/
│   │   └── ProgressView.swift       Weekly bar chart, PB line chart, type breakdown
│   ├── History/
│   │   └── HistoryView.swift        Grouped session log by date
│   ├── Settings/
│   │   └── SettingsView.swift       PB picker, haptics/audio toggles
│   └── Components/
│       ├── SessionCard.swift        Home grid card
│       ├── TimerComponents.swift    CountdownRing, PhasePill, RoundBadge
│       ├── BreathGuideCircle.swift  Animated expanding/contracting breath circle
│       └── ActionButton.swift      Reusable primary/secondary button
└── Resources/
    └── DesignSystem.swift           Colours, fonts, spacing, corner radii
```

### Data flow
- **No ViewModel layer** — SwiftUI `@Query` macros pull directly from SwiftData.
  This keeps the code concise for a single-user, local-only app. If the app grows to need
  server sync or complex derived state, ViewModels can be introduced per-screen without
  changing the model layer.
- **Services are value types (structs)** where stateless (TableGeneratorService,
  BreathingSessionFactory, StreakService). Only HapticService and AudioCueService are classes
  because they hold hardware engine references.

---

## 🏋️ Training Modules

### Table-based sessions (driven by Personal Best)

All three training tables are **dynamically generated** from the user's PB breath-hold time.
This means the app automatically becomes harder as the user improves — no manual difficulty setting.

| Module | Hold | Rest | Rounds | Total |
|---|---|---|---|---|
| **CO₂ Training** | Fixed at 50% PB | Starts at PB, −15s/round | 8 | ~10 min |
| **O₂ Training** | Starts at 50% PB, +15s/round | Fixed 2:00 | 8 | ~21 min |
| **Empty Lungs** | Starts at 30% PB, +10s/round | Fixed 2:00 | 8 | ~18 min |

Example for a 2:00 PB:

**CO₂ table:** Hold 1:00 throughout. Rest: 2:00, 1:45, 1:30, 1:15, 1:00, 0:45, 0:30, 0:20  
**O₂ table:** Rest 2:00 throughout. Hold: 1:00, 1:15, 1:30, 1:45, 2:00, 2:15, 2:30, 2:45  
**Empty Lungs:** Rest 2:00 throughout. Hold: 0:36, 0:46, 0:56, 1:06, 1:16, 1:26, 1:36, 1:46

### Breathing exercises (fixed sequences)

| Module | Pattern | Duration | Purpose |
|---|---|---|---|
| **Pre Breath** | Inhale 4s → Hold 4s → Exhale 6s | 2 min | O₂/CO₂ balance before a dive |
| **Square Table** | 5s × 4 (inhale/hold/exhale/hold) | 5 min | Nervous system prep, breath control |
| **Pranayama** | Alt-nostril 4-4-4-4 (L-in/hold/R-out/R-in/hold/L-out) | 5 min | Relax, open nasal passages |
| **Diaphragmatic** | Belly in 4s → Belly out 8s | 5 min | Parasympathetic activation, deep relax |

### Breath Hold Test
3-phase flow:
1. **Breathe-up** — optional 2-min countdown with controlled breathing cues
2. **Hold** — live stopwatch, automatically detects new PB, "BREATHE" tap button
3. **Result** — shows time, comparison to PB, one-tap save that immediately updates all tables

---

## 🔔 Sensory Feedback

Haptic and audio cues fire at every phase transition so the user never needs to look at the screen
during a session. Both can be independently disabled in Settings.

| Event | Haptic | Sound |
|---|---|---|
| Hold starts | Single heavy tap | Sharp click (system 1057) |
| Rest starts | Two medium taps | Soft tone (system 1054) |
| 5 seconds remaining | Single rigid tap | — |
| Session complete | Three light taps | Glass chime (system 1025) |

Haptic patterns use **CoreHaptics** for precise multi-event sequences, with a `UIImpactFeedbackGenerator`
fallback on devices where CHHapticEngine is unavailable.

---

## 📊 Progress & Tracking

### Streak
- Counts consecutive calendar days on which at least one completed session was recorded
- "Forgiving" calculation: counts from today *or* yesterday, so an early-morning check
  doesn't break a streak built the previous evening
- Shown as a badge on the Home screen and as a stat pill on Progress

### Charts (Swift Charts)
- **PB over time** — line + area + dot marks. Requires ≥2 saved PBs to display
- **Sessions this week** — bar chart, one bar per day for the last 7 calendar days
- **Sessions by type** — list with proportional mini-bars (relative to most-trained type)

---

## 🔐 Security & Privacy

- No network calls — no data ever leaves the device
- No analytics, no tracking
- GitHub token stored in `~/.bob/settings/mcp.json` (local machine only, not in repo)
- `.gitignore` excludes Xcode derived data, build artefacts, and `*.ipa`

---

## 🗺️ Potential Future Work

These were discussed or considered but deliberately excluded from v1 to keep scope tight:

| Feature | Notes |
|---|---|
| **Apple Watch companion** | SwiftUI + WatchConnectivity; the timer engine is already watch-compatible |
| **HealthKit integration** | Log sessions as Mindful Minutes; read HRV post-session |
| **iCloud sync** | SwiftData + CloudKit = one-line change in the model container |
| **Custom table builder** | Let advanced users set their own hold/rest sequences |
| **Audio guidance** | Text-to-speech phase callouts ("Breathe in… now hold…") |
| **Widgets** | Today's streak and next session suggestion on the home screen |
| **Offline video tips** | Bundled technique clips for each session type |

---

## 📦 Build Phases Summary

| Phase | Commit | What shipped |
|---|---|---|
| **Phase 1** | `8e25215` | Project structure, all SwiftData models, design system, all view skeletons, tab navigation |
| **Phase 2** | `2f155bf` | BreathHoldTestView, BreathGuideCircle, BreathingExerciseView, BreathingSessionFactory, ActionButton, session routing |
| **Phase 3** | `f9a612f` | StreakService, WeeklyActivityRow, next-round preview, haptic/audio prefs wiring, weekly bar chart, PB chart improvements |

---

*Built with IBM Bob · August 2026*
