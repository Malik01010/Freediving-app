import AVFoundation
import AudioToolbox

// MARK: - Audio Cue Service
// Plays tonal cues at session phase transitions.
// Breath cues use synthesised sine tones — no audio files required.
// Hold/rest/complete cues use system sounds as fallback.

final class AudioCueService {

    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var isEngineReady = false

    init() {
        setupEngine()
    }

    // MARK: - Breathing phase cues (synthesised tones)

    /// Short rising tone — signals start of INHALE
    func playInhaleCue() {
        playTone(frequency: 528, duration: 0.35, fadeIn: true)
    }

    /// Short falling tone — signals start of EXHALE
    func playExhaleCue() {
        playTone(frequency: 396, duration: 0.35, fadeOut: true)
    }

    /// Soft mid tone — signals HOLD start
    func playHoldCue() {
        playTone(frequency: 440, duration: 0.2)
    }

    // MARK: - Session lifecycle cues (system sounds)

    func playRestCue() {
        playSystemSound(1054) // Bamboo — soft
    }

    func playCompleteCue() {
        playSystemSound(1025) // Glass chime
    }

    func playWarningCue() {
        playSystemSound(1052) // Short alert
    }

    // MARK: - Sine tone synthesiser

    private func setupEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            audioEngine.attach(playerNode)
            let mixer = audioEngine.mainMixerNode
            // Match the mixer's output format exactly (stereo, native sample rate)
            let outputFormat = mixer.outputFormat(forBus: 0)
            audioEngine.connect(playerNode, to: mixer, format: outputFormat)
            try audioEngine.start()
            isEngineReady = true
        } catch {
            // Engine failed — fall back to system sounds silently
            isEngineReady = false
        }
    }

    private func playTone(
        frequency: Double,
        duration: Double,
        amplitude: Float = 0.25,
        fadeIn: Bool = false,
        fadeOut: Bool = false
    ) {
        guard isEngineReady else {
            playSystemSound(1057)
            return
        }

        // Use the player node's output format so channel count always matches
        let format = playerNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        let channelCount = Int(format.channelCount)
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        for ch in 0..<channelCount {
            let data = buffer.floatChannelData![ch]
            for i in 0..<Int(frameCount) {
                let t = Double(i) / sampleRate
                var sample = Float(sin(2.0 * Double.pi * frequency * t)) * amplitude

                // Envelope shaping
                let progress = Float(i) / Float(frameCount)
                if fadeIn {
                    sample *= min(progress * 4, 1.0)
                }
                if fadeOut {
                    sample *= max(1.0 - (progress - 0.6) * 2.5, 0.0)
                }
                // End-fade to prevent clicks
                let endFade = max(1.0 - (progress - 0.85) * 6.0, 0.0)
                sample *= endFade

                data[i] = sample
            }
        }

        playerNode.stop()
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        playerNode.play()
    }

    // MARK: - System sounds

    private func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
