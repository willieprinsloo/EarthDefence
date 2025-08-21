import Foundation
import AVFoundation

// Advanced Sound Generator with built-in synthesis
class AudioKitSoundGenerator {
    static let shared = AudioKitSoundGenerator()
    
    private var audioEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var isInitialized = false
    private var backgroundMusicNode: AVAudioPlayerNode?
    private var backgroundMusicBuffer: AVAudioPCMBuffer?
    private var currentMelodyIndex = 0
    private var melodyTimer: Timer?
    
    private init() {
        audioEngine = AVAudioEngine()
        mixerNode = audioEngine.mainMixerNode
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            isInitialized = true
            print("✅ AudioKitSoundGenerator initialized")
        } catch {
            print("❌ Failed to initialize audio engine: \(error)")
        }
    }
    
    // Generate a complex laser sound with multiple oscillators
    func playLaserSound() {
        guard isInitialized else { return }
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: nil)
        
        // Create a complex laser sound buffer
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 0.3
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        
        // Generate complex waveform with frequency sweep and modulation
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // Frequency sweep from 3000Hz to 500Hz
            let baseFreq = 3000 * exp(-time * 8)
            
            // Main oscillator with sine wave
            let main = sin(2.0 * Float.pi * baseFreq * time)
            
            // Add harmonics for richness
            let harmonic1 = sin(2.0 * Float.pi * baseFreq * 2 * time) * 0.3
            let harmonic2 = sin(2.0 * Float.pi * baseFreq * 3 * time) * 0.15
            
            // Add some noise for texture
            let noise = Float.random(in: -0.05...0.05)
            
            // Amplitude envelope (fast attack, medium decay)
            let envelope = min(1, time * 50) * exp(-time * 4)
            
            // Mix all components
            let value = (main + harmonic1 + harmonic2 + noise) * envelope * 0.3
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                playerNode.stop()
                self.audioEngine.detach(playerNode)
            }
        }
    }
    
    // Generate SUPER COOL explosion sound with multiple layers
    func playExplosionSound() {
        guard isInitialized else { return }
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: nil)
        
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 0.8  // Longer explosion
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        
        // Generate multi-layered explosion
        var previousValue: Float = 0
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // LAYER 1: Initial blast - white noise burst
            var blast = Float.random(in: -1...1)
            let blastEnv = time < 0.05 ? exp(-time * 10) : 0
            blast *= blastEnv * 0.8
            
            // LAYER 2: Sub-bass impact
            let impact = sin(2.0 * Float.pi * 30 * time) * exp(-time * 8) * 0.6
            
            // LAYER 3: Filtered rumble (low-pass filtered noise)
            var rumbleNoise = Float.random(in: -1...1)
            let cutoffFreq = 150 * exp(-time * 2)
            let rc = 1.0 / (2.0 * Float.pi * cutoffFreq)
            let dt = 1.0 / sampleRate
            let alpha = dt / (rc + dt)
            rumbleNoise = previousValue + alpha * (rumbleNoise - previousValue)
            previousValue = rumbleNoise
            let rumble = rumbleNoise * exp(-time * 3) * 0.4
            
            // LAYER 4: Metallic resonance (ring modulation)
            let resonance = sin(2.0 * Float.pi * 800 * time) * 
                           sin(2.0 * Float.pi * 1200 * time) * 
                           exp(-time * 5) * 0.2
            
            // LAYER 5: Debris scatter (random high freq bursts)
            let debrisChance = Float.random(in: 0...1)
            let debris = (debrisChance > 0.98 && time > 0.1 && time < 0.4) ?
                sin(2.0 * Float.pi * Float.random(in: 2000...4000) * time) * 0.1 : 0
            
            // LAYER 6: Echo/reverb tail
            let echo = time > 0.2 ? 
                sin(2.0 * Float.pi * 100 * time) * exp(-(time - 0.2) * 4) * 0.15 : 0
            
            // Mix all layers with master envelope
            let masterEnv = time < 0.1 ? 1.0 : exp(-(time - 0.1) * 2)
            let value = (blast + impact + rumble + resonance + debris + echo) * masterEnv * 0.6
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                playerNode.stop()
                self.audioEngine.detach(playerNode)
            }
        }
    }
    
    // Generate a sci-fi plasma sound
    func playPlasmaSound() {
        guard isInitialized else { return }
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: nil)
        
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 0.25
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // Base frequency with vibrato
            let vibrato = sin(2.0 * Float.pi * 15 * time) * 50
            let baseFreq = 600 + vibrato
            
            // FM synthesis for metallic sound
            let modFreq = baseFreq * 1.5
            let modIndex = 3.0 * exp(-time * 2)
            let modulator = sin(2.0 * Float.pi * modFreq * time) * modIndex
            let carrier = sin(2.0 * Float.pi * baseFreq * time + modulator)
            
            // Add some ring modulation for alien effect
            let ringMod = sin(2.0 * Float.pi * 1200 * time)
            let ring = carrier * ringMod * 0.3
            
            // Envelope
            let attack = min(1, time * 20)
            let decay = exp(-time * 3)
            let envelope = attack * decay
            
            let value = (carrier + ring) * envelope * 0.3
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                playerNode.stop()
                self.audioEngine.detach(playerNode)
            }
        }
    }
    
    // Generate retro arcade button sound
    func playButtonSound() {
        guard isInitialized else { return }
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: nil)
        
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 0.1
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // Two-tone beep
            let freq1: Float = 800
            let freq2: Float = 1200
            let mixFreq = time < 0.05 ? freq1 : freq2
            
            // Square wave for retro sound
            let sine = sin(2.0 * Float.pi * mixFreq * time)
            let square: Float = sine > 0 ? 0.5 : -0.5
            
            // Quick envelope
            let envelope = exp(-time * 15)
            
            let value = square * envelope * Float(0.2)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                playerNode.stop()
                self.audioEngine.detach(playerNode)
            }
        }
    }
    
    // Generate Space Invaders style retro background music
    func playBackgroundMusic() {
        guard isInitialized else { return }
        
        stopBackgroundMusic()
        
        // Create a new player node for background music
        backgroundMusicNode = AVAudioPlayerNode()
        guard let bgNode = backgroundMusicNode else { return }
        
        audioEngine.attach(bgNode)
        audioEngine.connect(bgNode, to: mixerNode, format: nil)
        
        // Generate a classic Space Invaders style loop (8 seconds)
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 8.0
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        backgroundMusicBuffer = buffer
        
        // Space Invaders style notes (classic arcade pattern)
        // Using the distinctive 4-note descending pattern
        let invaderPattern: [Float] = [
            523.25, 493.88, 440.00, 392.00,  // C5, B4, A4, G4 (descending)
            349.23, 392.00, 440.00, 493.88   // F4, G4, A4, B4 (ascending)
        ]
        
        // Bass notes for that deep retro feel
        let bassPattern: [Float] = [65.41, 73.42, 82.41, 73.42]  // C2, D2, E2, D2
        
        // Generate classic Space Invaders style music
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // BASS - Deep, rhythmic pulse (classic arcade bass)
            let bassIndex = Int(time * 2) % bassPattern.count
            let bassFreq = bassPattern[bassIndex]
            // Square wave for retro sound
            let bassSine = sin(2.0 * Float.pi * bassFreq * time)
            let bassSquare: Float = bassSine > 0 ? 0.08 : -0.08
            let bassEnv = fmod(time * 2, 1.0) < 0.5 ? 1.0 : 0.3  // Rhythmic gating
            let bass = bassSquare * Float(bassEnv) * 0.06  // Very soft
            
            // MELODY - Classic Space Invaders descending pattern
            let melodyBeat = time * 4  // 4 notes per second
            let melodyIndex = Int(melodyBeat) % invaderPattern.count
            let melodyFreq = invaderPattern[melodyIndex]
            
            // Staccato envelope for each note (short, punchy)
            let notePhase = fmod(melodyBeat, 1.0)
            let noteEnv = notePhase < 0.3 ? 1.0 : 0  // Short notes
            
            // Square wave with slight pulse width modulation for interest
            let pwm = 0.5 + sin(2.0 * Float.pi * 0.5 * time) * 0.1
            let melodySine = sin(2.0 * Float.pi * melodyFreq * time)
            let melodySquare: Float = melodySine > pwm ? 0.1 : -0.1
            let melody = melodySquare * Float(noteEnv) * 0.05  // Very soft melody
            
            // PERCUSSION - Simulated white noise hi-hat
            let percussionBeat = fmod(time * 8, 1.0)
            let hihat = percussionBeat < 0.05 ? Float.random(in: -0.02...0.02) : 0
            
            // EFFECTS - Occasional "UFO" sweep sound
            let ufoChance = fmod(time, 4.0)
            let ufoFreq = 800 * (1 + sin(2.0 * Float.pi * 8 * time) * 0.5)
            let ufo = ufoChance > 3.5 ? sin(2.0 * Float.pi * ufoFreq * time) * 0.02 : 0
            
            // Mix all layers - EXTREMELY SOFT for background ambience
            let value = (bass + melody + hihat + ufo) * 0.03  // Even softer overall volume
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        // Apply fade in/out for smooth looping
        let fadeFrames = Int(sampleRate * 0.2) // 0.2 second fade
        for frame in 0..<fadeFrames {
            let fadeFactor = Float(frame) / Float(fadeFrames)
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] *= fadeFactor
                let endFrame = numberOfSamples - fadeFrames + frame
                buffer.floatChannelData?[channel][endFrame] *= (1.0 - fadeFactor)
            }
        }
        
        bgNode.play()
        bgNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        print("👾 Space Invaders style music started")
    }
    
    // Generate action-packed game music
    func playGameMusic() {
        guard isInitialized else { return }
        
        stopBackgroundMusic()
        
        backgroundMusicNode = AVAudioPlayerNode()
        guard let bgNode = backgroundMusicNode else { return }
        
        audioEngine.attach(bgNode)
        audioEngine.connect(bgNode, to: mixerNode, format: nil)
        
        // Generate a rhythmic game loop (8 seconds)
        let sampleRate = Float(mixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 8.0
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: mixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else { return }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        let channels = Int(mixerNode.outputFormat(forBus: 0).channelCount)
        backgroundMusicBuffer = buffer
        
        // Generate rhythmic game music
        for frame in 0..<numberOfSamples {
            let time = Float(frame) / sampleRate
            
            // Bass line - rhythmic pattern
            let bassPattern = Int(time * 4) % 8
            let bassFreq: Float = bassPattern < 4 ? 55 : 73.5  // A and D notes
            let bass = sin(2.0 * Float.pi * bassFreq * time) * 0.15
            
            // Kick drum simulation (every beat)
            let beatTime = fmod(time, 0.5)
            let kick = beatTime < 0.05 ? sin(2.0 * Float.pi * 60 * time) * exp(-beatTime * 20) * 0.3 : 0
            
            // Arpeggiated synth
            let arpIndex = Int(time * 8) % 4
            let arpFreqs: [Float] = [440, 523, 659, 523]  // A, C, E, C
            let arp = sin(2.0 * Float.pi * arpFreqs[arpIndex] * time) * 0.08
            
            // Hi-hat simulation
            let hihatTime = fmod(time, 0.25)
            let hihat = hihatTime < 0.02 ? Float.random(in: -0.05...0.05) : 0
            
            // Pad for atmosphere
            let pad1 = sin(2.0 * Float.pi * 220 * time) * 0.04
            let pad2 = sin(2.0 * Float.pi * 330 * time) * 0.03
            
            // Mix all elements
            let value = (bass + kick + arp + hihat + pad1 + pad2) * 0.4
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        bgNode.play()
        bgNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        print("🎮 Game music started")
    }
    
    func stopBackgroundMusic() {
        melodyTimer?.invalidate()
        melodyTimer = nil
        backgroundMusicNode?.stop()
        if let bgNode = backgroundMusicNode {
            audioEngine.detach(bgNode)
        }
        backgroundMusicNode = nil
        backgroundMusicBuffer = nil
        print("🔇 Background music stopped")
    }
    
    // MARK: - 20 Unique Game Melodies (1:20 each)
    
    // Play all melodies in sequence
    func playAllMelodies() {
        currentMelodyIndex = 0
        playMelodySequence()
    }
    
    private func playMelodySequence() {
        guard currentMelodyIndex < 20 else {
            currentMelodyIndex = 0
            playMelodySequence() // Loop back to start
            return
        }
        
        print("🎵 Playing melody \(currentMelodyIndex + 1) of 20: \(getMelodyName(currentMelodyIndex))")
        playMelody(index: currentMelodyIndex)
        
        // Schedule next melody after 20 seconds for testing (was 80 seconds)
        melodyTimer?.invalidate()
        melodyTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { _ in
            self.currentMelodyIndex += 1
            self.playMelodySequence()
        }
    }
    
    private func getMelodyName(_ index: Int) -> String {
        let melodyNames = [
            "Retro Arcade Classic",
            "Space Exploration",
            "Cyberpunk Battle",
            "Mysterious Alien",
            "Heroic Victory",
            "Dark Space Horror",
            "Fast Action Chase",
            "Epic Boss Battle",
            "Techno Drive",
            "Floating Nebula",
            "Intense Chase",
            "Cosmic Wonder",
            "Military March",
            "Electronic Dance",
            "Suspenseful Stealth",
            "Triumphant Fanfare",
            "Mechanical War",
            "Pulsating Energy",
            "Galactic Battle",
            "Final Showdown"
        ]
        
        guard index >= 0 && index < melodyNames.count else {
            return "Unknown Melody"
        }
        
        return melodyNames[index]
    }
    
    func playMelody(index: Int) {
        guard isInitialized else { return }
        guard index >= 0 && index < 20 else { return }
        
        // Perform audio operations on background queue to prevent graphics stalling
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.stopBackgroundMusic()
                
                self.backgroundMusicNode = AVAudioPlayerNode()
                guard let bgNode = self.backgroundMusicNode else { return }
                
                self.audioEngine.attach(bgNode)
                self.audioEngine.connect(bgNode, to: self.mixerNode, format: nil)
        
                let sampleRate = Float(self.mixerNode.outputFormat(forBus: 0).sampleRate)
                let duration: Float = 20.0  // 20 seconds per song for testing (was 80.0)
                let numberOfSamples = Int(sampleRate * duration)
                
                guard let buffer = AVAudioPCMBuffer(
                    pcmFormat: self.mixerNode.outputFormat(forBus: 0),
                    frameCapacity: AVAudioFrameCount(numberOfSamples)
                ) else { return }
                
                buffer.frameLength = AVAudioFrameCount(numberOfSamples)
                
                // Generate melody based on index
                switch index {
                case 0: self.generateRetroArcadeMelody(buffer: buffer, sampleRate: sampleRate)
                case 1: self.generateSpaceExplorationMelody(buffer: buffer, sampleRate: sampleRate)
                case 2: self.generateCyberpunkBattleMelody(buffer: buffer, sampleRate: sampleRate)
                case 3: self.generateMysteriousAlienMelody(buffer: buffer, sampleRate: sampleRate)
                case 4: self.generateHeroicVictoryMelody(buffer: buffer, sampleRate: sampleRate)
                case 5: self.generateDarkSpaceMelody(buffer: buffer, sampleRate: sampleRate)
                case 6: self.generateFastActionMelody(buffer: buffer, sampleRate: sampleRate)
                case 7: self.generateEpicBossMelody(buffer: buffer, sampleRate: sampleRate)
                case 8: self.generateTechnoDriveMelody(buffer: buffer, sampleRate: sampleRate)
                case 9: self.generateFloatingNebulaMelody(buffer: buffer, sampleRate: sampleRate)
                case 10: self.generateIntenseChaseMusic(buffer: buffer, sampleRate: sampleRate)
                case 11: self.generateCosmicWonderMelody(buffer: buffer, sampleRate: sampleRate)
                case 12: self.generateMilitaryMarchMelody(buffer: buffer, sampleRate: sampleRate)
                case 13: self.generateElectronicDanceMelody(buffer: buffer, sampleRate: sampleRate)
                case 14: self.generateSuspensefulMelody(buffer: buffer, sampleRate: sampleRate)
                case 15: self.generateTriumphantMelody(buffer: buffer, sampleRate: sampleRate)
                case 16: self.generateMechanicalWarMelody(buffer: buffer, sampleRate: sampleRate)
                case 17: self.generatePulsatingEnergyMelody(buffer: buffer, sampleRate: sampleRate)
                case 18: self.generateGalacticBattleMelody(buffer: buffer, sampleRate: sampleRate)
                case 19: self.generateFinalShowdownMelody(buffer: buffer, sampleRate: sampleRate)
                default: self.generateRetroArcadeMelody(buffer: buffer, sampleRate: sampleRate)
                }
                
                bgNode.play()
                bgNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            }
        }
    }
    
    // Melody 1: Retro Arcade Classic
    private func generateRetroArcadeMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Classic arcade bass line - softer triangular wave
            let bassFreq = [55, 73.5, 82.5, 73.5][Int(time * 2) % 4]
            let bass = triangleWave(frequency: Float(bassFreq), time: time) * 0.06
            
            // Melody with classic game progression - gentler sound
            let melodyPattern: [Float] = [440, 523, 659, 523, 784, 659, 523, 440]
            let melodyIndex = Int(time * 4) % melodyPattern.count
            let melody = sin(2 * Float.pi * melodyPattern[melodyIndex] * time) * 0.04
            
            // Soft percussion
            let kick = (fmod(time, 0.5) < 0.05) ? sin(2 * Float.pi * 60 * time) * 0.08 : 0
            
            let value = (bass + melody + kick) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 2: Space Exploration Theme
    private func generateSpaceExplorationMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Softer ambient pad
            let pad1 = sin(2 * Float.pi * 110 * time) * 0.02
            let pad2 = sin(2 * Float.pi * 165 * time) * 0.015
            let pad3 = sin(2 * Float.pi * 220 * time) * 0.01
            
            // Slow, contemplative melody
            let melodyPhase = fmod(time / 4, 8)
            let melodyNote: Float
            if melodyPhase < 1 { melodyNote = 440 }
            else if melodyPhase < 2 { melodyNote = 494 }
            else if melodyPhase < 3 { melodyNote = 554 }
            else if melodyPhase < 4 { melodyNote = 659 }
            else if melodyPhase < 5 { melodyNote = 587 }
            else if melodyPhase < 6 { melodyNote = 494 }
            else if melodyPhase < 7 { melodyNote = 440 }
            else { melodyNote = 392 }
            
            let melody = sin(2 * Float.pi * melodyNote * time) * 0.04
            
            // Subtle arpeggios
            let arpFreq = [880, 1100, 1320, 1100][Int(time * 8) % 4]
            let arp = sin(2 * Float.pi * Float(arpFreq) * time) * 0.015
            
            let value = (pad1 + pad2 + pad3 + melody + arp) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 3: Cyberpunk Battle Theme
    private func generateCyberpunkBattleMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Softer synth bass
            let bassFreq = [55, 55, 73.5, 82.5][Int(time * 4) % 4]
            let bass = triangleWave(frequency: Float(bassFreq), time: time) * 0.06
            
            // Gentler lead melody
            let leadPattern: [Float] = [220, 261, 329, 261, 392, 329, 261, 220]
            let leadIndex = Int(time * 8) % leadPattern.count
            let lead = sin(2 * Float.pi * leadPattern[leadIndex] * time) * 0.04
            
            // Softer percussion
            let kick = (fmod(time, 0.25) < 0.05) ? sin(2 * Float.pi * 50 * time) * exp(-fmod(time, 0.25) * 20) * 0.1 : 0
            let snare = (fmod(time + 0.125, 0.25) < 0.03) ? Float.random(in: -0.05...0.05) : 0
            
            // No distortion, clean mix
            let value = (bass + lead + kick + snare) * 0.04
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 4: Mysterious Alien Encounter
    private func generateMysteriousAlienMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Soft mysterious drone
            let drone = sin(2 * Float.pi * 73.5 * time) * 0.03
            
            // Gentle alien sounds
            let carrier = 440 + sin(2 * Float.pi * 0.5 * time) * 50
            let modulator = sin(2 * Float.pi * carrier * 1.73 * time) * 1
            let alien = sin(2 * Float.pi * carrier * time + modulator) * 0.02
            
            // Softer mysterious melody
            let melodyNotes: [Float] = [440, 466, 554, 622, 587, 523, 466, 440]
            let melodyIndex = Int(time * 2) % melodyNotes.count
            let melody = sin(2 * Float.pi * melodyNotes[melodyIndex] * time) * 0.03
            
            // Minimal glitch effects
            let glitch = (Float.random(in: 0...1) > 0.995) ? Float.random(in: -0.02...0.02) : 0
            
            let value = (drone + alien + melody + glitch) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 5: Heroic Victory March
    private func generateHeroicVictoryMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Softer brass-like harmony
            let brass1 = triangleWave(frequency: 261, time: time) * 0.03
            let brass2 = triangleWave(frequency: 329, time: time) * 0.025
            let brass3 = triangleWave(frequency: 392, time: time) * 0.02
            
            // Gentle heroic melody
            let melodyPattern: [Float] = [523, 523, 784, 659, 523, 784, 1046, 784]
            let melodyIndex = Int(time * 3) % melodyPattern.count
            let melody = sin(2 * Float.pi * melodyPattern[melodyIndex] * time) * 0.04
            
            // Soft drums
            let marchBeat = fmod(time * 2, 1)
            let drum = (marchBeat < 0.1 || (marchBeat > 0.5 && marchBeat < 0.6)) ? 
                sin(2 * Float.pi * 100 * time) * 0.06 : 0
            
            let value = (brass1 + brass2 + brass3 + melody + drum) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 6: Dark Space Horror
    private func generateDarkSpaceMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Soft low bass
            let bassFreq = 41.2 + sin(2 * Float.pi * 0.1 * time) * 3
            let bass = sin(2 * Float.pi * bassFreq * time) * 0.05
            
            // Subtle harmony
            let dissonant1 = sin(2 * Float.pi * 233 * time) * 0.015
            let dissonant2 = sin(2 * Float.pi * 311 * time) * 0.01
            
            // Gentle mysterious melody
            let melodyPhase = Int(time * 1.5) % 8
            let melodyNotes: [Float] = [220, 233, 220, 208, 196, 208, 220, 233]
            let melody = sin(2 * Float.pi * melodyNotes[melodyPhase] * time) * 0.025
            
            // Very soft whispers
            let whisper = Float.random(in: -0.005...0.005) * sin(2 * Float.pi * 8 * time)
            
            let value = (bass + dissonant1 + dissonant2 + melody + whisper) * 0.025
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 7: Fast Action Chase
    private func generateFastActionMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Rapid bass line
            let bassPattern: [Float] = [110, 110, 146.5, 110, 165, 146.5, 110, 110]
            let bassIndex = Int(time * 16) % bassPattern.count
            let bass = sawtoothWave(frequency: bassPattern[bassIndex], time: time) * 0.12
            
            // Quick arpeggios
            let arpPattern: [Float] = [440, 554, 659, 880]
            let arpIndex = Int(time * 32) % arpPattern.count
            let arp = squareWave(frequency: arpPattern[arpIndex], time: time) * 0.06
            
            // Driving percussion
            let kick = (fmod(time * 4, 1) < 0.1) ? sin(2 * Float.pi * 60 * time) * 0.25 : 0
            let hihat = (fmod(time * 16, 1) < 0.05) ? Float.random(in: -0.1...0.1) : 0
            
            // Lead melody
            let leadNotes: [Float] = [880, 784, 659, 784, 880, 1046, 880, 784]
            let leadIndex = Int(time * 8) % leadNotes.count
            let lead = triangleWave(frequency: leadNotes[leadIndex], time: time) * 0.08
            
            let value = (bass + arp + kick + hihat + lead) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 8: Epic Boss Battle
    private func generateEpicBossMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Massive orchestral-style hits
            let hitPhase = fmod(time, 2)
            let orchestralHit = (hitPhase < 0.2) ? 
                (sin(2 * Float.pi * 55 * time) + 
                 sin(2 * Float.pi * 110 * time) * 0.5 + 
                 sin(2 * Float.pi * 220 * time) * 0.25) * exp(-hitPhase * 5) * 0.3 : 0
            
            // Choir-like pad
            let choir1 = sin(2 * Float.pi * 220 * time) * 0.04
            let choir2 = sin(2 * Float.pi * 330 * time) * 0.03
            let choir3 = sin(2 * Float.pi * 440 * time) * 0.02
            
            // Epic melody
            let melodySection = Int(time / 4) % 4
            let melodyNote: Float
            switch melodySection {
            case 0: melodyNote = 440  // A
            case 1: melodyNote = 466  // Bb
            case 2: melodyNote = 523  // C
            case 3: melodyNote = 392  // G
            default: melodyNote = 440
            }
            let melody = sawtoothWave(frequency: melodyNote, time: time) * 0.1
            
            // Timpani rolls
            let timpani = sin(2 * Float.pi * 82.5 * time) * (sin(2 * Float.pi * 8 * time) * 0.5 + 0.5) * 0.08
            
            let value = (orchestralHit + choir1 + choir2 + choir3 + melody + timpani) * 0.035
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 9: Techno Drive
    private func generateTechnoDriveMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Four-on-the-floor kick
            let kick = (fmod(time * 2, 1) < 0.1) ? sin(2 * Float.pi * 55 * time) * exp(-fmod(time * 2, 1) * 10) * 0.4 : 0
            
            // Rolling bassline
            let bassSeq: [Float] = [110, 110, 138.5, 110, 146.5, 110, 138.5, 110]
            let bassIndex = Int(time * 8) % bassSeq.count
            let bass = sawtoothWave(frequency: bassSeq[bassIndex], time: time) * 0.12
            
            // Techno stabs
            let stabPhase = fmod(time * 4, 1)
            let stab = (stabPhase > 0.5 && stabPhase < 0.55) ? 
                (sawtoothWave(frequency: 440, time: time) + 
                 sawtoothWave(frequency: 554, time: time) * 0.7) * 0.15 : 0
            
            // Filter sweep
            let filterFreq = 2000 + sin(2 * Float.pi * 0.25 * time) * 1500
            let sweep = sin(2 * Float.pi * filterFreq * time) * 0.03
            
            let value = (kick + bass + stab + sweep) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 10: Floating Nebula
    private func generateFloatingNebulaMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Ambient layers
            let layer1 = sin(2 * Float.pi * 110 * time + sin(time * 0.5) * 0.5) * 0.05
            let layer2 = sin(2 * Float.pi * 165 * time + cos(time * 0.3) * 0.3) * 0.04
            let layer3 = sin(2 * Float.pi * 220 * time + sin(time * 0.7) * 0.2) * 0.03
            
            // Slow evolving melody
            let melodyFreq = 440 + sin(2 * Float.pi * 0.1 * time) * 100
            let melody = sin(2 * Float.pi * melodyFreq * time) * 0.06
            
            // Sparkles (random high frequencies)
            let sparkle = (Float.random(in: 0...1) > 0.99) ? 
                sin(2 * Float.pi * Float.random(in: 2000...4000) * time) * 0.05 : 0
            
            // Deep space rumble
            let rumble = sin(2 * Float.pi * 55 * time) * 0.03
            
            let value = (layer1 + layer2 + layer3 + melody + sparkle + rumble) * 0.025
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 11: Intense Chase Music
    private func generateIntenseChaseMusic(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Urgent bassline
            let bassPattern: [Float] = [82.5, 82.5, 110, 82.5, 73.5, 82.5, 110, 146.5]
            let bassIndex = Int(time * 16) % bassPattern.count
            let bass = sawtoothWave(frequency: bassPattern[bassIndex], time: time) * 0.15
            
            // Rapid percussion
            let kick = (fmod(time * 8, 1) < 0.05) ? sin(2 * Float.pi * 60 * time) * 0.3 : 0
            let snare = (fmod(time * 8 + 0.5, 1) < 0.05) ? Float.random(in: -0.2...0.2) : 0
            let hihat = Float.random(in: -0.05...0.05) * (sin(2 * Float.pi * 16 * time) * 0.5 + 0.5)
            
            // Tense melody
            let melodyNotes: [Float] = [659, 622, 587, 622, 659, 698, 784, 659]
            let melodyIndex = Int(time * 12) % melodyNotes.count
            let melody = squareWave(frequency: melodyNotes[melodyIndex], time: time) * 0.08
            
            // Siren-like sweep
            let siren = sin(2 * Float.pi * (1000 + sin(2 * Float.pi * 4 * time) * 500) * time) * 0.03
            
            let value = (bass + kick + snare + hihat + melody + siren) * 0.035
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 12: Cosmic Wonder
    private func generateCosmicWonderMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Celestial pad
            let pad1 = sin(2 * Float.pi * 220 * time) * 0.04
            let pad2 = sin(2 * Float.pi * 277 * time) * 0.035
            let pad3 = sin(2 * Float.pi * 330 * time) * 0.03
            let pad4 = sin(2 * Float.pi * 440 * time) * 0.025
            
            // Mystical melody using pentatonic scale
            let pentatonic: [Float] = [440, 494, 554, 659, 740] // A pentatonic
            let melodyIndex = Int(sin(time * 0.5) * 2.5 + 2.5) % pentatonic.count
            let melody = sin(2 * Float.pi * pentatonic[melodyIndex] * time) * 0.08
            
            // Shimmering effect
            let shimmer = sin(2 * Float.pi * 2200 * time) * sin(2 * Float.pi * 7 * time) * 0.02
            
            // Deep space bass
            let bassFreq = 55 + sin(2 * Float.pi * 0.05 * time) * 10
            let bass = sin(2 * Float.pi * bassFreq * time) * 0.06
            
            let value = (pad1 + pad2 + pad3 + pad4 + melody + shimmer + bass) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 13: Military March
    private func generateMilitaryMarchMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Snare drum pattern
            let snarePattern = fmod(time * 4, 1)
            let snare = ((snarePattern < 0.1) || (snarePattern > 0.5 && snarePattern < 0.6)) ? 
                Float.random(in: -0.15...0.15) : 0
            
            // Bass drum
            let bassDrumPattern = fmod(time * 2, 1)
            let bassDrum = (bassDrumPattern < 0.1) ? sin(2 * Float.pi * 80 * time) * exp(-bassDrumPattern * 10) * 0.3 : 0
            
            // Brass section melody
            let brassNotes: [Float] = [261, 261, 329, 392, 329, 261, 392, 523]
            let brassIndex = Int(time * 4) % brassNotes.count
            let brass = sawtoothWave(frequency: brassNotes[brassIndex], time: time) * 0.1
            
            // Piccolo counter-melody
            let piccoloNotes: [Float] = [1046, 1174, 1318, 1174]
            let piccoloIndex = Int(time * 8) % piccoloNotes.count
            let piccolo = triangleWave(frequency: piccoloNotes[piccoloIndex], time: time) * 0.04
            
            let value = (snare + bassDrum + brass + piccolo) * 0.03
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 14: Electronic Dance
    private func generateElectronicDanceMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // House kick
            let kickPhase = fmod(time * 2, 1)
            let kick = (kickPhase < 0.15) ? sin(2 * Float.pi * 55 * time) * exp(-kickPhase * 8) * 0.4 : 0
            
            // Sidechained bass
            let sidechain = 1.0 - (kickPhase < 0.2 ? kickPhase * 5 : 1.0)
            let bassFreq: Float = 110
            let bass = sawtoothWave(frequency: bassFreq, time: time) * sidechain * 0.12
            
            // Pluck synth
            let pluckNotes: [Float] = [440, 554, 659, 554, 784, 659, 554, 440]
            let pluckIndex = Int(time * 8) % pluckNotes.count
            let pluckEnv = exp(-fmod(time * 8, 1) * 5)
            let pluck = sawtoothWave(frequency: pluckNotes[pluckIndex], time: time) * pluckEnv * 0.08
            
            // Hi-hats
            let hihatOpen = (fmod(time * 4 + 0.5, 1) < 0.3) ? Float.random(in: -0.08...0.08) : 0
            let hihatClosed = (fmod(time * 8, 1) < 0.05) ? Float.random(in: -0.05...0.05) : 0
            
            // Build-up sweep
            let buildupPhase = fmod(time / 8, 1)
            let sweep = sin(2 * Float.pi * (500 + buildupPhase * 3000) * time) * buildupPhase * 0.05
            
            let value = (kick + bass + pluck + hihatOpen + hihatClosed + sweep) * 0.07
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 15: Suspenseful Stealth
    private func generateSuspensefulMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Low tension drone
            let drone = sin(2 * Float.pi * 55 * time) * 0.08
            
            // Heartbeat rhythm
            let heartbeatPhase = fmod(time * 1.2, 1)
            let heartbeat1 = (heartbeatPhase < 0.1) ? sin(2 * Float.pi * 60 * time) * 0.15 : 0
            let heartbeat2 = (heartbeatPhase > 0.2 && heartbeatPhase < 0.25) ? sin(2 * Float.pi * 60 * time) * 0.1 : 0
            
            // Tense melody with chromatic movement
            let melodyNotes: [Float] = [220, 233, 220, 208, 220, 233, 247, 233]
            let melodyIndex = Int(time * 2) % melodyNotes.count
            let melodyEnv = sin(time * 0.5) * 0.5 + 0.5
            let melody = sin(2 * Float.pi * melodyNotes[melodyIndex] * time) * melodyEnv * 0.06
            
            // Occasional stinger
            let stinger = (fmod(time, 8) < 0.1) ? 
                sin(2 * Float.pi * 1000 * time) * exp(-fmod(time, 8) * 10) * 0.1 : 0
            
            // Ambient noise
            let noise = Float.random(in: -0.01...0.01)
            
            let value = (drone + heartbeat1 + heartbeat2 + melody + stinger + noise) * 0.05
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 16: Triumphant Fanfare
    private func generateTriumphantMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Fanfare trumpets
            let fanfareNotes: [Float] = [523, 523, 523, 659, 784, 784, 784, 1046]
            let fanfareIndex = Int(time * 4) % fanfareNotes.count
            let fanfare = sawtoothWave(frequency: fanfareNotes[fanfareIndex], time: time) * 0.12
            
            // Harmony
            let harmonyNotes: [Float] = [329, 329, 329, 392, 523, 523, 523, 659]
            let harmony = sawtoothWave(frequency: harmonyNotes[fanfareIndex], time: time) * 0.08
            
            // Timpani
            let timpaniPhase = fmod(time * 2, 1)
            let timpani = (timpaniPhase < 0.2) ? 
                sin(2 * Float.pi * 110 * time) * exp(-timpaniPhase * 5) * 0.2 : 0
            
            // Cymbal crashes
            let cymbalPhase = fmod(time, 4)
            let cymbal = (cymbalPhase < 0.3) ? 
                Float.random(in: -0.1...0.1) * exp(-cymbalPhase * 3) : 0
            
            // Bass support
            let bassNotes: [Float] = [130.5, 130.5, 130.5, 165, 196, 196, 196, 261]
            let bass = sin(2 * Float.pi * bassNotes[fanfareIndex] * time) * 0.1
            
            let value = (fanfare + harmony + timpani + cymbal + bass) * 0.07
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 17: Mechanical War Machine
    private func generateMechanicalWarMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Industrial rhythm
            let industrialKick = (fmod(time * 3, 1) < 0.1) ? 
                sin(2 * Float.pi * 50 * time) * exp(-fmod(time * 3, 1) * 10) * 0.4 : 0
            
            // Metallic percussion
            let metalHit = (fmod(time * 6 + 0.5, 1) < 0.05) ? 
                (sin(2 * Float.pi * 800 * time) + Float.random(in: -0.1...0.1)) * 0.2 : 0
            
            // Mechanical bass sequence
            let mechBass: [Float] = [55, 55, 82.5, 55, 73.5, 55, 82.5, 110]
            let bassIndex = Int(time * 8) % mechBass.count
            let bass = squareWave(frequency: mechBass[bassIndex], time: time) * 0.15
            
            // Distorted lead
            let leadNotes: [Float] = [220, 261, 220, 196, 220, 261, 329, 261]
            let leadIndex = Int(time * 6) % leadNotes.count
            var lead = sawtoothWave(frequency: leadNotes[leadIndex], time: time) * 0.1
            lead = tanh(lead * 3) // Heavy distortion
            
            // Steam hiss
            let steamHiss = (fmod(time, 2) > 1.8) ? Float.random(in: -0.05...0.05) : 0
            
            let value = (industrialKick + metalHit + bass + lead + steamHiss) * 0.07
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 18: Pulsating Energy
    private func generatePulsatingEnergyMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Pulsating bass
            let pulseFreq = 110 * (1 + sin(2 * Float.pi * 4 * time) * 0.2)
            let pulseBass = sawtoothWave(frequency: pulseFreq, time: time) * 0.12
            
            // Energy bursts
            let burstPhase = fmod(time * 2, 1)
            let burst = (burstPhase < 0.3) ? 
                sin(2 * Float.pi * (880 + burstPhase * 1000) * time) * exp(-burstPhase * 3) * 0.15 : 0
            
            // Rhythmic arpeggios
            let arpNotes: [Float] = [440, 554, 659, 880, 659, 554, 440, 329]
            let arpIndex = Int(time * 16) % arpNotes.count
            let arp = triangleWave(frequency: arpNotes[arpIndex], time: time) * 0.06
            
            // Electric zaps
            let zapChance = Float.random(in: 0...1)
            let zap = (zapChance > 0.98) ? 
                sin(2 * Float.pi * Float.random(in: 2000...4000) * time) * 0.1 : 0
            
            // Driving kick
            let kick = (fmod(time * 4, 1) < 0.1) ? 
                sin(2 * Float.pi * 60 * time) * 0.25 : 0
            
            let value = (pulseBass + burst + arp + zap + kick) * 0.06
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 19: Galactic Battle
    private func generateGalacticBattleMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Epic space bass
            let bassNotes: [Float] = [41.2, 41.2, 55, 41.2, 36.7, 41.2, 55, 73.5]
            let bassIndex = Int(time * 4) % bassNotes.count
            let bass = sawtoothWave(frequency: bassNotes[bassIndex], time: time) * 0.18
            
            // Laser battle sounds
            let laserPhase = fmod(time * 8, 1)
            let laser = (laserPhase < 0.1) ? 
                sin(2 * Float.pi * (3000 * exp(-laserPhase * 10)) * time) * 0.12 : 0
            
            // Heroic melody
            let melodyNotes: [Float] = [523, 659, 784, 659, 523, 392, 523, 784]
            let melodyIndex = Int(time * 6) % melodyNotes.count
            let melody = triangleWave(frequency: melodyNotes[melodyIndex], time: time) * 0.1
            
            // Explosion effects
            let explosionChance = Float.random(in: 0...1)
            let explosion = (explosionChance > 0.97) ? 
                Float.random(in: -0.2...0.2) * exp(-(fmod(time, 0.5) * 10)) : 0
            
            // Space ambience
            let ambience = sin(2 * Float.pi * 110 * time) * 0.03 + 
                          sin(2 * Float.pi * 165 * time) * 0.02
            
            let value = (bass + laser + melody + explosion + ambience) * 0.07
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Melody 20: Final Showdown
    private func generateFinalShowdownMelody(buffer: AVAudioPCMBuffer, sampleRate: Float) {
        let channels = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        
        for frame in 0..<frameCount {
            let time = Float(frame) / sampleRate
            
            // Building tension with ascending bass
            let tensionPhase = fmod(time / 16, 1)
            let bassFreq = 55 * pow(2, tensionPhase)
            let bass = sawtoothWave(frequency: bassFreq, time: time) * 0.15
            
            // Dramatic orchestral hits
            let hitTiming = fmod(time, 2)
            let orchestralHit = (hitTiming < 0.15) ? 
                (sin(2 * Float.pi * 82.5 * time) + 
                 sin(2 * Float.pi * 165 * time) * 0.7 + 
                 sin(2 * Float.pi * 329 * time) * 0.4) * exp(-hitTiming * 6) * 0.25 : 0
            
            // Final boss melody - complex and varied
            let melodySection = Int(time / 2) % 8
            let melodyNotes: [Float] = [440, 466, 523, 587, 659, 698, 784, 880]
            let melody = sawtoothWave(frequency: melodyNotes[melodySection], time: time) * 0.12
            
            // Counter melody
            let counterNotes: [Float] = [220, 247, 261, 293, 329, 349, 392, 440]
            let counter = triangleWave(frequency: counterNotes[7 - melodySection], time: time) * 0.08
            
            // Climactic percussion
            let drums = (fmod(time * 8, 1) < 0.1) ? sin(2 * Float.pi * 80 * time) * 0.3 : 0
            let cymbals = (fmod(time, 4) < 0.5) ? Float.random(in: -0.05...0.05) : 0
            
            // Final flourish
            let flourishPhase = fmod(time / 8, 1)
            let flourish = (flourishPhase > 0.9) ? 
                sin(2 * Float.pi * (1000 + flourishPhase * 2000) * time) * 0.1 : 0
            
            let value = (bass + orchestralHit + melody + counter + drums + cymbals + flourish) * 0.08
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
    }
    
    // Helper functions for wave generation
    private func squareWave(frequency: Float, time: Float) -> Float {
        return sin(2 * Float.pi * frequency * time) > 0 ? 0.5 : -0.5
    }
    
    private func sawtoothWave(frequency: Float, time: Float) -> Float {
        let phase = fmod(frequency * time, 1.0)
        return 2 * phase - 1
    }
    
    private func triangleWave(frequency: Float, time: Float) -> Float {
        let phase = fmod(frequency * time, 1.0)
        return phase < 0.5 ? 4 * phase - 1 : 3 - 4 * phase
    }
}