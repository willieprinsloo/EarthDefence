import AVFoundation
import Foundation

class ProceduralSoundGenerator {
    static let shared = ProceduralSoundGenerator()
    
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var mixer: AVAudioMixerNode
    
    private init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixer, format: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            playerNode.play()
            print("✅ ProceduralSoundGenerator initialized successfully")
        } catch {
            print("❌ Failed to setup audio engine: \(error)")
        }
    }
    
    func playTone(frequency: Float, duration: Double, volume: Float = 0.5) {
        print("🎶 playTone called: freq=\(frequency)Hz, duration=\(duration)s, volume=\(volume)")
        
        // Ensure audio engine is running
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                playerNode.play()
                print("🔄 Restarted audio engine")
            } catch {
                print("❌ Failed to restart audio engine: \(error)")
                return
            }
        }
        
        // Ensure player node is playing
        if !playerNode.isPlaying {
            playerNode.play()
            print("▶️ Started player node")
        }
        
        let sampleRate = Float(mixer.outputFormat(forBus: 0).sampleRate)
        let numberOfSamples = Int(sampleRate * Float(duration))
        
        // Create buffer
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0), 
                                           frameCapacity: AVAudioFrameCount(numberOfSamples)) else { 
            print("❌ Failed to create audio buffer")
            return 
        }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        
        // Generate sine wave
        let channels = Int(mixer.outputFormat(forBus: 0).channelCount)
        for frame in 0..<numberOfSamples {
            let value = sin(2.0 * Float.pi * frequency * Float(frame) / sampleRate) * volume
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        // Apply envelope for smoother sound
        applyEnvelope(to: buffer, attackTime: 0.01, releaseTime: 0.05)
        
        // Play the buffer
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: {
            // Finished playing tone at \(frequency)Hz
        })
    }
    
    private func applyEnvelope(to buffer: AVAudioPCMBuffer, attackTime: Double, releaseTime: Double) {
        let sampleRate = Float(mixer.outputFormat(forBus: 0).sampleRate)
        let attackSamples = Int(sampleRate * Float(attackTime))
        let releaseSamples = Int(sampleRate * Float(releaseTime))
        let totalSamples = Int(buffer.frameLength)
        let channels = Int(mixer.outputFormat(forBus: 0).channelCount)
        
        for frame in 0..<totalSamples {
            var envelope: Float = 1.0
            
            // Attack phase
            if frame < attackSamples {
                envelope = Float(frame) / Float(attackSamples)
            }
            // Release phase
            else if frame > totalSamples - releaseSamples {
                let releaseFrame = frame - (totalSamples - releaseSamples)
                envelope = 1.0 - (Float(releaseFrame) / Float(releaseSamples))
            }
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] *= envelope
            }
        }
    }
    
    // Predefined sound effects
    func playButtonTap() {
        print("🔊 Playing procedural button tap sound")
        playTone(frequency: 1000, duration: 0.05, volume: 0.3)
    }
    
    func playTowerPlace() {
        print("🔊 Playing procedural tower place sound")
        // Two-tone placement sound
        DispatchQueue.main.async {
            self.playTone(frequency: 400, duration: 0.1, volume: 0.4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(frequency: 600, duration: 0.1, volume: 0.4)
        }
    }
    
    func playEnemyHit() {
        print("🔊 Playing procedural enemy hit sound")
        playTone(frequency: 200, duration: 0.1, volume: 0.5)
    }
    
    func playEnemyDestroyed() {
        // Explosive destruction with resonance
        DispatchQueue.main.async {
            self.playTone(frequency: 200, duration: 0.05, volume: 0.8)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.playTone(frequency: 150, duration: 0.08, volume: 0.6)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(frequency: 100, duration: 0.15, volume: 0.4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playTone(frequency: 80, duration: 0.2, volume: 0.2)
        }
    }
    
    func playLaserFire() {
        print("🔊 Playing procedural laser fire sound")
        // Sci-fi laser with frequency sweep and harmonics
        
        // Initial charge-up sound
        DispatchQueue.main.async {
            self.playTone(frequency: 800, duration: 0.02, volume: 0.2)
        }
        
        // Main laser sweep - high to low frequency
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.playTone(frequency: 4000, duration: 0.03, volume: 0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.playTone(frequency: 3200, duration: 0.03, volume: 0.4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.playTone(frequency: 2400, duration: 0.04, volume: 0.35)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            self.playTone(frequency: 1800, duration: 0.05, volume: 0.3)
        }
        
        // Harmonic resonance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.playTone(frequency: 1600, duration: 0.08, volume: 0.15)
        }
        
        // Low frequency tail
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.playTone(frequency: 400, duration: 0.1, volume: 0.1)
        }
    }
    
    func playCannonFire() {
        print("🔊 Playing procedural cannon fire sound")
        // Deep explosive boom with echo
        DispatchQueue.main.async {
            self.playTone(frequency: 80, duration: 0.15, volume: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(frequency: 120, duration: 0.1, volume: 0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playTone(frequency: 60, duration: 0.2, volume: 0.3)
        }
    }
    
    func playWaveStart() {
        // Alert sound - three ascending tones
        let frequencies: [Float] = [440, 554, 659]
        for (index, freq) in frequencies.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                self.playTone(frequency: freq, duration: 0.2, volume: 0.4)
            }
        }
    }
    
    func playWaveComplete() {
        // Victory fanfare - ascending major chord
        let frequencies: [Float] = [523, 659, 784, 1046] // C, E, G, C
        for (index, freq) in frequencies.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                self.playTone(frequency: freq, duration: 0.3, volume: 0.5)
            }
        }
    }
    
    func playCreditEarned() {
        // Coin sound - two quick high tones
        playTone(frequency: 1500, duration: 0.05, volume: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(frequency: 1800, duration: 0.1, volume: 0.3)
        }
    }
}