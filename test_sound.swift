#!/usr/bin/env swift

import AVFoundation
import Foundation

// Test procedural sound generation
class SimpleSoundTest {
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    
    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            playerNode.play()
            print("✅ Audio engine started")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }
    
    func playBeep() {
        let sampleRate = Float(audioEngine.mainMixerNode.outputFormat(forBus: 0).sampleRate)
        let duration: Float = 0.2
        let frequency: Float = 440.0 // A4 note
        let numberOfSamples = Int(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioEngine.mainMixerNode.outputFormat(forBus: 0),
            frameCapacity: AVAudioFrameCount(numberOfSamples)
        ) else {
            print("Failed to create buffer")
            return
        }
        
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        
        let channels = Int(audioEngine.mainMixerNode.outputFormat(forBus: 0).channelCount)
        for frame in 0..<numberOfSamples {
            let value = sin(2.0 * Float.pi * frequency * Float(frame) / sampleRate) * 0.5
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = value
            }
        }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            print("✅ Finished playing beep")
        }
        
        print("🔊 Playing beep at 440Hz")
    }
}

// Run the test
print("Starting sound test...")
let test = SimpleSoundTest()
test.playBeep()

// Keep the program running for a bit to hear the sound
Thread.sleep(forTimeInterval: 1.0)
print("Test complete")