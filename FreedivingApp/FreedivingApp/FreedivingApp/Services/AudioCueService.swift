import AVFoundation

// MARK: - Audio Cue Service
// Plays simple audio tones at session phase transitions.
// Uses AVAudioPlayer with system sounds as fallback.

final class AudioCueService {

    private var player: AVAudioPlayer?

    // Spoken or tonal cue for phase start
    func playHoldCue() {
        playSystemSound(1057) // "Tink" — sharp click
    }

    func playRestCue() {
        playSystemSound(1054) // "Bamboo" — soft tone
    }

    func playCompleteCue() {
        playSystemSound(1025) // "Glass" — completion chime
    }

    func playWarningCue() {
        playSystemSound(1052) // short alert
    }

    private func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}

import AudioToolbox
