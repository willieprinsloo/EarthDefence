import Foundation
import AVFoundation
import SpriteKit

// MARK: - Sound Manager
class SoundManager {
    
    static let shared = SoundManager()
    
    // Sound settings (persisted in UserDefaults)
    var soundEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "soundEnabled") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "soundEnabled")
            if !newValue {
                stopAllSounds()
            }
        }
    }
    
    var musicEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "musicEnabled") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "musicEnabled")
            if newValue {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    var soundVolume: Float {
        get { UserDefaults.standard.float(forKey: "soundVolume") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "soundVolume")
            updateVolumes()
        }
    }
    
    var musicVolume: Float {
        get { UserDefaults.standard.float(forKey: "musicVolume") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "musicVolume")
            backgroundMusicPlayer?.volume = newValue
        }
    }
    
    // Audio players
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var activeSounds: Set<AVAudioPlayer> = []
    
    // Sound effect types
    enum SoundEffect: String {
        // Tower sounds
        case towerPlace = "tower_place"
        case towerUpgrade = "tower_upgrade"
        case towerSell = "tower_sell"
        case cannonFire = "cannon_fire"
        case laserFire = "laser_fire"
        case plasmaFire = "plasma_fire"
        case missileLaunch = "missile_launch"
        case teslaZap = "tesla_zap"
        
        // Enemy sounds
        case enemyHit = "enemy_hit"
        case enemyDestroyed = "enemy_destroyed"
        case enemySpawn = "enemy_spawn"
        case bossSpawn = "boss_spawn"
        case bossDestroyed = "boss_destroyed"
        
        // UI sounds
        case buttonTap = "button_tap"
        case menuOpen = "menu_open"
        case menuClose = "menu_close"
        case waveStart = "wave_start"
        case waveComplete = "wave_complete"
        case mapComplete = "map_complete"
        
        // Game events
        case coreHit = "core_hit"
        case coreDestroyed = "core_destroyed"
        case creditEarned = "credit_earned"
        case powerUp = "power_up"
        case insufficientFunds = "insufficient_funds"
        
        // Background music
        case menuMusic = "menu_music"
        case gameMusic = "game_music"
        case bossMusic = "boss_music"
    }
    
    private init() {
        // Set default values if not already set
        if !UserDefaults.standard.bool(forKey: "hasSetAudioDefaults") {
            UserDefaults.standard.set(true, forKey: "hasSetAudioDefaults")
            UserDefaults.standard.set(true, forKey: "soundEnabled")
            UserDefaults.standard.set(true, forKey: "musicEnabled")
            UserDefaults.standard.set(0.5, forKey: "soundVolume")  // Reduced from 0.7 to 0.5 (30% reduction)
            UserDefaults.standard.set(0.35, forKey: "musicVolume")  // Reduced from 0.5 to 0.35 (30% reduction)
        }
        
        setupAudioSession()
        preloadSounds()
        
        // Initialize ProceduralSoundGenerator early
        _ = ProceduralSoundGenerator.shared
        print("🎮 SoundManager initialized with procedural sound support")
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // Preload commonly used sounds
    private func preloadSounds() {
        let commonSounds: [SoundEffect] = [
            .cannonFire, .laserFire, .enemyHit, .enemyDestroyed,
            .buttonTap, .towerPlace, .creditEarned
        ]
        
        for sound in commonSounds {
            _ = loadSound(sound)
        }
    }
    
    // Load a sound file
    private func loadSound(_ sound: SoundEffect) -> AVAudioPlayer? {
        // Check if already loaded
        if let player = soundPlayers[sound.rawValue] {
            return player
        }
        
        // Try to load the sound file
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else {
            // If .wav doesn't exist, try .mp3
            guard let mp3Url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
                // Sound file not found - will use procedural sound
                return nil
            }
            return loadSoundFromURL(mp3Url, key: sound.rawValue)
        }
        
        return loadSoundFromURL(url, key: sound.rawValue)
    }
    
    private func loadSoundFromURL(_ url: URL, key: String) -> AVAudioPlayer? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = soundVolume
            soundPlayers[key] = player
            return player
        } catch {
            print("Failed to load sound \(key): \(error)")
            return nil
        }
    }
    
    // MARK: - Public Methods
    
    // Play a sound effect
    func playSound(_ sound: SoundEffect, volume: Float? = nil) {
        guard soundEnabled else { 
            print("⚠️ Sound is disabled in settings")
            return 
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let player = self.loadSound(sound) {
                // Create a copy for concurrent playback
                do {
                    let url = player.url!
                    let newPlayer = try AVAudioPlayer(contentsOf: url)
                    let reducedVolume = (volume ?? self.soundVolume) * 0.7  // Apply 30% reduction
                    newPlayer.volume = reducedVolume
                    newPlayer.prepareToPlay()
                    
                    DispatchQueue.main.async {
                        newPlayer.play()
                        self.activeSounds.insert(newPlayer)
                        
                        // Remove from active sounds when finished
                        DispatchQueue.main.asyncAfter(deadline: .now() + newPlayer.duration) {
                            self.activeSounds.remove(newPlayer)
                        }
                    }
                } catch {
                    print("Failed to play sound \(sound.rawValue): \(error)")
                    // Fallback to procedural sound
                    DispatchQueue.main.async {
                        self.playProceduralSound(sound)
                    }
                }
            } else {
                // No sound file found, use procedural sound as fallback
                DispatchQueue.main.async {
                    self.playProceduralSound(sound)
                }
            }
        }
    }
    
    // Play sound with SKAction (for use with SpriteKit nodes)
    func soundAction(_ sound: SoundEffect) -> SKAction {
        guard soundEnabled else { return SKAction() }
        
        // Create a simple beep sound as fallback
        _ = getFrequencyForSound(sound)
        return SKAction.playSoundFileNamed("beep", waitForCompletion: false)
    }
    
    // Generate procedural sound frequencies
    private func getFrequencyForSound(_ sound: SoundEffect) -> Double {
        switch sound {
        case .cannonFire: return 150.0
        case .laserFire: return 800.0
        case .plasmaFire: return 600.0
        case .missileLaunch: return 300.0
        case .teslaZap: return 1200.0
        case .enemyHit: return 400.0
        case .enemyDestroyed: return 200.0
        case .buttonTap: return 1000.0
        case .creditEarned: return 1500.0
        default: return 500.0
        }
    }
    
    // Play background music
    func playBackgroundMusic(_ music: SoundEffect = .gameMusic) {
        guard musicEnabled else { return }
        
        stopBackgroundMusic()
        
        // Try to load music file first
        if let url = Bundle.main.url(forResource: music.rawValue, withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop forever
                backgroundMusicPlayer?.volume = musicVolume
                backgroundMusicPlayer?.play()
                return
            } catch {
                print("Failed to play background music file: \(error)")
            }
        }
        
        // Fallback to procedural music
        print("Background music not found: \(music.rawValue) - using procedural music")
        switch music {
        case .menuMusic:
            AudioKitSoundGenerator.shared.playBackgroundMusic()
        case .gameMusic:
            AudioKitSoundGenerator.shared.playGameMusic()
        default:
            AudioKitSoundGenerator.shared.playBackgroundMusic()
        }
    }
    
    // Play specific melody by index (0-19)
    func playMelody(_ index: Int) {
        guard musicEnabled else { return }
        guard index >= 0 && index < 20 else { 
            print("Invalid melody index: \(index). Must be 0-19")
            return 
        }
        
        stopBackgroundMusic()
        AudioKitSoundGenerator.shared.playMelody(index: index)
        print("🎵 Playing melody \(index + 1) of 20")
    }
    
    // Play a random melody
    func playRandomMelody() {
        let randomIndex = Int.random(in: 0..<20)
        playMelody(randomIndex)
    }
    
    // Play all melodies in sequence
    func playAllMelodies() {
        guard musicEnabled else { return }
        stopBackgroundMusic()
        AudioKitSoundGenerator.shared.playAllMelodies()
        print("🎵 Starting melody playlist (20 songs, 1:20 each)")
    }
    
    // Get melody name for display
    func getMelodyName(_ index: Int) -> String {
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
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        AudioKitSoundGenerator.shared.stopBackgroundMusic()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard musicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    // Stop all sounds
    func stopAllSounds() {
        for player in activeSounds {
            player.stop()
        }
        activeSounds.removeAll()
    }
    
    // Update volumes for all active sounds
    private func updateVolumes() {
        for player in activeSounds {
            player.volume = soundVolume
        }
    }
    
    // Haptic feedback (for supported devices)
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Play sound for specific game events
    func playTowerSound(type: String) {
        switch type {
        case "kinetic", "cannon":
            playSound(.cannonFire)
        case "laser":
            playSound(.laserFire)
        case "plasma":
            playSound(.plasmaFire)
        case "missile":
            playSound(.missileLaunch)
        case "tesla":
            playSound(.teslaZap)
        default:
            playSound(.cannonFire)
        }
    }
    
    // Play procedural sound as fallback
    private func playProceduralSound(_ sound: SoundEffect) {
        guard soundEnabled else { return }
        
        // Playing procedural sound: \(sound.rawValue)
        
        // Use AudioKitSoundGenerator for better sounds
        switch sound {
        case .buttonTap:
            AudioKitSoundGenerator.shared.playButtonSound()
        case .towerPlace:
            AudioKitSoundGenerator.shared.playButtonSound()
        case .enemyHit:
            AudioKitSoundGenerator.shared.playPlasmaSound()
        case .enemyDestroyed:
            AudioKitSoundGenerator.shared.playExplosionSound()
        case .laserFire:
            AudioKitSoundGenerator.shared.playLaserSound()
        case .cannonFire:
            AudioKitSoundGenerator.shared.playExplosionSound()
        case .waveStart:
            ProceduralSoundGenerator.shared.playWaveStart()
        case .waveComplete:
            ProceduralSoundGenerator.shared.playWaveComplete()
        case .creditEarned:
            ProceduralSoundGenerator.shared.playCreditEarned()
        case .plasmaFire:
            ProceduralSoundGenerator.shared.playTone(frequency: 600, duration: 0.15, volume: 0.4)
        case .missileLaunch:
            ProceduralSoundGenerator.shared.playTone(frequency: 300, duration: 0.3, volume: 0.5)
        case .teslaZap:
            ProceduralSoundGenerator.shared.playTone(frequency: 1200, duration: 0.1, volume: 0.4)
        case .towerUpgrade:
            ProceduralSoundGenerator.shared.playTone(frequency: 800, duration: 0.2, volume: 0.4)
        case .towerSell:
            ProceduralSoundGenerator.shared.playTone(frequency: 400, duration: 0.2, volume: 0.3)
        case .enemySpawn:
            ProceduralSoundGenerator.shared.playTone(frequency: 350, duration: 0.1, volume: 0.3)
        case .bossSpawn:
            ProceduralSoundGenerator.shared.playTone(frequency: 150, duration: 0.5, volume: 0.6)
        case .bossDestroyed:
            ProceduralSoundGenerator.shared.playTone(frequency: 100, duration: 0.8, volume: 0.7)
        case .menuOpen:
            ProceduralSoundGenerator.shared.playTone(frequency: 700, duration: 0.1, volume: 0.3)
        case .menuClose:
            ProceduralSoundGenerator.shared.playTone(frequency: 500, duration: 0.1, volume: 0.3)
        case .mapComplete:
            ProceduralSoundGenerator.shared.playWaveComplete()
        case .coreHit:
            ProceduralSoundGenerator.shared.playTone(frequency: 250, duration: 0.3, volume: 0.6)
        case .coreDestroyed:
            ProceduralSoundGenerator.shared.playTone(frequency: 100, duration: 1.0, volume: 0.8)
        case .insufficientFunds:
            ProceduralSoundGenerator.shared.playTone(frequency: 200, duration: 0.2, volume: 0.4)
        case .powerUp:
            ProceduralSoundGenerator.shared.playTone(frequency: 1000, duration: 0.3, volume: 0.5)
        default:
            ProceduralSoundGenerator.shared.playTone(frequency: 500, duration: 0.1, volume: 0.3)
        }
    }
}

// MARK: - Procedural Sound Generator
extension SoundManager {
    
    // Generate simple procedural sounds as fallback
    func generateProceduralSound(_ type: SoundEffect) -> SKAction {
        guard soundEnabled else { return SKAction() }
        
        let frequency: Float
        
        switch type {
        case .cannonFire:
            frequency = 150
        case .laserFire:
            frequency = 800
        case .plasmaFire:
            frequency = 600
        case .enemyHit:
            frequency = 400
        case .enemyDestroyed:
            frequency = 200
        case .buttonTap:
            frequency = 1000
        case .creditEarned:
            frequency = 1500
        default:
            frequency = 500
        }
        
        // Create a custom sound action
        return SKAction.run {
            // This would normally generate a tone, but for now we'll use a placeholder
            // Playing procedural sound: \(type.rawValue) at \(frequency)Hz
        }
    }
}