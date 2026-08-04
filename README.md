# 🤿 Freediving Breath Training App

A native iOS app (SwiftUI) for freedivers to train their breath-holding abilities through structured, guided sessions.

## Features

| Module | Duration | Description |
|---|---|---|
| Breath Hold Test | Variable | Set your personal best — drives all table difficulty |
| Pre Breath | 2 min | Controlled breathing to balance O₂/CO₂ |
| CO₂ Training | 10 min · 8 rounds | Fixed hold, decreasing rest — builds CO₂ tolerance |
| O₂ Training | 21 min · 8 rounds | Fixed rest, increasing hold — builds O₂ efficiency |
| Empty Lungs | 18 min · 8 rounds | Post-exhale holds, increasing apnea time |
| Square Table | 5 min | Equal-ratio breathing cycles to prep the nervous system |
| Pranayama | 5 min | Alternate nostril breathing |
| Diaphragmatic | 5 min | Belly breathing for deep relaxation |

## Tech Stack

- **SwiftUI** — native iOS UI
- **SwiftData** — local offline persistence (no login required)
- **Swift Charts** — personal best and session charts
- **CoreHaptics** — tactile phase transition cues
- **AVFoundation** — audio cues
- **iOS 17+**

## Architecture

```
FreedivingApp/
├── Models/
│   ├── UserProfile.swift
│   ├── TrainingSession.swift
│   ├── SessionRound.swift
│   └── PersonalBest.swift
├── Services/
│   ├── TableGeneratorService.swift
│   ├── HapticService.swift
│   └── AudioCueService.swift
├── Views/
│   ├── ContentView.swift
│   ├── Home/HomeView.swift
│   ├── Session/
│   │   ├── SessionDetailView.swift
│   │   ├── ActiveSessionView.swift
│   │   └── SessionCompleteView.swift
│   ├── Progress/ProgressView.swift
│   ├── History/HistoryView.swift
│   ├── Settings/SettingsView.swift
│   └── Components/
│       ├── SessionCard.swift
│       └── TimerComponents.swift
└── Resources/
    └── DesignSystem.swift
```

## Design

Dark deep-ocean theme: navy (`#0A0F1E`) background, teal (`#0ECDCD`) accent.

## Getting Started

1. Open `FreedivingApp.xcodeproj` in Xcode 15+
2. Select an iOS 17+ simulator or physical device
3. Build & Run (`⌘R`)
4. Complete a **Breath Hold Test** first to calibrate your training tables

## Privacy

All data is stored locally on-device. No account, no internet connection required.
