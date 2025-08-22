import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene {
    
    // Layer nodes for proper z-ordering
    private var backgroundLayer: SKNode!
    private var gameplayLayer: SKNode!
    private var towerLayer: SKNode!
    private var enemyLayer: SKNode!
    private var projectileLayer: SKNode!
    private var effectsLayer: SKNode!
    private var uiLayer: SKNode!
    
    // Camera for panning and zooming
    private var gameCamera: SKCameraNode!
    
    // Touch handling
    private var selectedNode: SKNode?
    private var lastTouchLocation: CGPoint?
    
    // Game references - initialize lazily to avoid blocking
    private var gameEngine: GameEngine!
    private var assetManager: AssetManager!
    private var particleManager: ParticleEffectsManager!
    
    // HUD and UI
    private var gameHUD: SKNode? // Changed to SKNode for now
    private var towerSelector: SKNode? // Changed to SKNode for now
    
    // Tower placement UI
    private var towerSelectionMenu: SKNode?
    private var selectedBuildNode: SKNode?
    private var selectedTowerType: String? // Changed to String for now
    
    // Map Visual Themes
    enum MapTheme {
        case alphaCentauri  // Bright yellow/gold - alien star system
        case proximaB       // Red/orange - toxic alien world
        case keplerStation  // Purple/magenta - advanced space station
        case tauCeti        // Teal/cyan - peaceful colony
        case pluto          // Gray/white - icy frontier
        case neptune        // Deep blue - gas giant
        case uranus         // Light blue - ice giant
        case saturn         // Golden/yellow - ringed giant
        case jupiter        // Brown/orange - storm giant
        case mars           // Red/rust - desert world
        case moon           // Gray/white - lunar base
        case earth          // Blue/green - home world
    }
    
    // Game State
    private var score: Int = 0
    private var currentWave: Int = 1
    private var currentMap: Int = 7 // Starting on Jupiter for testing
    private var wavesPerMap: Int = 3  // Default value, will be updated based on map
    private var resources: Int = 300
    private var playerSalvage: Int = 120  // Will be recalculated based on map
    private var powerAvailable: Float = 5.0
    private var powerMax: Float = 10.0
    
    // Screen clear superweapon
    private var screenClearCharges: Int = 1  // Start with 1 charge
    private var maxScreenClearCharges: Int = 3
    private var screenClearButton: SKNode?
    
    // Visual effects
    private var backgroundStars: SKEmitterNode?
    private var spaceDust: SKEmitterNode?
    private var stationCore: StationCore?
    
    // Map data for custom maps
    private var mapSpawnPoints: [CGPoint] = []
    
    // Power-ups system
    enum PowerUpType {
        case speedBoost    // Increases tower fire rate temporarily
        case damageBoost   // Increases tower damage temporarily
        case salvageMultiplier // Doubles salvage for a short time
        case shield        // Temporary invincibility for station core
    }
    
    struct ActivePowerUp {
        let type: PowerUpType
        let duration: TimeInterval
        let startTime: TimeInterval
        let multiplier: Float
    }
    
    private var activePowerUps: [ActivePowerUp] = []
    private var powerUpDropChance: Float = 0.15  // 15% chance per enemy kill
    
    // Tower synergies system
    enum SynergyType {
        case damageBonus      // Nearby towers get damage boost
        case rangeBonus       // Nearby towers get range boost
        case speedBonus       // Nearby towers fire faster
        case armorPiercing    // Nearby towers pierce armor better
    }
    
    struct TowerSynergy {
        let towerType: String
        let synergyType: SynergyType
        let radius: CGFloat
        let bonus: Float
        let affectedTypes: [String]  // Which tower types are affected
    }
    
    private var towerSynergies: [TowerSynergy] = [
        // Laser towers boost nearby energy weapons
        TowerSynergy(towerType: "laser", synergyType: .damageBonus, radius: 80, bonus: 1.25, affectedTypes: ["plasma", "tesla"]),
        // Missile towers provide targeting assistance
        TowerSynergy(towerType: "missile", synergyType: .rangeBonus, radius: 100, bonus: 1.2, affectedTypes: ["machinegun", "kinetic"]),
        // Tesla towers boost fire rate of nearby towers
        TowerSynergy(towerType: "tesla", synergyType: .speedBonus, radius: 70, bonus: 1.3, affectedTypes: ["laser", "plasma"]),
        // Kinetic towers provide armor piercing to projectile weapons
        TowerSynergy(towerType: "kinetic", synergyType: .armorPiercing, radius: 90, bonus: 1.4, affectedTypes: ["machinegun", "missile"])
    ]
    
    // Achievement Bonuses System
    enum AchievementType {
        case towersBuilt        // Build X towers total
        case enemiesKilled      // Kill X enemies total  
        case wavesCompleted     // Complete X waves total
        case mapsCompleted      // Complete X maps total
        case salvageEarned      // Earn X salvage total
        case perfectWaves       // Complete waves without core damage
        case powerUpCollector   // Collect X power-ups
        case synergyMaster      // Use tower synergies effectively
    }
    
    struct Achievement {
        let type: AchievementType
        let threshold: Int
        let bonusType: String
        let bonusValue: Float
        let title: String
        let description: String
    }
    
    struct AchievementProgress {
        let achievement: Achievement
        var currentProgress: Int
        var isUnlocked: Bool
        var isActive: Bool
    }
    
    private var achievements: [Achievement] = [
        // Tower Building Achievements - MUCH HIGHER THRESHOLDS
        Achievement(type: .towersBuilt, threshold: 50, bonusType: "buildDiscount", bonusValue: 0.9, title: "Engineer", description: "Build 50 towers - 10% build cost reduction"),
        Achievement(type: .towersBuilt, threshold: 150, bonusType: "buildDiscount", bonusValue: 0.8, title: "Master Builder", description: "Build 150 towers - 20% build cost reduction"),
        
        // Combat Achievements - HIGHER THRESHOLDS
        Achievement(type: .enemiesKilled, threshold: 500, bonusType: "damageBonus", bonusValue: 1.1, title: "Defender", description: "Kill 500 enemies - 10% damage bonus"),
        Achievement(type: .enemiesKilled, threshold: 2000, bonusType: "damageBonus", bonusValue: 1.2, title: "Legend", description: "Kill 2000 enemies - 20% damage bonus"),
        
        // Wave Completion Achievements - HIGHER THRESHOLDS
        Achievement(type: .wavesCompleted, threshold: 25, bonusType: "salvageBonus", bonusValue: 1.15, title: "Survivor", description: "Complete 25 waves - 15% salvage bonus"),
        Achievement(type: .wavesCompleted, threshold: 75, bonusType: "salvageBonus", bonusValue: 1.25, title: "Hero", description: "Complete 75 waves - 25% salvage bonus"),
        
        // Map Completion Achievements  
        Achievement(type: .mapsCompleted, threshold: 3, bonusType: "startingBonus", bonusValue: 1.2, title: "Explorer", description: "Complete 3 maps - 20% extra starting resources"),
        Achievement(type: .mapsCompleted, threshold: 8, bonusType: "startingBonus", bonusValue: 1.5, title: "Pathfinder", description: "Complete 8 maps - 50% extra starting resources")
    ]
    
    private var achievementProgress: [AchievementProgress] = []
    private var gameStats = [
        "towersBuilt": 0,
        "enemiesKilled": 0, 
        "wavesCompleted": 0,
        "mapsCompleted": 0,
        "salvageEarned": 0,
        "perfectWaves": 0,
        "powerUpCollector": 0,
        "synergyUsage": 0
    ]
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Background music removed - only effect sounds
        
        // Initialize userData for game state tracking
        if userData == nil {
            userData = NSMutableDictionary()
        }
        
        // Check if starting at a specific map
        if let startingMap = userData?["startingMap"] as? Int {
            currentMap = startingMap
            print("Starting at map \(startingMap)")
        }
        
        // Calculate correct starting salvage based on map
        let baseSalvage = 120 + ((currentMap - 1) * 40)
        
        // Apply achievement starting bonus after achievements are set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let achievementBonuses = self.getActiveAchievementBonuses()
            let startingBonus = achievementBonuses["startingBonus"] ?? 1.0
            let finalSalvage = Int(Float(baseSalvage) * startingBonus)
            self.playerSalvage = finalSalvage
            self.updateSalvageDisplay()
            
            if startingBonus > 1.0 {
                let bonus = finalSalvage - baseSalvage
                self.showMessage("Achievement Bonus: +\(bonus)💰", at: CGPoint(x: 0, y: 100), color: .green)
            }
            
            print("Initial salvage for map \(self.currentMap): \(finalSalvage) (base: \(baseSalvage), bonus: \(startingBonus))")
        }
        
        playerSalvage = baseSalvage  // Set temporarily
        
        // Initialize managers - comment out heavy ones for now
        gameEngine = GameEngine.shared
        // assetManager = AssetManager.shared  // Comment out for now
        // particleManager = ParticleEffectsManager.shared  // Comment out for now
        
        // Set background color immediately to show scene is loaded
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        
        // Set anchor point to center for better positioning
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupLayers()
        setupCamera()
        setupGestureRecognizers()
        setupHUD()
        
        // Load the map and create necessary elements
        setupInitialMap()
        
        // Create background stars
        createStarBackground()
        
        // Add map-specific planet backgrounds
        addMapSpecificBackground()
        
        // Add galaxy plasma effects for certain maps
        addGalaxyPlasmaEffects()
        
        // Add animated background elements
        addBackgroundAnimations()
        
        // Initialize difficulty - commented out for now
        // DifficultyManager.shared.setDifficulty(.normal)
        
        // Start with initial HUD values
        updateHUD()
        
        // Background music removed - only effect sounds
        
        // Don't start game engine yet - let's get the scene displaying first
        // gameEngine.startNewGame()
    }
    
    private func setupLayers() {
        // Create layer hierarchy
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = 0
        backgroundLayer.name = "backgroundLayer"
        addChild(backgroundLayer)
        
        gameplayLayer = SKNode()
        gameplayLayer.zPosition = 100
        gameplayLayer.name = "gameplayLayer"
        addChild(gameplayLayer)
        
        towerLayer = SKNode()
        towerLayer.zPosition = 200
        towerLayer.name = "towerLayer"
        gameplayLayer.addChild(towerLayer)
        
        enemyLayer = SKNode()
        enemyLayer.zPosition = 150
        enemyLayer.name = "enemyLayer"
        gameplayLayer.addChild(enemyLayer)
        
        projectileLayer = SKNode()
        projectileLayer.zPosition = 175
        projectileLayer.name = "projectileLayer"
        gameplayLayer.addChild(projectileLayer)
        
        effectsLayer = SKNode()
        effectsLayer.zPosition = 300
        effectsLayer.name = "effectsLayer"
        addChild(effectsLayer)
        
        uiLayer = SKNode()
        uiLayer.zPosition = 1000
        uiLayer.name = "uiLayer"
        // Don't add here - will be added to camera in setupCamera()
    }
    
    private func setupHUD() {
        // Create main HUD - using existing createHUD method
        createHUD()
        
        // Create the control buttons (Speed, Next Level) from the start
        createControlButtons()
        
        // Create start wave button (circular purple style in bottom right)
        createStartWaveButton()
        
        // Don't create tower selector here - will be created when clicking build nodes
        
        // Set initial values - commented out for now
        // gameHUD?.setScore(score)
        // gameHUD?.setWave(currentWave)
        // gameHUD?.setLives(lives)
        // gameHUD?.setResources(resources)
        // gameHUD?.setPower(available: powerAvailable, max: powerMax)
        
        // Start score simulation for testing
        startScoreSimulation()
    }
    
    private func startScoreSimulation() {
        // Simulate score increase
        let scoreAction = SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run { [weak self] in
                self?.addScore(10)
            }
        ])
        run(SKAction.repeatForever(scoreAction), withKey: "scoreSimulation")
        
        // Simulate resource generation
        let resourceAction = SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.run { [weak self] in
                self?.addResources(5)
            }
        ])
        run(SKAction.repeatForever(resourceAction), withKey: "resourceGeneration")
    }
    
    private func updateGameHUD() {
        // Update the new HUD system when available
        // gameHUD?.setScore(score)
        // gameHUD?.setWave(currentWave)
        // gameHUD?.setLives(lives)
        // gameHUD?.setResources(resources)
        // gameHUD?.setPower(available: powerAvailable, max: powerMax)
        // towerSelector?.updateAvailability(resources: resources)
        
        // For now, use the existing updateHUD
        updateHUD()
    }
    
    private func addScore(_ points: Int) {
        // Only add score during active waves
        if isWaveActive {
            score += points
            // gameHUD?.setScore(score)
            updateHUD()
        }
    }
    
    private func addResources(_ amount: Int) {
        resources += amount
        // Don't automatically add to salvage - only add when enemies are destroyed
        // playerSalvage += amount  // REMOVED - this was causing auto-increase
        // gameHUD?.setResources(resources)
        // towerSelector?.updateAvailability(resources: resources)
        updateHUD()
    }
    
    
    private func completeWave() {
        // Prevent duplicate completions
        guard isWaveActive else { return }
        
        // Stop wave completion checking
        removeAction(forKey: "waveCompletionCheck")
        
        // Mark wave as inactive
        isWaveActive = false
        isCheckingWaveCompletion = false  // Reset the checking flag
        
        // Calculate wave completion bonus - scales with wave and map difficulty
        let baseBonus = 25
        let waveBonus = baseBonus + (currentWave * 10) + (currentMap * 15)
        let perfectionBonus = stationHealth == 3 ? waveBonus / 2 : 0  // Bonus for no damage taken
        let totalBonus = waveBonus + perfectionBonus
        
        // Award salvage bonus
        playerSalvage += totalBonus
        addScore(100 + totalBonus)  // Score bonus
        
        // Track achievement progress
        updateAchievementProgress(.wavesCompleted)
        if perfectionBonus > 0 {
            updateAchievementProgress(.perfectWaves)
        }
        
        // Show bonus message
        let bonusText = perfectionBonus > 0 ? 
            "+\(totalBonus) salvage (Perfect!)" : "+\(totalBonus) salvage bonus"
        showFloatingText(bonusText, at: CGPoint(x: 0, y: 50), color: .yellow)
        
        // Show wave completion message BEFORE incrementing
        showWaveCompleteMessage()
        
        // Check if this was the last wave of the map
        if currentWave >= wavesPerMap {
            // Map completed - show next level button
            completeMap()
        } else {
            // More waves to go, advance to next wave
            currentWave += 1
            
            // Show "Ready for next wave!" message
            showReadyForNextWaveMessage()
            
            // Ensure next wave button exists
            if uiLayer.childNode(withName: "nextWaveButton") == nil {
                createNextWaveButtonInCircularStyle()
            }
        }
        
        updateHUD()
    }
    
    private func completeMap() {
        print("Map \(currentMap) completed!")
        
        // Save progress
        var completedMaps = UserDefaults.standard.array(forKey: "completedMaps") as? [Int] ?? []
        if !completedMaps.contains(currentMap) {
            completedMaps.append(currentMap)
            UserDefaults.standard.set(completedMaps, forKey: "completedMaps")
            
            // Track achievement progress for map completion
            updateAchievementProgress(.mapsCompleted)
        }
        
        // Unlock next map
        let highestUnlocked = UserDefaults.standard.integer(forKey: "highestUnlockedMap")
        if currentMap >= highestUnlocked {
            UserDefaults.standard.set(currentMap + 1, forKey: "highestUnlockedMap")
        }
        
        // Check if this was the final map
        if currentMap >= 10 {
            showFinalVictoryScreen()
            return
        }
        
        // Show map completion message
        showMapCompleteMessage()
        
        // Auto-advance to next map after delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in
                self?.advanceToNextMap()
            }
        ]))
    }
    
    private func showFinalVictoryScreen() {
        // Clear everything
        isPaused = true
        
        // Create epic victory overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.95)
        overlay.position = CGPoint.zero
        overlay.zPosition = 1000
        uiLayer.addChild(overlay)
        
        // Add Earth in the background
        let earth = SKShapeNode(circleOfRadius: 100)
        earth.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0)
        earth.strokeColor = SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        earth.lineWidth = 3
        earth.glowWidth = 10
        earth.position = CGPoint(x: 0, y: 50)
        earth.zPosition = 1001
        overlay.addChild(earth)
        
        // Add clouds to Earth for consistency
        for _ in 0..<4 {
            let cloud = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 20...35), height: CGFloat.random(in: 15...25)))
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: 0...70) // Within earth radius of 100
            cloud.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            cloud.fillColor = SKColor.white.withAlphaComponent(0.8)
            cloud.strokeColor = .clear
            cloud.alpha = CGFloat.random(in: 0.6...0.9)
            cloud.blendMode = .alpha
            earth.addChild(cloud)
        }
        
        // Rotate Earth
        earth.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)))
        
        // Victory title
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "🎊 EARTH SAVED! 🎊"
        title.fontSize = 48
        title.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        title.position = CGPoint(x: 0, y: 200)
        title.zPosition = 1002
        overlay.addChild(title)
        
        // Pulse animation for title
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        title.run(SKAction.repeatForever(pulse))
        
        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitle.text = "You have defended all 10 sectors!"
        subtitle.fontSize = 24
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: 0, y: 160)
        subtitle.zPosition = 1002
        overlay.addChild(subtitle)
        
        // Stats
        let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statsLabel.text = "Mission Complete"
        statsLabel.fontSize = 20
        statsLabel.fontColor = SKColor.cyan
        statsLabel.position = CGPoint(x: 0, y: -80)
        statsLabel.zPosition = 1002
        overlay.addChild(statsLabel)
        
        // Credits
        let creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        creditsLabel.text = "Thank you for playing Space Salvagers!"
        creditsLabel.fontSize = 18
        creditsLabel.fontColor = SKColor.lightGray
        creditsLabel.position = CGPoint(x: 0, y: -120)
        creditsLabel.zPosition = 1002
        overlay.addChild(creditsLabel)
        
        // Play Again button
        let playAgainButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        playAgainButton.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        playAgainButton.strokeColor = .white
        playAgainButton.lineWidth = 2
        playAgainButton.position = CGPoint(x: 0, y: -200)
        playAgainButton.name = "playAgain"
        playAgainButton.zPosition = 1002
        overlay.addChild(playAgainButton)
        
        let playAgainLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        playAgainLabel.text = "PLAY AGAIN"
        playAgainLabel.fontSize = 24
        playAgainLabel.fontColor = .white
        playAgainLabel.verticalAlignmentMode = .center
        playAgainButton.addChild(playAgainLabel)
        
        // Main Menu button
        let menuButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        menuButton.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        menuButton.strokeColor = .white
        menuButton.lineWidth = 2
        menuButton.position = CGPoint(x: 0, y: -280)
        menuButton.name = "mainMenu"
        menuButton.zPosition = 1002
        overlay.addChild(menuButton)
        
        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.text = "MAIN MENU"
        menuLabel.fontSize = 24
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        // Add fireworks
        for _ in 0..<5 {
            let delay = Double.random(in: 0...3)
            run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run {
                    self.createFirework(at: CGPoint(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -100...150)
                    ), parent: overlay)
                }
            ]))
        }
        
        // Play victory sound
        SoundManager.shared.playSound(.mapComplete)
    }
    
    private func createFirework(at position: CGPoint, parent: SKNode) {
        guard let emitter = SKEmitterNode(fileNamed: "Firework") else {
            // Create programmatic firework if no asset
            let firework = SKShapeNode(circleOfRadius: 2)
            firework.fillColor = SKColor(
                red: CGFloat.random(in: 0.7...1.0),
                green: CGFloat.random(in: 0.7...1.0),
                blue: CGFloat.random(in: 0.7...1.0),
                alpha: 1.0
            )
            firework.position = position
            firework.zPosition = 1003
            parent.addChild(firework)
            
            // Explosion effect
            let expand = SKAction.scale(to: 20, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            firework.run(SKAction.sequence([SKAction.group([expand, fade]), remove]))
            return
        }
        
        emitter.position = position
        emitter.zPosition = 1003
        parent.addChild(emitter)
        
        // Remove after animation
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showWaveCompleteMessage() {
        // Play wave complete sound
        // SoundManager.shared.playSound(.waveComplete)
        
        // Award screen clear charge every 2 waves
        if currentWave % 2 == 0 && screenClearCharges < maxScreenClearCharges {
            screenClearCharges += 1
            createScreenClearButton()  // Update button appearance
            showMessage("Screen Clear Charge +1", at: CGPoint(x: 0, y: -50), color: .orange)
        }
        
        // Create a prominent container for the wave complete message
        let container = SKNode()
        container.position = CGPoint(x: 0, y: 0)
        container.zPosition = 2000
        container.name = "waveCompleteMessage"
        uiLayer.addChild(container)
        
        // Create subtle background panel for visibility
        let background = SKShapeNode(rectOf: CGSize(width: 350, height: 80), cornerRadius: 10)
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = SKColor.green.withAlphaComponent(0.8)
        background.lineWidth = 2
        background.glowWidth = 5
        container.addChild(background)
        
        // Main message - more modest size
        let message = SKLabelNode(text: "Wave \(currentWave) Complete")
        message.fontSize = 28
        message.fontName = "AvenirNext-Bold"
        message.fontColor = SKColor.green
        message.position = CGPoint(x: 0, y: 15)
        container.addChild(message)
        
        // Add checkmark icon - smaller
        let checkmark = SKLabelNode(text: "✓")
        checkmark.fontSize = 32
        checkmark.fontColor = SKColor.green
        checkmark.position = CGPoint(x: -130, y: 10)
        container.addChild(checkmark)
        
        // Sub-message showing remaining waves - smaller and subtler
        let remainingWaves = wavesPerMap - currentWave
        let subMessage: SKLabelNode
        if remainingWaves > 0 {
            subMessage = SKLabelNode(text: "\(remainingWaves) wave\(remainingWaves == 1 ? "" : "s") remaining")
            subMessage.fontColor = SKColor.cyan.withAlphaComponent(0.8)
        } else {
            subMessage = SKLabelNode(text: "Map cleared!")
            subMessage.fontColor = SKColor.yellow.withAlphaComponent(0.8)
        }
        subMessage.fontSize = 16
        subMessage.fontName = "AvenirNext-Regular"
        subMessage.position = CGPoint(x: 0, y: -15)
        container.addChild(subMessage)
        
        // Add subtle pulse animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        container.run(pulse)
        
        // Keep message on screen briefly
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),  // Show for 2.5 seconds
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        // Also flash the start wave button to draw attention
        if remainingWaves > 0 {
            flashStartWaveButton()
        }
    }
    
    private func flashStartWaveButton() {
        // Find the start wave button and make it flash
        uiLayer.enumerateChildNodes(withName: "//startWaveButton") { button, _ in
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ])
            button.run(SKAction.repeat(flash, count: 3))
        }
    }
    
    private func showMapCompleteMessage() {
        let message = SKLabelNode(text: "Map \(currentMap) Complete!")
        message.fontSize = 32
        message.fontName = "AvenirNext-Bold"
        message.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        message.position = CGPoint(x: 0, y: 150)
        message.zPosition = 2000
        message.name = "mapCompleteMessage"
        
        uiLayer.addChild(message)
        
        // Fade out after 5 seconds
        message.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showReadyForNextWaveMessage() {
        // Remove any existing ready messages first
        uiLayer.enumerateChildNodes(withName: "readyMessage") { node, _ in
            node.removeAllActions()
            node.removeFromParent()
        }
        
        // Create container for the message
        let messageContainer = SKNode()
        messageContainer.position = CGPoint(x: 0, y: 50)
        messageContainer.zPosition = 2000
        messageContainer.name = "readyMessage"
        
        // Main message
        let message = SKLabelNode(text: "READY FOR NEXT WAVE!")
        message.fontSize = 28
        message.fontName = "Helvetica-Bold"
        message.fontColor = .cyan
        message.position = CGPoint(x: 0, y: 20)
        messageContainer.addChild(message)
        
        // Add glow effect
        let glowMessage = SKLabelNode(text: "READY FOR NEXT WAVE!")
        glowMessage.fontSize = 28
        glowMessage.fontName = "Helvetica-Bold"
        glowMessage.fontColor = .cyan
        glowMessage.position = CGPoint(x: 0, y: 20)
        glowMessage.alpha = 0.4
        glowMessage.blendMode = .add
        glowMessage.setScale(1.1)
        messageContainer.addChild(glowMessage)
        
        // Wave info
        let waveInfo = SKLabelNode(text: "Wave \(currentWave) of \(wavesPerMap)")
        waveInfo.fontSize = 18
        waveInfo.fontName = "Helvetica"
        waveInfo.fontColor = .white
        waveInfo.position = CGPoint(x: 0, y: -5)
        messageContainer.addChild(waveInfo)
        
        // Instruction
        let instruction = SKLabelNode(text: "Tap the purple button to begin")
        instruction.fontSize = 16
        instruction.fontName = "Helvetica"
        instruction.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        instruction.position = CGPoint(x: 0, y: -30)
        messageContainer.addChild(instruction)
        
        uiLayer.addChild(messageContainer)
        
        // Pulse animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        messageContainer.run(SKAction.repeatForever(pulse))
        
        // Remove after 10 seconds or when wave starts
        messageContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func gameOver() {
        // Game over logic
        print("Game Over! Final Score: \(score)")
        
        // Clean up any stuck red screens first
        uiLayer.enumerateChildNodes(withName: "damageFlash") { node, _ in
            node.removeFromParent()
        }
        
        // COMPLETELY STOP THE GAME
        isWaveActive = false
        isCheckingWaveCompletion = false
        
        // Stop ALL actions and timers
        self.removeAllActions()
        // DON'T pause the entire scene yet - we need UI animations to work
        
        // Stop all GAME layers (but not UI layer)
        [gameplayLayer, enemyLayer, towerLayer, projectileLayer, effectsLayer, backgroundLayer].forEach { layer in
            layer.removeAllActions()
            layer.isPaused = true
            layer.enumerateChildNodes(withName: "*") { node, _ in
                node.removeAllActions()
                node.isPaused = true
                // Invalidate any timers
                if let timer = node.userData?["velocityTimer"] as? Timer {
                    timer.invalidate()
                }
                if let timer = node.userData?["trailTimer"] as? Timer {
                    timer.invalidate()
                }
            }
        }
        
        // Clear all projectiles and effects immediately
        projectileLayer.removeAllChildren()
        effectsLayer.removeAllChildren()
        
        // IMPORTANT: Hide all game UI elements
        // Remove tower selection menu if open
        towerSelectionMenu?.removeFromParent()
        towerSelectionMenu = nil
        
        // Hide all UI buttons and elements (except what we need for game over)
        uiLayer.enumerateChildNodes(withName: "*") { node, _ in
            // Hide everything except the overlay we're about to create
            if node.name != "gameOverOverlay" && node.name != "gameOverContainer" {
                node.alpha = 0
                node.removeFromParent()
            }
        }
        
        // Hide the entire gameplay layer
        gameplayLayer.alpha = 0.3  // Dim the game in background
        
        // Create full screen overlay to block everything
        let overlay = SKSpriteNode(color: .black, size: CGSize(width: size.width * 2, height: size.height * 2))
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = 1999
        overlay.alpha = 0
        overlay.name = "gameOverOverlay"
        uiLayer.addChild(overlay)
        
        // Fade in the overlay
        overlay.run(SKAction.fadeAlpha(to: 0.85, duration: 1.0))
        
        // Create game over container
        let gameOverContainer = SKNode()
        gameOverContainer.name = "gameOverContainer"
        gameOverContainer.zPosition = 2000
        gameOverContainer.position = CGPoint(x: 0, y: 0)
        gameOverContainer.alpha = 0
        uiLayer.addChild(gameOverContainer)
        
        // Game over title with story context
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "PORTAL BREACHED!"
        gameOverLabel.fontSize = 56
        gameOverLabel.fontColor = SKColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        gameOverLabel.position = CGPoint(x: 0, y: 120)
        gameOverContainer.addChild(gameOverLabel)
        
        // Add glow effect to title
        let glowLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        glowLabel.text = "PORTAL BREACHED!"
        glowLabel.fontSize = 56
        glowLabel.fontColor = .red
        glowLabel.position = CGPoint(x: 0, y: 120)
        glowLabel.blendMode = .add
        glowLabel.alpha = 0.5
        gameOverContainer.addChild(glowLabel)
        
        // Story message
        let storyLabel = SKLabelNode(fontNamed: "Helvetica")
        let planetName = getMapName(for: currentMap)
        storyLabel.text = "The aliens have escaped \(planetName)!"
        storyLabel.fontSize = 24
        storyLabel.fontColor = SKColor.orange
        storyLabel.position = CGPoint(x: 0, y: 60)
        gameOverContainer.addChild(storyLabel)
        
        // Warning about Earth
        let warningLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        let planetsRemaining = 3 - currentMap  // Earth is map 3
        if currentMap < 3 {
            warningLabel.text = "Only \(planetsRemaining) planets stand between them and Earth!"
            warningLabel.fontColor = SKColor.yellow
        } else if currentMap == 3 {
            warningLabel.text = "EARTH IS IN IMMEDIATE DANGER!"
            warningLabel.fontColor = SKColor.red
        } else {
            warningLabel.text = "They're advancing toward Earth!"
            warningLabel.fontColor = SKColor.orange
        }
        warningLabel.fontSize = 20
        warningLabel.position = CGPoint(x: 0, y: 20)
        gameOverContainer.addChild(warningLabel)
        
        // Stats
        let statsLabel = SKLabelNode(fontNamed: "Helvetica")
        statsLabel.text = "Enemies Destroyed: \(enemiesDestroyed) | Waves Survived: \(currentWave - 1)"
        statsLabel.fontSize = 18
        statsLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        statsLabel.position = CGPoint(x: 0, y: -20)
        gameOverContainer.addChild(statsLabel)
        
        // Create buttons container
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: 0, y: -100)
        gameOverContainer.addChild(buttonContainer)
        
        // Create restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 10)
        restartButton.position = CGPoint(x: -100, y: 0)
        restartButton.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
        restartButton.strokeColor = .white
        restartButton.lineWidth = 2
        restartButton.name = "restartButton"
        buttonContainer.addChild(restartButton)
        
        let restartButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        restartButtonLabel.text = "TRY AGAIN"
        restartButtonLabel.fontSize = 20
        restartButtonLabel.fontColor = .white
        restartButtonLabel.verticalAlignmentMode = .center
        restartButtonLabel.name = "restartButtonLabel"
        restartButton.addChild(restartButtonLabel)
        
        // Create map selection button (emphasized as main action)
        let mapButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 10)
        mapButton.position = CGPoint(x: 100, y: 0)
        mapButton.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1)
        mapButton.strokeColor = .cyan
        mapButton.lineWidth = 3
        mapButton.glowWidth = 2
        mapButton.name = "mapSelectionButton"
        buttonContainer.addChild(mapButton)
        
        let mapButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        mapButtonLabel.text = "RETREAT"
        mapButtonLabel.fontSize = 22
        mapButtonLabel.fontColor = .white
        mapButtonLabel.verticalAlignmentMode = .center
        mapButtonLabel.name = "mapSelectionButtonLabel"
        mapButton.addChild(mapButtonLabel)
        
        // Pulse animation for buttons
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        restartButton.run(SKAction.repeatForever(pulse))
        mapButton.run(SKAction.repeatForever(pulse.copy() as! SKAction))
        
        // Fade in the game over screen
        gameOverContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Stop spawning but don't pause entirely to allow animations
        isWaveActive = false
        
        // Unpause UI layer to allow button interactions
        uiLayer.isPaused = false
        gameOverContainer.isPaused = false
        
        // Enable interaction immediately for buttons
        self.isUserInteractionEnabled = true
        if self.userData == nil {
            self.userData = NSMutableDictionary()
        }
        self.userData?["gameOverTapEnabled"] = true
        print("Game over screen ready - buttons enabled")
    }
    
    private func addGalaxyPlasmaEffects() {
        // Add different effects based on map
        switch currentMap {
        case 2, 5, 7, 9:  // Add plasma effects to specific maps
            createSlowPlasmaBackground()
        case 3, 6, 8:  // Add nebula effects
            createNebulaBackground()
        case 4, 10:  // Add aurora effects
            createAuroraBackground()
        default:
            break
        }
    }
    
    private func createSlowPlasmaBackground() {
        let plasmaContainer = SKNode()
        plasmaContainer.name = "plasmaBackground"
        plasmaContainer.zPosition = -100  // Behind everything
        backgroundLayer.addChild(plasmaContainer)
        
        // Create multiple plasma layers
        for i in 0..<3 {
            let plasma = createPlasmaLayer(index: i)
            plasmaContainer.addChild(plasma)
        }
    }
    
    private func createPlasmaLayer(index: Int) -> SKNode {
        let layer = SKNode()
        
        // Create plasma blobs
        let blobCount = 5 + index * 2
        for _ in 0..<blobCount {
            let blob = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...200))
            
            // Set plasma colors
            let colors: [SKColor] = [
                SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.15),  // Purple
                SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.15),  // Cyan
                SKColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 0.15),  // Pink
                SKColor(red: 0.4, green: 1.0, blue: 0.8, alpha: 0.15)   // Turquoise
            ]
            
            blob.fillColor = colors.randomElement()!
            blob.strokeColor = .clear
            blob.blendMode = .add
            blob.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            
            // Add slow movement
            let moveX = CGFloat.random(in: -30...30)
            let moveY = CGFloat.random(in: -30...30)
            let duration = Double.random(in: 20...40)
            
            let moveAction = SKAction.sequence([
                SKAction.moveBy(x: moveX, y: moveY, duration: duration),
                SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            ])
            
            // Add scale pulsing
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: duration * 0.5),
                SKAction.scale(to: 0.8, duration: duration * 0.5)
            ])
            
            // Add rotation
            let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: duration * 2)
            
            blob.run(SKAction.repeatForever(SKAction.group([moveAction, scaleAction, rotateAction])))
            layer.addChild(blob)
        }
        
        // Offset each layer slightly
        layer.alpha = 0.3 - CGFloat(index) * 0.1
        layer.speed = 1.0 - CGFloat(index) * 0.2
        
        return layer
    }
    
    private func createNebulaBackground() {
        let nebulaContainer = SKNode()
        nebulaContainer.name = "nebulaBackground"
        nebulaContainer.zPosition = -95  // In front of stars but behind stations
        backgroundLayer.addChild(nebulaContainer)
        
        // Create nebula clouds
        for i in 0..<4 {
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: 200...400),
                height: CGFloat.random(in: 150...300)
            ))
            
            let colors: [SKColor] = [
                SKColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 0.1),
                SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.1),
                SKColor(red: 0.5, green: 0.9, blue: 0.3, alpha: 0.1),
                SKColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 0.1)
            ]
            
            cloud.fillColor = colors[i % colors.count]
            cloud.strokeColor = .clear
            cloud.blendMode = .add
            cloud.position = CGPoint(
                x: CGFloat.random(in: -size.width/3...size.width/3),
                y: CGFloat.random(in: -size.height/3...size.height/3)
            )
            
            // Slow drift - reduced range to prevent edge visibility
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20), 
                              y: CGFloat.random(in: -20...20), 
                              duration: Double.random(in: 30...50)),
                SKAction.moveBy(x: CGFloat.random(in: -20...20), 
                              y: CGFloat.random(in: -20...20), 
                              duration: Double.random(in: 30...50))
            ])
            
            cloud.run(SKAction.repeatForever(drift))
            nebulaContainer.addChild(cloud)
        }
    }
    
    private func createAuroraBackground() {
        let auroraContainer = SKNode()
        auroraContainer.name = "auroraBackground"
        auroraContainer.zPosition = -100
        backgroundLayer.addChild(auroraContainer)
        
        // Create aurora waves
        for i in 0..<3 {
            let wave = SKShapeNode()
            let path = CGMutablePath()
            
            // Create wavy path
            path.move(to: CGPoint(x: -size.width/2, y: 0))
            for x in stride(from: -size.width/2, to: size.width/2, by: 20) {
                let y = sin(x * 0.01 + CGFloat(i)) * 100
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            wave.path = path
            wave.strokeColor = SKColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 0.2)
            wave.lineWidth = CGFloat(30 + i * 20)
            wave.blendMode = .add
            wave.position = CGPoint(x: 0, y: CGFloat(i * 50))
            
            // Animate the wave
            let shift = SKAction.moveBy(x: 100, y: 0, duration: Double(10 + i * 5))
            let reset = SKAction.moveBy(x: -100, y: 0, duration: 0)
            let sequence = SKAction.sequence([shift, reset])
            
            wave.run(SKAction.repeatForever(sequence))
            auroraContainer.addChild(wave)
        }
    }
    
    private func returnToMapSelection() {
        print("Returning to map selection...")
        
        // Clean up any stuck red screens before transitioning
        uiLayer.enumerateChildNodes(withName: "damageFlash") { node, _ in
            node.removeFromParent()
        }
        
        // Stop all game activities
        isWaveActive = false
        isCheckingWaveCompletion = false
        removeAction(forKey: "waveSpawning")
        removeAction(forKey: "enemySpawning")
        removeAction(forKey: "waveCompletionCheck")
        
        // Transition to map selection scene
        let mapScene = MapSelectionScene(size: size)
        mapScene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(mapScene, transition: transition)
    }
    
    private func restartGame() {
        print("Restarting game...")
        
        // Clean up any stuck red screens
        uiLayer.enumerateChildNodes(withName: "damageFlash") { node, _ in
            node.removeFromParent()
        }
        
        // The best way to restart is to create a fresh GameScene
        if let view = self.view {
            // Create a new game scene with the same map
            let newGameScene = GameScene(size: view.bounds.size)
            newGameScene.scaleMode = .aspectFill
            newGameScene.currentMap = self.currentMap  // Keep the same map
            
            // Transition to the new scene
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newGameScene, transition: transition)
        }
    }
    
    private func setupCamera() {
        gameCamera = SKCameraNode()
        gameCamera.position = CGPoint.zero  // Center since anchor is 0.5, 0.5
        camera = gameCamera
        addChild(gameCamera)
        
        // Add UI elements to camera so they stay fixed
        gameCamera.addChild(uiLayer)
        
        // Auto-scale camera for higher maps to fit everything on screen
        adjustCameraForMap()
    }
    
    private func adjustCameraForMap() {
        // Normal zoom levels for gameplay
        var zoomScale: CGFloat = 1.0
        
        switch currentMap {
        case 8...10:
            zoomScale = 1.1  // Zoom out 10% for maps 8-10
        case 11:
            zoomScale = 1.15  // Zoom out 15% for map 11
        case 12:
            zoomScale = 1.2  // Zoom out 20% for map 12 (has 5 parallel paths)
        default:
            zoomScale = 1.0  // Normal zoom for maps 1-7
        }
        
        // Apply zoom by scaling the camera
        gameCamera.setScale(zoomScale)
        
        // Center camera on map
        gameCamera.position = CGPoint.zero
    }
    
    private func setupGestureRecognizers() {
        // Disabled - causing screen jumping and touch conflicts
        return
    }
    
    private func setupInitialMap() {
        // Create dark neon-style background
        let background = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        background.fillColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0) // Very dark blue
        background.strokeColor = .clear
        background.zPosition = -10
        backgroundLayer.addChild(background)
        
        // Add neon grid effect
        createNeonGrid()
        
        // Try to load vector map first
        if SimpleVectorMapLoader.shared.createVectorMapNodes(mapNumber: currentMap, in: gameplayLayer) {
            print("✅ Successfully loaded vector map \(currentMap)")
            
            // Get spawn points from the vector map
            mapSpawnPoints = SimpleVectorMapLoader.shared.getSpawnPoints(mapNumber: currentMap)
            print("📍 Loaded \(mapSpawnPoints.count) spawn points for map \(currentMap)")
            for (index, point) in mapSpawnPoints.enumerated() {
                print("  Spawn \(index + 1): \(point)")
            }
            
            // Add Proxima B star system for Map 2
            if currentMap == 2 {
                addProximaBStarSystem()
            }
        } else {
            // Fallback to original system
            print("⚠️ Vector map \(currentMap) not found, using fallback")
            createMap()
            loadMapLayout()
        }
    }
    
    private func setupGameplay() {
        // Create the game map
        createMap()
        
        // Setup build nodes
        createBuildNodes()
        
        // Create paths for enemies
        createEnemyPaths()
        
        // Setup UI
        createHUD()
        
        // Initialize achievements
        setupAchievements()
    }
    
    // MARK: - Achievement System
    private func setupAchievements() {
        // Load game statistics from UserDefaults
        loadGameStatistics()
        
        // Initialize achievement progress
        achievementProgress = achievements.map { achievement in
            let statKey = getStatKeyForAchievement(achievement.type)
            let currentProgress = gameStats[statKey] ?? 0
            let isUnlocked = currentProgress >= achievement.threshold
            return AchievementProgress(
                achievement: achievement, 
                currentProgress: currentProgress, 
                isUnlocked: isUnlocked, 
                isActive: isUnlocked
            )
        }
        
        print("🏆 Achievement system initialized with \(achievements.count) achievements")
        checkAchievementUnlocks()
    }
    
    private func loadGameStatistics() {
        // Load persistent statistics from UserDefaults
        let defaults = UserDefaults.standard
        gameStats["towersBuilt"] = defaults.integer(forKey: "stat_towersBuilt")
        gameStats["enemiesKilled"] = defaults.integer(forKey: "stat_enemiesKilled") 
        gameStats["wavesCompleted"] = defaults.integer(forKey: "stat_wavesCompleted")
        gameStats["mapsCompleted"] = defaults.integer(forKey: "stat_mapsCompleted")
        gameStats["salvageEarned"] = defaults.integer(forKey: "stat_salvageEarned")
        gameStats["perfectWaves"] = defaults.integer(forKey: "stat_perfectWaves")
        gameStats["powerUpCollector"] = defaults.integer(forKey: "stat_powerUpCollector")
        gameStats["synergyUsage"] = defaults.integer(forKey: "stat_synergyUsage")
    }
    
    private func saveGameStatistics() {
        // Save persistent statistics to UserDefaults
        let defaults = UserDefaults.standard
        for (key, value) in gameStats {
            defaults.set(value, forKey: "stat_\(key)")
        }
        defaults.synchronize()
    }
    
    private func getStatKeyForAchievement(_ type: AchievementType) -> String {
        switch type {
        case .towersBuilt: return "towersBuilt"
        case .enemiesKilled: return "enemiesKilled"
        case .wavesCompleted: return "wavesCompleted"
        case .mapsCompleted: return "mapsCompleted"
        case .salvageEarned: return "salvageEarned"
        case .perfectWaves: return "perfectWaves"
        case .powerUpCollector: return "powerUpCollector"
        case .synergyMaster: return "synergyUsage"
        }
    }
    
    private func updateAchievementProgress(_ type: AchievementType, increment: Int = 1) {
        let statKey = getStatKeyForAchievement(type)
        gameStats[statKey] = (gameStats[statKey] ?? 0) + increment
        
        // Check if any achievements were unlocked
        let _ = achievementProgress
        for i in 0..<achievementProgress.count {
            if achievementProgress[i].achievement.type == type && !achievementProgress[i].isUnlocked {
                let newProgress = gameStats[statKey] ?? 0
                achievementProgress[i].currentProgress = newProgress
                
                if newProgress >= achievementProgress[i].achievement.threshold {
                    achievementProgress[i].isUnlocked = true
                    achievementProgress[i].isActive = true
                    showAchievementUnlock(achievementProgress[i].achievement)
                }
            }
        }
        
        // Save updated statistics
        saveGameStatistics()
    }
    
    private func checkAchievementUnlocks() {
        for i in 0..<achievementProgress.count {
            if achievementProgress[i].isUnlocked && !achievementProgress[i].isActive {
                achievementProgress[i].isActive = true
            }
        }
    }
    
    private func showAchievementUnlock(_ achievement: Achievement) {
        // Create achievement notification - BIGGER AND MORE PROMINENT
        let notification = SKNode()
        notification.position = CGPoint(x: 0, y: size.height/2 - 120)
        notification.zPosition = 3000
        
        // Background - MUCH BIGGER
        let bg = SKShapeNode(rectOf: CGSize(width: 450, height: 140), cornerRadius: 15)
        bg.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.95)
        bg.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        bg.lineWidth = 3
        bg.glowWidth = 8
        notification.addChild(bg)
        
        // Achievement unlocked text - BIGGER
        let titleLabel = SKLabelNode(text: "🏆 ACHIEVEMENT UNLOCKED! 🏆")
        titleLabel.fontSize = 24
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 35)
        notification.addChild(titleLabel)
        
        // Achievement name - BIGGER
        let nameLabel = SKLabelNode(text: achievement.title)
        nameLabel.fontSize = 20
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        nameLabel.position = CGPoint(x: 0, y: 5)
        notification.addChild(nameLabel)
        
        // Achievement description - BIGGER
        let descLabel = SKLabelNode(text: achievement.description)
        descLabel.fontSize = 16
        descLabel.fontName = "AvenirNext"
        descLabel.fontColor = .white
        descLabel.position = CGPoint(x: 0, y: -25)
        notification.addChild(descLabel)
        
        uiLayer.addChild(notification)
        
        // Animation
        notification.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
        notification.run(sequence)
        
        // Sound effect
        SoundManager.shared.playSound(.creditEarned)
        
        print("🏆 Achievement unlocked: \(achievement.title)")
    }
    
    private func getActiveAchievementBonuses() -> [String: Float] {
        var bonuses: [String: Float] = [:]
        
        for progress in achievementProgress {
            if progress.isUnlocked && progress.isActive {
                let achievement = progress.achievement
                if let existing = bonuses[achievement.bonusType] {
                    // Use the best bonus for each type
                    bonuses[achievement.bonusType] = max(existing, achievement.bonusValue)
                } else {
                    bonuses[achievement.bonusType] = achievement.bonusValue
                }
            }
        }
        
        return bonuses
    }
    
    private func createMap() {
        // Create dark neon-style background
        let background = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        background.fillColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0) // Very dark blue
        background.strokeColor = .clear
        background.zPosition = -10
        backgroundLayer.addChild(background)
        
        // Add neon grid effect
        createNeonGrid()
        
        // Add neon star field effect
        for _ in 0..<80 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            let colors = [
                SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0), // Cyan
                SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0), // Purple
                SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0), // Pink
                SKColor.white
            ]
            star.fillColor = colors.randomElement()!
            star.strokeColor = .clear
            star.glowWidth = 2
            star.alpha = CGFloat.random(in: 0.3...0.7)
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            star.zPosition = -2
            backgroundLayer.addChild(star)
            
            // Add twinkle animation
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(sequence))
        }
        
        // Station core is now created by the custom map loader at the proper end position
        // No need to create it here at (0,0)
    }
    
    private func createBuildNodes() {
        // Create build nodes positioned strategically along the path
        // REDUCED to 12 positions (removed 7)
        let buildPositions = [
            // Entry defense (right side)
            CGPoint(x: 340, y: 0),
            CGPoint(x: 280, y: 90),
            
            // Top curve defense
            CGPoint(x: 150, y: 120),
            CGPoint(x: 0, y: 110),
            CGPoint(x: -150, y: 120),
            
            // Left side defense
            CGPoint(x: -280, y: 0),
            
            // Bottom curve defense
            CGPoint(x: -150, y: -140),
            CGPoint(x: 0, y: -150),
            CGPoint(x: 150, y: -140),
            
            // Core defense positions
            CGPoint(x: 100, y: 0),
            CGPoint(x: -100, y: 0),
            CGPoint(x: 50, y: -50),
        ]
        
        // Define special damage bonus positions (strategic spots)
        let damageBonusPositions = [
            CGPoint(x: 0, y: 110),     // Top center - key chokepoint
            CGPoint(x: -280, y: 0),    // Left side - mid path
            CGPoint(x: 100, y: 0),     // Near core - final defense
        ]
        
        for position in buildPositions {
            let isDamageBonus = damageBonusPositions.contains { abs($0.x - position.x) < 5 && abs($0.y - position.y) < 5 }
            let buildNode = createBuildNode(isDamageBonus: isDamageBonus)
            buildNode.position = position
            gameplayLayer.addChild(buildNode)
        }
    }
    
    private func createBuildNode(isDamageBonus: Bool = false) -> SKNode {
        let node = SKShapeNode(circleOfRadius: 20)
        
        if isDamageBonus {
            // Special damage bonus tile - golden appearance
            node.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.9)
            node.lineWidth = 4
            node.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.0, alpha: 0.3)
            node.name = "buildNodeDamage"
            node.glowWidth = 6
            
            // Add sparkling effect for special tiles
            let sparkle = SKShapeNode(circleOfRadius: 18)
            sparkle.strokeColor = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.6)
            sparkle.lineWidth = 2
            sparkle.fillColor = .clear
            sparkle.name = "buildNode"
            
            // Add rotating sparkle effect
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 3.0)
            sparkle.run(SKAction.repeatForever(rotate))
            node.addChild(sparkle)
            
            // Add damage bonus indicator
            let bonusLabel = SKLabelNode(text: "+25%")
            bonusLabel.fontSize = 12
            bonusLabel.fontName = "AvenirNext-Bold"
            bonusLabel.fontColor = SKColor.white
            bonusLabel.position = CGPoint(x: 0, y: -4)
            bonusLabel.zPosition = 1
            node.addChild(bonusLabel)
            
            // Special golden pulse effect
            let goldPulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ])
            node.run(SKAction.repeatForever(goldPulse))
            
        } else {
            // Regular build node
            node.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.8)
            node.lineWidth = 3
            node.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.4)
            node.name = "buildNode"
            
            // Add holographic effect with stronger visibility
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: 1.0),
                SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            ])
            node.run(SKAction.repeatForever(pulse))
            
            // Add inner circle to make it more visible
            let innerCircle = SKShapeNode(circleOfRadius: 16)
            innerCircle.strokeColor = SKColor.cyan
            innerCircle.lineWidth = 1
            innerCircle.fillColor = .clear
            innerCircle.name = "buildNode"  // Also name the inner circle
            node.addChild(innerCircle)
        }
        
        node.zPosition = 100  // Make sure it's above background
        node.isUserInteractionEnabled = false  // Let parent handle touches
        
        // Initialize user data for occupation status and damage bonus
        node.userData = NSMutableDictionary()
        node.userData?["isOccupied"] = false
        node.userData?["damageBonus"] = isDamageBonus ? 1.25 : 1.0  // Store damage multiplier
        
        return node
    }
    
    private func createStationCore() -> SKNode {
        let core = SKShapeNode(circleOfRadius: 35)
        core.strokeColor = SKColor.cyan
        core.lineWidth = 3
        core.fillColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.3)
        core.name = "stationCore"
        
        // Add pulsing glow effect
        let glow = SKShapeNode(circleOfRadius: 40)
        glow.strokeColor = SKColor.cyan
        glow.lineWidth = 2
        glow.alpha = 0.5
        core.addChild(glow)
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        glow.run(SKAction.repeatForever(pulse))
        
        return core
    }
    
    private func createNeonGrid() {
        // Create neon purple grid lines
        let gridSpacing: CGFloat = 50
        let gridColor = SKColor(red: 0.5, green: 0, blue: 1, alpha: 0.1) // Purple grid
        
        // Vertical lines
        for x in stride(from: -size.width/2, through: size.width/2, by: gridSpacing) {
            let line = SKShapeNode(rect: CGRect(x: x, y: -size.height/2, width: 1, height: size.height))
            line.fillColor = gridColor
            line.strokeColor = .clear
            line.zPosition = -9
            backgroundLayer.addChild(line)
        }
        
        // Horizontal lines
        for y in stride(from: -size.height/2, through: size.height/2, by: gridSpacing) {
            let line = SKShapeNode(rect: CGRect(x: -size.width/2, y: y, width: size.width, height: 1))
            line.fillColor = gridColor
            line.strokeColor = .clear
            line.zPosition = -9
            backgroundLayer.addChild(line)
        }
        
        // Add some glowing intersection points
        for x in stride(from: -size.width/2, through: size.width/2, by: gridSpacing * 2) {
            for y in stride(from: -size.height/2, through: size.height/2, by: gridSpacing * 2) {
                let dot = SKShapeNode(circleOfRadius: 2)
                dot.fillColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.4)
                dot.strokeColor = .clear
                dot.glowWidth = 4
                dot.position = CGPoint(x: x, y: y)
                dot.zPosition = -8
                backgroundLayer.addChild(dot)
            }
        }
    }
    
    private func createEnemyPaths() {
        // Create an extended S-shaped path for enemies
        let path = CGMutablePath()
        
        // Start point (far right, moved down)
        let startPoint = CGPoint(x: size.width/2 + 100, y: -50)
        path.move(to: startPoint)
        
        // Create S-curve path
        path.addLine(to: CGPoint(x: 300, y: 0))
        
        // Curve upward
        path.addCurve(to: CGPoint(x: 0, y: 150),
                     control1: CGPoint(x: 250, y: 0),
                     control2: CGPoint(x: 150, y: 150))
        
        // Curve left and down
        path.addCurve(to: CGPoint(x: -200, y: 0),
                     control1: CGPoint(x: -100, y: 150),
                     control2: CGPoint(x: -200, y: 100))
        
        // Curve to bottom
        path.addCurve(to: CGPoint(x: 0, y: -150),
                     control1: CGPoint(x: -200, y: -100),
                     control2: CGPoint(x: -100, y: -150))
        
        // Final approach to station
        path.addCurve(to: CGPoint(x: 0, y: 0),
                     control1: CGPoint(x: 100, y: -150),
                     control2: CGPoint(x: 50, y: -75))
        
        // Create TWO NEON OUTLINE LINES for road borders (not filled)
        // Use stroke to create the outline effect
        
        // Outer border (wider, creates the road width visual)
        let outerBorder = SKShapeNode(path: path)
        outerBorder.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.8) // Purple
        outerBorder.lineWidth = 40 // This creates the road width
        outerBorder.lineCap = .round
        outerBorder.fillColor = .clear // No fill, just outline
        outerBorder.zPosition = 4
        gameplayLayer.addChild(outerBorder)
        
        // Inner clear space - REMOVED: This was blocking planet backgrounds
        // The hollow road effect is now created differently
        
        // Add glowing border lines
        let leftGlow = SKShapeNode(path: path)
        leftGlow.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 1.0, alpha: 0.6) // Bright purple
        leftGlow.lineWidth = 42
        leftGlow.lineCap = .round
        leftGlow.fillColor = .clear
        leftGlow.glowWidth = 8
        leftGlow.zPosition = 3
        gameplayLayer.addChild(leftGlow)
        
        // Center dots for lane divider
        for t in stride(from: 0.0, to: 1.0, by: 0.03) {
            let point = getPointOnPath(path: path, t: t)
            let dot = SKShapeNode(circleOfRadius: 1)
            dot.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.6)
            dot.strokeColor = .clear
            dot.glowWidth = 3
            dot.position = point
            dot.zPosition = 6
            gameplayLayer.addChild(dot)
        }
        
        // Add pulsing to glow
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.5),
            SKAction.fadeAlpha(to: 0.6, duration: 1.5)
        ])
        leftGlow.run(SKAction.repeatForever(pulse))
        
        // START indicator
        createStartIndicator(at: startPoint)
        
        // END indicator at station
        createEndIndicator()
        
        // Direction arrows - disabled as they were showing wrong directions
        // addDirectionArrows()
    }
    
    private func createStartIndicator(at position: CGPoint) {
        let startContainer = SKNode()
        startContainer.position = position
        startContainer.zPosition = 50
        
        let startBg = SKShapeNode(rectOf: CGSize(width: 70, height: 30), cornerRadius: 5)
        startBg.fillColor = SKColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 0.9)
        startBg.strokeColor = SKColor.green
        startBg.lineWidth = 2
        startBg.glowWidth = 3
        startContainer.addChild(startBg)
        
        let startLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        startLabel.text = "SPAWN"
        startLabel.fontSize = 14
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startContainer.addChild(startLabel)
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        startContainer.run(SKAction.repeatForever(pulse))
        
        gameplayLayer.addChild(startContainer)
    }
    
    private func createEndIndicator() {
        let endContainer = SKNode()
        endContainer.position = CGPoint.zero
        endContainer.zPosition = 45
        
        // Danger zone circles
        for i in 1...3 {
            let radius = CGFloat(50 + i * 15)
            let dangerCircle = SKShapeNode(circleOfRadius: radius)
            dangerCircle.fillColor = .clear
            dangerCircle.strokeColor = SKColor.red.withAlphaComponent(CGFloat(0.6 - Double(i) * 0.15))
            dangerCircle.lineWidth = 2
            dangerCircle.glowWidth = 3
            
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: Double(5 + i * 2))
            dangerCircle.run(SKAction.repeatForever(rotate))
            
            endContainer.addChild(dangerCircle)
        }
        
        let endLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        endLabel.text = "DEFEND!"
        endLabel.fontSize = 16
        endLabel.fontColor = SKColor.red
        endLabel.position = CGPoint(x: -15, y: -90)
        endLabel.verticalAlignmentMode = .center
        endContainer.addChild(endLabel)
        
        gameplayLayer.addChild(endContainer)
    }
    
    private func addDirectionArrows() {
        let arrowPositions = [
            (CGPoint(x: 380, y: 0), CGFloat.pi),
            (CGPoint(x: 250, y: 50), CGFloat.pi * 3/4),
            (CGPoint(x: 100, y: 150), CGFloat.pi/2),
            (CGPoint(x: -50, y: 150), CGFloat.pi/2),
            (CGPoint(x: -150, y: 100), CGFloat.pi * 3/4),
            (CGPoint(x: -200, y: 0), CGFloat.pi),
            (CGPoint(x: -150, y: -100), -CGFloat.pi * 3/4),
            (CGPoint(x: 0, y: -150), 0),
            (CGPoint(x: 50, y: -100), CGFloat.pi/4),
        ]
        
        for (position, rotation) in arrowPositions {
            let arrow = createDirectionArrow()
            arrow.position = position
            arrow.zRotation = rotation
            gameplayLayer.addChild(arrow)
        }
    }
    
    private func getPointOnPath(path: CGPath, t: CGFloat) -> CGPoint {
        // Approximate path position for dots
        // This is a simplified calculation for the S-curve
        if t < 0.2 {
            // Initial straight section
            let localT = t * 5
            return CGPoint(x: 400 - (100 * localT), y: -50 + (50 * localT))
        } else if t < 0.4 {
            // First curve up
            let localT = (t - 0.2) * 5
            return CGPoint(
                x: 300 - (300 * localT),
                y: 0 + (150 * localT)
            )
        } else if t < 0.6 {
            // Curve left and down
            let localT = (t - 0.4) * 5
            return CGPoint(
                x: 0 - (200 * localT),
                y: 150 - (150 * localT)
            )
        } else if t < 0.8 {
            // Curve to bottom
            let localT = (t - 0.6) * 5
            return CGPoint(
                x: -200 + (200 * localT),
                y: 0 - (150 * localT)
            )
        } else {
            // Final approach
            let localT = (t - 0.8) * 5
            return CGPoint(
                x: 0,
                y: -150 + (150 * localT)
            )
        }
    }
    
    private func createHeartShape() -> SKShapeNode {
        let path = CGMutablePath()
        let size: CGFloat = 8
        
        // Create heart shape
        path.move(to: CGPoint(x: 0, y: -size * 0.5))
        path.addCurve(to: CGPoint(x: -size, y: size * 0.3),
                     control1: CGPoint(x: 0, y: -size * 0.2),
                     control2: CGPoint(x: -size, y: -size * 0.1))
        path.addArc(center: CGPoint(x: -size * 0.5, y: size * 0.5),
                   radius: size * 0.5,
                   startAngle: .pi,
                   endAngle: 0,
                   clockwise: true)
        path.addArc(center: CGPoint(x: size * 0.5, y: size * 0.5),
                   radius: size * 0.5,
                   startAngle: .pi,
                   endAngle: 0,
                   clockwise: true)
        path.addCurve(to: CGPoint(x: 0, y: -size * 0.5),
                     control1: CGPoint(x: size, y: -size * 0.1),
                     control2: CGPoint(x: 0, y: -size * 0.2))
        
        let heart = SKShapeNode(path: path)
        heart.lineWidth = 1.5
        return heart
    }
    
    private func createDirectionArrow() -> SKNode {
        let arrow = SKNode()
        arrow.zPosition = 7
        
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -15, y: -8))
        arrowPath.addLine(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: -15, y: 8))
        
        let arrowShape = SKShapeNode(path: arrowPath)
        arrowShape.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8)
        arrowShape.lineWidth = 3
        arrowShape.lineCap = .round
        arrowShape.glowWidth = 2
        arrow.addChild(arrowShape)
        
        let moveForward = SKAction.moveBy(x: 5, y: 0, duration: 0.5)
        let moveBack = SKAction.moveBy(x: -5, y: 0, duration: 0.5)
        let sequence = SKAction.sequence([moveForward, moveBack])
        arrow.run(SKAction.repeatForever(sequence))
        
        return arrow
    }
    
    private func removeTowerSelector() {
        gameplayLayer.childNode(withName: "towerSelectorContainer")?.removeFromParent()
        uiLayer.childNode(withName: "towerSelectorContainer")?.removeFromParent()
        towerSelectionMenu = nil
    }
    
    private func createEnhancedTowerSelector(at buildNodePosition: CGPoint) {
        // Store the build node position for tower placement
        selectedBuildNode?.userData = ["originalPosition": NSValue(cgPoint: buildNodePosition)]
        
        // Remove any existing tower selector
        removeTowerSelector()
        
        // Create container for the selector
        let selectorContainer = SKNode()
        selectorContainer.name = "towerSelectorContainer"
        selectorContainer.zPosition = 1500
        
        // Add full-screen overlay to dim the background and block ALL touches
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: size.height * 3))
        overlay.fillColor = SKColor.black.withAlphaComponent(0.6)  // Slightly darker
        overlay.strokeColor = .clear
        overlay.position = CGPoint.zero
        overlay.zPosition = -1
        overlay.name = "selectorOverlay"
        overlay.isUserInteractionEnabled = true  // Block touches to elements behind
        selectorContainer.addChild(overlay)
        
        // Add invisible touch blocker specifically for the overlay
        let touchBlocker = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: size.height * 3))
        touchBlocker.fillColor = .clear
        touchBlocker.strokeColor = .clear
        touchBlocker.position = CGPoint.zero
        touchBlocker.zPosition = -2
        touchBlocker.name = "touchBlocker"
        touchBlocker.isUserInteractionEnabled = true
        selectorContainer.addChild(touchBlocker)
        
        // ALWAYS position selector at bottom of screen
        let bottomY = -(size.height / 2) + 80  // Safe margin from bottom
        selectorContainer.position = CGPoint(x: 0, y: bottomY)
        
        // Background for selector - wider to fit all 7 towers
        let selectorBg = SKShapeNode(rectOf: CGSize(width: 720, height: 100), cornerRadius: 10)
        selectorBg.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 0.98)
        selectorBg.strokeColor = SKColor(red: 0.5, green: 0, blue: 1, alpha: 1) // Purple outline
        selectorBg.lineWidth = 2
        selectorBg.glowWidth = 4
        selectorBg.name = "selectorBackground"
        selectorContainer.addChild(selectorBg)
        
        // Tower buttons with proper graphics - Progressive unlocking by MAP
        let allTowers: [(String, String, SKColor, Int, Int)] = [  // Added unlock map
            // Always available (3 basic towers)
            ("machinegun", "MachineGun", SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0), 75, 1),  // Map 1
            ("kinetic", "Cannon", SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), 80, 1),   // Map 1
            ("laser", "Laser", SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0), 120, 1),     // Map 1
            
            // Unlock by map progression
            ("plasma", "Plasma", SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0), 150, 2),   // Map 2
            ("missile", "Missile", SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0), 250, 3), // Map 3
            ("tesla", "EMP", SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0), 350, 4),       // Map 4
            ("freeze", "Freeze", SKColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0), 200, 5)   // Map 5
        ]
        
        // Filter to show only unlocked towers based on current map
        let unlockedTowers = allTowers.filter { $0.4 <= currentMap }
        
        let buttonSpacing: CGFloat = 100  // Reduced from 120 to fit better
        let startX = -CGFloat(unlockedTowers.count - 1) * buttonSpacing / 2
        
        // Show "New Tower Unlocked!" notification if applicable
        if currentMap > 1 {
            let newlyUnlocked = allTowers.filter { $0.4 == currentMap }
            if !newlyUnlocked.isEmpty {
                let unlockLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
                unlockLabel.text = "NEW: \(newlyUnlocked[0].1) Tower!"
                unlockLabel.fontSize = 16
                unlockLabel.fontColor = SKColor.yellow
                unlockLabel.position = CGPoint(x: 0, y: 60)
                selectorContainer.addChild(unlockLabel)
                
                // Pulse animation
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                unlockLabel.run(SKAction.repeat(pulse, count: 3))
            }
        }
        
        for (index, (type, name, color, cost, _)) in unlockedTowers.enumerated() {
            let buttonContainer = SKNode()
            buttonContainer.position = CGPoint(x: startX + CGFloat(index) * buttonSpacing, y: 0)
            buttonContainer.name = "towerButton_\(type)"
            buttonContainer.zPosition = 1001
            
            // Button frame
            let buttonBg = SKShapeNode(rectOf: CGSize(width: 80, height: 80), cornerRadius: 8)
            buttonBg.fillColor = SKColor.black.withAlphaComponent(0.85)  // Darker background for better contrast
            buttonBg.strokeColor = color
            buttonBg.lineWidth = 2
            buttonBg.glowWidth = 2
            buttonContainer.addChild(buttonBg)
            
            // Tower icon preview (simplified version of actual tower)
            let icon = createTowerIcon(type: type, color: color)
            icon.position = CGPoint(x: 0, y: 10)
            buttonContainer.addChild(icon)
            
            // Tower name
            let nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            nameLabel.text = name
            nameLabel.fontSize = 14
            nameLabel.fontColor = .white  // White for maximum readability
            nameLabel.position = CGPoint(x: 0, y: -25)
            buttonContainer.addChild(nameLabel)
            
            // Cost
            let costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            costLabel.text = "$\(cost)"
            costLabel.fontSize = 12
            costLabel.fontColor = SKColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0)  // Light yellow
            costLabel.position = CGPoint(x: 0, y: -38)
            buttonContainer.addChild(costLabel)
            
            selectorContainer.addChild(buttonContainer)
        }
        
        // Add close button
        let closeButton = SKShapeNode(circleOfRadius: 28)  // Much bigger for easier tapping
        closeButton.fillColor = SKColor.red.withAlphaComponent(0.95)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 3
        closeButton.glowWidth = 5
        closeButton.position = CGPoint(x: 360, y: 40)  // Right side, higher position
        closeButton.name = "closeTowerSelector"
        closeButton.zPosition = 1000  // Ensure always on top
        selectorContainer.addChild(closeButton)
        
        let closeX = SKLabelNode(fontNamed: "Helvetica-Bold")
        closeX.text = "×"
        closeX.fontSize = 20
        closeX.fontColor = .white
        closeX.position = CGPoint(x: 0, y: 0)  // Keep centered
        closeX.verticalAlignmentMode = .center
        closeX.horizontalAlignmentMode = .center
        closeButton.addChild(closeX)
        
        // Add to UI layer so it stays fixed at bottom of screen
        uiLayer.addChild(selectorContainer)
        
        // Store reference
        towerSelectionMenu = selectorContainer
    }
    
    private func createTowerIcon(type: String, color: SKColor) -> SKNode {
        let icon = SKNode()
        
        switch type {
        case "machinegun":
            // Machine gun tower icon - twin barrels like a tank
            let base = SKShapeNode(circleOfRadius: 6)
            base.strokeColor = color
            base.lineWidth = 2
            base.fillColor = .clear
            icon.addChild(base)
            
            // Twin barrels - thin and parallel
            let barrelLength: CGFloat = 14
            let barrelWidth: CGFloat = 2
            let barrelSpacing: CGFloat = 3
            
            // Left barrel
            let leftBarrel = SKShapeNode(rect: CGRect(x: -barrelSpacing - barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
            leftBarrel.strokeColor = color
            leftBarrel.lineWidth = 1
            leftBarrel.fillColor = color.withAlphaComponent(0.3)
            icon.addChild(leftBarrel)
            
            // Right barrel
            let rightBarrel = SKShapeNode(rect: CGRect(x: barrelSpacing - barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
            rightBarrel.strokeColor = color
            rightBarrel.lineWidth = 1
            rightBarrel.fillColor = color.withAlphaComponent(0.3)
            icon.addChild(rightBarrel)
            
            // Ammo box
            let ammoBox = SKShapeNode(rect: CGRect(x: -5, y: -6, width: 10, height: 4))
            ammoBox.strokeColor = color.withAlphaComponent(0.7)
            ammoBox.lineWidth = 1
            ammoBox.fillColor = .clear
            icon.addChild(ammoBox)
            
        case "laser":
            // Laser tower icon
            let base = SKShapeNode(circleOfRadius: 8)
            base.strokeColor = color
            base.lineWidth = 2
            base.fillColor = .clear
            icon.addChild(base)
            
            let barrel = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 16))
            barrel.strokeColor = color
            barrel.lineWidth = 1.5
            barrel.fillColor = .clear
            barrel.glowWidth = 2
            icon.addChild(barrel)
            
        case "kinetic", "cannon":
            // Kinetic cannon icon
            let base = SKShapeNode(circleOfRadius: 8)
            base.strokeColor = color
            base.lineWidth = 2
            base.fillColor = .clear
            icon.addChild(base)
            
            // Thick barrel
            let barrel = SKShapeNode(rect: CGRect(x: -3, y: 0, width: 6, height: 14))
            barrel.strokeColor = color
            barrel.lineWidth = 2
            barrel.fillColor = .clear
            icon.addChild(barrel)
            
            // Muzzle brake
            let muzzle = SKShapeNode(rect: CGRect(x: -4, y: 12, width: 8, height: 2))
            muzzle.strokeColor = color
            muzzle.lineWidth = 1.5
            muzzle.fillColor = .clear
            icon.addChild(muzzle)
            
        case "plasma":
            // Plasma tower icon
            let chamber = SKShapeNode(rect: CGRect(x: -6, y: -4, width: 12, height: 12))
            chamber.strokeColor = color
            chamber.lineWidth = 2
            chamber.fillColor = .clear
            chamber.glowWidth = 3
            icon.addChild(chamber)
            
            let orb = SKShapeNode(circleOfRadius: 4)
            orb.strokeColor = color
            orb.fillColor = color.withAlphaComponent(0.3)
            orb.glowWidth = 4
            orb.position = CGPoint(x: 0, y: 4)
            icon.addChild(orb)
            
        case "missile":
            // Missile tower icon  
            for x in [-6, 6] {
                let tube = SKShapeNode(rect: CGRect(x: x - 2, y: -4, width: 4, height: 12))
                tube.strokeColor = color
                tube.lineWidth = 1.5
                tube.fillColor = .clear
                icon.addChild(tube)
                
                // Missile tip
                let tip = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: x - 2, y: 8))
                path.addLine(to: CGPoint(x: x, y: 12))
                path.addLine(to: CGPoint(x: x + 2, y: 8))
                tip.path = path
                tip.strokeColor = SKColor.red
                tip.lineWidth = 1
                tip.glowWidth = 2
                icon.addChild(tip)
            }
            
        case "freeze":
            // Freeze tower icon - snowflake design
            let base = SKShapeNode(circleOfRadius: 8)
            base.strokeColor = color
            base.lineWidth = 2
            base.fillColor = .clear
            icon.addChild(base)
            
            // Snowflake pattern
            for angle in stride(from: 0, to: 360, by: 60) {
                let rad = CGFloat(angle) * .pi / 180
                let spike = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint.zero)
                path.addLine(to: CGPoint(x: cos(rad) * 12, y: sin(rad) * 12))
                spike.path = path
                spike.strokeColor = color
                spike.lineWidth = 1.5
                spike.glowWidth = 2
                icon.addChild(spike)
                
                // Small branches
                let branch1 = SKShapeNode()
                let branchPath1 = CGMutablePath()
                branchPath1.move(to: CGPoint(x: cos(rad) * 6, y: sin(rad) * 6))
                branchPath1.addLine(to: CGPoint(
                    x: cos(rad) * 6 + cos(rad + .pi/4) * 3,
                    y: sin(rad) * 6 + sin(rad + .pi/4) * 3
                ))
                branch1.path = branchPath1
                branch1.strokeColor = color
                branch1.lineWidth = 1
                icon.addChild(branch1)
            }
            
        case "tesla":
            // EMP tower icon
            let tower = SKShapeNode(rect: CGRect(x: -4, y: -6, width: 8, height: 14))
            tower.strokeColor = color
            tower.lineWidth = 2
            tower.fillColor = .clear
            icon.addChild(tower)
            
            // Electric arcs
            for angle in [45, 135, 225, 315] {
                let rad = CGFloat(angle) * .pi / 180
                let arc = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: 8))
                path.addLine(to: CGPoint(x: cos(rad) * 10, y: 8 + sin(rad) * 6))
                arc.path = path
                arc.strokeColor = color.withAlphaComponent(0.6)
                arc.lineWidth = 1
                arc.glowWidth = 2
                icon.addChild(arc)
            }
            
        default:
            // Generic icon
            let shape = SKShapeNode(circleOfRadius: 10)
            shape.strokeColor = color
            shape.lineWidth = 2
            shape.fillColor = .clear
            icon.addChild(shape)
        }
        
        return icon
    }
    
    private func createHUD() {
        // This will be expanded with proper UI elements
        // For now, create basic labels
        
        // Clear any existing HUD elements first
        uiLayer.children.forEach { node in
            if node.name == "salvageLabel" || node.name == "waveLabel" || node.name == "hpLabel" || 
               node.name == "hudBg" || node.name == "scoreLabel" || node.name == "scoreGlow" || node.name == "salvageIcon" {
                node.removeFromParent()
            }
        }
        
        // Get the actual visible area based on screen size
        let screenHeight = size.height / 2  // Half height since anchor is 0.5
        let topY = screenHeight - 20  // Safe margin from top
        
        // NO BORDER - removed hudBg panel to save space
        
        // Score counter (moved right to avoid X button overlap)
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "SCORE: \(score)"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = SKColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 1.0) // Bright green
        scoreLabel.position = CGPoint(x: -(size.width/2 - 50), y: topY)  // Adjusted for smaller X button
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 999
        uiLayer.addChild(scoreLabel)
        
        // Salvage counter right after score (money following score)
        let salvageIcon = SKShapeNode(circleOfRadius: 5)
        salvageIcon.fillColor = .yellow
        salvageIcon.strokeColor = .orange
        salvageIcon.lineWidth = 1
        salvageIcon.glowWidth = 2
        salvageIcon.position = CGPoint(x: -(size.width/2 - 180), y: topY + 2)  // Proper spacing
        salvageIcon.zPosition = 999
        salvageIcon.name = "salvageIcon"
        uiLayer.addChild(salvageIcon)
        
        let salvageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        salvageLabel.text = "\(playerSalvage)"
        salvageLabel.fontSize = 18
        salvageLabel.fontColor = .yellow
        salvageLabel.position = CGPoint(x: -(size.width/2 - 190), y: topY)  // Proper spacing
        salvageLabel.horizontalAlignmentMode = .left
        salvageLabel.name = "salvageLabel"
        salvageLabel.zPosition = 999
        uiLayer.addChild(salvageLabel)
        
        // Wave counter on RIGHT side of screen (shows wave X/5 for current map) - SMALLER TEXT
        let waveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        waveLabel.text = "MAP \(currentMap) - WAVE \(currentWave)/\(wavesPerMap)"
        waveLabel.fontSize = 14  // Reduced from 18
        waveLabel.fontColor = .cyan
        waveLabel.position = CGPoint(x: size.width/2 - 20, y: topY)  // Safe margin from right
        waveLabel.horizontalAlignmentMode = .right
        waveLabel.name = "waveLabel"
        waveLabel.zPosition = 999
        uiLayer.addChild(waveLabel)
        
        
        // Abort Game button (X icon) - moved down and right, made bigger
        let abortButton = SKNode()
        abortButton.position = CGPoint(x: -size.width/2 + 60, y: topY - 60)  // More right and down
        abortButton.name = "abortButton"
        abortButton.zPosition = 1002
        
        let abortBg = SKShapeNode(circleOfRadius: 24)  // Much bigger for easier tapping
        abortBg.fillColor = SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.9)
        abortBg.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        abortBg.lineWidth = 2  // Slightly thicker
        abortBg.name = "abortBg"
        abortButton.addChild(abortBg)
        
        // X icon - bigger
        let xIcon = SKLabelNode(text: "✕")
        xIcon.fontSize = 20  // Bigger font to match bigger button
        xIcon.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
        xIcon.verticalAlignmentMode = .center
        xIcon.horizontalAlignmentMode = .center
        xIcon.name = "xIcon"
        abortButton.addChild(xIcon)
        
        uiLayer.addChild(abortButton)
        
        // Screen Clear Superweapon button (bottom left)
        createScreenClearButton()
        
        // Secret level skip button (invisible, top left corner - tap 3 times to activate)
        let secretButton = SKShapeNode(rectOf: CGSize(width: 60, height: 40))
        secretButton.position = CGPoint(x: -size.width/2 + 30, y: size.height/2 - 30)
        secretButton.fillColor = .clear
        secretButton.strokeColor = .clear
        secretButton.name = "secretLevelSkip"
        secretButton.userData = NSMutableDictionary()
        secretButton.userData?["tapCount"] = 0
        secretButton.zPosition = 9999
        uiLayer.addChild(secretButton)
        
        // Station HP with heart icons - better visualization
        let hpContainer = SKNode()
        hpContainer.position = CGPoint(x: size.width/2 - 120, y: topY - 25)  // Proper spacing
        hpContainer.name = "hpContainer"
        uiLayer.addChild(hpContainer)
        
        // Create heart icons for lives
        let maxHearts = maxStationHealth  // Show 1 heart per HP (5 hearts for 5 HP)
        let hpPerHeart = 1
        let heartSpacing: CGFloat = 20
        
        for i in 0..<maxHearts {
            let heart = createHeartShape()
            heart.position = CGPoint(x: CGFloat(i) * heartSpacing, y: 0)
            heart.name = "heart_\(i)"
            
            let heartHP = stationHealth - (i * hpPerHeart)
            if heartHP >= hpPerHeart {
                // Full heart
                heart.fillColor = SKColor(red: 1, green: 0.2, blue: 0.3, alpha: 1)
                heart.strokeColor = SKColor(red: 1, green: 0.4, blue: 0.5, alpha: 1)
                heart.glowWidth = 2
            } else if heartHP > 0 {
                // Partial heart
                heart.fillColor = SKColor(red: 1, green: 0.2, blue: 0.3, alpha: 0.5)
                heart.strokeColor = SKColor(red: 1, green: 0.4, blue: 0.5, alpha: 1)
                heart.glowWidth = 1
            } else {
                // Empty heart
                heart.fillColor = SKColor.clear
                heart.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 0.3)
                heart.glowWidth = 0
            }
            
            hpContainer.addChild(heart)
        }
        
        // Lives count label
        let hpLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        hpLabel.text = "\(stationHealth)"
        hpLabel.fontSize = 16
        hpLabel.fontColor = SKColor(red: 1, green: 0.3, blue: 0.4, alpha: 1)
        hpLabel.position = CGPoint(x: heartSpacing * CGFloat(maxHearts) + 5, y: -4)
        hpLabel.horizontalAlignmentMode = .left
        hpLabel.name = "hpLabel"
        hpLabel.zPosition = 999
        hpContainer.addChild(hpLabel)
        
        // No pulse animation - user requested removal
        
        // Start Wave Button
        createStartWaveButton()
    }
    
    private func createScreenClearButton() {
        // Remove existing button
        screenClearButton?.removeFromParent()
        
        // Create screen clear superweapon button (bottom left)
        screenClearButton = SKNode()
        screenClearButton!.position = CGPoint(x: -size.width/2 + 60, y: -size.height/2 + 60)
        screenClearButton!.name = "screenClearButton"
        screenClearButton!.zPosition = 1001
        
        // Button background - changes color based on charges available
        let buttonBg = SKShapeNode(circleOfRadius: 30)
        if screenClearCharges > 0 {
            // Active - golden/orange
            buttonBg.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.8)
            buttonBg.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            buttonBg.lineWidth = 3
            buttonBg.glowWidth = 6
        } else {
            // Inactive - dark gray
            buttonBg.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
            buttonBg.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
            buttonBg.lineWidth = 2
            buttonBg.glowWidth = 0
        }
        buttonBg.name = "buttonBg"
        screenClearButton!.addChild(buttonBg)
        
        // Lightning bolt icon for screen clear
        let icon = SKLabelNode(text: "⚡")
        icon.fontSize = 24
        icon.fontColor = screenClearCharges > 0 ? .white : SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        icon.verticalAlignmentMode = .center
        icon.horizontalAlignmentMode = .center
        screenClearButton!.addChild(icon)
        
        // Charges indicator
        let chargesLabel = SKLabelNode(text: "\(screenClearCharges)")
        chargesLabel.fontSize = 14
        chargesLabel.fontName = "AvenirNext-Bold"
        chargesLabel.fontColor = screenClearCharges > 0 ? .yellow : SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        chargesLabel.position = CGPoint(x: 20, y: -20)
        chargesLabel.name = "chargesLabel"
        screenClearButton!.addChild(chargesLabel)
        
        // Add pulsing effect when available
        if screenClearCharges > 0 {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.8),
                SKAction.scale(to: 1.0, duration: 0.8)
            ])
            buttonBg.run(SKAction.repeatForever(pulse))
        }
        
        uiLayer.addChild(screenClearButton!)
    }
    
    private func activateScreenClear() {
        // Check if we have charges available
        guard screenClearCharges > 0 else {
            showMessage("No charges available!", at: CGPoint(x: 0, y: 0), color: .red)
            return
        }
        
        // Consume a charge
        screenClearCharges -= 1
        
        // Create massive screen-wide explosion effect
        let screenClearEffect = SKShapeNode(circleOfRadius: 10)
        screenClearEffect.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.8)
        screenClearEffect.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        screenClearEffect.lineWidth = 5
        screenClearEffect.glowWidth = 15
        screenClearEffect.position = CGPoint.zero
        screenClearEffect.zPosition = 950
        effectsLayer.addChild(screenClearEffect)
        
        // Expand the effect across the entire screen
        let expandAction = SKAction.scale(to: 50.0, duration: 1.0)
        let fadeAction = SKAction.fadeOut(withDuration: 1.0)
        let combinedAction = SKAction.group([expandAction, fadeAction])
        
        screenClearEffect.run(SKAction.sequence([
            combinedAction,
            SKAction.removeFromParent()
        ]))
        
        // Destroy all enemies on screen and award salvage
        var totalSalvage = 0
        let enemiesToRemove: [SKNode] = Array(enemyLayer.children)
        
        for enemy in enemiesToRemove {
            if enemy.name?.contains("enemy_") == true {
                // Award salvage for each enemy killed
                if let userData = enemy.userData, let salvageValue = userData["salvageValue"] as? Int {
                    totalSalvage += salvageValue
                } else {
                    totalSalvage += 10  // Default salvage if not set
                }
                
                // Create destruction effect for each enemy
                let destructEffect = SKShapeNode(circleOfRadius: 15)
                destructEffect.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
                destructEffect.strokeColor = .clear
                destructEffect.position = enemy.position
                destructEffect.zPosition = 900
                effectsLayer.addChild(destructEffect)
                
                destructEffect.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 3.0, duration: 0.3),
                        SKAction.fadeOut(withDuration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ]))
                
                // Remove the enemy
                enemy.removeFromParent()
            }
        }
        
        // Award total salvage
        if totalSalvage > 0 {
            playerSalvage += totalSalvage
            updateSalvageDisplay()
            showMessage("+\(totalSalvage) Salvage", at: CGPoint(x: 0, y: 100), color: .yellow)
        }
        
        // Update the screen clear button
        createScreenClearButton()
        
        // Play sound effect
        SoundManager.shared.playSound(.waveComplete, volume: 0.8)
        
        showMessage("SCREEN CLEARED!", at: CGPoint(x: 0, y: 50), color: .orange)
        
        print("Screen clear activated! Destroyed \(enemiesToRemove.count) enemies, awarded \(totalSalvage) salvage")
    }
    
    private func createControlButtons() {
        // Remove any existing control buttons first
        uiLayer.childNode(withName: "speedButton")?.removeFromParent()
        uiLayer.childNode(withName: "nextMapButton")?.removeFromParent()
        
        // Position at same level as Score HUD
        let topY = size.height/2 - 20  // Same as Score label position
        
        // LEFT BUTTON: Speed Control (keep at bottom for easy access during gameplay)
        let speedContainer = SKNode()
        speedContainer.name = "speedButton"
        speedContainer.position = CGPoint(x: -size.width/2 + 80, y: -(size.height/2 - 120))  // Bottom left
        
        // Circular button with OUTLINE design (no fill) - ORANGE for speed
        let speedBg = SKShapeNode(circleOfRadius: 30)
        speedBg.fillColor = .clear  // No fill, just outline
        speedBg.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)  // Orange outline
        speedBg.lineWidth = 2
        speedBg.glowWidth = 2
        speedBg.name = "speedButtonBg"
        speedBg.zPosition = 1
        speedContainer.addChild(speedBg)
        
        // Speed icon (fast forward arrows)
        let speedIcon = SKLabelNode(text: "1x")
        speedIcon.fontSize = 18
        speedIcon.fontName = "AvenirNext-Bold"
        speedIcon.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
        speedIcon.verticalAlignmentMode = .center
        speedIcon.zPosition = 2
        speedIcon.name = "speedIconLabel"
        speedContainer.addChild(speedIcon)
        
        // Add label below the button
        let speedLabel = SKLabelNode(text: "SPEED")
        speedLabel.fontSize = 10
        speedLabel.fontName = "AvenirNext-Bold"
        speedLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
        speedLabel.position = CGPoint(x: 0, y: -45)
        speedLabel.zPosition = 2
        speedContainer.addChild(speedLabel)
        
        speedContainer.userData = NSMutableDictionary()
        speedContainer.userData?["currentSpeed"] = 1
        
        uiLayer.addChild(speedContainer)
        
        // NEXT LEVEL BUTTON: Small button at top right, same row as Score
        let levelContainer = SKNode()
        levelContainer.name = "nextMapButton"
        levelContainer.position = CGPoint(x: size.width/2 - 100, y: topY)  // Top right, same level as Score
        
        // Smaller circular button to match HUD size
        let levelBg = SKShapeNode(circleOfRadius: 20)
        levelBg.fillColor = .clear  // No fill, just outline
        levelBg.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.8)  // Green outline
        levelBg.lineWidth = 2
        levelBg.glowWidth = 2
        levelBg.name = "nextMapButtonBg"
        levelBg.zPosition = 1
        levelContainer.addChild(levelBg)
        
        // Level icon (skip arrow)
        let levelIcon = SKShapeNode()
        let path = CGMutablePath()
        // Create skip icon (|>>)
        path.move(to: CGPoint(x: -10, y: -8))
        path.addLine(to: CGPoint(x: -10, y: 8))
        path.move(to: CGPoint(x: -6, y: -8))
        path.addLine(to: CGPoint(x: 2, y: 0))
        path.addLine(to: CGPoint(x: -6, y: 8))
        path.move(to: CGPoint(x: 2, y: -8))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 2, y: 8))
        levelIcon.path = path
        levelIcon.fillColor = .clear
        levelIcon.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.8)
        levelIcon.lineWidth = 1.5
        levelIcon.glowWidth = 1
        levelIcon.zPosition = 2
        levelContainer.addChild(levelIcon)
        
        // Add label below the button
        let levelLabel = SKLabelNode(text: "NEXT LEVEL")
        levelLabel.fontSize = 10
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.8)
        levelLabel.position = CGPoint(x: 0, y: -45)
        levelLabel.zPosition = 2
        levelContainer.addChild(levelLabel)
        
        uiLayer.addChild(levelContainer)
    }
    
    private func createNextWaveButtonInCircularStyle() {
        // Remove any existing next wave button first
        uiLayer.childNode(withName: "nextWaveButton")?.removeFromParent()
        
        // Create button container with same style as start wave button
        let buttonContainer = SKNode()
        buttonContainer.name = "nextWaveButton"
        // Position button in bottom right corner (same as start wave button)
        buttonContainer.position = CGPoint(x: size.width/2 - 60, y: -(size.height/2 - 80))  // Bottom right
        
        // Circular button with OUTLINE design (no fill) - PURPLE and less bright
        let buttonBg = SKShapeNode(circleOfRadius: 30)
        buttonBg.fillColor = .clear  // No fill, just outline
        buttonBg.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)  // Purple outline, less bright
        buttonBg.lineWidth = 2
        buttonBg.glowWidth = 2  // Reduced glow for less brightness
        buttonBg.name = "nextWaveButtonBg"
        buttonBg.zPosition = 1
        buttonContainer.addChild(buttonBg)
        
        // Forward arrow icon with outline style - matching purple
        let forwardIcon = SKShapeNode()
        let path = CGMutablePath()
        // Create double arrow (>>)
        path.move(to: CGPoint(x: -12, y: -10))
        path.addLine(to: CGPoint(x: -2, y: 0))
        path.addLine(to: CGPoint(x: -12, y: 10))
        path.move(to: CGPoint(x: 2, y: -10))
        path.addLine(to: CGPoint(x: 12, y: 0))
        path.addLine(to: CGPoint(x: 2, y: 10))
        forwardIcon.path = path
        forwardIcon.fillColor = .clear  // No fill
        forwardIcon.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)  // Purple outline
        forwardIcon.lineWidth = 1.5
        forwardIcon.glowWidth = 1
        forwardIcon.zPosition = 2
        buttonContainer.addChild(forwardIcon)
        
        // Add label below the button
        let label = SKLabelNode(text: "NEXT WAVE")
        label.fontSize = 10
        label.fontName = "AvenirNext-Bold"
        label.fontColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)
        label.position = CGPoint(x: 0, y: -45)
        label.zPosition = 2
        buttonContainer.addChild(label)
        
        uiLayer.addChild(buttonContainer)
        
        // Add pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        buttonContainer.run(SKAction.repeatForever(pulse))
    }
    
    private func createStartWaveButton() {
        // Remove any existing start wave or next wave buttons first
        uiLayer.childNode(withName: "startWaveButton")?.removeFromParent()
        uiLayer.childNode(withName: "nextWaveButton")?.removeFromParent()
        
        // Create button container
        let buttonContainer = SKNode()
        buttonContainer.name = "startWaveButton"
        // Position button in bottom right corner
        buttonContainer.position = CGPoint(x: size.width/2 - 60, y: -(size.height/2 - 80))  // Safe margins
        
        // Circular button with OUTLINE design (no fill) - PURPLE and less bright
        let buttonBg = SKShapeNode(circleOfRadius: 30)
        buttonBg.fillColor = .clear  // No fill, just outline
        buttonBg.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)  // Purple outline, less bright
        buttonBg.lineWidth = 2
        buttonBg.glowWidth = 2  // Reduced glow for less brightness
        buttonBg.name = "startWaveButtonBg"
        buttonBg.zPosition = 1
        buttonContainer.addChild(buttonBg)
        
        // Play icon with outline style - matching purple
        let playIcon = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -8, y: -12))
        path.addLine(to: CGPoint(x: -8, y: 12))
        path.addLine(to: CGPoint(x: 12, y: 0))
        path.closeSubpath()
        playIcon.path = path
        playIcon.fillColor = .clear  // No fill
        playIcon.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 0.8)  // Purple outline, less bright
        playIcon.lineWidth = 1.5
        playIcon.glowWidth = 1
        playIcon.position = CGPoint(x: 3, y: 0)  // Slightly offset for visual balance
        playIcon.name = "startWaveButtonIcon"
        buttonContainer.addChild(playIcon)
        
        // Wave number below button
        let waveText = SKLabelNode(fontNamed: "Helvetica")
        waveText.text = "Wave 1"
        waveText.fontSize = 12
        waveText.fontColor = .white
        waveText.position = CGPoint(x: 0, y: -50)
        waveText.horizontalAlignmentMode = .center
        waveText.name = "startWaveButtonLabel"
        buttonContainer.addChild(waveText)
        
        // Subtle breathing animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        buttonBg.run(SKAction.repeatForever(pulse))
        
        uiLayer.addChild(buttonContainer)
    }
    
    private func generateGridTexture() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Dark background
            UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Grid lines
            UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.5).setStroke()
            let gridSize: CGFloat = 50
            
            for x in stride(from: 0, through: size.width, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: x, y: 0))
                context.cgContext.addLine(to: CGPoint(x: x, y: size.height))
            }
            
            for y in stride(from: 0, through: size.height, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: 0, y: y))
                context.cgContext.addLine(to: CGPoint(x: size.width, y: y))
            }
            
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchLocation = location
        
        // Debug: Print touch location
        print("Touch at location: \(location)")
        
        // PRIORITY 0: Check if tower selector is open - block all non-selector touches
        if let selectorContainer = uiLayer.childNode(withName: "towerSelectorContainer") ?? 
           gameplayLayer.childNode(withName: "towerSelectorContainer") {
            // Get touch location in selector container
            let selectorLocation = touch.location(in: selectorContainer)
            let selectorNodes = selectorContainer.nodes(at: selectorLocation)
            
            // Check if we clicked on a valid selector element
            var clickedOnSelector = false
            for node in selectorNodes {
                if let nodeName = node.name {
                    if nodeName.starts(with: "towerButton_") ||
                       nodeName == "closeTowerSelector" ||
                       nodeName == "selectorBackground" ||
                       nodeName.contains("TowerButton") ||
                       node.parent?.name?.starts(with: "towerButton_") == true {
                        clickedOnSelector = true
                        // Process the selector interaction
                        break
                    }
                }
            }
            
            // If we didn't click on a selector element but clicked on overlay, close selector
            if !clickedOnSelector {
                for node in selectorNodes {
                    if node.name == "selectorOverlay" || node.name == "touchBlocker" {
                        removeTowerSelector()
                        selectedBuildNode = nil
                        return
                    }
                }
                // Block all other touches when selector is open
                return
            }
        }
        
        // PRIORITY 1: Check for game over screen button interactions
        if uiLayer.childNode(withName: "gameOverOverlay") != nil {
            print("Game over screen active - checking buttons")
            
            // Get all nodes at the touch location in uiLayer (where buttons actually are)
            let uiLocation = touch.location(in: uiLayer)
            let uiNodes = uiLayer.nodes(at: uiLocation)
            
            print("UI touch location: \(uiLocation)")
            print("UI nodes found: \(uiNodes.count)")
            
            // Check all nodes at this location
            for node in uiNodes {
                print("Checking node: \(node.name ?? "unnamed"), parent: \(node.parent?.name ?? "no parent")")
                
                // Check for restart button
                if node.name == "restartButton" || 
                   node.parent?.name == "restartButton" ||
                   node.name == "restartButtonLabel" {
                    print("Restart button clicked!")
                    // Add button press animation
                    let buttonNode = (node.name == "restartButton") ? node : (node.parent?.name == "restartButton" ? node.parent : nil)
                    if let button = buttonNode {
                        let press = SKAction.sequence([
                            SKAction.scale(to: 0.9, duration: 0.1),
                            SKAction.scale(to: 1.0, duration: 0.1)
                        ])
                        button.run(press) { [weak self] in
                            self?.restartGame()
                        }
                    }
                    return
                }
                
                // Check for map selection button
                if node.name == "mapSelectionButton" || 
                   node.parent?.name == "mapSelectionButton" ||
                   node.name == "mapSelectionButtonLabel" {
                    print("Map selection button clicked!")
                    // Add button press animation
                    let buttonNode = (node.name == "mapSelectionButton") ? node : (node.parent?.name == "mapSelectionButton" ? node.parent : nil)
                    if let button = buttonNode {
                        let press = SKAction.sequence([
                            SKAction.scale(to: 0.9, duration: 0.1),
                            SKAction.scale(to: 1.0, duration: 0.1)
                        ])
                        button.run(press) { [weak self] in
                            self?.returnToMapSelection()
                        }
                    }
                    return
                }
            }
            
            // If game over screen is showing, block ALL other touches
            print("Game over screen blocking other touches")
            return
        }
        
        // If any modal menu is open, check if we're clicking on valid elements
        if let upgradeMenu = towerSelectionMenu {
            let menuLocation = touch.location(in: upgradeMenu)
            let menuNodes = upgradeMenu.nodes(at: menuLocation)
            
            // Check if we clicked on a button or valid menu element
            var clickedOnMenuElement = false
            for node in menuNodes {
                if let nodeName = node.name {
                    // Check for valid menu interactions
                    if nodeName.starts(with: "towerButton_") ||
                       nodeName == "upgradeButton" ||
                       nodeName == "sellButton" ||
                       nodeName == "closeUpgradeMenu" ||
                       nodeName == "closeTowerSelector" ||
                       nodeName == "selectorBackground" ||
                       node.parent?.name?.starts(with: "towerButton_") == true {
                        clickedOnMenuElement = true
                        break
                    }
                }
            }
            
            // Check if clicking on overlay specifically (only close if clicking overlay AND not on a button)
            let hasOverlay = menuNodes.contains { $0.name == "menuOverlay" || $0.name == "selectorOverlay" }
            
            // Only close menu if clicking on overlay and NOT on any menu elements
            if hasOverlay && !clickedOnMenuElement {
                towerSelectionMenu?.removeFromParent()
                towerSelectionMenu = nil
                // Hide range indicators
                towerLayer.children.forEach { tower in
                    if let range = tower.childNode(withName: "range") {
                        range.run(SKAction.fadeOut(withDuration: 0.2))
                    }
                }
                return
            }
            
            // If we clicked on a menu element, continue processing
        }
        
        // Check what was touched
        let touchedNodes = nodes(at: location)
        
        // PRIORITY 2: Check for power-up collection
        for node in touchedNodes {
            if let nodeName = node.name, nodeName.hasPrefix("powerUp_") {
                collectPowerUp(node)
                return
            }
        }
        
        // Debug: List all touched nodes
        print("Touched nodes count: \(touchedNodes.count)")
        for node in touchedNodes {
            print("- Node: \(node.name ?? "unnamed") at \(node.position)")
        }
        
        // Check UI layer touches for Start Wave button
        let uiLocation = touch.location(in: uiLayer)
        let uiNodes = uiLayer.nodes(at: uiLocation)
        
        for node in uiNodes {
            if node.name == "startWaveButton" || 
               node.parent?.name == "startWaveButton" ||
               node.name == "startWaveButtonBg" ||
               node.name == "startWaveButtonLabel" {
                // Check if button is disabled
                let button = uiLayer.childNode(withName: "startWaveButton")
                if button?.userData?["disabled"] as? Bool != true {
                    startWave()
                }
                return
            }
            
            // Handle next map button (circular style)
            if node.name == "nextMapButton" || 
               node.parent?.name == "nextMapButton" ||
               node.name == "nextMapButtonBg" {
                advanceToNextMap()
                return
            }
            
            // Handle next wave button (circular style)
            if node.name == "nextWaveButton" || 
               node.parent?.name == "nextWaveButton" ||
               node.name == "nextWaveButtonBg" {
                print("Next Wave button tapped! isWaveActive: \(isWaveActive)")
                if !isWaveActive {
                    print("Starting new wave...")
                    startWave()
                } else {
                    print("Wave already active, button ignored")
                }
                return
            }
            
            // Handle speed button (circular style)
            if node.name == "speedButton" || 
               node.parent?.name == "speedButton" ||
               node.name == "speedButtonBg" ||
               node.name == "speedIconLabel" {
                toggleGameSpeed()
                return
            }
            
            // Handle abort button
            if node.name == "abortButton" || node.parent?.name == "abortButton" || 
               node.name == "abortBg" || node.name == "xIcon" {
                showAbortConfirmation()
                return
            }
            
            // Handle screen clear button
            if node.name == "screenClearButton" || node.parent?.name == "screenClearButton" {
                activateScreenClear()
                return
            }
            
            // Handle abort confirmation
            if node.name == "abortYes" {
                // Abort the game and return to map selection
                if let overlay = uiLayer.childNode(withName: "abortOverlay") {
                    overlay.removeFromParent()
                }
                returnToMapSelection()
                return
            } else if node.name == "abortNo" {
                // Continue playing
                if let overlay = uiLayer.childNode(withName: "abortOverlay") {
                    overlay.removeFromParent()
                }
                // Resume the game
                gameplayLayer.isPaused = false
                enemyLayer.isPaused = false
                towerLayer.isPaused = false
                projectileLayer.isPaused = false
                backgroundLayer.isPaused = false
                return
            }
            
            // Handle fast forward button
            
            // Handle secret level skip button (tap 3 times)
            if node.name == "secretLevelSkip" {
                let tapCount = (node.userData?["tapCount"] as? Int ?? 0) + 1
                node.userData?["tapCount"] = tapCount
                
                if tapCount >= 3 {
                    // Skip to next level
                    skipToNextLevel()
                    node.userData?["tapCount"] = 0  // Reset counter
                    
                    // Brief visual feedback
                    let flash = SKShapeNode(rectOf: CGSize(width: 60, height: 40))
                    flash.position = .zero
                    flash.fillColor = .green
                    flash.alpha = 0.3
                    node.addChild(flash)
                    flash.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))
                }
                
                // Reset counter after 2 seconds if not completed
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if node.userData?["tapCount"] as? Int ?? 0 < 3 {
                        node.userData?["tapCount"] = 0
                    }
                }
                return
            }
        }
        
        for node in touchedNodes {
            // Check for tower menu interactions first
            if let nodeName = node.name {
                // Check if closing tower selector
                if nodeName == "closeTowerSelector" || node.parent?.name == "closeTowerSelector" {
                    removeTowerSelector()
                    selectedBuildNode = nil
                    return
                }
                
                // Check enhanced tower selector buttons
                if nodeName.starts(with: "towerButton_") {
                    // Check if it's from the enhanced selector
                    if let container = node.parent,
                       (container.name == "towerSelectorContainer" || container.parent?.name == "towerSelectorContainer") {
                        // Enhanced selector button
                        let towerType = nodeName.replacingOccurrences(of: "towerButton_", with: "")
                        
                        // Get cost for this tower type
                        let costs: [String: Int] = [
                            "machinegun": 75,
                            "kinetic": 80,    // Cannon - basic tower
                            "laser": 120,     // Laser - mid-tier
                            "freeze": 200,    // Freeze - slowing support
                            "plasma": 150,    // Plasma - buffed damage
                            "missile": 250,   // Missile - reduced price
                            "tesla": 350      // Tesla/EMP - reduced price
                        ]
                        let cost = costs[towerType] ?? 100
                        
                        // Check if player has enough salvage
                        if playerSalvage >= cost {
                            // Place the tower at the selected build node
                            if selectedBuildNode != nil {
                                placeTower(type: towerType, cost: cost)
                                removeTowerSelector()
                                selectedBuildNode = nil
                            }
                        } else {
                            showMessage("Need \(cost) salvage!", at: CGPoint(x: 0, y: 0), color: .red)
                        }
                        return
                    } else {
                        // Old menu button
                        if let userData = node.userData,
                           let cost = userData["cost"] as? Int,
                           let type = userData["type"] as? String {
                            placeTower(type: type, cost: cost)
                        }
                    }
                    return
                } else if nodeName == "closeMenu" {
                    closeTowerMenu()
                    return
                } else if nodeName == "upgradeButton" || node.parent?.name == "upgradeButton" || node.parent?.parent?.name == "upgradeButton" {
                    // Handle upgrade button - check multiple levels of hierarchy and find userData
                    var userData: NSMutableDictionary? = node.userData
                    if userData == nil || userData?["tower"] == nil {
                        userData = node.parent?.userData
                    }
                    if userData == nil || userData?["tower"] == nil {
                        userData = node.parent?.parent?.userData
                    }
                    // Also check siblings for the shape node with userData
                    if userData == nil || userData?["tower"] == nil {
                        if let parent = node.parent {
                            for child in parent.children {
                                if child.name == "upgradeButton" && child.userData?["tower"] != nil {
                                    userData = child.userData
                                    break
                                }
                            }
                        }
                    }
                    
                    if let tower = userData?["tower"] as? SKNode,
                       let cost = userData?["cost"] as? Int {
                        upgradeTower(tower, cost: cost)
                    }
                    return
                } else if nodeName == "sellButton" || node.parent?.name == "sellButton" || node.parent?.parent?.name == "sellButton" {
                    // Handle sell button - check multiple levels of hierarchy and find userData
                    var userData: NSMutableDictionary? = node.userData
                    if userData == nil || userData?["tower"] == nil {
                        userData = node.parent?.userData
                    }
                    if userData == nil || userData?["tower"] == nil {
                        userData = node.parent?.parent?.userData
                    }
                    // Also check siblings for the shape node with userData
                    if userData == nil || userData?["tower"] == nil {
                        if let parent = node.parent {
                            for child in parent.children {
                                if child.name == "sellButton" && child.userData?["tower"] != nil {
                                    userData = child.userData
                                    break
                                }
                            }
                        }
                    }
                    
                    if let tower = userData?["tower"] as? SKNode,
                       let value = userData?["value"] as? Int {
                        sellTower(tower, value: value)
                    }
                    return
                } else if nodeName == "closeUpgradeMenu" || node.parent?.name == "closeUpgradeMenu" {
                    // Close upgrade menu
                    towerSelectionMenu?.removeFromParent()
                    towerSelectionMenu = nil
                    // Remove range indicators
                    effectsLayer.enumerateChildNodes(withName: "rangeIndicator") { node, _ in
                        node.removeFromParent()
                    }
                    return
                }
            }
            
            // Check for game objects - check both the node and its parent
            if node.name == "buildNode" || node.parent?.name == "buildNode" || 
               node.name == "buildNodeDamage" || node.parent?.name == "buildNodeDamage" {
                // Find the actual build node (might be parent)
                var buildNode = node
                if node.parent?.name == "buildNode" || node.parent?.name == "buildNodeDamage" {
                    buildNode = node.parent!
                }
                
                print("Build node clicked at \(buildNode.position)")
                
                // Check if there's ALREADY a tower selection menu open
                if towerSelectionMenu != nil {
                    // Close existing menu first
                    towerSelectionMenu?.removeFromParent()
                    towerSelectionMenu = nil
                }
                
                // Always check if there's a tower at this position first (in towerLayer)
                var towerFound: SKNode? = nil
                towerLayer.enumerateChildNodes(withName: "tower_*") { towerNode, _ in
                    if towerFound == nil && abs(towerNode.position.x - buildNode.position.x) < 30 &&
                       abs(towerNode.position.y - buildNode.position.y) < 30 {
                        // Tower found at this position
                        towerFound = towerNode
                        print("Found tower at build node position: \(towerNode.name ?? "unknown")")
                    }
                }
                
                if let tower = towerFound {
                    // Tower exists here - select it for upgrade/sell
                    selectTower(tower)
                } else {
                    // No tower here - check if occupied flag is set
                    let isOccupied = buildNode.userData?["isOccupied"] as? Bool ?? false
                    
                    if isOccupied {
                        // Flag says occupied but no tower found - try a more thorough search
                        print("Warning: Build node marked as occupied but no tower found, doing thorough search")
                        
                        // Do a more extensive search for any tower at this position
                        var thoroughTowerFound: SKNode? = nil
                        for child in towerLayer.children {
                            if child.name?.contains("tower_") == true {
                                let distance = hypot(child.position.x - buildNode.position.x, 
                                                   child.position.y - buildNode.position.y)
                                if distance < 40 {
                                    thoroughTowerFound = child
                                    break
                                }
                            }
                        }
                        
                        if let tower = thoroughTowerFound {
                            // Found tower with thorough search
                            selectTower(tower)
                        } else {
                            // Really no tower - clear flag and show build menu
                            buildNode.userData?["isOccupied"] = false
                            selectedNode = buildNode
                            selectedBuildNode = buildNode
                            handleTowerSelection(at: buildNode.position)
                        }
                    } else {
                        // Truly empty - show tower placement menu
                        selectedNode = buildNode
                        selectedBuildNode = buildNode
                        handleTowerSelection(at: buildNode.position)
                    }
                }
                return
            } else if node.name?.contains("tower_") == true {
                // Select tower for upgrade/sell
                // Only select if no menu is currently open or it's a different tower
                if towerSelectionMenu == nil {
                    selectTower(node)
                } else {
                    // Check if it's the same tower that's already selected
                    let selectedTower = (towerSelectionMenu?.childNode(withName: "upgradeButton")?.userData?["tower"] as? SKNode) ??
                                      (towerSelectionMenu?.childNode(withName: "sellButton")?.userData?["tower"] as? SKNode)
                    if selectedTower !== node {
                        // Different tower, switch selection
                        towerSelectionMenu?.removeFromParent()
                        towerSelectionMenu = nil
                        selectTower(node)
                    }
                    // If same tower, do nothing (keep menu open)
                }
                return
            } else if node.parent?.name?.contains("tower_") == true {
                // Clicked on a child of a tower (like turret)
                let tower = node.parent!
                if towerSelectionMenu == nil {
                    selectTower(tower)
                } else {
                    // Check if it's the same tower
                    let selectedTower = (towerSelectionMenu?.childNode(withName: "upgradeButton")?.userData?["tower"] as? SKNode) ??
                                      (towerSelectionMenu?.childNode(withName: "sellButton")?.userData?["tower"] as? SKNode)
                    if selectedTower !== tower {
                        towerSelectionMenu?.removeFromParent()
                        towerSelectionMenu = nil
                        selectTower(tower)
                    }
                }
                return
            }
        }
        
        // Already handled at the beginning of touchesBegan - removed duplicate
        
        // If clicking outside menu, close it
        if towerSelectionMenu != nil {
            var clickedOnMenu = false
            for node in touchedNodes {
                if node == towerSelectionMenu || node.parent == towerSelectionMenu {
                    clickedOnMenu = true
                    break
                }
            }
            if !clickedOnMenu {
                closeTowerMenu()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Disabled to prevent screen jumping
        return
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchLocation = nil
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Disabled
        return
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // Disabled
        return
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // Disabled
        return
    }
    
    // MARK: - Tower Management
    
    private func handleTowerSelection(at position: CGPoint) {
        // Create the enhanced tower selector at the build node position
        createEnhancedTowerSelector(at: position)
    }
    
    private func showTowerMenu(at position: CGPoint) {
        // Remove any existing menu
        towerSelectionMenu?.removeFromParent()
        
        print("Showing tower menu at position: \(position)")
        
        // Store the actual build node (not just position)
        selectedBuildNode = selectedNode  // Use the node we already found
        
        // Create tower selection menu
        let menu = SKNode()
        menu.name = "towerMenu"
        menu.zPosition = 600
        
        // Create semi-transparent background
        let background = SKShapeNode(rectOf: CGSize(width: 320, height: 200))
        background.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        background.strokeColor = SKColor.cyan
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        menu.addChild(background)
        
        // Add title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "Select Tower"
        title.fontSize = 20
        title.fontColor = .cyan
        title.position = CGPoint(x: 0, y: 70)
        menu.addChild(title)
        
        // Tower types with costs and unlock map requirements
        let allTowers = [
            // Always available (3 basic towers)
            ("MachineGun", 75, SKColor.orange, 1),     // Map 1
            ("Laser", 120, SKColor.cyan, 1),           // Map 1
            ("Kinetic", 80, SKColor.gray, 1),          // Map 1
            
            // Unlock by map progression
            ("Plasma", 150, SKColor.purple, 2),        // Map 2
            ("Missile", 250, SKColor.orange, 3),       // Map 3
            ("Tesla", 350, SKColor.yellow, 4),         // Map 4
            ("Freeze", 200, SKColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0), 5) // Map 5
        ]
        
        // Filter towers based on current map
        let unlockedTowers = allTowers.filter { $0.3 <= currentMap }
        
        // Create tower buttons only for unlocked towers
        var xOffset: CGFloat = -CGFloat(unlockedTowers.count * 40 - 40) // Center the buttons
        for (towerName, cost, color, _) in unlockedTowers {
            let button = createTowerButton(name: towerName, cost: cost, color: color)
            button.position = CGPoint(x: xOffset, y: 0)
            menu.addChild(button)
            xOffset += 80
        }
        
        // Show locked towers as grayed out hints
        let lockedTowers = allTowers.filter { $0.3 > currentMap }
        if !lockedTowers.isEmpty {
            let lockedLabel = SKLabelNode(fontNamed: "Helvetica")
            lockedLabel.text = "More towers unlock at map \(lockedTowers[0].3)"
            lockedLabel.fontSize = 12
            lockedLabel.fontColor = SKColor.gray
            lockedLabel.position = CGPoint(x: 0, y: -100)
            menu.addChild(lockedLabel)
        }
        
        // Add close button with properly centered X
        let closeButton = SKShapeNode(circleOfRadius: 18)  // Bigger for easier tapping
        closeButton.fillColor = SKColor.red.withAlphaComponent(0.9)
        closeButton.strokeColor = SKColor.white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: 140, y: 50)
        closeButton.name = "closeMenu"
        closeButton.zPosition = 1000  // Ensure it's always on top
        menu.addChild(closeButton)
        
        let xLabel = SKLabelNode(text: "×")
        xLabel.fontSize = 22
        xLabel.fontColor = .white
        xLabel.position = CGPoint(x: 0, y: 0) // Already centered properly
        xLabel.verticalAlignmentMode = .center
        xLabel.horizontalAlignmentMode = .center
        closeButton.addChild(xLabel)
        
        // Position menu above the build node but ensure it's visible
        var menuPosition = CGPoint(x: position.x, y: position.y + 150)
        
        // Clamp menu position to screen bounds
        let halfWidth: CGFloat = 160
        let halfHeight: CGFloat = 100
        menuPosition.x = max(-size.width/2 + halfWidth, min(size.width/2 - halfWidth, menuPosition.x))
        menuPosition.y = max(-size.height/2 + halfHeight, min(size.height/2 - halfHeight, menuPosition.y))
        
        menu.position = menuPosition
        
        // Add to gameplay layer so it moves with the camera
        gameplayLayer.addChild(menu)
        towerSelectionMenu = menu
        
        print("Tower menu created at: \(menuPosition)")
        
        // Animate menu appearance
        menu.alpha = 0
        menu.setScale(0.8)
        menu.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
    }
    
    private func createTowerButton(name: String, cost: Int, color: SKColor) -> SKNode {
        let button = SKNode()
        button.name = "towerButton_\(name.lowercased())"
        
        // Tower icon background
        let iconBg = SKShapeNode(circleOfRadius: 20)  // Smaller icon
        iconBg.fillColor = color.withAlphaComponent(0.3)
        iconBg.strokeColor = color
        iconBg.lineWidth = 2
        button.addChild(iconBg)
        
        // Tower icon (simplified representation)
        let icon = SKShapeNode(rectOf: CGSize(width: 14, height: 14))  // Smaller icon
        icon.fillColor = color
        icon.strokeColor = .white
        icon.lineWidth = 1
        icon.position = CGPoint(x: 0, y: 5)
        button.addChild(icon)
        
        // Tower name
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = name
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -50)
        button.addChild(nameLabel)
        
        // Cost label
        let costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        costLabel.text = "\(cost)"
        costLabel.fontSize = 16
        costLabel.fontColor = playerSalvage >= cost ? SKColor.green : SKColor.red
        costLabel.position = CGPoint(x: 0, y: -70)
        button.addChild(costLabel)
        
        // Store cost as userData
        button.userData = ["cost": cost, "type": name.lowercased()]
        
        return button
    }
    
    private func placeTower(type: String, cost: Int) {
        guard let buildNode = selectedBuildNode else { 
            print("No build node selected")
            return 
        }
        
        // Use the build node's position directly
        let towerPosition = buildNode.position
        print("Placing tower at build node position: \(towerPosition)")
        
        // Apply achievement build cost discount
        let bonuses = getActiveAchievementBonuses()
        let discountMultiplier = bonuses["buildDiscount"] ?? 1.0
        let finalCost = Int(Float(cost) * discountMultiplier)
        
        // Check if player has enough salvage
        if playerSalvage < finalCost {
            // Show insufficient funds message
            showMessage("Insufficient Salvage!", at: towerPosition, color: .red)
            // SoundManager.shared.playSound(.insufficientFunds)
            return
        }
        
        // Create and place the tower at the exact build node position
        let tower = createTowerSprite(type: type, at: towerPosition)
        tower.position = towerPosition  // Ensure position is set
        
        // Store tower data for upgrades
        if tower.userData == nil {
            tower.userData = NSMutableDictionary()
        }
        tower.userData?["type"] = type
        tower.userData?["level"] = 1
        tower.userData?["baseCost"] = cost
        tower.userData?["totalCost"] = cost  // Track total investment for refunds
        
        // Mark build node as occupied
        buildNode.userData?["isOccupied"] = true
        
        // Transfer damage bonus from build node to tower
        if let buildNodeData = buildNode.userData, let damageBonus = buildNodeData["damageBonus"] as? Float {
            tower.userData?["tileDamageBonus"] = damageBonus
            if damageBonus > 1.0 {
                print("Tower placed on special damage tile with +25% bonus!")
                // Show visual feedback for special tile placement
                showMessage("+25% Damage!", at: tower.position, color: .yellow)
            }
        }
        
        towerLayer.addChild(tower)
        
        // Don't remove the build node - just hide it and keep it for tracking
        buildNode.alpha = 0.0  // Make invisible but keep for position tracking
        
        // Deduct salvage (use final discounted cost)
        playerSalvage -= finalCost
        updateSalvageDisplay()
        
        // Track achievement progress
        updateAchievementProgress(.towersBuilt)
        
        // Show discount feedback if applicable
        if discountMultiplier < 1.0 {
            let discount = cost - finalCost
            showMessage("Discount: -\(discount)💰", at: CGPoint(x: towerPosition.x, y: towerPosition.y + 40), color: .green)
        }
        
        // Play tower placement sound
        // SoundManager.shared.playSound(.towerPlace)
        // SoundManager.shared.playHaptic(.medium)
        
        // Close the menu
        closeTowerMenu()
        
        // Show placement effect
        showPlacementEffect(at: buildNode.position)
        
        print("Placed \(type) tower at \(buildNode.position) for \(cost) salvage")
    }
    
    private func closeTowerMenu() {
        guard let menu = towerSelectionMenu else { return }
        
        menu.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.scale(to: 0.8, duration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))
        
        towerSelectionMenu = nil
        selectedBuildNode = nil
    }
    
    private func showMessage(_ text: String, at position: CGPoint, color: SKColor) {
        // Remove any existing messages at similar positions to prevent overlap
        uiLayer.enumerateChildNodes(withName: "messageContainer") { node, _ in
            let distance = hypot(node.position.x - position.x, node.position.y - position.y)
            if distance < 100 {  // If messages are too close, remove the old one
                node.removeAllActions()
                node.removeFromParent()
            }
        }
        
        // Create container for message with background
        let container = SKNode()
        container.name = "messageContainer"
        container.position = position
        container.zPosition = 900  // Higher z-position for better visibility
        
        // Check if this is a critical message (insufficient funds, etc)
        let isCritical = text.contains("salvage") || text.contains("Salvage") || 
                        text.contains("Need") || text.contains("Insufficient")
        
        if isCritical {
            // Create background panel for critical messages
            let background = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 8)
            background.fillColor = SKColor.black.withAlphaComponent(0.8)
            background.strokeColor = color
            background.lineWidth = 2
            background.glowWidth = 3
            container.addChild(background)
        }
        
        // Create the message label
        let message = SKLabelNode(fontNamed: "Helvetica-Bold")
        message.text = text
        message.fontSize = isCritical ? 22 : 18  // Larger font for critical messages
        message.fontColor = color
        message.verticalAlignmentMode = .center
        message.horizontalAlignmentMode = .center
        
        // Add glow effect for critical messages
        if isCritical {
            let glow = SKLabelNode(fontNamed: "Helvetica-Bold")
            glow.text = text
            glow.fontSize = 22
            glow.fontColor = color
            glow.alpha = 0.5
            glow.blendMode = .add
            glow.verticalAlignmentMode = .center
            glow.horizontalAlignmentMode = .center
            container.addChild(glow)
        }
        
        container.addChild(message)
        
        // Add to UI layer for critical messages, gameplay layer for others
        if isCritical {
            uiLayer.addChild(container)
        } else {
            gameplayLayer.addChild(container)
        }
        
        // Animate the message
        let duration = isCritical ? 2.5 : 1.5  // Longer duration for critical messages
        
        // Add shake animation for critical messages
        if isCritical {
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 5, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.1),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            container.run(shake)
        }
        
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 50, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func showPlacementEffect(at position: CGPoint) {
        let effect = SKShapeNode(circleOfRadius: 20)  // Smaller effect
        effect.strokeColor = SKColor.cyan
        effect.lineWidth = 3
        effect.fillColor = .clear
        effect.position = position
        effect.zPosition = 250
        
        effectsLayer.addChild(effect)
        
        effect.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func updateSalvageDisplay() {
        // Update salvage using the main HUD update
        updateHUD()
    }
    
    private func showEnhancedMessage(_ text: String, at position: CGPoint, color: SKColor, icon: String) {
        let messageContainer = SKNode()
        messageContainer.position = position
        messageContainer.zPosition = 700
        
        // Background panel
        if let panelTexture = assetManager.getTexture(named: "ui_button_normal") {
            let background = SKSpriteNode(texture: panelTexture)
            background.size = CGSize(width: 250, height: 50)
            background.alpha = 0.9
            messageContainer.addChild(background)
        }
        
        // Icon
        let iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = 24
        iconLabel.position = CGPoint(x: -80, y: -8)
        messageContainer.addChild(iconLabel)
        
        // Message text
        let message = SKLabelNode(fontNamed: "Helvetica-Bold")
        message.text = text
        message.fontSize = 16
        message.fontColor = color
        message.position = CGPoint(x: 0, y: -8)
        message.horizontalAlignmentMode = .center
        messageContainer.addChild(message)
        
        gameplayLayer.addChild(messageContainer)
        
        // Animated appearance and disappearance
        messageContainer.alpha = 0
        messageContainer.setScale(0.5)
        
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.8, duration: 0.3),
            SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        ])
        
        messageContainer.run(SKAction.sequence([
            appear,
            SKAction.wait(forDuration: 2.0),
            disappear,
            SKAction.removeFromParent()
        ]))
    }
    
    private func showAdvancedPlacementEffect(at position: CGPoint, towerType: String) {
        // Create multiple layered effects
        
        // 1. Energy pulse
        if let pulseTexture = assetManager.getTexture(named: "effect_energy_pulse") {
            let pulse = SKSpriteNode(texture: pulseTexture)
            pulse.position = position
            pulse.zPosition = 250
            pulse.blendMode = .add
            pulse.alpha = 0.8
            effectsLayer.addChild(pulse)
            
            pulse.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 3.0, duration: 1.0),
                    SKAction.fadeOut(withDuration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // 2. Construction particles
        let constructionEffect = particleManager.createTowerBuildEffect(at: position)
        effectsLayer.addChild(constructionEffect)
        
        constructionEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
        
        // 3. Holographic materialization rings
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 20)  // Smaller ring
            ring.strokeColor = getTowerColor(type: towerType)
            ring.lineWidth = 2
            ring.fillColor = .clear
            ring.position = position
            ring.zPosition = 240
            ring.alpha = 0.8
            effectsLayer.addChild(ring)
            
            let delay = Double(i) * 0.2
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 2.0, duration: 0.8),
                    SKAction.fadeOut(withDuration: 0.8)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // 4. Screen flash effect
        let flashOverlay = SKSpriteNode(color: getTowerColor(type: towerType), size: size)
        flashOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        flashOverlay.alpha = 0.0
        flashOverlay.zPosition = 1000
        flashOverlay.blendMode = .add
        addChild(flashOverlay)
        
        flashOverlay.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createAdvancedTowerSprite(type: String, at position: CGPoint) -> SKNode {
        let tower = SKNode()
        tower.position = position
        tower.name = "tower_\(type)"
        
        // Create tower base using asset manager
        if let baseTexture = assetManager.getTexture(named: "tower_base") {
            let base = SKSpriteNode(texture: baseTexture)
            base.size = CGSize(width: 64, height: 64)
            base.zPosition = 0
            tower.addChild(base)
        }
        
        // Create turret using type-specific texture
        if let turretTexture = assetManager.getTexture(named: "tower_\(type)_turret") {
            let turret = SKSpriteNode(texture: turretTexture)
            turret.size = CGSize(width: 48, height: 48)
            turret.zPosition = 1
            turret.name = "turret"
            tower.addChild(turret)
            
            // Add type-specific effects and animations
            setupTowerTypeEffects(tower: tower, turret: turret, type: type)
        }
        
        // Add range indicator (initially hidden)
        let rangeRadius = getTowerRange(type: type)
        let range = SKShapeNode(circleOfRadius: rangeRadius)
        range.strokeColor = getTowerColor(type: type).withAlphaComponent(0.3)
        range.fillColor = .clear
        range.lineWidth = 2
        range.name = "range"
        range.alpha = 0  // Hidden by default
        range.zPosition = -1
        tower.addChild(range)
        
        // Add construction effect
        let buildEffect = particleManager.createTowerBuildEffect(at: CGPoint.zero)
        tower.addChild(buildEffect)
        buildEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
        
        return tower
    }
    
    private func setupTowerTypeEffects(tower: SKNode, turret: SKSpriteNode, type: String) {
        switch type {
        case "laser":
            // Add rotating crystal effect
            if let crystalTexture = assetManager.getTexture(named: "tower_laser_crystal") {
                let crystal = SKSpriteNode(texture: crystalTexture)
                crystal.size = CGSize(width: 16, height: 16)
                crystal.blendMode = .add
                crystal.zPosition = 2
                turret.addChild(crystal)
                
                // Rotate crystal
                let rotation = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
                crystal.run(SKAction.repeatForever(rotation))
                
                // Pulsing glow
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: 1.0),
                    SKAction.fadeAlpha(to: 1.0, duration: 1.0)
                ])
                crystal.run(SKAction.repeatForever(pulse))
            }
            
        case "plasma":
            // Add floating plasma orb
            if let orbTexture = assetManager.getTexture(named: "tower_plasma_orb") {
                let orb = SKSpriteNode(texture: orbTexture)
                orb.size = CGSize(width: 20, height: 20)
                orb.blendMode = .add
                orb.zPosition = 2
                turret.addChild(orb)
                
                // Floating animation
                let float = SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 3, duration: 2.0),
                    SKAction.moveBy(x: 0, y: -3, duration: 2.0)
                ])
                orb.run(SKAction.repeatForever(float))
                
                // Energy swirl effect
                let swirl = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
                orb.run(SKAction.repeatForever(swirl))
            }
            
        case "missile":
            // Add missile pods
            let podPositions = [CGPoint(x: -12, y: 0), CGPoint(x: 12, y: 0)]
            for position in podPositions {
                if let podTexture = assetManager.getTexture(named: "tower_missile_pod") {
                    let pod = SKSpriteNode(texture: podTexture)
                    pod.size = CGSize(width: 12, height: 20)
                    pod.position = position
                    pod.zPosition = 2
                    turret.addChild(pod)
                }
            }
            
        case "tesla":
            // Add tesla coil with electric effects
            if let coilTexture = assetManager.getTexture(named: "tower_tesla_coil") {
                let coil = SKSpriteNode(texture: coilTexture)
                coil.size = CGSize(width: 24, height: 24)
                coil.blendMode = .add
                coil.zPosition = 2
                turret.addChild(coil)
                
                // Electric discharge effect
                let discharge = particleManager.createTeslaDischarge(from: CGPoint.zero, to: CGPoint(x: 30, y: 0))
                discharge.particleBirthRate = 3
                discharge.numParticlesToEmit = 0  // Continuous
                turret.addChild(discharge)
            }
            
        default:
            break
        }
        
        // Common turret rotation animation
        let rotation = SKAction.rotate(byAngle: .pi * 2, duration: 15.0)
        turret.run(SKAction.repeatForever(rotation))
    }
    
    private func getTowerRange(type: String) -> CGFloat {
        switch type {
        case "machinegun": return 100  // Short range
        case "laser": return 150
        case "plasma": return 120
        case "missile": return 200
        case "tesla": return 100
        default: return 120
        }
    }
    
    private func getTowerColor(type: String) -> SKColor {
        switch type {
        case "machinegun": return SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)  // Orange
        case "laser": return AssetManager.Colors.neonCyan
        case "plasma": return AssetManager.Colors.neonPurple
        case "missile": return AssetManager.Colors.neonOrange
        case "tesla": return AssetManager.Colors.neonYellow
        default: return SKColor.white
        }
    }
    
    private func getDamageMultiplier(type: String) -> Int {
        switch type {
        case "machinegun": return 1  // Low damage but very fast fire rate
        case "kinetic": return 1  // Reduced by 30% (was implicitly 1, now explicitly lower damage per level)
        case "laser": return 1
        case "plasma": return 2
        case "missile": return 3
        case "tesla": return 2
        default: return 1
        }
    }
    
    private func createUpgradeTowerVisual(type: String, level: Int) -> SKNode {
        let tower = SKNode()
        
        // Base size increases with level
        let baseSize = CGFloat(20 + level * 5)
        let base = SKShapeNode(circleOfRadius: baseSize)
        base.strokeColor = getTowerColor(type: type)
        base.lineWidth = CGFloat(level)
        base.fillColor = SKColor.black.withAlphaComponent(0.5)
        base.glowWidth = CGFloat(level * 2)
        tower.addChild(base)
        
        // Tower-specific visuals that evolve with level
        switch type {
        case "laser":
            // Multiple barrels at higher levels
            for i in 0..<level {
                let angle = CGFloat(i) * (2 * .pi / CGFloat(level))
                let barrel = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 15 + level * 3))
                barrel.strokeColor = AssetManager.Colors.neonCyan
                barrel.lineWidth = 1
                barrel.fillColor = .clear
                barrel.position = CGPoint(x: cos(angle) * 8, y: sin(angle) * 8)
                barrel.zRotation = angle
                tower.addChild(barrel)
            }
            
        case "plasma":
            // Larger plasma orb with more energy rings
            let orb = SKShapeNode(circleOfRadius: CGFloat(8 + level * 3))
            orb.strokeColor = AssetManager.Colors.neonPurple
            orb.lineWidth = CGFloat(level)
            orb.fillColor = AssetManager.Colors.neonPurple.withAlphaComponent(0.2)
            orb.glowWidth = CGFloat(level * 3)
            tower.addChild(orb)
            
            // Energy rings
            for i in 1...level {
                let ring = SKShapeNode(circleOfRadius: CGFloat(12 + i * 4))
                ring.strokeColor = AssetManager.Colors.neonPurple.withAlphaComponent(0.5)
                ring.lineWidth = 0.5
                tower.addChild(ring)
            }
            
        case "missile":
            // More missile pods at higher levels
            let podCount = 2 + level
            for i in 0..<podCount {
                let angle = CGFloat(i) * (2 * .pi / CGFloat(podCount))
                let pod = SKShapeNode(rect: CGRect(x: -3, y: 0, width: 6, height: 12 + level * 2))
                pod.strokeColor = AssetManager.Colors.neonOrange
                pod.lineWidth = 1
                pod.fillColor = .clear
                pod.position = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12)
                pod.zRotation = angle
                tower.addChild(pod)
            }
            
        default:
            // Generic tower that scales with level
            let turret = SKShapeNode(rectOf: CGSize(width: 15 * level, height: 15 * level))
            turret.strokeColor = .white
            turret.lineWidth = CGFloat(level)
            turret.fillColor = .clear
            tower.addChild(turret)
        }
        
        // Level indicator dots
        for i in 0..<level {
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = .yellow
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat(-8 + i * 8), y: -baseSize - 8)
            tower.addChild(dot)
        }
        
        return tower
    }
    
    private func createStarShape(radius: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        let angleStep = CGFloat.pi * 2 / 10  // 10 points (5 outer, 5 inner)
        
        for i in 0..<10 {
            let angle = angleStep * CGFloat(i) - CGFloat.pi / 2
            let r = i % 2 == 0 ? radius : radius * 0.5  // Alternate between outer and inner radius
            let x = cos(angle) * r
            let y = sin(angle) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return SKShapeNode(path: path)
    }
    
    private func createEvolutionArrow() -> SKNode {
        let arrow = SKNode()
        
        // Arrow shaft
        let shaft = SKShapeNode(rect: CGRect(x: 0, y: -1, width: 20, height: 2))
        shaft.strokeColor = .white
        shaft.fillColor = .white
        shaft.alpha = 0.6
        arrow.addChild(shaft)
        
        // Arrow head
        let headPath = CGMutablePath()
        headPath.move(to: CGPoint(x: 20, y: -4))
        headPath.addLine(to: CGPoint(x: 28, y: 0))
        headPath.addLine(to: CGPoint(x: 20, y: 4))
        let head = SKShapeNode(path: headPath)
        head.strokeColor = .white
        head.lineWidth = 2
        arrow.addChild(head)
        
        return arrow
    }
    
    private func createMiniTowerPreview(type: String, level: Int) -> SKNode {
        // Create a smaller version of the tower for preview
        let preview = createUpgradeTowerVisual(type: type, level: level)
        preview.setScale(0.6)
        return preview
    }
    
    private func getSpecialAbility(type: String, level: Int) -> String {
        // Return special ability description based on tower type and level
        switch type {
        case "kinetic":
            switch level {
            case 1: return "Basic Cannon"
            case 2: return "Rapid Fire"
            case 3: return "Triple Shot"
            default: return "Unknown"
            }
        case "laser":
            switch level {
            case 1: return "Single Beam"
            case 2: return "Dual Beams"
            case 3: return "Triple Beams + Burn"
            default: return "Unknown"
            }
        case "plasma":
            switch level {
            case 1: return "Plasma Bolt"
            case 2: return "Charged Plasma"
            case 3: return "Plasma Storm"
            default: return "Unknown"
            }
        case "missile":
            switch level {
            case 1: return "Guided Missile"
            case 2: return "Cluster Missiles"
            case 3: return "MIRV Warhead"
            default: return "Unknown"
            }
        case "tesla":
            switch level {
            case 1: return "Chain Lightning"
            case 2: return "EMP Burst"
            case 3: return "Lightning Storm"
            default: return "Unknown"
            }
        default:
            return "Unknown Ability"
        }
    }
    
    private func createEnhancedMenuButton(text: String, subtext: String, position: CGPoint, color: SKColor, enabled: Bool) -> SKNode {
        let button = SKNode()
        button.position = position
        button.isUserInteractionEnabled = false  // Let parent handle touches
        
        // Button background with glow effect - make larger for easier clicking
        let bg = SKShapeNode(rectOf: CGSize(width: 140, height: 70), cornerRadius: 8)
        bg.fillColor = enabled ? color.withAlphaComponent(0.3) : SKColor.gray.withAlphaComponent(0.2)
        bg.strokeColor = enabled ? color : SKColor.gray
        bg.lineWidth = 2
        if enabled {
            bg.glowWidth = 3
        }
        bg.name = "buttonBg"  // Add name for hit testing
        button.addChild(bg)
        
        // Main text
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 14
        label.fontColor = enabled ? .white : SKColor.gray
        label.position = CGPoint(x: 0, y: 8)
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        // Subtext (cost/value)
        let sublabel = SKLabelNode(fontNamed: "Helvetica")
        sublabel.text = subtext
        sublabel.fontSize = 11
        sublabel.fontColor = enabled ? color : SKColor.gray
        sublabel.position = CGPoint(x: 0, y: -10)
        sublabel.verticalAlignmentMode = .center
        button.addChild(sublabel)
        
        // Add pulse animation if enabled
        if enabled {
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.8, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])
            bg.run(SKAction.repeatForever(pulse))
        }
        
        return button
    }
    
    private func selectTower(_ tower: SKNode) {
        // Validate that tower actually exists and has a parent
        guard tower.parent != nil, 
              tower.name?.contains("tower_") == true else {
            print("WARNING: Attempted to select invalid tower")
            return
        }
        
        // Clear any existing selection first
        towerSelectionMenu?.removeFromParent()
        towerSelectionMenu = nil
        effectsLayer.enumerateChildNodes(withName: "rangeIndicator") { node, _ in
            node.removeFromParent()
        }
        
        // Small delay to ensure clean state
        run(SKAction.wait(forDuration: 0.05)) { [weak self] in
            // Show tower range indicator
            self?.showTowerRangeIndicator(for: tower)
            
            // Show tower upgrade menu
            self?.showTowerUpgradeMenu(for: tower)
        }
    }
    
    private func showTowerRangeIndicator(for tower: SKNode) {
        // Remove any existing range indicators
        effectsLayer.enumerateChildNodes(withName: "rangeIndicator") { node, _ in
            node.removeFromParent()
        }
        
        // Get tower range
        let towerType = tower.userData?["type"] as? String ?? "laser"
        let currentLevel = tower.userData?["level"] as? Int ?? 1
        let baseRange = getTowerRange(type: towerType)
        let range = baseRange + CGFloat((currentLevel - 1) * 20)
        
        // Create range circle
        let rangeCircle = SKShapeNode(circleOfRadius: range)
        rangeCircle.position = tower.position
        rangeCircle.fillColor = SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.1)
        rangeCircle.strokeColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.5)
        rangeCircle.lineWidth = 2
        rangeCircle.glowWidth = 1
        rangeCircle.name = "rangeIndicator"
        rangeCircle.zPosition = 5  // Above path but below UI
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        ])
        rangeCircle.run(SKAction.repeatForever(pulse))
        
        effectsLayer.addChild(rangeCircle)
    }
    
    private func showTowerUpgradeMenu(for tower: SKNode) {
        // Remove any existing menus
        towerSelectionMenu?.removeFromParent()
        
        // Get tower type and level
        let towerType = tower.userData?["type"] as? String ?? "unknown"
        let currentLevel = tower.userData?["level"] as? Int ?? 1
        let baseCost = tower.userData?["baseCost"] as? Int ?? 100
        
        // Create upgrade menu - SIMPLIFIED VERSION
        let menu = SKNode()
        menu.name = "upgradeMenu"
        menu.zPosition = 1000  // Very high to ensure it's on top
        menu.position = CGPoint(x: 0, y: 0)  // Center on screen
        
        // Add FULL SCREEN overlay to completely block all touches
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: size.height * 3))
        overlay.fillColor = SKColor.black.withAlphaComponent(0.7)
        overlay.strokeColor = .clear
        overlay.position = CGPoint.zero
        overlay.zPosition = -1
        overlay.name = "menuOverlay"
        overlay.isUserInteractionEnabled = true  // Block touches to elements behind
        menu.addChild(overlay)
        
        // SIMPLIFIED BACKGROUND - single clean panel with larger size
        let background = SKShapeNode(rectOf: CGSize(width: 320, height: 220), cornerRadius: 15)
        background.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95)
        background.strokeColor = getTowerColor(type: towerType)
        background.lineWidth = 2
        background.position = CGPoint.zero
        menu.addChild(background)
        
        // SIMPLIFIED TITLE - just tower name and level
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "\(towerType.uppercased()) - LVL \(currentLevel)"
        title.fontSize = 18
        title.fontColor = getTowerColor(type: towerType)
        title.position = CGPoint(x: 0, y: 65)
        menu.addChild(title)
        
        // SIMPLIFIED STATS - text only, no fancy buttons
        let damage = Int(10 * currentLevel * getDamageMultiplier(type: towerType))
        let range = Int(getTowerRange(type: towerType) + CGFloat((currentLevel - 1) * 20))
        let fireRate = getTowerFireRate(type: towerType, level: currentLevel)
        let speed = String(format: "%.1f", 1.0 / fireRate)
        
        let statsText = "Damage: \(damage)   Range: \(range)   Speed: \(speed)/s"
        let statsLabel = SKLabelNode(fontNamed: "Helvetica")
        statsLabel.text = statsText
        statsLabel.fontSize = 12
        statsLabel.fontColor = .white
        statsLabel.position = CGPoint(x: 0, y: 30)
        menu.addChild(statsLabel)
        
        // SIMPLIFIED BUTTONS - just upgrade and sell
        let actionsContainer = SKNode()
        actionsContainer.position = CGPoint(x: 0, y: -20)
        menu.addChild(actionsContainer)
        
        if currentLevel < 3 {
            // SIMPLIFIED UPGRADE BUTTON - LARGER HIT AREA
            let upgradeCost = Int(Double(baseCost) * 1.5)
            let canAfford = playerSalvage >= upgradeCost
            
            let upgradeButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 5)
            upgradeButton.position = CGPoint(x: -60, y: 0)
            upgradeButton.fillColor = canAfford ? SKColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 0.95) : SKColor.gray.withAlphaComponent(0.5)
            upgradeButton.strokeColor = canAfford ? .green : .darkGray
            upgradeButton.lineWidth = 2
            upgradeButton.name = "upgradeButton"
            upgradeButton.userData = NSMutableDictionary()
            upgradeButton.userData?["tower"] = tower
            upgradeButton.userData?["cost"] = upgradeCost
            upgradeButton.zPosition = 10  // Ensure button is above other elements
            actionsContainer.addChild(upgradeButton)
            
            let upgradeLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            upgradeLabel.text = "UPGRADE"
            upgradeLabel.fontSize = 16
            upgradeLabel.fontColor = .white  // Pure white for maximum contrast
            upgradeLabel.position = CGPoint(x: -60, y: 8)
            upgradeLabel.name = "upgradeButton"
            upgradeLabel.isUserInteractionEnabled = false  // Let touches pass through to button
            upgradeLabel.userData = NSMutableDictionary()
            upgradeLabel.userData?["tower"] = tower
            upgradeLabel.userData?["cost"] = upgradeCost
            actionsContainer.addChild(upgradeLabel)
            
            let costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            costLabel.text = "$\(upgradeCost)"
            costLabel.fontSize = 14
            costLabel.fontColor = canAfford ? SKColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0) : .gray  // Very light green
            costLabel.position = CGPoint(x: -60, y: -10)
            costLabel.name = "upgradeButton"
            costLabel.isUserInteractionEnabled = false
            costLabel.userData = NSMutableDictionary()
            costLabel.userData?["tower"] = tower
            costLabel.userData?["cost"] = upgradeCost
            actionsContainer.addChild(costLabel)
        } else {
            // MAX LEVEL - simple text
            let maxLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            maxLabel.text = "MAX LEVEL"
            maxLabel.fontSize = 12
            maxLabel.fontColor = .yellow
            maxLabel.position = CGPoint(x: -55, y: 0)
            actionsContainer.addChild(maxLabel)
        }
        
        // SIMPLIFIED SELL BUTTON - LARGER HIT AREA
        let sellValue = getSellValue(for: tower)
        let sellButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 5)
        sellButton.position = CGPoint(x: 60, y: 0)
        sellButton.fillColor = SKColor(red: 0.5, green: 0.15, blue: 0.0, alpha: 0.95)
        sellButton.strokeColor = .orange
        sellButton.lineWidth = 2
        sellButton.name = "sellButton"
        sellButton.userData = NSMutableDictionary()
        sellButton.userData?["tower"] = tower
        sellButton.userData?["value"] = sellValue
        sellButton.zPosition = 10  // Ensure button is above other elements
        actionsContainer.addChild(sellButton)
        
        let sellLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        sellLabel.text = "SELL"
        sellLabel.fontSize = 16
        sellLabel.fontColor = .white  // Pure white for maximum contrast
        sellLabel.position = CGPoint(x: 60, y: 8)
        sellLabel.name = "sellButton"
        sellLabel.isUserInteractionEnabled = false  // Let touches pass through to button
        sellLabel.userData = NSMutableDictionary()
        sellLabel.userData?["tower"] = tower
        sellLabel.userData?["value"] = sellValue
        actionsContainer.addChild(sellLabel)
        
        let valueLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        valueLabel.text = "$\(sellValue)"
        valueLabel.fontSize = 14
        valueLabel.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1.0)  // Very light orange
        valueLabel.position = CGPoint(x: 60, y: -10)
        valueLabel.name = "sellButton"
        valueLabel.isUserInteractionEnabled = false
        valueLabel.userData = NSMutableDictionary()
        valueLabel.userData?["tower"] = tower
        valueLabel.userData?["value"] = sellValue
        actionsContainer.addChild(valueLabel)
        
        // SIMPLIFIED CLOSE BUTTON - X in top-right corner (LARGER)
        let closeButton = SKShapeNode(circleOfRadius: 20)
        closeButton.fillColor = SKColor.red.withAlphaComponent(0.9)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: 140, y: 75)
        closeButton.name = "closeUpgradeMenu"
        closeButton.zPosition = 1001
        menu.addChild(closeButton)
        
        let closeX = SKLabelNode(fontNamed: "Helvetica-Bold")
        closeX.text = "×"
        closeX.fontSize = 24
        closeX.fontColor = .white
        closeX.position = CGPoint(x: 0, y: 0)  // FIX: Center the X properly
        closeX.verticalAlignmentMode = .center
        closeX.horizontalAlignmentMode = .center
        closeX.name = "closeUpgradeMenu"
        closeButton.addChild(closeX)
        
        // Store reference and add to UI
        towerSelectionMenu = menu
        uiLayer.addChild(menu)
        
        // Show range indicator
        if let range = tower.childNode(withName: "range") {
            range.run(SKAction.fadeIn(withDuration: 0.2))
        }
    }
    
    private func createMenuButton(text: String, subtext: String, position: CGPoint, color: SKColor) -> SKNode {
        let button = SKNode()
        button.position = position
        
        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 5)
        bg.fillColor = color.withAlphaComponent(0.3)
        bg.strokeColor = color
        bg.lineWidth = 2
        button.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 14
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 8)
        button.addChild(label)
        
        let sublabel = SKLabelNode(fontNamed: "Helvetica")
        sublabel.text = subtext
        sublabel.fontSize = 11
        sublabel.fontColor = color
        sublabel.position = CGPoint(x: 0, y: -10)
        button.addChild(sublabel)
        
        return button
    }
    
    private func getSellValue(for tower: SKNode) -> Int {
        let level = tower.userData?["level"] as? Int ?? 1
        let baseCost = tower.userData?["baseCost"] as? Int ?? 100
        return (baseCost * level) / 2  // Sell for half the total investment
    }
    
    private func upgradeTower(_ tower: SKNode, cost: Int) {
        // Check if player has enough salvage
        if playerSalvage < cost {
            showMessage("Insufficient Salvage!", at: tower.position, color: .red)
            // SoundManager.shared.playSound(.insufficientFunds)
            return
        }
        
        // Deduct cost
        playerSalvage -= cost
        
        // Update total cost for refund tracking
        let currentTotalCost = tower.userData?["totalCost"] as? Int ?? 0
        tower.userData?["totalCost"] = currentTotalCost + cost
        
        // Upgrade tower level
        let currentLevel = tower.userData?["level"] as? Int ?? 1
        let newLevel = currentLevel + 1
        tower.userData?["level"] = newLevel
        
        // Store tower type and position
        let towerType = tower.name?.replacingOccurrences(of: "tower_", with: "") ?? "laser"
        let towerPosition = tower.position
        
        // Epic upgrade effect
        let upgradeEffect = SKShapeNode(circleOfRadius: 40)
        upgradeEffect.position = towerPosition
        upgradeEffect.strokeColor = .green
        upgradeEffect.lineWidth = 3
        upgradeEffect.fillColor = .clear
        upgradeEffect.glowWidth = 15
        upgradeEffect.zPosition = 500
        effectsLayer.addChild(upgradeEffect)
        
        // Multiple expanding rings for dramatic effect
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 30)
            ring.position = towerPosition
            ring.strokeColor = getTowerColor(type: towerType)
            ring.lineWidth = 2
            ring.fillColor = .clear
            ring.glowWidth = 10
            ring.zPosition = 499
            effectsLayer.addChild(ring)
            
            let delay = Double(i) * 0.1
            let expand = SKAction.scale(to: CGFloat(2 + i), duration: 0.6)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([expand, fade]),
                SKAction.removeFromParent()
            ]))
        }
        
        let expand = SKAction.scale(to: 2.5, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        upgradeEffect.run(SKAction.sequence([SKAction.group([expand, fade]), SKAction.removeFromParent()]))
        
        // Completely rebuild the tower with new level visuals
        tower.removeAllChildren()
        
        // Recreate the tower with the new level
        let newTowerVisuals = createSimpleTowerSprite(type: towerType, at: towerPosition)
        newTowerVisuals.userData = tower.userData  // Preserve user data
        
        // Transfer all children from new tower to existing tower
        for child in newTowerVisuals.children {
            child.removeFromParent()
            tower.addChild(child)
        }
        
        // Add level indicator badges
        for i in 0..<newLevel {
            let star = createStarShape(radius: 3)
            star.fillColor = .yellow
            star.strokeColor = .orange
            star.lineWidth = 1
            star.glowWidth = 2
            star.position = CGPoint(x: -10 + i * 10, y: -25)
            star.zPosition = 10
            tower.addChild(star)
        }
        
        // Update range indicator
        let newRange = getTowerRange(type: towerType) + CGFloat(newLevel - 1) * 20
        
        // Remove old range if exists
        tower.childNode(withName: "range")?.removeFromParent()
        
        let newRangeIndicator = SKShapeNode(circleOfRadius: newRange)
        newRangeIndicator.strokeColor = getTowerColor(type: towerType).withAlphaComponent(0.3)
        newRangeIndicator.fillColor = .clear
        newRangeIndicator.lineWidth = CGFloat(newLevel)
        newRangeIndicator.name = "range"
        newRangeIndicator.alpha = 0
        tower.addChild(newRangeIndicator)
        
        // Close menu and update HUD
        towerSelectionMenu?.removeFromParent()
        towerSelectionMenu = nil
        updateHUD()
        
        showMessage("Tower Upgraded!", at: tower.position, color: .green)
    }
    
    private func sellTower(_ tower: SKNode, value: Int) {
        // Play sell sound
        // SoundManager.shared.playSound(.towerSell)
        
        // Add salvage
        playerSalvage += value
        
        // Find and mark the build node as unoccupied and make it visible again
        gameplayLayer.enumerateChildNodes(withName: "buildNode*") { node, _ in
            if abs(node.position.x - tower.position.x) < 20 &&
               abs(node.position.y - tower.position.y) < 20 {
                node.userData?["isOccupied"] = false
                node.alpha = 1.0  // Make build node visible again
            }
        }
        
        // Sell effect
        let sellEffect = SKShapeNode(circleOfRadius: 30)
        sellEffect.position = tower.position
        sellEffect.fillColor = .orange
        sellEffect.strokeColor = .yellow
        sellEffect.glowWidth = 8
        sellEffect.zPosition = 500
        effectsLayer.addChild(sellEffect)
        
        let shrink = SKAction.scale(to: 0.1, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        sellEffect.run(SKAction.sequence([SKAction.group([shrink, fade]), SKAction.removeFromParent()]))
        
        // Remove tower
        tower.removeFromParent()
        
        // Close menu and update HUD
        towerSelectionMenu?.removeFromParent()
        towerSelectionMenu = nil
        updateHUD()
        
        showMessage("+\(value) Salvage", at: tower.position, color: .yellow)
    }
    
    private func createTowerSprite(type: String, at position: CGPoint) -> SKNode {
        print("Creating tower sprite of type \(type) at \(position)")
        // Skip AssetManager for now and use simple sprites
        /* if let towerTexture = assetManager.getTexture(named: "tower_\(type)_base") {
            let tower = SKSpriteNode(texture: towerTexture)
            tower.position = position
            tower.name = "tower_\(type)"
            tower.size = CGSize(width: 50, height: 50)
            
            // Add turret
            if let turretTexture = assetManager.getTexture(named: "tower_\(type)_turret") {
                let turret = SKSpriteNode(texture: turretTexture)
                turret.name = "turret"
                turret.size = CGSize(width: 40, height: 40)
                turret.zPosition = 1
                tower.addChild(turret)
                
                // Don't add idle rotation - turrets will aim at enemies instead
            }
            
            // Add range indicator (initially hidden)
            let rangeRadius: CGFloat
            switch type {
            case "laser": rangeRadius = 300  // Long range sniper tower
            case "plasma": rangeRadius = 120
            case "missile": rangeRadius = 200
            case "tesla": rangeRadius = 100
            case "kinetic", "cannon": rangeRadius = 180
            default: rangeRadius = 150
            }
            
            let range = SKShapeNode(circleOfRadius: rangeRadius)
            range.strokeColor = SKColor.cyan.withAlphaComponent(0.2) // assetManager.getTowerColor(type: type).withAlphaComponent(0.2)
            range.fillColor = .clear
            range.lineWidth = 1
            range.name = "range"
            range.alpha = 0  // Hidden by default
            tower.addChild(range)
            
            return tower
        } */
        
        // Always use simple shape for now
        return createSimpleTowerSprite(type: type, at: position)
    }
    
    private func createSimpleTowerSprite(type: String, at position: CGPoint) -> SKNode {
        let tower = SKNode()
        // Don't set position here - it's already set in placeTower
        tower.name = "tower_\(type)"
        
        // Store initial level
        if tower.userData == nil {
            tower.userData = NSMutableDictionary()
        }
        let level = tower.userData?["level"] as? Int ?? 1
        
        // Create enhanced base that grows with level
        let baseSize = CGFloat(18 + level * 2)  // Bigger base with each level
        let basePath = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let x = cos(angle) * baseSize
            let y = sin(angle) * baseSize
            if i == 0 {
                basePath.move(to: CGPoint(x: x, y: y))
            } else {
                basePath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        basePath.closeSubpath()
        
        let base = SKShapeNode(path: basePath)
        base.name = "base"
        base.lineWidth = CGFloat(2 + level)  // Thicker lines with level
        base.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        base.fillColor = .clear // Outline only
        base.glowWidth = CGFloat(level)  // Add glow that increases with level
        
        // Set colors and range based on tower type
        var rangeRadius: CGFloat = 150
        
        switch type {
        case "laser":
            // Enhanced laser turret that scales with level
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 150 + CGFloat(level - 1) * 30
            
            // Main rotating mount - bigger with each level
            let mountSize = CGFloat(10 + level * 3)
            let mount = SKShapeNode(circleOfRadius: mountSize)
            mount.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0) // Cyan
            mount.lineWidth = CGFloat(2 + level)
            mount.fillColor = .clear
            mount.glowWidth = CGFloat(3 + level * 2)
            turret.addChild(mount)
            
            // Multiple barrels at higher levels
            let barrelCount = level  // 1 barrel at L1, 2 at L2, 3 at L3
            for i in 0..<barrelCount {
                let barrelContainer = SKNode()
                if barrelCount > 1 {
                    // Spread barrels in a fan pattern
                    let angle = CGFloat(i - barrelCount/2) * 0.2
                    barrelContainer.zRotation = angle
                }
                
                // Laser barrel - longer and thicker with level
                let barrelLength = 22 + level * 6
                let barrelWidth = 4 + level
                let barrel = SKShapeNode(rect: CGRect(x: -barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
                barrel.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0)
                barrel.lineWidth = CGFloat(2 + level)
                barrel.fillColor = .clear
                barrel.glowWidth = CGFloat(4 + level * 2)
                barrelContainer.addChild(barrel)
                
                // Focusing rings at tip - more rings with level
                for j in 0..<(2 + level) {
                    let ring = SKShapeNode(circleOfRadius: CGFloat(3 + j * 2))
                    ring.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: CGFloat(0.8 - Float(j) * 0.15))
                    ring.lineWidth = CGFloat(1 + (level > 2 ? 1 : 0))
                    ring.fillColor = .clear
                    ring.position = CGPoint(x: 0, y: CGFloat(barrelLength - 2))
                    ring.glowWidth = CGFloat(level)
                    barrelContainer.addChild(ring)
                }
                
                // Add energy core at level 3
                if level >= 3 {
                    let core = SKShapeNode(circleOfRadius: 3)
                    core.fillColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 0.8)
                    core.strokeColor = .white
                    core.lineWidth = 1
                    core.glowWidth = 5
                    core.position = CGPoint(x: 0, y: CGFloat(barrelLength))
                    
                    // Pulsing effect for level 3
                    let pulse = SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.3),
                        SKAction.scale(to: 1.0, duration: 0.3)
                    ])
                    core.run(SKAction.repeatForever(pulse))
                    barrelContainer.addChild(core)
                }
                
                turret.addChild(barrelContainer)
            }
            
            // Don't add idle rotation - let aiming system control turret rotation
            
            tower.addChild(turret)
            
        case "plasma":
            // Enhanced plasma gun that evolves with level
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 120 + CGFloat(level - 1) * 25
            
            // Energy chamber - grows with level
            let chamberSize = CGFloat(16 + level * 4)
            let chamber = SKShapeNode(rect: CGRect(x: -chamberSize/2, y: -4, width: chamberSize, height: chamberSize))
            chamber.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0) // Purple
            chamber.lineWidth = CGFloat(2 + level)
            chamber.fillColor = .clear
            chamber.glowWidth = CGFloat(4 + level * 3)
            turret.addChild(chamber)
            
            // Plasma coils inside - more coils with level
            let coilCount = 3 + level
            for i in 0..<coilCount {
                let y = CGFloat(i) * (chamberSize / CGFloat(coilCount))
                let coil = SKShapeNode(ellipseOf: CGSize(width: chamberSize - 4, height: 2))
                coil.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.8)
                coil.lineWidth = CGFloat(level)
                coil.fillColor = .clear
                coil.position = CGPoint(x: 0, y: y - 2)
                coil.glowWidth = CGFloat(level)
                
                // Rotating coils at higher levels
                if level >= 2 {
                    let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0 / Double(level))
                    coil.run(SKAction.repeatForever(rotate))
                }
                turret.addChild(coil)
            }
            
            // Multiple emitters at higher levels
            let emitterCount = level
            for i in 0..<emitterCount {
                let emitterContainer = SKNode()
                let spreadAngle = CGFloat(i - emitterCount/2) * 0.3
                emitterContainer.zRotation = spreadAngle
                
                // Emitter barrel - bigger with level
                let emitterSize = 8 + level * 2
                let emitter = SKShapeNode(rect: CGRect(x: -emitterSize/2, y: Int(chamberSize) - 4, width: emitterSize, height: emitterSize))
                emitter.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0)
                emitter.lineWidth = CGFloat(2 + level)
                emitter.fillColor = .clear
                emitter.glowWidth = CGFloat(6 + level * 2)
                emitterContainer.addChild(emitter)
                
                // Plasma orb at level 3
                if level >= 3 {
                    let orb = SKShapeNode(circleOfRadius: 4)
                    orb.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.9)
                    orb.strokeColor = .white
                    orb.lineWidth = 1
                    orb.glowWidth = 8
                    orb.position = CGPoint(x: 0, y: chamberSize + 4)
                    emitterContainer.addChild(orb)
                }
                
                turret.addChild(emitterContainer)
            }
            
            // More intense energy effect with level
            let pulseSpeed = 0.4 / Double(level)
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: pulseSpeed),
                SKAction.fadeAlpha(to: 1.0, duration: pulseSpeed)
            ])
            turret.run(SKAction.repeatForever(pulse))
            
            tower.addChild(turret)
            
        case "missile":
            // Missile launcher with angled launch tubes
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 200
            
            // Central rotating mount
            let mount = SKShapeNode(circleOfRadius: 8)
            mount.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Gray metal
            mount.lineWidth = 2
            mount.fillColor = .clear
            mount.glowWidth = 1
            turret.addChild(mount)
            
            // Missile pods (angled for launch)
            for (_, angle) in [45, 135, 225, 315].enumerated() {
                let rad = CGFloat(angle) * .pi / 180
                
                // Launch tube
                let tubeContainer = SKNode()
                tubeContainer.position = CGPoint(
                    x: cos(rad) * 12,
                    y: sin(rad) * 12
                )
                tubeContainer.zRotation = rad
                
                // Tube body
                let tube = SKShapeNode(rect: CGRect(x: -3, y: 0, width: 6, height: 16))
                tube.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0) // Orange
                tube.lineWidth = 2
                tube.fillColor = .clear
                tube.glowWidth = 3
                tubeContainer.addChild(tube)
                
                // Missile inside (ready to launch)
                let missileBody = SKShapeNode(rect: CGRect(x: -2, y: 2, width: 4, height: 10))
                missileBody.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
                missileBody.lineWidth = 1.5
                missileBody.fillColor = .clear
                missileBody.glowWidth = 2
                tubeContainer.addChild(missileBody)
                
                // Missile warhead (pointed)
                let warheadPath = CGMutablePath()
                warheadPath.move(to: CGPoint(x: -2, y: 12))
                warheadPath.addLine(to: CGPoint(x: 0, y: 16))
                warheadPath.addLine(to: CGPoint(x: 2, y: 12))
                warheadPath.closeSubpath()
                let warhead = SKShapeNode(path: warheadPath)
                warhead.strokeColor = SKColor.red
                warhead.lineWidth = 1
                warhead.fillColor = .clear
                warhead.glowWidth = 4
                tubeContainer.addChild(warhead)
                
                // Exhaust flame effect (for launch readiness)
                let flame = SKShapeNode(ellipseOf: CGSize(width: 4, height: 6))
                flame.position = CGPoint(x: 0, y: -2)
                flame.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.6)
                flame.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.3)
                flame.glowWidth = 6
                tubeContainer.addChild(flame)
                
                // Flicker effect for exhaust
                let flicker = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                    SKAction.fadeAlpha(to: 0.6, duration: 0.2)
                ])
                flame.run(SKAction.repeatForever(flicker))
                
                turret.addChild(tubeContainer)
            }
            
            // Targeting radar on top
            let radar = SKShapeNode(rect: CGRect(x: -4, y: -2, width: 8, height: 4))
            radar.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            radar.lineWidth = 1
            radar.fillColor = .clear
            radar.position = CGPoint(x: 0, y: 0)
            turret.addChild(radar)
            
            // Radar sweep line
            let sweep = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 1, height: 8))
            sweep.strokeColor = SKColor.green
            sweep.lineWidth = 1
            sweep.glowWidth = 3
            radar.addChild(sweep)
            let sweepRotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
            sweep.run(SKAction.repeatForever(sweepRotate))
            
            tower.addChild(turret)
            
        case "tesla":
            // EMP/Tesla tower with coils
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 100
            
            // Central tower structure
            let towerBody = SKShapeNode(rect: CGRect(x: -6, y: -8, width: 12, height: 20))
            towerBody.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0) // Yellow
            towerBody.lineWidth = 2
            towerBody.fillColor = .clear
            towerBody.glowWidth = 3
            turret.addChild(towerBody)
            
            // Tesla coils (3 levels)
            for (index, y) in [-4, 4, 12].enumerated() {
                let coil = SKShapeNode(circleOfRadius: CGFloat(8 - index * 2))
                coil.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
                coil.lineWidth = 1.5
                coil.fillColor = .clear
                coil.position = CGPoint(x: 0, y: y)
                turret.addChild(coil)
            }
            
            // Electric arcs
            for angle in stride(from: 0, to: 360, by: 90) {
                let arcPath = CGMutablePath()
                arcPath.move(to: CGPoint(x: 0, y: 12))
                let endX = cos(CGFloat(angle) * .pi / 180) * 15
                let endY = 12 + sin(CGFloat(angle) * .pi / 180) * 8
                // Add zigzag for electric effect
                arcPath.addLine(to: CGPoint(x: endX * 0.5, y: endY * 0.7))
                arcPath.addLine(to: CGPoint(x: endX, y: endY))
                
                let arc = SKShapeNode(path: arcPath)
                arc.strokeColor = SKColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 0.7)
                arc.lineWidth = 1
                arc.glowWidth = 4
                turret.addChild(arc)
                
                // Flicker
                let flicker = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.1)
                ])
                arc.run(SKAction.repeatForever(flicker))
            }
            
            tower.addChild(turret)
            
        case "machinegun":
            // Twin-barrel machine gun like on a tank
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 100 + CGFloat(level - 1) * 15  // Short range
            
            // Rotating base
            let mountRadius = CGFloat(10 + level * 2)
            let mount = SKShapeNode(circleOfRadius: mountRadius)
            mount.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)  // Orange
            mount.lineWidth = 2
            mount.fillColor = .clear
            mount.glowWidth = CGFloat(2 + level)
            turret.addChild(mount)
            
            // Twin barrels - thin and parallel
            let barrelLength = CGFloat(20 + level * 3)
            let barrelWidth: CGFloat = 2  // Very thin barrels
            let barrelSpacing: CGFloat = 4  // Space between barrels
            
            // Left barrel
            let leftBarrel = SKShapeNode(rect: CGRect(x: -barrelSpacing - barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
            leftBarrel.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
            leftBarrel.lineWidth = 1.5
            leftBarrel.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.8)
            leftBarrel.glowWidth = 1
            turret.addChild(leftBarrel)
            
            // Right barrel
            let rightBarrel = SKShapeNode(rect: CGRect(x: barrelSpacing - barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
            rightBarrel.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
            rightBarrel.lineWidth = 1.5
            rightBarrel.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.8)
            rightBarrel.glowWidth = 1
            turret.addChild(rightBarrel)
            
            // Muzzle flash containers at barrel tips (for visual effect when firing)
            let leftMuzzle = SKShapeNode(circleOfRadius: 2)
            leftMuzzle.position = CGPoint(x: -barrelSpacing, y: barrelLength)
            leftMuzzle.fillColor = .clear
            leftMuzzle.strokeColor = .clear
            leftMuzzle.name = "leftMuzzle"
            turret.addChild(leftMuzzle)
            
            let rightMuzzle = SKShapeNode(circleOfRadius: 2)
            rightMuzzle.position = CGPoint(x: barrelSpacing, y: barrelLength)
            rightMuzzle.fillColor = .clear
            rightMuzzle.strokeColor = .clear
            rightMuzzle.name = "rightMuzzle"
            turret.addChild(rightMuzzle)
            
            // Ammo feed box (grows with level)
            let boxSize = CGFloat(8 + level * 2)
            let ammoBox = SKShapeNode(rect: CGRect(x: -boxSize/2, y: -5, width: boxSize, height: boxSize * 0.6))
            ammoBox.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
            ammoBox.lineWidth = 1
            ammoBox.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.5)
            turret.addChild(ammoBox)
            
            // Belt feed visual (connecting barrels to ammo box)
            for i in 0..<2 {
                let beltX = CGFloat(i == 0 ? -barrelSpacing : barrelSpacing)
                let belt = SKShapeNode()
                let beltPath = CGMutablePath()
                beltPath.move(to: CGPoint(x: beltX, y: 0))
                beltPath.addLine(to: CGPoint(x: beltX * 0.5, y: -3))
                belt.path = beltPath
                belt.strokeColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.8)
                belt.lineWidth = 1
                turret.addChild(belt)
            }
            
            // Add level indicators as extra barrels or upgrades
            if level >= 2 {
                // Add cooling vents
                for i in 0..<2 {
                    let vent = SKShapeNode(rect: CGRect(x: -6 + i * 12, y: 8, width: 2, height: 4))
                    vent.strokeColor = SKColor(red: 0.6, green: 0.3, blue: 0.0, alpha: 0.8)
                    vent.lineWidth = 1
                    turret.addChild(vent)
                }
            }
            
            if level >= 3 {
                // Add third central barrel for max level
                let centerBarrel = SKShapeNode(rect: CGRect(x: -barrelWidth/2, y: 2, width: barrelWidth, height: barrelLength - 2))
                centerBarrel.strokeColor = SKColor(red: 0.9, green: 0.5, blue: 0.0, alpha: 1.0)
                centerBarrel.lineWidth = 1.5
                centerBarrel.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 0.8)
                centerBarrel.glowWidth = 2
                turret.addChild(centerBarrel)
            }
            
            tower.addChild(turret)
            
        case "kinetic", "cannon":
            // Kinetic cannon with robust barrel and tripod
            let turret = SKNode()
            turret.name = "turret"
            rangeRadius = 180 + CGFloat(level - 1) * 20
            
            // Tripod base (grows with level)
            let baseRadius = CGFloat(8 + level * 2)
            let base = SKShapeNode(circleOfRadius: baseRadius)
            base.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            base.lineWidth = 2
            base.fillColor = .clear
            base.glowWidth = CGFloat(1 + level)  // Subtle glow
            turret.addChild(base)
            
            // Barrel dimensions (used for both single and dual configurations)
            let barrelWidth = CGFloat(4 + level)
            let barrelLength = CGFloat(16 + level * 4)
            
            // Dual barrels for level 3, single for lower levels
            if level >= 3 {
                // Dual cannon barrels
                let dualBarrelWidth = CGFloat(3 + level/2)
                
                // Left barrel
                let leftBarrel = SKShapeNode(rect: CGRect(x: -dualBarrelWidth * 1.5 - 1, y: 0, width: dualBarrelWidth, height: barrelLength))
                leftBarrel.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.6, alpha: 1)
                leftBarrel.lineWidth = 2
                leftBarrel.fillColor = .clear
                leftBarrel.glowWidth = CGFloat(level)
                turret.addChild(leftBarrel)
                
                // Right barrel
                let rightBarrel = SKShapeNode(rect: CGRect(x: dualBarrelWidth * 0.5 + 1, y: 0, width: dualBarrelWidth, height: barrelLength))
                rightBarrel.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.6, alpha: 1)
                rightBarrel.lineWidth = 2
                rightBarrel.fillColor = .clear
                rightBarrel.glowWidth = CGFloat(level)
                turret.addChild(rightBarrel)
                
                // Connect piece between barrels
                let connector = SKShapeNode(rect: CGRect(x: -dualBarrelWidth * 1.5, y: barrelLength - 4, width: dualBarrelWidth * 3, height: 3))
                connector.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.5, alpha: 1)
                connector.lineWidth = 1
                connector.fillColor = .clear
                turret.addChild(connector)
            } else {
                // Single cannon barrel for levels 1-2
                let barrelWidth = CGFloat(4 + level)
                let barrelLength = CGFloat(16 + level * 4)
                let barrel = SKShapeNode(rect: CGRect(x: -barrelWidth/2, y: 0, width: barrelWidth, height: barrelLength))
                barrel.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.6, alpha: 1)
                barrel.lineWidth = 2
                barrel.fillColor = .clear
                barrel.glowWidth = CGFloat(1) + CGFloat(level) * 0.5  // Subtle barrel glow
                turret.addChild(barrel)
            }
            // Barrel reinforcement bands (more bands at higher levels)
            for i in 1...level {
                let bandY = CGFloat(i * 4)
                let band = SKShapeNode(rect: CGRect(x: -barrelWidth/2 - 1, y: bandY, width: barrelWidth + 2, height: 1))
                band.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.5, alpha: 1)
                band.lineWidth = 1
                turret.addChild(band)
            }
            
            // Muzzle brake (bigger at higher levels)
            let muzzleSize = CGFloat(6 + level * 2)
            let muzzle = SKShapeNode(rect: CGRect(x: -muzzleSize/2, y: barrelLength - 2, width: muzzleSize, height: 4))
            muzzle.strokeColor = SKColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1)
            muzzle.lineWidth = 1.5
            muzzle.fillColor = .clear
            muzzle.glowWidth = CGFloat(level)  // Muzzle glow effect
            turret.addChild(muzzle)
            
            // Support legs (more at higher levels)
            let legCount = 3 + (level - 1)
            for i in 0..<legCount {
                let angle = (CGFloat(i) / CGFloat(legCount)) * 2 * .pi
                let legLength = baseRadius + 3
                let legX = cos(angle) * legLength
                let legY = sin(angle) * legLength
                let leg = SKShapeNode(rect: CGRect(x: legX - 0.5, y: legY - 0.5, width: 1, height: 6))
                leg.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                leg.lineWidth = 1
                turret.addChild(leg)
            }
            
            tower.addChild(turret)
            
        default:
            // Generic outline tower
            let turret = SKShapeNode(circleOfRadius: 10)
            turret.strokeColor = .white
            turret.lineWidth = 2
            turret.fillColor = .clear
            turret.name = "turret"
            tower.addChild(turret)
        }
        
        tower.addChild(base)
        
        // Add range indicator (initially hidden)
        let range = SKShapeNode(circleOfRadius: rangeRadius)
        range.strokeColor = SKColor.cyan.withAlphaComponent(0.2)
        range.fillColor = .clear
        range.lineWidth = 1
        range.name = "range"
        range.alpha = 0  // Hidden by default
        tower.addChild(range)
        
        // Don't add idle rotation - turrets will aim at enemies instead
        
        return tower
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        gameEngine.update(currentTime: currentTime)
        
        // Apply game speed to scene
        self.speed = CGFloat(GameEngine.shared.gameSpeed)
        
        // Update power-ups
        updatePowerUps(deltaTime: currentTime)
        
        // Update tower synergy indicators
        updateTowerSynergyIndicators()
        
        // Update game systems
        updateEnemies(currentTime: currentTime)
        updateTowers(currentTime: currentTime)
        // Only check wave completion if wave is active and not already checking
        if isWaveActive && !isCheckingWaveCompletion {
            checkWaveCompletion()
        }
    }
    
    // MARK: - Wave Management
    
    private var isWaveActive = false
    private var isCheckingWaveCompletion = false  // Prevent multiple completions
    private var enemiesSpawned = 0
    private var enemiesPerWave = 10
    private var enemiesDestroyed = 0
    private var stationHealth = 3  // Less health
    private var maxStationHealth = 3  // Harder game
    private var lastFireTime: [SKNode: TimeInterval] = [:]
    
    private func startWave() {
        guard !isWaveActive else { return }
        
        print("Starting wave \(currentWave)")
        
        // Check for newly unlocked towers
        checkForNewTowerUnlocks()
        
        // Play wave start sound
        // SoundManager.shared.playSound(.waveStart)
        // SoundManager.shared.playHaptic(.medium)
        
        // Remove ready message if it exists
        if let readyMessage = uiLayer.childNode(withName: "readyMessage") {
            readyMessage.removeAllActions()
            readyMessage.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
        
        // Remove start button completely
        if let button = uiLayer.childNode(withName: "startWaveButton") {
            button.removeFromParent()
        }
        
        // Create next wave button with same style as start wave button
        createNextWaveButtonInCircularStyle()
        
        isWaveActive = true
        isCheckingWaveCompletion = false  // Reset the checking flag for new wave
        enemiesSpawned = 0
        // BALANCED ENEMY COUNT PROGRESSION
        // Each planet has appropriate enemy counts for its difficulty
        switch currentMap {
        case 1:  // Mercury - Tutorial
            enemiesPerWave = 5 + (currentWave * 2)  // Wave 1: 7, Wave 2: 9, Wave 3: 11
        case 2:  // Venus - First Challenge  
            enemiesPerWave = 8 + (currentWave * 2)  // Wave 1: 10, Wave 2: 12, Wave 3: 14
        case 3:  // Kepler Station - Defend the Station
            // Reduced by 15% for better balance
            enemiesPerWave = Int(Double(10 + (currentWave * 2)) * 0.85) // Wave 1: 10, Wave 2: 12, Wave 3: 14
        case 4:  // Mars - Military Outpost
            enemiesPerWave = 12 + (currentWave * 2) // Wave 1: 14, Wave 2: 16, Wave 3: 18
        case 5:  // Ceres - Asteroid Belt (swarms)
            enemiesPerWave = 15 + (currentWave * 3) // More enemies but weaker types
        case 6:  // Jupiter - Gas Giant
            enemiesPerWave = 14 + (currentWave * 2) // Fewer but tougher enemies
        case 7:  // Saturn - Ring Defense
            enemiesPerWave = 16 + (currentWave * 2)
        case 8:  // Uranus - Ice World
            enemiesPerWave = 18 + (currentWave * 2)
        case 9:  // Neptune - Deep Space
            enemiesPerWave = 20 + (currentWave * 2)
        case 10...12:  // Pluto, Eris, Makemake - Endgame
            enemiesPerWave = 22 + (currentMap - 9) * 3 + (currentWave * 3)
        default:
            enemiesPerWave = 25 + (currentWave * 3)  // Fallback for additional maps
        }
        
        // Start spawning enemies
        spawnEnemies()
        
        updateHUD()
    }
    
    private func spawnEnemies() {
        // Spawn enemies over time
        var spawnCount = 0
        let spawnAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if spawnCount < self.enemiesPerWave {
                self.spawnEnemy()
                spawnCount += 1
                self.enemiesSpawned += 1
            }
        }
        
        // Progressively faster spawn rate both within map and across maps
        let mapSpeedBoost = Double(currentMap - 1) * 0.15   // 15% faster per map
        let waveSpeedBoost = Double(currentWave - 1) * 0.1  // 10% faster per wave
        let spawnDelay = max(0.6, 1.5 - mapSpeedBoost - waveSpeedBoost)  // Gets faster each wave AND map
        let waitAction = SKAction.wait(forDuration: spawnDelay)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        let repeatAction = SKAction.repeat(sequence, count: enemiesPerWave)
        let completeAction = SKAction.run { [weak self] in
            // All enemies have been spawned, start checking for wave completion
            self?.checkWaveCompletion()
        }
        let fullSequence = SKAction.sequence([repeatAction, completeAction])
        
        run(fullSequence)
    }
    
    
    private func spawnEnemy() {
        // Get enemy type
        let enemyType = getEnemyTypeForWave()
        
        // Play spawn sound for boss enemies
        if enemyType == "boss" || enemyType == "destroyer" {
            // SoundManager.shared.playSound(.bossSpawn)
        }
        
        // Determine spawn position based on whether we have custom map spawn points
        let baseSpawnPosition: CGPoint
        if !mapSpawnPoints.isEmpty {
            // Use custom map spawn points (pick random one if multiple)
            let randomIndex = Int.random(in: 0..<mapSpawnPoints.count)
            baseSpawnPosition = mapSpawnPoints[randomIndex]
            print("🎯 Spawning from spawn point \(randomIndex + 1) of \(mapSpawnPoints.count): \(baseSpawnPosition)")
            
            // Extra debug: print all spawn points to verify they're different
            if mapSpawnPoints.count > 1 {
                print("  Available spawn points: \(mapSpawnPoints)")
            }
        } else {
            // Use default hardcoded spawn position
            print("⚠️ No spawn points loaded, using default position")
            baseSpawnPosition = CGPoint(x: size.width/2 + 100, y: 0)
        }
        
        // Special handling for swarms - spawn 2-4 at once in a cluster
        if enemyType == "swarm" {
            let swarmSize = Int.random(in: 2...4)  // Spawn 2-4 swarms together
            for i in 0..<swarmSize {
                let enemy = createEnemy(type: "swarm")
                
                // Cluster them together with small offsets
                let xOffset = CGFloat(i * 15) - CGFloat(Double(swarmSize) * 7.5)
                let yVariation = CGFloat.random(in: -20...20)
                enemy.position = CGPoint(x: baseSpawnPosition.x + xOffset, y: baseSpawnPosition.y + yVariation)
                enemyLayer.addChild(enemy)
                
                // Add slight delay between swarm members
                let delay = SKAction.wait(forDuration: Double(i) * 0.1)
                enemy.run(delay) {
                    self.moveEnemyAlongPath(enemy: enemy)
                }
            }
        } else {
            // Normal single enemy spawn
            let enemy = createEnemy(type: enemyType)
            
            // Set spawn position with slight variation
            let yVariation = CGFloat.random(in: -15...15)
            enemy.position = CGPoint(x: baseSpawnPosition.x, y: baseSpawnPosition.y + yVariation)
            enemyLayer.addChild(enemy)
            
            // Move enemy along the track
            moveEnemyAlongPath(enemy: enemy)
        }
    }
    
    private func getEnemyTypeForWave() -> String {
        // COMPREHENSIVE DIFFICULTY PROGRESSION SYSTEM WITH NEW ENEMY TYPES
        // Each planet has unique enemy compositions that increase in difficulty
        
        switch currentMap {
        case 1:  // ALPHA CENTAURI - First Contact (Tutorial)
            // Theme: Learn basic enemy types
            if currentWave == 1 {
                return "scout"  // Wave 1: Only scouts (100%)
            } else if currentWave == 2 {
                // Wave 2: Introduce fast enemies (60% scouts, 40% fast)
                return Int.random(in: 1...10) <= 6 ? "scout" : "fast"
            } else if currentWave == 3 {
                // Wave 3: Add swarms (40% scouts, 30% fast, 30% swarm)
                let roll = Int.random(in: 1...10)
                if roll <= 4 { return "scout" }
                else if roll <= 7 { return "fast" }
                else { return "swarm" }
            } else {
                // Wave 4+: Mix with armored (30% scout, 30% fast, 20% swarm, 20% armored)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "scout" }
                else if roll <= 6 { return "fast" }
                else if roll <= 8 { return "swarm" }
                else { return "armored" }
            }
            
        case 2:  // PROXIMA B - Red Dwarf Colony
            // Theme: Heat and shields - introduce shielded and regenerator enemies
            if currentWave == 1 {
                // Wave 1: Mix of basic (50% swarm, 50% fast)
                return Int.random(in: 1...2) == 1 ? "swarm" : "fast"
            } else if currentWave == 2 {
                // Wave 2: Introduce shielded (40% swarm, 30% fast, 30% shielded)
                let roll = Int.random(in: 1...10)
                if roll <= 4 { return "swarm" }
                else if roll <= 7 { return "fast" }
                else { return "shielded" }
            } else {
                // Wave 3+: First bombers appear (30% fighters, 30% bombers, 40% swarms)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "fighter" }
                else if roll <= 6 { return "bomber" }
                else { return "swarm" }
            }
            
        case 3:  // EARTH - Defend Home
            // Theme: Balanced mix of all basic enemy types
            if currentWave == 1 {
                // Wave 1: Standard mix (50% fighters, 50% swarms)
                return Int.random(in: 1...2) == 1 ? "fighter" : "swarm"
            } else if currentWave == 2 {
                // Wave 2: Add special units (30% fighters, 30% bombers, 20% stealth, 20% swarms)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "fighter" }
                else if roll <= 6 { return "bomber" }
                else if roll <= 8 { return "stealth" }
                else { return "swarm" }
            } else {
                // Wave 3+: Shield units appear (25% each: fighters, bombers, shields, stealth)
                return ["fighter", "bomber", "shield", "stealth"].randomElement()!
            }
            
        case 4:  // MARS - Military Outpost
            // Theme: Heavy armored units and organized attacks
            if currentWave == 1 {
                // Wave 1: Tougher basics (60% fighters, 40% bombers)
                return Int.random(in: 1...10) <= 6 ? "fighter" : "bomber"
            } else if currentWave == 2 {
                // Wave 2: Shield and stealth units (30% shields, 30% stealth, 40% bombers)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "shield" }
                else if roll <= 6 { return "stealth" }
                else { return "bomber" }
            } else {
                // Wave 3+: Destroyer units (30% destroyers, 30% shields, 40% bombers)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "destroyer" }
                else if roll <= 6 { return "shield" }
                else { return "bomber" }
            }
            
        case 5:  // CERES - Asteroid Belt
            // Theme: Swarm tactics with occasional heavy units
            if currentWave == 1 {
                // Wave 1: Mostly swarms (70% swarms, 30% fighters)
                return Int.random(in: 1...10) <= 7 ? "swarm" : "fighter"
            } else if currentWave == 2 {
                // Wave 2: Mixed swarms (50% swarms, 30% bombers, 20% stealth)
                let roll = Int.random(in: 1...10)
                if roll <= 5 { return "swarm" }
                else if roll <= 8 { return "bomber" }
                else { return "stealth" }
            } else {
                // Wave 3+: Swarms with heavies (40% swarms, 30% destroyers, 30% shields)
                let roll = Int.random(in: 1...10)
                if roll <= 4 { return "swarm" }
                else if roll <= 7 { return "destroyer" }
                else { return "shield" }
            }
            
        case 6:  // JUPITER - Gas Giant
            // Theme: Massive, powerful enemies
            if currentWave == 1 {
                // Wave 1: Heavy units (50% bombers, 50% shields)
                return Int.random(in: 1...2) == 1 ? "bomber" : "shield"
            } else if currentWave == 2 {
                // Wave 2: Destroyers arrive (40% destroyers, 30% shields, 30% bombers)
                let roll = Int.random(in: 1...10)
                if roll <= 4 { return "destroyer" }
                else if roll <= 7 { return "shield" }
                else { return "bomber" }
            } else {
                // Wave 3+: Elite mix (Equal chances of destroyer, shield, stealth, bomber)
                return ["destroyer", "shield", "stealth", "bomber"].randomElement()!
            }
            
        case 7:  // SATURN - Ring Defense
            // Theme: Multi-directional attacks with varied enemies
            if currentWave == 1 {
                // Wave 1: Diverse mix (Equal chances of fighter, bomber, stealth)
                return ["fighter", "bomber", "stealth"].randomElement()!
            } else if currentWave == 2 {
                // Wave 2: Advanced units (Equal chances of shield, destroyer, stealth, bomber)
                return ["shield", "destroyer", "stealth", "bomber"].randomElement()!
            } else {
                // Wave 3+: Full variety (All enemy types with destroyer emphasis)
                let roll = Int.random(in: 1...10)
                if roll <= 3 { return "destroyer" }
                else if roll <= 5 { return "shield" }
                else if roll <= 7 { return "stealth" }
                else if roll <= 9 { return "bomber" }
                else { return "swarm" }
            }
            
        case 8:  // URANUS - Ice World
            // Theme: Slow but extremely durable enemies
            return ["shield", "destroyer", "bomber", "stealth"].randomElement()!
            
        case 9:  // NEPTUNE - Deep Space
            // Theme: Elite enemy compositions
            if currentWave <= 2 {
                return ["destroyer", "shield", "bomber"].randomElement()!
            } else {
                // Later waves: 50% destroyers, 50% other elites
                return Int.random(in: 1...2) == 1 ? "destroyer" : 
                       ["shield", "stealth", "bomber"].randomElement()!
            }
            
        case 10:  // PLUTO - Dwarf Planet
            // Theme: Extreme challenge with mostly elite units and TITANS
            let roll = Int.random(in: 1...10)
            if roll == 1 && currentWave >= 2 {
                return "titan"  // 10% chance of TITAN after wave 1
            } else {
                return ["destroyer", "shield", "destroyer", "stealth"].randomElement()!
            }
            
        case 11:  // ERIS - Chaos World
            // Theme: Unpredictable mix of all enemy types including TITANS
            let roll = Int.random(in: 1...10)
            if roll <= 2 && currentWave >= 2 {
                return "titan"  // 20% chance of TITAN
            } else {
                return ["fighter", "bomber", "destroyer", "shield", "stealth", "swarm"].randomElement()!
            }
            
        case 12:  // MAKEMAKE - Final Challenge
            // Theme: Ultimate test with MULTIPLE TITANS
            if currentWave == 1 {
                return ["destroyer", "shield"].randomElement()!
            } else if currentWave >= 3 {
                // Wave 3+: TITAN INVASION
                let roll = Int.random(in: 1...10)
                if roll <= 3 {
                    return "titan"  // 30% chance of TITAN in final waves!
                } else {
                    return ["destroyer", "shield"].randomElement()!
                }
            } else {
                // Wave 2: Build up with destroyers
                return Int.random(in: 1...10) <= 7 ? 
                       ["destroyer", "shield"].randomElement()! :
                       ["bomber", "stealth"].randomElement()!
            }
            
        default:
            // Fallback for any additional maps
            return ["destroyer", "shield", "bomber", "stealth"].randomElement()!
        }
    }
    
    private func createEnemy(type: String) -> SKNode {
        let enemy = SKNode()
        enemy.name = "enemy_\(type)"
        
        // Set enemy properties
        var health: Int = 1
        var speed: CGFloat = 1.0
        var salvageReward: Int = 10
        
        // Create OUTLINE-STYLE enemy visuals with increased glow
        let body: SKShapeNode
        
        switch type {
        case "scout":
            // Fast triangular scout ship
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 12))
            path.addLine(to: CGPoint(x: -10, y: -8))
            path.addLine(to: CGPoint(x: 10, y: -8))
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0) // Neon pink
            body.lineWidth = 2
            body.fillColor = .clear // Outline only
            body.glowWidth = 6 // Increased glow
            health = 2  // Fast but fragile as specified
            speed = 1.2
            salvageReward = 5  // Scout reward
            
            // Add engine trail with particles
            let trail = SKShapeNode(circleOfRadius: 3)
            trail.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.5)
            trail.strokeColor = .clear
            trail.position = CGPoint(x: 0, y: -10)
            trail.glowWidth = 4
            body.addChild(trail)
            
        case "fighter":
            // Diamond-shaped fighter
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 12))
            path.addLine(to: CGPoint(x: 12, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -12))
            path.addLine(to: CGPoint(x: -12, y: 0))
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0) // Neon orange
            body.lineWidth = 2
            body.fillColor = .clear
            body.glowWidth = 6
            health = 4  // Balanced fighter
            speed = 1.0
            salvageReward = 12  // Fighter reward
            
            // Add weapon ports
            for x in [-8, 8] {
                let port = SKShapeNode(circleOfRadius: 2)
                port.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.8)
                port.lineWidth = 1
                port.fillColor = .clear
                port.position = CGPoint(x: x, y: 0)
                body.addChild(port)
            }
            
        case "bomber":
            // Spiked circular bomber
            let path = CGMutablePath()
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let radius: CGFloat = i % 2 == 0 ? 18 : 12
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0) // Neon purple
            body.lineWidth = 2.5
            body.fillColor = .clear
            body.glowWidth = 8 // Extra glow for bombers
            health = 10  // Tanky bomber as specified
            speed = 0.8
            salvageReward = 15  // Bomber reward
            
            // Add rotating core
            let core = SKShapeNode(circleOfRadius: 5)
            core.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.8)
            core.lineWidth = 1.5
            core.fillColor = .clear
            core.glowWidth = 3
            body.addChild(core)
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            core.run(SKAction.repeatForever(rotate))
            
        case "destroyer":
            // Hexagonal heavy destroyer
            let path = CGMutablePath()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3
                let x = cos(angle) * 20
                let y = sin(angle) * 20
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0) // Neon red
            body.lineWidth = 3
            body.fillColor = .clear
            body.glowWidth = 10 // Maximum glow for boss enemies
            health = 30  // Boss destroyer as specified
            speed = 0.6
            salvageReward = 18  // Destroyer reward
            
        case "titan":
            // MASSIVE ALIEN BOSS - Extremely slow but incredibly powerful
            let path = CGMutablePath()
            // Create a complex alien shape with tentacles
            path.addEllipse(in: CGRect(x: -30, y: -30, width: 60, height: 60))
            
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 0.8, green: 0.0, blue: 1.0, alpha: 1.0) // Purple alien
            body.lineWidth = 5
            body.fillColor = .clear
            body.glowWidth = 20 // Maximum glow
            body.setScale(1.5) // Make it bigger
            
            // Add pulsing core
            let core = SKShapeNode(circleOfRadius: 15)
            core.fillColor = SKColor(red: 1.0, green: 0.0, blue: 0.8, alpha: 0.8)
            core.strokeColor = .clear
            core.glowWidth = 10
            body.addChild(core)
            
            // Add rotating tentacles
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let tentacle = SKShapeNode()
                let tentaclePath = CGMutablePath()
                tentaclePath.move(to: CGPoint.zero)
                tentaclePath.addCurve(
                    to: CGPoint(x: cos(angle) * 40, y: sin(angle) * 40),
                    control1: CGPoint(x: cos(angle) * 15, y: sin(angle) * 15),
                    control2: CGPoint(x: cos(angle) * 30, y: sin(angle) * 30)
                )
                tentacle.path = tentaclePath
                tentacle.strokeColor = SKColor(red: 0.6, green: 0.0, blue: 0.8, alpha: 0.8)
                tentacle.lineWidth = 3
                tentacle.glowWidth = 5
                body.addChild(tentacle)
            }
            
            health = 100  // EXTREMELY high health
            speed = 0.3   // VERY slow movement
            salvageReward = 50  // Huge reward for defeating it
            
            // Add armor plates
            let innerPath = CGMutablePath()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3
                let x = cos(angle) * 12
                let y = sin(angle) * 12
                if i == 0 {
                    innerPath.move(to: CGPoint(x: x, y: y))
                } else {
                    innerPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            innerPath.closeSubpath()
            let armor = SKShapeNode(path: innerPath)
            armor.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.5)
            armor.lineWidth = 1.5
            armor.fillColor = .clear
            body.addChild(armor)
            
        case "swarm":
            // Tiny SUPER fast swarm unit
            body = SKShapeNode(circleOfRadius: 4)  // Even smaller
            body.strokeColor = SKColor(red: 0.2, green: 1.0, blue: 0.8, alpha: 1.0) // Neon cyan
            body.lineWidth = 1.5
            body.fillColor = .clear
            body.glowWidth = 4
            health = 1  // Dies in one hit
            speed = 2.5  // SUPER FAST! (was 1.8)
            salvageReward = 7  // Swarm reward
            
        case "shield":
            // Shielded tank with regeneration
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: -15, y: -10, width: 30, height: 20))
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0) // Blue shield
            body.lineWidth = 3
            body.fillColor = .clear
            body.glowWidth = 10
            health = 15  // High health
            speed = 0.7  // Slow
            salvageReward = 15  // Shield tank reward
            
            // Add shield effect
            let shield = SKShapeNode(circleOfRadius: 20)
            shield.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.3)
            shield.lineWidth = 2
            shield.fillColor = .clear
            shield.glowWidth = 5
            body.addChild(shield)
            
        case "stealth":
            // Stealth unit that phases in and out
            let stealthPath = CGMutablePath()
            stealthPath.move(to: CGPoint(x: 0, y: 15))
            stealthPath.addLine(to: CGPoint(x: -5, y: 0))
            stealthPath.addLine(to: CGPoint(x: -8, y: -15))
            stealthPath.addLine(to: CGPoint(x: 0, y: -10))
            stealthPath.addLine(to: CGPoint(x: 8, y: -15))
            stealthPath.addLine(to: CGPoint(x: 5, y: 0))
            stealthPath.closeSubpath()
            body = SKShapeNode(path: stealthPath)
            body.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Dark gray
            body.lineWidth = 1.5
            body.fillColor = .clear
            body.glowWidth = 2
            health = 3  // Fragile
            speed = 1.4  // Fast
            salvageReward = 10  // Stealth reward
            
        case "swarmer":
            // Small pack enemy with bonus when grouped
            body = SKShapeNode(ellipseOf: CGSize(width: 12, height: 12))
            body.strokeColor = SKColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0) // Bright green
            body.lineWidth = 1.5
            body.fillColor = .clear
            body.glowWidth = 4
            health = 4  // More health than swarm
            speed = 1.2  // Fast but not super fast
            salvageReward = 6  // Pack enemy reward
            
            // Add pack indicator
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = SKColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1.0)
            dot.strokeColor = .clear
            body.addChild(dot)
            
        case "robot":
            // Mechanical armored unit
            let robotPath = CGMutablePath()
            robotPath.addRect(CGRect(x: -12, y: -12, width: 24, height: 24))
            body = SKShapeNode(path: robotPath)
            body.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0) // Orange
            body.lineWidth = 3
            body.fillColor = .clear
            body.glowWidth = 6
            health = 15  // High health with armor
            speed = 0.6  // Slow mechanical movement
            salvageReward = 12  // Armored unit reward
            
            // Add mechanical details
            let core = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            core.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 0.8)
            core.lineWidth = 1
            core.fillColor = .clear
            body.addChild(core)
            
            // Add armor plating indicators
            for angle in [0, CGFloat.pi/2, CGFloat.pi, 3*CGFloat.pi/2] {
                let plate = SKShapeNode(rectOf: CGSize(width: 4, height: 8))
                plate.strokeColor = SKColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.6)
                plate.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
                plate.zRotation = angle
                body.addChild(plate)
            }
            
        case "drone":
            // Flying unit with shields
            let dronePath = CGMutablePath()
            dronePath.addEllipse(in: CGRect(x: -10, y: -8, width: 20, height: 16))
            body = SKShapeNode(path: dronePath)
            body.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0) // Cyan
            body.lineWidth = 2
            body.fillColor = .clear
            body.glowWidth = 7
            health = 8  // Medium health
            speed = 1.0  // Normal speed
            salvageReward = 10  // Shielded unit reward
            
            // Add shield effect
            let shield = SKShapeNode(ellipseOf: CGSize(width: 28, height: 22))
            shield.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.3)
            shield.lineWidth = 1.5
            shield.fillColor = .clear
            shield.glowWidth = 4
            shield.name = "shield"
            body.addChild(shield)
            
            // Shield shimmer animation
            let shimmer = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: 0.5),
                SKAction.fadeAlpha(to: 0.4, duration: 0.5)
            ])
            shield.run(SKAction.repeatForever(shimmer))
            
        case "bioTitan":
            // Massive biological boss enemy
            let bioPath = CGMutablePath()
            bioPath.addEllipse(in: CGRect(x: -35, y: -35, width: 70, height: 70))
            body = SKShapeNode(path: bioPath)
            body.strokeColor = SKColor(red: 0.6, green: 0.0, blue: 0.8, alpha: 1.0) // Purple
            body.lineWidth = 4
            body.fillColor = .clear
            body.glowWidth = 15
            body.setScale(1.2)
            health = 120  // Extremely high health
            speed = 0.4  // Very slow
            salvageReward = 80  // Massive reward
            
            // Add bio-organic details
            let bioCore = SKShapeNode(circleOfRadius: 20)
            bioCore.fillColor = SKColor(red: 0.8, green: 0.0, blue: 0.6, alpha: 0.6)
            bioCore.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.8)
            bioCore.lineWidth = 2
            bioCore.glowWidth = 8
            body.addChild(bioCore)
            
            // Add tentacle-like appendages
            for i in 0..<6 {
                let angle = CGFloat(i) * CGFloat.pi / 3
                let tentacle = SKShapeNode()
                let tentaclePath = CGMutablePath()
                tentaclePath.move(to: CGPoint.zero)
                tentaclePath.addQuadCurve(
                    to: CGPoint(x: cos(angle) * 45, y: sin(angle) * 45),
                    control: CGPoint(x: cos(angle) * 20, y: sin(angle) * 20)
                )
                tentacle.path = tentaclePath
                tentacle.strokeColor = SKColor(red: 0.5, green: 0.0, blue: 0.6, alpha: 0.8)
                tentacle.lineWidth = 3
                tentacle.glowWidth = 4
                body.addChild(tentacle)
            }
            
            // Add bio-pulsing effect
            let bioPulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 1.0),
                SKAction.scale(to: 0.95, duration: 1.0)
            ])
            bioCore.run(SKAction.repeatForever(bioPulse))
            
        // NEW ENEMY TYPES
        case "fast":
            // Sleek arrow-shaped speed demon with afterburner effects
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 12))
            path.addLine(to: CGPoint(x: -8, y: -10))
            path.addLine(to: CGPoint(x: -3, y: -8))
            path.addLine(to: CGPoint(x: 0, y: -6))
            path.addLine(to: CGPoint(x: 3, y: -8))
            path.addLine(to: CGPoint(x: 8, y: -10))
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // Bright yellow
            body.lineWidth = 2.5
            body.fillColor = .clear
            body.glowWidth = 10
            health = 2  // Very fragile
            speed = 2.0  // Extremely fast
            salvageReward = 8
            
            // Add speed trail effects
            for i in 1...4 {
                let trail = SKShapeNode(rectOf: CGSize(width: 12 - CGFloat(i * 2), height: 2))
                trail.strokeColor = .clear
                trail.fillColor = SKColor.yellow.withAlphaComponent(0.5 / CGFloat(i))
                trail.position = CGPoint(x: 0, y: -12 - CGFloat(i * 4))
                trail.glowWidth = 3
                trail.blendMode = .add
                body.addChild(trail)
                
                // Animate the trails
                let flicker = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.fadeAlpha(to: 0.5 / CGFloat(i), duration: 0.1)
                ])
                trail.run(SKAction.repeatForever(flicker))
            }
            
            // Add engine glow
            let engine = SKShapeNode(circleOfRadius: 3)
            engine.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
            engine.strokeColor = .clear
            engine.position = CGPoint(x: 0, y: -8)
            engine.glowWidth = 5
            engine.blendMode = .add
            body.addChild(engine)
            
            // Pulsing engine
            let enginePulse = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.scale(to: 0.8, duration: 0.1)
            ])
            engine.run(SKAction.repeatForever(enginePulse))
            
        case "armored":
            // Heavy tank with layered armor plating
            body = SKShapeNode(rectOf: CGSize(width: 28, height: 28), cornerRadius: 4)
            body.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Metal gray
            body.lineWidth = 3
            body.fillColor = .clear
            body.glowWidth = 6
            health = 20  // Very tanky
            speed = 0.5  // Very slow
            salvageReward = 20
            
            // Add layered armor plates
            let outerPlate = SKShapeNode(rectOf: CGSize(width: 22, height: 22), cornerRadius: 2)
            outerPlate.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.9)
            outerPlate.lineWidth = 2
            outerPlate.fillColor = .clear
            body.addChild(outerPlate)
            
            let innerPlate = SKShapeNode(rectOf: CGSize(width: 16, height: 16))
            innerPlate.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
            innerPlate.lineWidth = 1.5
            innerPlate.fillColor = .clear
            body.addChild(innerPlate)
            
            // Add rivets
            for angle in [0, CGFloat.pi/2, CGFloat.pi, 3*CGFloat.pi/2] {
                let rivet = SKShapeNode(circleOfRadius: 2)
                rivet.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
                rivet.strokeColor = .clear
                rivet.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
                body.addChild(rivet)
            }
            
        case "shielded":
            // Diamond core with energy shield
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 14))
            path.addLine(to: CGPoint(x: 12, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -14))
            path.addLine(to: CGPoint(x: -12, y: 0))
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0) // Bright cyan
            body.lineWidth = 2.5
            body.fillColor = .clear
            body.glowWidth = 8
            health = 10
            speed = 0.8
            salvageReward = 15
            
            // Add hexagonal shield bubble
            let shieldPath = CGMutablePath()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3
                let x = cos(angle) * 20
                let y = sin(angle) * 20
                if i == 0 {
                    shieldPath.move(to: CGPoint(x: x, y: y))
                } else {
                    shieldPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            shieldPath.closeSubpath()
            
            let shield = SKShapeNode(path: shieldPath)
            shield.strokeColor = SKColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 0.6)
            shield.lineWidth = 2
            shield.fillColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.1)
            shield.glowWidth = 4
            shield.name = "shield"
            body.addChild(shield)
            
            // Shield rotation and pulsing
            let shieldRotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
            shield.run(SKAction.repeatForever(shieldRotate))
            
            let shieldPulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.8),
                SKAction.scale(to: 0.95, duration: 0.8)
            ])
            shield.run(SKAction.repeatForever(shieldPulse))
            
        case "regenerator":
            // Organic healing entity with pulsing core
            body = SKShapeNode(ellipseOf: CGSize(width: 22, height: 28))
            body.strokeColor = SKColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0) // Bright green
            body.lineWidth = 3
            body.fillColor = .clear
            body.glowWidth = 10
            health = 12
            speed = 0.7
            salvageReward = 18
            
            // Add healing aura rings
            for i in 1...3 {
                let aura = SKShapeNode(circleOfRadius: CGFloat(15 + i * 6))
                aura.strokeColor = SKColor.green.withAlphaComponent(0.3 / CGFloat(i))
                aura.lineWidth = 1.5
                aura.fillColor = .clear
                aura.glowWidth = CGFloat(6 - i)
                aura.blendMode = .add
                body.addChild(aura)
                
                // Rotating aura rings
                let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: TimeInterval(3 + i))
                aura.run(SKAction.repeatForever(rotate))
            }
            
            // Add healing particles
            for _ in 0..<4 {
                let particle = SKShapeNode(circleOfRadius: 2)
                particle.fillColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.8)
                particle.strokeColor = .clear
                particle.glowWidth = 3
                particle.blendMode = .add
                
                let angle = CGFloat.random(in: 0...(2 * .pi))
                particle.position = CGPoint(x: cos(angle) * 8, y: sin(angle) * 10)
                body.addChild(particle)
                
                // Floating particle animation
                let float = SKAction.sequence([
                    SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: 1.5),
                    SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: 1.5)
                ])
                particle.run(SKAction.repeatForever(float))
            }
            
        case "boss":
            // Massive intimidating fortress with rotating parts
            let path = CGMutablePath()
            for i in 0..<16 {
                let angle = CGFloat(i) * .pi / 8
                let radius: CGFloat = i % 2 == 0 ? 35 : 25
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            body = SKShapeNode(path: path)
            body.strokeColor = SKColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0) // Deep red
            body.lineWidth = 5
            body.fillColor = .clear
            body.glowWidth = 15
            health = 100  // Extremely tanky
            speed = 0.3   // Very slow
            salvageReward = 100
            
            // Add rotating inner core
            let core = SKShapeNode(circleOfRadius: 18)
            core.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.9)
            core.lineWidth = 3
            core.fillColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.3)
            core.glowWidth = 8
            body.addChild(core)
            
            let coreRotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
            core.run(SKAction.repeatForever(coreRotate))
            
            // Add weapon ports
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let port = SKShapeNode(circleOfRadius: 4)
                port.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.9)
                port.strokeColor = SKColor.red
                port.lineWidth = 1
                port.glowWidth = 3
                port.position = CGPoint(x: cos(angle) * 28, y: sin(angle) * 28)
                body.addChild(port)
                
                // Pulsing weapon ports
                let portPulse = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.3),
                    SKAction.scale(to: 0.8, duration: 0.3)
                ])
                port.run(SKAction.repeatForever(portPulse))
            }
            
            // Add danger indicator
            let danger = SKLabelNode(text: "⚠")
            danger.fontSize = 20
            danger.fontColor = SKColor.red
            danger.position = CGPoint(x: 0, y: 0)
            body.addChild(danger)
            
            // Flash danger indicator
            let flash = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.fadeIn(withDuration: 0.5)
            ])
            danger.run(SKAction.repeatForever(flash))
            
        default:
            // Generic enemy with enhanced outline
            body = SKShapeNode(circleOfRadius: 10)
            body.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
            body.lineWidth = 2
            body.fillColor = .clear
            body.glowWidth = 5
            health = 1
            speed = 1.0
            salvageReward = 10  // Default enemy reward
        }
        
        // Add pulsing animation to all enemies
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        body.run(SKAction.repeatForever(pulse))
        
        // Add movement animation based on type
        switch type {
        case "scout":
            // Wobble side to side as it flies
            let wobble = SKAction.sequence([
                SKAction.rotate(toAngle: 0.1, duration: 0.3),
                SKAction.rotate(toAngle: -0.1, duration: 0.3)
            ])
            body.run(SKAction.repeatForever(wobble))
            
        case "fighter":
            // Subtle rotation
            let spin = SKAction.rotate(byAngle: .pi * 2, duration: 8.0)
            body.run(SKAction.repeatForever(spin))
            
        case "bomber":
            // Already has rotating core, add body oscillation
            let oscillate = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.5),
                SKAction.scale(to: 0.95, duration: 0.5)
            ])
            body.run(SKAction.repeatForever(oscillate))
            
        case "destroyer":
            // Heavy mechanical movement
            let heavyPulse = SKAction.sequence([
                SKAction.scale(to: 1.02, duration: 1.0),
                SKAction.scale(to: 0.98, duration: 1.0)
            ])
            body.run(SKAction.repeatForever(heavyPulse))
            
        case "titan":
            // Alien titan movement - tentacles writhe and core pulses
            let corePulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.8),
                SKAction.scale(to: 0.8, duration: 0.8)
            ])
            if let core = body.childNode(withName: "//core") as? SKShapeNode {
                core.run(SKAction.repeatForever(corePulse))
            }
            
            // Writhing tentacles
            body.enumerateChildNodes(withName: "//tentacle") { tentacle, _ in
                let writhe = SKAction.sequence([
                    SKAction.rotate(byAngle: .pi/8, duration: 1.5),
                    SKAction.rotate(byAngle: -.pi/4, duration: 1.5),
                    SKAction.rotate(byAngle: .pi/8, duration: 1.5)
                ])
                tentacle.run(SKAction.repeatForever(writhe))
            }
            
            // Ominous glow effect
            let glow = SKAction.sequence([
                SKAction.customAction(withDuration: 2.0) { node, elapsedTime in
                    if let shape = node as? SKShapeNode {
                        shape.glowWidth = 20 + sin(elapsedTime * 2) * 10
                    }
                }
            ])
            body.run(SKAction.repeatForever(glow))
            
            // Add rotating warning lights
            for angle in stride(from: 0, to: 360, by: 90) {
                let light = SKShapeNode(circleOfRadius: 2)
                light.fillColor = SKColor.red
                light.strokeColor = .clear
                light.glowWidth = 4
                let rad = CGFloat(angle) * .pi / 180
                light.position = CGPoint(x: cos(rad) * 18, y: sin(rad) * 18)
                body.addChild(light)
                
                let blink = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
                light.run(SKAction.repeatForever(blink))
            }
            
        case "swarm":
            // Erratic rapid movement - harder to hit
            let zigzag = SKAction.sequence([
                SKAction.moveBy(x: 8, y: 3, duration: 0.08),
                SKAction.moveBy(x: -8, y: -3, duration: 0.08),
                SKAction.moveBy(x: -6, y: 4, duration: 0.06),
                SKAction.moveBy(x: 6, y: -4, duration: 0.06)
            ])
            body.run(SKAction.repeatForever(zigzag))
            
            // Add spinning effect for visual chaos
            let spin = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 0.5))
            body.run(spin)
            
        case "shield":
            // Shield pulsing effect
            if let shield = body.children.first {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 1.0),
                    SKAction.scale(to: 0.9, duration: 1.0)
                ])
                shield.run(SKAction.repeatForever(pulse))
            }
            
        case "stealth":
            // Phasing in and out - completely disappear and become untargetable
            enemy.userData?["isStealthed"] = false
            
            let disappearDuration = Double.random(in: 1.0...3.0)  // Random 1-3 seconds invisible
            let visibleDuration = Double.random(in: 2.0...3.0)    // 2-3 seconds visible
            
            // Create stealth cycle
            let stealthCycle = SKAction.sequence([
                // Visible phase
                SKAction.run { [weak enemy] in
                    enemy?.userData?["isStealthed"] = false
                },
                SKAction.fadeAlpha(to: 1.0, duration: 0.2),
                SKAction.wait(forDuration: visibleDuration),
                
                // Disappearing phase
                SKAction.fadeAlpha(to: 0.1, duration: 0.3),
                SKAction.run { [weak enemy] in
                    enemy?.userData?["isStealthed"] = true
                },
                SKAction.wait(forDuration: disappearDuration),
                
                // Reappearing phase  
                SKAction.fadeAlpha(to: 0.5, duration: 0.2)
            ])
            
            // Start with a random delay so not all stealth units sync up
            let initialDelay = SKAction.wait(forDuration: Double.random(in: 0...2))
            body.run(SKAction.sequence([
                initialDelay,
                SKAction.repeatForever(stealthCycle)
            ]))
            
        default:
            break
        }
        
        // Apply difficulty scaling based on wave within the map
        // Each wave in a map makes enemies tougher
        let waveScaling = 1.0 + (Double(currentWave - 1) * 0.15)  // 15% health boost per wave
        let mapScaling = 1.0 + (Double(currentMap - 1) * 0.2)     // 20% health boost per map
        
        // Apply scaling to health (speed stays consistent for predictability)
        let scaledHealth = Int(Double(health) * waveScaling * mapScaling)
        
        // Store properties in userData
        enemy.userData = NSMutableDictionary()
        enemy.userData?["health"] = scaledHealth
        enemy.userData?["maxHealth"] = scaledHealth
        enemy.userData?["speed"] = speed
        enemy.userData?["salvageReward"] = salvageReward
        
        enemy.addChild(body)
        
        // Add health bar for enemies with more than 1 health
        if health > 1 {
            let healthBarBg = SKShapeNode(rectOf: CGSize(width: 30, height: 3))
            healthBarBg.fillColor = .darkGray
            healthBarBg.strokeColor = .clear
            healthBarBg.position = CGPoint(x: 0, y: 15)
            enemy.addChild(healthBarBg)
            
            let healthBar = SKShapeNode(rectOf: CGSize(width: 30, height: 3))
            healthBar.fillColor = .green
            healthBar.strokeColor = .clear
            healthBar.position = CGPoint(x: 0, y: 15)
            healthBar.name = "healthBar"
            enemy.addChild(healthBar)
        }
        
        // Add enemy glow/engine effect
        let glow = SKShapeNode(circleOfRadius: 5)
        glow.fillColor = SKColor.red.withAlphaComponent(0.5)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: -10, y: 0)
        glow.glowWidth = 5
        enemy.addChild(glow)
        
        return enemy
    }
    
    private func getPathForCurrentMap(startingFrom startPoint: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: startPoint)
        
        // Use vector map paths - get all paths and find the one matching our spawn point
        let allPaths = SimpleVectorMapLoader.shared.getAllVectorPaths(mapNumber: currentMap)
        if !allPaths.isEmpty {
            // Find which spawn point index this is closest to
            let spawnPoints = SimpleVectorMapLoader.shared.getSpawnPoints(mapNumber: currentMap)
            var pathIndex = 0
            
            if !spawnPoints.isEmpty {
                // Find the closest spawn point to determine which path to use
                var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
                for (index, spawn) in spawnPoints.enumerated() {
                    let distance = hypot(spawn.x - startPoint.x, spawn.y - startPoint.y)
                    if distance < minDistance {
                        minDistance = distance
                        pathIndex = index
                    }
                }
            }
            
            // Use the corresponding path (or first if index out of bounds)
            print("🛤️ Using path \(pathIndex + 1) of \(allPaths.count) for spawn at \(startPoint)")
            if pathIndex < allPaths.count {
                return allPaths[pathIndex].mutableCopy()!
            } else {
                // If we have fewer paths than spawn points, use the first path
                print("⚠️ Path index \(pathIndex) out of bounds, using first path")
                return allPaths[0].mutableCopy()!
            }
        }
        
        // Fall back to hardcoded paths
        switch currentMap {
        case 1:
            // S-shaped path for Map 1
            path.addLine(to: CGPoint(x: 300, y: startPoint.y))
            path.addCurve(to: CGPoint(x: 0, y: 150),
                         control1: CGPoint(x: 250, y: startPoint.y),
                         control2: CGPoint(x: 150, y: 150))
            path.addCurve(to: CGPoint(x: -200, y: 0),
                         control1: CGPoint(x: -100, y: 150),
                         control2: CGPoint(x: -200, y: 100))
            path.addCurve(to: CGPoint(x: 0, y: -150),
                         control1: CGPoint(x: -200, y: -100),
                         control2: CGPoint(x: -100, y: -150))
            path.addCurve(to: CGPoint(x: 0, y: 0),
                         control1: CGPoint(x: 100, y: -150),
                         control2: CGPoint(x: 50, y: -75))
                         
        case 2:
            // Figure-8 path for Map 2
            path.addLine(to: CGPoint(x: 300, y: 0))
            path.addCurve(to: CGPoint(x: 0, y: 180),
                         control1: CGPoint(x: 250, y: 100),
                         control2: CGPoint(x: 100, y: 180))
            path.addCurve(to: CGPoint(x: -200, y: 0),
                         control1: CGPoint(x: -100, y: 180),
                         control2: CGPoint(x: -200, y: 90))
            path.addCurve(to: CGPoint(x: 0, y: -180),
                         control1: CGPoint(x: -200, y: -90),
                         control2: CGPoint(x: -100, y: -180))
            path.addCurve(to: CGPoint(x: 100, y: 0),
                         control1: CGPoint(x: 100, y: -180),
                         control2: CGPoint(x: 150, y: -90))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case 3:
            // Spiral inward for Map 3
            let spiralSteps = 6
            for i in 0..<spiralSteps {
                let radius = 300.0 - (Double(i) * 50.0)
                let angle = Double(i) * .pi * 0.75
                let x = CGFloat(cos(angle) * radius)
                let y = CGFloat(sin(angle) * radius)
                if i == 0 {
                    path.addLine(to: CGPoint(x: x, y: y))
                } else {
                    let prevAngle = Double(i-1) * .pi * 0.75
                    let prevRadius = 300.0 - (Double(i-1) * 50.0)
                    let controlX = CGFloat(cos((angle + prevAngle) / 2) * (radius + prevRadius) / 2)
                    let controlY = CGFloat(sin((angle + prevAngle) / 2) * (radius + prevRadius) / 2)
                    path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: controlX, y: controlY))
                }
            }
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case 4:
            // Diamond/Square path for Map 4
            path.addLine(to: CGPoint(x: 250, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 200))
            path.addLine(to: CGPoint(x: -250, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -200))
            path.addLine(to: CGPoint(x: 150, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        case 5:
            // Zigzag maze for Map 5
            path.addLine(to: CGPoint(x: 300, y: 0))
            path.addLine(to: CGPoint(x: 300, y: 150))
            path.addLine(to: CGPoint(x: -300, y: 150))
            path.addLine(to: CGPoint(x: -300, y: -150))
            path.addLine(to: CGPoint(x: 200, y: -150))
            path.addLine(to: CGPoint(x: 200, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        default:
            // More complex paths for later maps
            // Use a wavy pattern as default
            for i in 1...4 {
                let x = CGFloat(300 - i * 150)
                let y = CGFloat(i % 2 == 0 ? 150 : -150)
                path.addQuadCurve(to: CGPoint(x: x, y: y),
                                 control: CGPoint(x: x + 75, y: 0))
            }
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        return path
    }
    
    private func moveEnemyAlongPath(enemy: SKNode) {
        // Create path based on current map
        let path = getPathForCurrentMap(startingFrom: enemy.position)
        
        // Speed based on enemy type
        var duration: TimeInterval = 15.0
        
        if enemy.name?.contains("scout") == true {
            duration = 12.0  // Fastest
        } else if enemy.name?.contains("fighter") == true {
            duration = 15.0
        } else if enemy.name?.contains("bomber") == true {
            duration = 18.0
        } else if enemy.name?.contains("destroyer") == true {
            duration = 22.0  // Slow boss
        } else if enemy.name?.contains("titan") == true {
            duration = 40.0  // EXTREMELY SLOW ALIEN TITAN
        } else if enemy.name?.contains("swarm") == true {
            duration = 10.0  // Very fast swarm
        } else if enemy.name?.contains("shield") == true {
            duration = 20.0  // Slow tank
        } else if enemy.name?.contains("stealth") == true {
            duration = 11.0  // Fast stealth
        }
        
        let followPath = SKAction.follow(path, asOffset: false, orientToPath: true, duration: duration)
        
        // Track enemy velocity and path progress for targeting prediction
        var lastPosition = enemy.position
        let startTime = CACurrentMediaTime()
        let velocityTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard enemy.parent != nil else { return }
            
            let currentPosition = enemy.position
            let deltaX = currentPosition.x - lastPosition.x
            let deltaY = currentPosition.y - lastPosition.y
            let velocity = CGVector(dx: deltaX * 10, dy: deltaY * 10)  // Scale by 10 (1/0.1)
            
            // Calculate path progress (0.0 = start, 1.0 = end)
            let elapsedTime = CACurrentMediaTime() - startTime
            let progress = min(elapsedTime / duration, 1.0)
            
            enemy.userData?["velocity"] = velocity
            enemy.userData?["pathProgress"] = progress
            lastPosition = currentPosition
        }
        enemy.userData?["velocityTimer"] = velocityTimer
        
        // Add trail effect for moving enemies
        let trailTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard enemy.parent != nil else {
                return
            }
            
            // Create trail particle
            let trail = SKShapeNode(circleOfRadius: 3)
            trail.position = enemy.position
            trail.fillColor = .clear
            
            // Trail color based on enemy type
            if enemy.name?.contains("scout") == true {
                trail.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 0.5)
            } else if enemy.name?.contains("fighter") == true {
                trail.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.5)
            } else if enemy.name?.contains("bomber") == true {
                trail.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.5)
            } else if enemy.name?.contains("destroyer") == true {
                trail.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.5)
            } else {
                trail.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 0.5)
            }
            
            trail.lineWidth = 1
            trail.glowWidth = 2
            trail.zPosition = enemy.zPosition - 1
            self.effectsLayer.addChild(trail)
            
            // Fade and remove trail
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            trail.run(SKAction.sequence([fadeOut, remove]))
        }
        
        // Store timer reference to invalidate when enemy is removed
        enemy.userData?["trailTimer"] = trailTimer
        enemy.run(followPath) { [weak self] in
            guard let self = self else { return }
            // Enemy reached end of path - damage station
            if let timer = enemy.userData?["trailTimer"] as? Timer {
                timer.invalidate()
            }
            if let timer = enemy.userData?["velocityTimer"] as? Timer {
                timer.invalidate()
            }
            // Apply damage when enemy completes path
            self.stationHealth -= 1
            print("Station damaged! Health: \(self.stationHealth)/\(self.maxStationHealth)")
            
            // Play core hit sound and haptic
            SoundManager.shared.playSound(.coreHit)
            SoundManager.shared.playHaptic(.heavy)
            
            // MASSIVE EXPLOSION AND SCREEN SHAKE EFFECT
            self.createMassiveExplosion(at: enemy.position)
            self.shakeScreen()
            
            // Flash the screen red for damage feedback
            let damageFlash = SKSpriteNode(color: .red, size: self.size)
            damageFlash.position = CGPoint.zero
            damageFlash.zPosition = 900
            damageFlash.alpha = 0.4
            damageFlash.name = "damageFlash"
            self.uiLayer.addChild(damageFlash)
            
            // Ensure red flash is removed properly
            damageFlash.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ])) {
                // Clean up any stuck red screens
                self.uiLayer.enumerateChildNodes(withName: "damageFlash") { node, _ in
                    node.removeFromParent()
                }
            }
            
            self.updateHUD()
            enemy.removeFromParent()
            
            // Check game over
            if self.stationHealth <= 0 {
                self.gameOver()
            }
        }
    }
    
    private func updateEnemies(currentTime: TimeInterval) {
        // Move enemies along path
        // Note: Damage is already handled in moveEnemyAlongPath completion
        // This function is reserved for other enemy updates like status effects
    }
    
    private func updateTowers(currentTime: TimeInterval) {
        // Enhanced tower targeting and shooting with improved aiming
        towerLayer.children.forEach { tower in
            if tower.name?.starts(with: "tower_") == true {
                
                // Get tower type for enhanced targeting behavior
                let towerType = tower.userData?["type"] as? String ?? ""
                let towerLevel = tower.userData?["level"] as? Int ?? 1
                let towerRange = getTowerRange(type: towerType, level: towerLevel, tower: tower)
                
                // Find best target based on tower type and targeting mode
                if let target = findBestTarget(for: tower, type: towerType, range: towerRange) {
                    
                    // Fire rate check
                    let fireRate = getTowerFireRate(type: towerType, level: towerLevel, tower: tower)
                    let timeSinceLastFire = currentTime - (lastFireTime[tower] ?? 0)
                    let readyToFire = timeSinceLastFire > fireRate
                    
                    // Enhanced turret aiming with more aggressive tracking when ready to fire
                    let aimingSpeed = readyToFire ? 0.02 : 0.05  // Faster aiming when ready to fire
                    aimTurretAtTarget(tower: tower, target: target, towerType: towerType, urgentAiming: readyToFire, aimingSpeed: aimingSpeed)
                    
                    // Check if turret is properly aimed before firing
                    let isAimedCorrectly = checkTurretAiming(tower: tower, target: target, towerType: towerType)
                    
                    // Special check for laser towers - they need to be fully charged
                    let canFire: Bool
                    if towerType == "laser" {
                        let chargeProgress = Float(timeSinceLastFire / fireRate)
                        let fullyCharged = chargeProgress >= 1.0
                        if readyToFire && isAimedCorrectly && !fullyCharged {
                        }
                        canFire = readyToFire && isAimedCorrectly && fullyCharged  // Must be 100% charged
                    } else {
                        canFire = readyToFire && isAimedCorrectly
                    }
                    
                    if canFire {
                        fireProjectile(from: tower, to: target)
                        lastFireTime[tower] = currentTime
                    } else if towerType == "laser" {
                        // Add charging effect for laser towers, but only if aimed correctly
                        if isAimedCorrectly {
                            updateLaserChargingEffect(tower: tower, chargeProgress: Float(timeSinceLastFire / fireRate), level: towerLevel)
                        } else {
                            // Clear charging effect if not aimed correctly
                            tower.childNode(withName: "chargingEffect")?.removeFromParent()
                        }
                    }
                    
                    // Debug aiming status
                    if readyToFire && !isAimedCorrectly {
                    }
                } else {
                    // Clear charging effects when no targets
                    if towerType == "laser" {
                        tower.childNode(withName: "chargingEffect")?.removeFromParent()
                    }
                }
            }
        }
    }
    
    private func getTowerRange(type: String, level: Int, tower: SKNode? = nil) -> CGFloat {
        let baseRange: CGFloat
        switch type {
        case "machinegun": baseRange = 100  // Short range but fast fire
        case "laser": baseRange = 300  // VERY long range - lasers can shoot far!
        case "freeze": baseRange = 120  // Medium range for freeze effect
        case "plasma": baseRange = 180
        case "missile": baseRange = 220  // Missiles should have longest range
        case "kinetic": baseRange = 160
        case "tesla": baseRange = 140  // Tesla has shorter range but area effect
        default: baseRange = 180
        }
        
        let levelAdjustedRange = baseRange * (1.0 + CGFloat(level - 1) * 0.2)  // Better range scaling
        
        // Apply synergy bonuses if tower is provided
        if let tower = tower {
            let synergies = calculateTowerSynergies(for: tower)
            return levelAdjustedRange * CGFloat(synergies.rangeBonus)
        }
        
        return levelAdjustedRange
    }
    
    private func getTowerFireRate(type: String, level: Int, tower: SKNode? = nil) -> TimeInterval {
        let baseRate: TimeInterval
        switch type {
        case "machinegun": baseRate = 0.16  // Fast but balanced (6.25 shots/second - 50% reduction)
        case "laser": baseRate = 3.0  // Very slow charging - needs time to build up power
        case "freeze": baseRate = 0.5  // Constant freeze effect application
        case "plasma": baseRate = 1.2
        case "missile": baseRate = 2.0
        case "kinetic": baseRate = 0.8  // Reduced power: slower fire rate (was 0.6)
        case "tesla": baseRate = 1.5
        default: baseRate = 1.0
        }
        
        let levelAdjustedRate = baseRate / (1.0 + Double(level - 1) * 0.2)
        
        // Apply speed boost power-up multiplier (lower fire rate = faster firing)
        let speedMultiplier = Double(getPowerUpMultiplier(type: .speedBoost))
        
        // Apply synergy speed bonuses if tower is provided
        var synergySpeedMultiplier = 1.0
        if let tower = tower {
            let synergies = calculateTowerSynergies(for: tower)
            synergySpeedMultiplier = Double(synergies.speedBonus)
        }
        
        return levelAdjustedRate / (speedMultiplier * synergySpeedMultiplier)
    }
    
    private func findBestTarget(for tower: SKNode, type: String, range: CGFloat) -> SKNode? {
        var bestTarget: SKNode?
        var bestScore: CGFloat = -1
        
        // Get targeting mode based on tower type
        let targetingMode = getTargetingMode(for: type)
        
        var enemiesInRange = 0
        enemyLayer.children.forEach { enemy in
            if enemy.name?.starts(with: "enemy_") == true {
                // Skip stealthed enemies - they cannot be targeted while invisible
                let isStealthed = enemy.userData?["isStealthed"] as? Bool ?? false
                if isStealthed {
                    return  // Skip this enemy, can't target it
                }
                
                let dist = distance(from: tower.position, to: enemy.position)
                if dist <= range {
                    enemiesInRange += 1
                    let score = calculateTargetScore(for: enemy, distance: dist, mode: targetingMode)
                    if score > bestScore {
                        bestScore = score
                        bestTarget = enemy
                    }
                }
            }
        }
        
        if enemiesInRange > 0 {
        }
        
        return bestTarget
    }
    
    private func getTargetingMode(for towerType: String) -> TargetingMode {
        switch towerType {
        case "laser": return .nearest
        case "plasma": return .strongest
        case "missile": return .furthest
        case "kinetic": return .first
        case "tesla": return .weakest
        default: return .nearest
        }
    }
    
    enum TargetingMode {
        case nearest, furthest, strongest, weakest, first, last
    }
    
    private func calculateTargetScore(for enemy: SKNode, distance: CGFloat, mode: TargetingMode) -> CGFloat {
        let health = enemy.userData?["health"] as? CGFloat ?? 100
        let maxHealth = enemy.userData?["maxHealth"] as? CGFloat ?? 100
        let pathProgress = enemy.userData?["pathProgress"] as? CGFloat ?? 0
        
        switch mode {
        case .nearest:
            return 1000 - distance  // Closer = higher score
        case .furthest:
            return distance  // Further = higher score
        case .strongest:
            return maxHealth  // More max health = higher score
        case .weakest:
            return 1000 - health  // Less current health = higher score
        case .first:
            return pathProgress * 1000  // Further along path = higher score
        case .last:
            return (1 - pathProgress) * 1000  // Earlier in path = higher score
        }
    }
    
    private func aimTurretAtTarget(tower: SKNode, target: SKNode, towerType: String, urgentAiming: Bool = false, aimingSpeed: TimeInterval = 0.05) {
        // SIMPLE DIRECT AIMING - NO COMPLEX ANIMATIONS
        
        // Find turret
        var turret = tower.childNode(withName: "turret")
        if turret == nil {
            turret = tower.childNode(withName: "//turret")
        }
        
        // If still no turret, find ANY rotatable part
        if turret == nil {
            for child in tower.children {
                if child.name?.contains("turret") == true || 
                   child.name?.contains("barrel") == true ||
                   child.name?.contains("cannon") == true {
                    turret = child
                    break
                }
            }
        }
        
        guard let turret = turret else { 
            return 
        }
        
        
        // SIMPLE ANGLE CALCULATION
        let deltaX = target.position.x - tower.position.x
        let deltaY = target.position.y - tower.position.y
        let targetAngle = atan2(deltaY, deltaX) - .pi/2  // -90 degrees because turrets point up
        
        // SMOOTH INTERPOLATED ROTATION
        turret.removeAllActions()
        
        // Calculate shortest rotation path
        let currentAngle = turret.zRotation
        var angleDifference = targetAngle - currentAngle
        
        // Normalize angle difference to [-π, π]
        while angleDifference > .pi {
            angleDifference -= 2 * .pi
        }
        while angleDifference < -.pi {
            angleDifference += 2 * .pi
        }
        
        // Smooth rotation with lerp
        let rotationSpeed: CGFloat = 0.15  // 15% per frame for smooth rotation
        let newAngle = currentAngle + (angleDifference * rotationSpeed)
        turret.zRotation = newAngle
        
    }
    
    private func checkTurretAiming(tower: SKNode, target: SKNode, towerType: String) -> Bool {
        // Find turret
        var turret = tower.childNode(withName: "turret")
        if turret == nil {
            turret = tower.childNode(withName: "//turret")
        }
        
        // If no turret found, try to find any rotating part
        if turret == nil {
            for child in tower.children {
                if child.name?.contains("turret") == true || 
                   child.name?.contains("barrel") == true ||
                   child.name?.contains("cannon") == true {
                    turret = child
                    break
                }
            }
        }
        
        guard let turret = turret else { return false }
        
        // Calculate target angle with prediction
        var targetPosition = target.position
        
        // Add target prediction for faster projectiles
        if towerType == "laser" || towerType == "kinetic" {
            if let enemyVelocity = target.userData?["velocity"] as? CGVector {
                let projectileSpeed: CGFloat = towerType == "laser" ? 1000 : 400
                let timeToHit = distance(from: tower.position, to: target.position) / projectileSpeed
                targetPosition.x += enemyVelocity.dx * timeToHit
                targetPosition.y += enemyVelocity.dy * timeToHit
            }
        }
        
        // Calculate required angle
        let deltaX = targetPosition.x - tower.position.x
        let deltaY = targetPosition.y - tower.position.y
        let requiredAngle = atan2(deltaY, deltaX) - .pi/2  // Adjust for turret orientation
        
        // Get current turret angle
        let currentAngle = turret.zRotation
        
        // Calculate angular difference
        var angleDiff = requiredAngle - currentAngle
        
        // Normalize to [-π, π] range
        while angleDiff > .pi { angleDiff -= 2 * .pi }
        while angleDiff < -.pi { angleDiff += 2 * .pi }
        
        // Define aiming tolerance based on tower type (more reasonable values)
        let aimingTolerance: Float
        switch towerType {
        case "laser": aimingTolerance = 0.15  // ~8.5 degrees - reasonable for laser
        case "kinetic": aimingTolerance = 0.20  // ~11.5 degrees - ballistic weapons
        case "missile": aimingTolerance = 0.25  // ~14 degrees - guided missiles
        case "plasma": aimingTolerance = 0.18  // ~10 degrees - energy weapons
        case "tesla": aimingTolerance = 0.22  // ~12.5 degrees - area effect
        default: aimingTolerance = 0.20
        }
        
        // Check if within tolerance
        let isAimed = abs(Float(angleDiff)) <= aimingTolerance
        return isAimed
    }
    
    private func updateLaserChargingEffect(tower: SKNode, chargeProgress: Float, level: Int) {
        // Find or create charging effect
        var chargingEffect = tower.childNode(withName: "chargingEffect") as? SKShapeNode
        
        if chargingEffect == nil {
            // Create more dramatic charging effect
            let radius = CGFloat(25 + level * 8)
            let newEffect = SKShapeNode(circleOfRadius: radius)
            newEffect.name = "chargingEffect"
            newEffect.strokeColor = SKColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)  // Bright red
            newEffect.fillColor = SKColor(red: 1, green: 0, blue: 0, alpha: 0.1)  // Subtle red fill
            newEffect.lineWidth = 3
            newEffect.zPosition = tower.zPosition + 1  // Above tower
            tower.addChild(newEffect)
            chargingEffect = newEffect
        }
        
        // NO GLOW for charging effect
        let maxGlow = CGFloat(0)  // NO GLOW AT ALL
        let currentGlow = maxGlow * CGFloat(chargeProgress * chargeProgress)  // Exponential growth
        chargingEffect?.glowWidth = currentGlow
        
        // Color intensity changes with charge
        let intensity = CGFloat(chargeProgress)
        chargingEffect?.strokeColor = SKColor(red: 1, green: 0.2 * (1 - intensity), blue: 0.2 * (1 - intensity), alpha: 1)
        
        // Much more visible opacity
        chargingEffect?.alpha = CGFloat(chargeProgress * 0.9 + 0.1)  // Never fully invisible
        
        // Enhanced pulse effect
        if chargeProgress > 0.7 {
            let pulseIntensity = (chargeProgress - 0.7) / 0.3  // 0 to 1 over last 30%
            let pulseScale = 1.0 + sin(CACurrentMediaTime() * 25) * CGFloat(0.2 * pulseIntensity)
            chargingEffect?.setScale(pulseScale)
            
            // Add rapid pulsing when almost ready
            if chargeProgress > 0.9 {
                let rapidPulse = sin(CACurrentMediaTime() * 40) * 0.3 + 0.7
                chargingEffect?.alpha = CGFloat(rapidPulse)
            }
        } else {
            chargingEffect?.setScale(1.0)
        }
        
    }
    
    private func getTurretFirePosition(tower: SKNode) -> CGPoint {
        // Find turret component
        var turret = tower.childNode(withName: "turret")
        if turret == nil {
            turret = tower.childNode(withName: "//turret")
        }
        
        // If still no turret, find ANY rotatable part
        if turret == nil {
            for child in tower.children {
                if child.name?.contains("turret") == true || 
                   child.name?.contains("barrel") == true {
                    turret = child
                    break
                }
            }
        }
        
        if let turret = turret {
            // Calculate position at front of turret based on its rotation
            // Different turret lengths for different tower types
            var turretLength: CGFloat = 30
            
            // Check tower type for appropriate barrel length
            if tower.name?.contains("kinetic") == true {
                // Cannon has longer barrel based on level
                let level = tower.userData?["level"] as? Int ?? 1
                turretLength = CGFloat(20 + level * 4)  // Matches barrel length from creation
            } else if tower.name?.contains("laser") == true {
                turretLength = 25
            } else if tower.name?.contains("plasma") == true {
                turretLength = 28
            } else if tower.name?.contains("missile") == true {
                turretLength = 20
            }
            
            let angle = turret.zRotation + .pi/2  // Turret points up by default, so add 90 degrees
            
            let offsetX = cos(angle) * turretLength
            let offsetY = sin(angle) * turretLength
            
            return CGPoint(
                x: tower.position.x + offsetX,
                y: tower.position.y + offsetY
            )
        }
        
        // Fallback to tower center if no turret found
        return tower.position
    }
    
    private func fireProjectile(from tower: SKNode, to target: SKNode) {
        // Get tower level for enhanced visuals
        let towerLevel = tower.userData?["level"] as? Int ?? 1
        let towerType = tower.userData?["type"] as? String ?? "kinetic"
        
        // Play appropriate sound effect
        // SoundManager.shared.playTowerSound(type: towerType)
        
        // Create projectile based on tower type
        if tower.name?.contains("laser") == true {
            createLaserBeam(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("plasma") == true {
            createPlasmaProjectile(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("freeze") == true || towerType == "freeze" {
            // Freeze tower - no projectile, just apply slow effect
            applyFreezeEffect(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("missile") == true {
            createHomingMissile(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("kinetic") == true {
            createKineticShell(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("tesla") == true {
            createLightningBolt(from: tower, to: target, level: towerLevel)
        } else if tower.name?.contains("machinegun") == true || towerType == "machinegun" {
            // Special machine gun bullets - small, fast, and numerous
            createMachineGunBullet(from: tower, to: target, level: towerLevel)
        } else {
            // Default projectile
            createBasicProjectile(from: tower, to: target)
        }
    }
    
    private func createMachineGunBullet(from tower: SKNode, to target: SKNode, level: Int) {
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Alternate between left and right barrels
        let isLeftBarrel = Int.random(in: 0...1) == 0
        let barrelOffset: CGFloat = isLeftBarrel ? -4 : 4  // Match barrel spacing
        
        // Find turret to get its rotation
        var turret = tower.childNode(withName: "turret")
        if turret == nil {
            turret = tower.childNode(withName: "//turret")
        }
        let turretRotation = turret?.zRotation ?? 0
        
        // Adjust fire position based on barrel and turret rotation
        let adjustedFirePosition = CGPoint(
            x: firePosition.x + barrelOffset * cos(turretRotation + .pi/2),
            y: firePosition.y + barrelOffset * sin(turretRotation + .pi/2)
        )
        
        // Create very small bullet - like tracer rounds
        let bullet = SKShapeNode(ellipseOf: CGSize(width: 3, height: 8))  // Elongated bullet shape
        bullet.position = adjustedFirePosition
        bullet.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)  // Yellow tracer
        bullet.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)  // Orange outline
        bullet.lineWidth = 0.5
        bullet.glowWidth = 2  // Small glow for tracer effect
        bullet.blendMode = .add  // Bright additive blending
        bullet.alpha = 0.9
        bullet.name = "machinegun_bullet"
        bullet.zPosition = 100
        
        // Store tower reference for synergy calculations
        bullet.userData = NSMutableDictionary()
        bullet.userData?["originTower"] = tower
        
        // Rotate bullet to face target
        let deltaX = target.position.x - adjustedFirePosition.x
        let deltaY = target.position.y - adjustedFirePosition.y
        let bulletAngle = atan2(deltaY, deltaX) + .pi/2
        bullet.zRotation = bulletAngle
        
        // Add small muzzle flash at barrel tip
        let muzzleFlash = SKShapeNode(circleOfRadius: 3)
        muzzleFlash.position = adjustedFirePosition
        muzzleFlash.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        muzzleFlash.strokeColor = .clear
        muzzleFlash.blendMode = .add
        muzzleFlash.setScale(0.5)
        effectsLayer.addChild(muzzleFlash)
        
        muzzleFlash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.05),
                SKAction.fadeOut(withDuration: 0.05)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Add bullet to projectile layer
        projectileLayer.addChild(bullet)
        
        // Very fast bullet speed
        let distance = self.distance(from: adjustedFirePosition, to: target.position)
        let bulletSpeed = CGFloat(800 + level * 100)  // VERY fast bullets
        let duration = TimeInterval(distance / bulletSpeed)
        
        // Add slight spread for realistic machine gun effect
        let spread = CGFloat.random(in: -10...10)
        let finalTarget = CGPoint(
            x: target.position.x + spread,
            y: target.position.y + spread
        )
        
        // Create fading tracer trail
        let trail = SKShapeNode()
        let trailPath = CGMutablePath()
        trailPath.move(to: adjustedFirePosition)
        trailPath.addLine(to: finalTarget)
        trail.path = trailPath
        trail.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.3)
        trail.lineWidth = 1
        trail.blendMode = .add
        trail.zPosition = 99
        projectileLayer.addChild(trail)
        
        // Fade out trail quickly
        trail.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Move bullet to target
        bullet.run(SKAction.sequence([
            SKAction.move(to: finalTarget, duration: duration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            // Check if we hit the target
            if target.parent != nil {
                let hitDistance = self?.distance(from: bullet.position, to: target.position) ?? 1000
                if hitDistance < 20 {  // Hit radius
                    // Small impact spark
                    let impact = SKShapeNode(circleOfRadius: 2)
                    impact.position = bullet.position
                    impact.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
                    impact.strokeColor = .clear
                    impact.blendMode = .add
                    self?.effectsLayer.addChild(impact)
                    
                    impact.run(SKAction.sequence([
                        SKAction.scale(to: 2, duration: 0.1),
                        SKAction.fadeOut(withDuration: 0.1),
                        SKAction.removeFromParent()
                    ]))
                    
                    // Deal damage - very low per bullet (0.5 damage per shot) but many bullets
                    // Machine gun fires 12.5 shots/sec, so 6.25 DPS at level 1
                    // Cannon fires slower but does 4-8 damage per shot
                    let originTower = bullet.userData?["originTower"] as? SKNode
                    self?.dealDamageToTarget(target, damage: 1, type: "machinegun", fromTower: originTower)  // Always 1 damage regardless of level
                }
            }
        }
        
        // Play rapid fire sound (only occasionally to avoid overwhelming)
        if Int.random(in: 0...3) == 0 {  // Play sound for 25% of bullets
            SoundManager.shared.playSound(.cannonFire)  // Use cannon sound for machine gun
        }
    }
    
    private func createLaserBeam(from tower: SKNode, to target: SKNode, level: Int) {
        // Remove charging effect when firing
        tower.childNode(withName: "chargingEffect")?.removeFromParent()
        
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Create muzzle flash at turret
        let muzzleFlash = SKShapeNode(circleOfRadius: CGFloat(15 + level * 5))
        muzzleFlash.position = firePosition
        muzzleFlash.fillColor = .white
        muzzleFlash.strokeColor = .clear
        muzzleFlash.alpha = 0.8
        muzzleFlash.blendMode = .add
        muzzleFlash.setScale(0.1)
        effectsLayer.addChild(muzzleFlash)
        
        muzzleFlash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Instant laser beam effect
        let beam = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: firePosition)
        path.addLine(to: target.position)
        beam.path = path
        
        // ENHANCED LASER VISUALS - Multiple beams for higher levels
        let beamColor: SKColor
        let beamWidth: CGFloat
        let beamGlow: CGFloat
        let beamCount: Int
        
        switch level {
        case 3:
            beamColor = SKColor(red: 0, green: 0.8, blue: 1, alpha: 1)  // Cyan/blue beam
            beamWidth = 12
            beamGlow = 15  // Strong glow for level 3
            beamCount = 3  // Triple beam
        case 2:
            beamColor = SKColor(red: 0.2, green: 0.9, blue: 1, alpha: 1)  // Bright cyan
            beamWidth = 8
            beamGlow = 10  // Medium glow
            beamCount = 2  // Double beam
        default:
            beamColor = SKColor(red: 0.5, green: 1, blue: 1, alpha: 1)  // Light cyan
            beamWidth = 5
            beamGlow = 6  // Light glow
            beamCount = 1  // Single beam
        }
        
        // Create multiple beams for higher levels
        var beamsCreated: [SKShapeNode] = []
        for i in 0..<beamCount {
            let currentBeam = (i == 0) ? beam : SKShapeNode()
            if i > 0 {
                currentBeam.path = path
            }
            // Add all beams to the layer
            projectileLayer.addChild(currentBeam)
            
            // Slightly offset multiple beams
            let offset = CGFloat(i - beamCount/2) * 3
            let offsetPath = CGMutablePath()
            offsetPath.move(to: CGPoint(x: firePosition.x + offset, y: firePosition.y))
            offsetPath.addLine(to: CGPoint(x: target.position.x + offset, y: target.position.y))
            currentBeam.path = offsetPath
            
            currentBeam.strokeColor = beamColor
            currentBeam.lineWidth = beamWidth
            currentBeam.glowWidth = beamGlow
            currentBeam.blendMode = .add  // Additive blending for energy effect
            currentBeam.alpha = 0
            
            beamsCreated.append(currentBeam)
        }
        
        // Add enhanced impact spark at target - bigger for higher levels
        let sparkSize = CGFloat(6 + level * 4)
        let spark = SKShapeNode(circleOfRadius: sparkSize)
        spark.position = target.position
        spark.fillColor = beamColor
        spark.strokeColor = .white
        spark.lineWidth = 1
        spark.glowWidth = CGFloat(level * 2)
        spark.alpha = 0
        projectileLayer.addChild(spark)
        
        // Add additional impact effects for level 3
        if level >= 3 {
            for _ in 0..<5 {
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
                let distance = CGFloat.random(in: 10...25)
                particle.position = CGPoint(
                    x: target.position.x + cos(angle) * distance,
                    y: target.position.y + sin(angle) * distance
                )
                particle.fillColor = beamColor
                particle.strokeColor = .clear
                particle.alpha = 0.8
                projectileLayer.addChild(particle)
                
                // Particle explosion animation
                particle.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 0.1, duration: 0.3),
                        SKAction.fadeOut(withDuration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
        }
        
        // Add energy particles along the beam
        for _ in 0..<(5 * level) {
            let particleDelay = Double.random(in: 0...0.1)
            let particlePosition = CGFloat.random(in: 0...1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + particleDelay) { [weak self] in
                guard let self = self else { return }
                
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                let beamX = firePosition.x + (target.position.x - firePosition.x) * particlePosition
                let beamY = firePosition.y + (target.position.y - firePosition.y) * particlePosition
                particle.position = CGPoint(x: beamX, y: beamY)
                particle.fillColor = beamColor
                particle.strokeColor = .clear
                particle.blendMode = .add
                particle.alpha = 0
                particle.zPosition = 201
                self.projectileLayer.addChild(particle)
                
                // Particle animation
                let offset = CGFloat.random(in: -20...20)
                particle.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.05),
                        SKAction.moveBy(x: offset, y: offset, duration: 0.2),
                        SKAction.scale(to: 0.1, duration: 0.2)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
        }
        
        // Animate all beams simultaneously with pulsing effect
        for (index, beam) in beamsCreated.enumerated() {
            let delay = Double(index) * 0.02
            beam.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.02),
                    SKAction.customAction(withDuration: 0.15) { node, elapsedTime in
                        if let shapeNode = node as? SKShapeNode {
                            // Pulsing width effect
                            let pulse = sin(elapsedTime * 20) * 2
                            shapeNode.lineWidth = beamWidth + pulse
                        }
                    }
                ]),
                SKAction.fadeOut(withDuration: 0.08),
                SKAction.removeFromParent()
            ]))
        }
        
        // Enhanced spark effect at impact point
        spark.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.02),
                SKAction.scale(to: 2.0, duration: 0.1),
                SKAction.rotate(byAngle: .pi * 2, duration: 0.2)
            ]),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.scale(to: 0.5, duration: 0.1)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Play laser sound
        SoundManager.shared.playSound(.laserFire)
        
        // Deal instant damage - HIGH damage to compensate for slow charging
        dealDamageToTarget(target, damage: 15 + (level * 5), type: "laser", fromTower: tower)  // Laser: 20/25/30 damage for levels 1/2/3
    }
    
    private func createPlasmaProjectile(from tower: SKNode, to target: SKNode, level: Int) {
        // Play plasma sound
        SoundManager.shared.playSound(.plasmaFire)
        
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Calculate predictive targeting - where enemy will be when projectile arrives
        let speed: CGFloat = 400 + CGFloat(level * 50)
        let distance = self.distance(from: firePosition, to: target.position)
        let flightTime = TimeInterval(distance / speed)
        
        // Get enemy velocity and predict future position
        var predictedPosition = target.position
        if let velocity = target.userData?["velocity"] as? CGVector {
            predictedPosition = CGPoint(
                x: target.position.x + velocity.dx * CGFloat(flightTime),
                y: target.position.y + velocity.dy * CGFloat(flightTime)
            )
        }
        
        // Plasma orb with trail
        let plasma = SKShapeNode(circleOfRadius: CGFloat(5 + level))
        plasma.position = firePosition
        plasma.fillColor = SKColor(red: 0.8, green: 0.2, blue: 1, alpha: 1)
        plasma.strokeColor = .white
        plasma.lineWidth = 2
        plasma.glowWidth = CGFloat(5 + level * 2)  // Reduced glow
        plasma.name = "plasma"
        
        // Add inner core
        let core = SKShapeNode(circleOfRadius: CGFloat(2 + level/2))
        core.fillColor = .white
        core.strokeColor = .clear
        core.glowWidth = 5
        plasma.addChild(core)
        
        // Pulsing effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        plasma.run(SKAction.repeatForever(pulse))
        
        projectileLayer.addChild(plasma)
        
        // Recalculate with predicted position
        let finalDistance = self.distance(from: firePosition, to: predictedPosition)
        let finalDuration = TimeInterval(finalDistance / speed)
        
        // Move with arc to predicted position
        let midPoint = CGPoint(
            x: (firePosition.x + predictedPosition.x) / 2,
            y: max(firePosition.y, predictedPosition.y) + 30
        )
        
        let path = CGMutablePath()
        path.move(to: firePosition)
        path.addQuadCurve(to: predictedPosition, control: midPoint)
        
        let followPath = SKAction.follow(path, asOffset: false, orientToPath: false, duration: finalDuration)
        
        // Store target reference for collision detection during flight
        plasma.userData = NSMutableDictionary()
        plasma.userData?["target"] = target
        plasma.userData?["damage"] = 2 + (2 * level)  // Buffed: 4/6/8 damage
        plasma.userData?["level"] = level
        
        plasma.run(SKAction.sequence([
            followPath,
            SKAction.removeFromParent()
        ])) { [weak self] in
            // Check if target is still near impact point for damage
            if target.parent != nil {
                let impactDistance = self?.distance(from: plasma.position, to: target.position) ?? 1000
                if impactDistance < 25 {  // Hit radius
                    self?.dealDamageToTarget(target, damage: 2 + (2 * level), type: "plasma")  // Buffed: 4/6/8 damage
                }
            }
            self?.createExplosion(at: predictedPosition, type: "plasma", level: level)
        }
    }
    
    private func createHomingMissile(from tower: SKNode, to target: SKNode, level: Int) {
        // Play missile sound
        SoundManager.shared.playSound(.missileLaunch)
        
        // Fire multiple missiles based on level
        let missileCount = level  // Level 1 = 1 missile, Level 2 = 2 missiles, Level 3 = 3 missiles
        
        for i in 0..<missileCount {
            // Delay each missile slightly for barrage effect
            let delay = Double(i) * 0.15
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    self?.launchSingleMissile(from: tower, to: target, level: level, offset: i)
                }
            ]))
        }
    }
    
    private func launchSingleMissile(from tower: SKNode, to target: SKNode, level: Int, offset: Int) {
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Create realistic missile
        let missile = SKNode()
        missile.position = firePosition
        missile.name = "missile"
        
        // FIXED: Missile now oriented horizontally with warhead at front (right) and exhaust at back (left)
        // Missile body (horizontal)
        let body = SKShapeNode(rect: CGRect(x: -10, y: -2, width: 20, height: 4))
        body.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        body.strokeColor = .orange
        body.lineWidth = 1
        missile.addChild(body)
        
        // Warhead (pointed front at right)
        let warheadPath = CGMutablePath()
        warheadPath.move(to: CGPoint(x: 10, y: -2))
        warheadPath.addLine(to: CGPoint(x: 15, y: 0))
        warheadPath.addLine(to: CGPoint(x: 10, y: 2))
        warheadPath.closeSubpath()
        let warhead = SKShapeNode(path: warheadPath)
        warhead.fillColor = .red
        warhead.strokeColor = .orange
        warhead.lineWidth = 0.5
        warhead.glowWidth = CGFloat(2 + level)
        missile.addChild(warhead)
        
        // Fins (on top and bottom)
        for y in [-3, 3] {
            let fin = SKShapeNode(rect: CGRect(x: -10, y: y, width: 5, height: 2))
            fin.fillColor = SKColor.darkGray
            fin.strokeColor = .gray
            fin.lineWidth = 0.5
            missile.addChild(fin)
        }
        
        // Exhaust flame (at back/left)
        let exhaust = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
        exhaust.fillColor = .orange
        exhaust.strokeColor = .yellow
        exhaust.lineWidth = 1
        exhaust.glowWidth = CGFloat(4 + level)  // Reduced glow
        exhaust.position = CGPoint(x: -13, y: 0)
        missile.addChild(exhaust)
        
        // Exhaust animation
        exhaust.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.05),
                SKAction.scale(to: 0.7, duration: 0.05)
            ])
        ))
        
        projectileLayer.addChild(missile)
        
        // Store target and parameters
        missile.userData = [
            "target": target,
            "speed": 100.0 + Double(level * 20),
            "turnRate": 3.0 + Double(level),
            "damage": 3 * level
        ]
        
        // Initial orientation - missile points directly at target (no offset needed)
        let angle = atan2(target.position.y - missile.position.y,
                         target.position.x - missile.position.x)
        missile.zRotation = angle
        
        // Start homing behavior
        startMissileTracking(missile)
    }
    
    private func startMissileTracking(_ missile: SKNode) {
        missile.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self, weak missile] in
                    guard let self = self,
                          let missile = missile,
                          let target = missile.userData?["target"] as? SKNode,
                          target.parent != nil else {
                        missile?.removeFromParent()
                        return
                    }
                    
                    let speed = missile.userData?["speed"] as? Double ?? 100.0
                    let turnRate = missile.userData?["turnRate"] as? Double ?? 3.0
                    
                    // Calculate angle to target
                    let targetAngle = atan2(target.position.y - missile.position.y,
                                          target.position.x - missile.position.x)
                    
                    // Smooth rotation (no offset needed since missile is horizontal)
                    let currentAngle = missile.zRotation
                    var angleDiff = targetAngle - currentAngle
                    
                    // Normalize angle
                    while angleDiff > .pi { angleDiff -= 2 * .pi }
                    while angleDiff < -.pi { angleDiff += 2 * .pi }
                    
                    // Apply turn limit
                    let maxTurn = CGFloat(turnRate) * 0.016
                    let actualTurn = max(-maxTurn, min(maxTurn, angleDiff))
                    missile.zRotation += actualTurn
                    
                    // Move forward (missile points in direction of rotation, no offset)
                    let velocity = CGVector(
                        dx: cos(missile.zRotation) * CGFloat(speed) * 0.016,
                        dy: sin(missile.zRotation) * CGFloat(speed) * 0.016
                    )
                    missile.position.x += velocity.dx
                    missile.position.y += velocity.dy
                    
                    // Check impact
                    let distance = hypot(target.position.x - missile.position.x,
                                       target.position.y - missile.position.y)
                    if distance < 15 {
                        let damage = missile.userData?["damage"] as? Int ?? 3
                        missile.removeAllActions()
                        missile.removeFromParent()
                        self.dealDamageToTarget(target, damage: damage, type: "missile")
                        self.createExplosion(at: target.position, type: "missile", level: damage/3)
                    }
                },
                SKAction.wait(forDuration: 0.016)
            ])
        ), withKey: "missileTracking")
    }
    
    private func createKineticShell(from tower: SKNode, to target: SKNode, level: Int) {
        // Play cannon sound
        SoundManager.shared.playSound(.cannonFire)
        
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Always fire single shell (dual barrels are just visual)
        let shellCount = 1
        
        // Only create one shell
        if shellCount > 0 {
            // let i = 0  // unused variable
            // Create a realistic shell/bullet shape
            let shell = SKNode()
            shell.position = firePosition
            shell.name = "kineticShell"
            shell.zPosition = 200
            
            // BIG CANNON SHELL - much larger than machine gun bullets
            let shellSize = CGFloat(8 + level * 2)  // Size 10/12/14 for levels 1/2/3
            let bullet = SKShapeNode(ellipseOf: CGSize(width: shellSize, height: shellSize * 1.5))  // Elongated shell
            bullet.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.3, alpha: 1.0)  // Metallic brass color
            bullet.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.4, alpha: 1.0)  // Lighter edge
            bullet.lineWidth = 1.5
            bullet.glowWidth = 3  // Some glow for power effect
            shell.addChild(bullet)
            
            // Add metallic shine on the tip
            let shine = SKShapeNode(ellipseOf: CGSize(width: shellSize * 0.4, height: shellSize * 0.6))
            shine.position = CGPoint(x: 0, y: shellSize * 0.3)
            shine.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.6, alpha: 0.6)
            shine.strokeColor = .clear
            shine.blendMode = .add
            bullet.addChild(shine)
            
            // Rotate the shell to point toward target
            let deltaX = target.position.x - firePosition.x
            let deltaY = target.position.y - firePosition.y
            let shellAngle = atan2(deltaY, deltaX) + .pi/2
            shell.zRotation = shellAngle
            
            // Store damage data for cannon - INCREASED for better balance
            shell.userData = NSMutableDictionary()
            // Cannon damage: higher base damage for better DPS
            let kineticDamage = 4 + (level * 2)  // 6/8/10 damage for levels 1/2/3
            shell.userData?["damage"] = kineticDamage
            shell.userData?["towerType"] = "kinetic"
            
            projectileLayer.addChild(shell)
            
            // Calculate predictive targeting for kinetic shells
            let speed: CGFloat = 400  // Fast projectile
            let distance = sqrt(pow(target.position.x - firePosition.x, 2) + pow(target.position.y - firePosition.y, 2))
            let flightTime = TimeInterval(distance / speed)
            
            // Get enemy velocity and predict future position
            var predictedPosition = target.position
            if let velocity = target.userData?["velocity"] as? CGVector {
                predictedPosition = CGPoint(
                    x: target.position.x + velocity.dx * CGFloat(flightTime),
                    y: target.position.y + velocity.dy * CGFloat(flightTime)
                )
            }
            
            // Calculate trajectory angle to predicted position
            let baseAngle = atan2(predictedPosition.y - firePosition.y, predictedPosition.x - firePosition.x)
            
            // Set initial rotation to point at predicted target
            shell.zRotation = baseAngle
            
            // Recalculate with predicted position
            let finalDistance = sqrt(pow(predictedPosition.x - firePosition.x, 2) + pow(predictedPosition.y - firePosition.y, 2))
            let duration = TimeInterval(finalDistance / speed)
            
            // Add slight arc to trajectory
            let midPoint = CGPoint(
                x: (firePosition.x + predictedPosition.x) / 2,
                y: (firePosition.y + predictedPosition.y) / 2 + 20
            )
            
            let path = CGMutablePath()
            path.move(to: firePosition)
            path.addQuadCurve(to: predictedPosition, control: midPoint)
            
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: true, duration: duration)
            let fadeAction = SKAction.fadeOut(withDuration: duration * 0.8)
            
            shell.run(SKAction.sequence([
                SKAction.group([moveAction, fadeAction]),
                SKAction.run { [weak self] in
                    // Impact effect
                    self?.createKineticImpact(at: shell.position, level: level)
                    
                    // Damage nearby enemies in the correct layer
                    self?.enemyLayer.enumerateChildNodes(withName: "enemy_*") { enemy, _ in
                        let distance = hypot(enemy.position.x - shell.position.x, enemy.position.y - shell.position.y)
                        if distance < 40 {  // Small splash radius for kinetic shells
                            let damage = shell.userData?["damage"] as? Int ?? 25
                            self?.dealDamageToTarget(enemy, damage: damage, type: "kinetic")
                        }
                    }
                },
                SKAction.removeFromParent()
            ]))
            
            // No delay needed for single shell
        }
    }
    
    private func createKineticImpact(at position: CGPoint, level: Int) {
        // Muzzle flash effect at impact
        let flash = SKShapeNode(circleOfRadius: CGFloat(15 + level * 5))
        flash.position = position
        flash.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.8)
        flash.strokeColor = SKColor.white
        flash.lineWidth = 2
        flash.glowWidth = CGFloat(8 + level * 2)
        flash.blendMode = .add
        flash.zPosition = 600
        effectsLayer.addChild(flash)
        
        // Debris particles
        for _ in 0..<(5 + level * 2) {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            debris.position = position
            debris.fillColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0)
            debris.strokeColor = .clear
            debris.zPosition = 500
            effectsLayer.addChild(debris)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 20...60)
            let moveAction = SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            debris.run(SKAction.sequence([SKAction.group([moveAction, fadeAction]), SKAction.removeFromParent()]))
        }
        
        // Flash fade out
        flash.run(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.group([
                SKAction.scale(to: 0.1, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createLightningBolt(from tower: SKNode, to target: SKNode, level: Int) {
        // Play tesla sound
        SoundManager.shared.playSound(.teslaZap)
        
        // Get firing position from front of turret
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Create more complex jagged lightning path with branches
        let mainPath = createLightningPath(from: firePosition, to: target.position, complexity: 8 + level * 2)
        
        // Create bright white core
        let coreBolt = SKShapeNode(path: mainPath)
        coreBolt.strokeColor = .white
        coreBolt.lineWidth = CGFloat(1.0 + Double(level) * 0.5)
        coreBolt.glowWidth = 0
        coreBolt.alpha = 0
        coreBolt.blendMode = .add
        projectileLayer.addChild(coreBolt)
        
        // Main bolt with electric blue color
        let bolt = SKShapeNode(path: mainPath)
        bolt.strokeColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
        bolt.lineWidth = CGFloat(3 + level)
        bolt.glowWidth = CGFloat(15 + level * 5)
        bolt.alpha = 0
        bolt.blendMode = .add
        projectileLayer.addChild(bolt)
        
        // Outer glow layer
        let glowBolt = SKShapeNode(path: mainPath)
        glowBolt.strokeColor = SKColor(red: 0.6, green: 0.9, blue: 1.0, alpha: 0.5)
        glowBolt.lineWidth = CGFloat(6 + level * 2)
        glowBolt.glowWidth = CGFloat(20 + level * 8)
        glowBolt.alpha = 0
        glowBolt.blendMode = .add
        projectileLayer.addChild(glowBolt)
        
        // Secondary branching bolts
        for _ in 0..<(level * 2) {
            let branchPath = createLightningPath(from: firePosition, to: target.position, complexity: 4 + level)
            let subBolt = SKShapeNode(path: branchPath)
            subBolt.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 1, alpha: 0.5)
            subBolt.lineWidth = 1
            subBolt.glowWidth = 3
            subBolt.alpha = 0
            projectileLayer.addChild(subBolt)
            
            subBolt.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...0.1)),
                SKAction.fadeIn(withDuration: 0.02),
                SKAction.wait(forDuration: 0.05),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))
        }
        
        // Create impact effect at target
        let impactFlash = SKShapeNode(circleOfRadius: CGFloat(20 + level * 5))
        impactFlash.position = target.position
        impactFlash.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.8)
        impactFlash.strokeColor = .clear
        impactFlash.blendMode = .add
        impactFlash.setScale(0.1)
        effectsLayer.addChild(impactFlash)
        
        // Animate all lightning elements
        let fadeInTime = 0.01
        let holdTime = 0.05 + Double(level) * 0.02
        let fadeOutTime = 0.1
        
        // Animate core
        coreBolt.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.wait(forDuration: holdTime),
            SKAction.fadeOut(withDuration: fadeOutTime * 0.5),
            SKAction.removeFromParent()
        ]))
        
        // Animate main bolt
        bolt.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.wait(forDuration: holdTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.removeFromParent()
        ]))
        
        // Animate glow
        glowBolt.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: fadeInTime),
            SKAction.wait(forDuration: holdTime),
            SKAction.fadeOut(withDuration: fadeOutTime * 1.5),
            SKAction.removeFromParent()
        ]))
        
        // Animate impact
        impactFlash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Chain damage to nearby enemies
        dealDamageToTarget(target, damage: 2 * level, type: "tesla", fromTower: tower)
        
        if level >= 2 {
            // Chain lightning
            enemyLayer.children.forEach { enemy in
                if enemy != target {
                    let dist = distance(from: target.position, to: enemy.position)
                    if dist < CGFloat(50 * level) {
                        createLightningChain(from: target.position, to: enemy.position)
                        dealDamageToTarget(enemy, damage: level, type: "tesla", fromTower: tower)
                    }
                }
            }
        }
    }
    
    private func createLightningPath(from start: CGPoint, to end: CGPoint, complexity: Int) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: start)
        
        var points: [CGPoint] = [start]
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        // Generate intermediate points with random offsets
        for i in 1..<complexity {
            let progress = CGFloat(i) / CGFloat(complexity)
            let baseX = start.x + dx * progress
            let baseY = start.y + dy * progress
            
            // Larger offset for middle points, smaller for edges
            let offsetScale = sin(progress * .pi) // Peak at middle
            let maxOffset: CGFloat = 25 * offsetScale
            
            let point = CGPoint(
                x: baseX + CGFloat.random(in: -maxOffset...maxOffset),
                y: baseY + CGFloat.random(in: -maxOffset...maxOffset)
            )
            points.append(point)
            path.addLine(to: point)
        }
        
        path.addLine(to: end)
        return path
    }
    
    private func applyFreezeEffect(from tower: SKNode, to target: SKNode, level: Int) {
        // Freeze tower - apply 75% slow effect, no damage
        
        // Visual freeze beam effect
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Create ice crystal beam effect
        let beamPath = CGMutablePath()
        beamPath.move(to: firePosition)
        beamPath.addLine(to: target.position)
        
        let freezeBeam = SKShapeNode(path: beamPath)
        freezeBeam.strokeColor = SKColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 0.8)
        freezeBeam.lineWidth = CGFloat(2 + level)
        freezeBeam.glowWidth = CGFloat(10 + level * 3)
        freezeBeam.alpha = 0
        freezeBeam.blendMode = .add
        projectileLayer.addChild(freezeBeam)
        
        // Animate the freeze beam
        freezeBeam.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
        
        // Apply slow effect to target - 75% slow (25% of normal speed)
        let slowMultiplier: CGFloat = 0.25
        let slowDuration: TimeInterval = 1.0 + TimeInterval(level) * 0.5  // Longer slow at higher levels
        
        // Store original speed if not already slowed
        if target.userData?["originalSpeed"] == nil {
            let currentSpeed = target.userData?["speed"] as? CGFloat ?? 100
            target.userData?["originalSpeed"] = currentSpeed
        }
        
        // Apply the slow effect
        let originalSpeed = target.userData?["originalSpeed"] as? CGFloat ?? 100
        target.userData?["speed"] = originalSpeed * slowMultiplier
        target.userData?["freezeEndTime"] = CACurrentMediaTime() + slowDuration
        
        // Visual ice effect on enemy
        if target.childNode(withName: "freezeEffect") == nil {
            let iceEffect = SKShapeNode(circleOfRadius: 15)
            iceEffect.fillColor = SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.3)
            iceEffect.strokeColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.6)
            iceEffect.lineWidth = 2
            iceEffect.name = "freezeEffect"
            iceEffect.zPosition = 10
            target.addChild(iceEffect)
            
            // Add ice crystal particles
            for _ in 0..<3 {
                let crystal = SKShapeNode(circleOfRadius: 2)
                crystal.fillColor = .white
                crystal.strokeColor = .clear
                crystal.position = CGPoint(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -10...10)
                )
                crystal.alpha = 0.8
                iceEffect.addChild(crystal)
                
                // Floating animation
                let float = SKAction.sequence([
                    SKAction.moveBy(x: 0, y: 5, duration: 1.0),
                    SKAction.moveBy(x: 0, y: -5, duration: 1.0)
                ])
                crystal.run(SKAction.repeatForever(float))
            }
        }
        
        // Schedule removal of freeze effect
        DispatchQueue.main.asyncAfter(deadline: .now() + slowDuration) { [weak target] in
            if let target = target {
                // Check if freeze effect has expired
                if let freezeEndTime = target.userData?["freezeEndTime"] as? TimeInterval {
                    if CACurrentMediaTime() >= freezeEndTime {
                        // Restore original speed
                        if let originalSpeed = target.userData?["originalSpeed"] as? CGFloat {
                            target.userData?["speed"] = originalSpeed
                            target.userData?["originalSpeed"] = nil
                            target.userData?["freezeEndTime"] = nil
                        }
                        // Remove visual effect
                        target.childNode(withName: "freezeEffect")?.removeFromParent()
                    }
                }
            }
        }
    }
    
    private func createLightningChain(from: CGPoint, to: CGPoint) {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: CGPoint(x: (from.x + to.x)/2 + CGFloat.random(in: -10...10),
                                y: (from.y + to.y)/2 + CGFloat.random(in: -10...10)))
        path.addLine(to: to)
        
        let chain = SKShapeNode(path: path)
        chain.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.8)
        chain.lineWidth = 1
        chain.glowWidth = 4
        projectileLayer.addChild(chain)
        
        chain.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.02),
            SKAction.wait(forDuration: 0.08),
            SKAction.fadeOut(withDuration: 0.05),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createBasicProjectile(from tower: SKNode, to target: SKNode) {
        // Get tower level for enhanced projectiles
        let level = tower.userData?["level"] as? Int ?? 1
        let towerType = tower.userData?["type"] as? String ?? "unknown"
        
        // Enhanced projectiles based on tower type and level
        switch towerType {
        case "cannon":
            createEnhancedCannonProjectile(from: tower, to: target, level: level)
        case "plasma":
            createEnhancedPlasmaProjectile(from: tower, to: target, level: level)
        case "missile":
            createEnhancedMissileProjectile(from: tower, to: target, level: level)
        default:
            // Basic projectile fallback
            createStandardProjectile(from: tower, to: target, level: level)
        }
    }
    
    private func createStandardProjectile(from tower: SKNode, to target: SKNode, level: Int) {
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Size and glow increase with level
        let projectileSize = CGFloat(4 + level * 2)
        let projectile = SKShapeNode(circleOfRadius: projectileSize)
        projectile.position = firePosition
        projectile.fillColor = .white
        projectile.strokeColor = .cyan
        projectile.lineWidth = CGFloat(1 + level)
        projectile.glowWidth = CGFloat(4 + level * 2)
        
        projectileLayer.addChild(projectile)
        
        let distance = self.distance(from: tower.position, to: target.position)
        let speed = CGFloat(500 + level * 50)
        let duration = TimeInterval(distance / speed) // Faster projectiles at higher levels
        
        projectile.run(SKAction.sequence([
            SKAction.move(to: target.position, duration: duration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.dealDamageToTarget(target, damage: 1 + level, type: "basic")
        }
    }
    
    private func createEnhancedCannonProjectile(from tower: SKNode, to target: SKNode, level: Int) {
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Cannon projectiles get MUCH bigger and more explosive
        let projectileSize = CGFloat(10 + level * 4)  // Size 14/18/22 for levels 1/2/3
        let projectile = SKShapeNode(ellipseOf: CGSize(width: projectileSize, height: projectileSize * 1.5))
        projectile.position = firePosition
        
        switch level {
        case 3:
            projectile.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Explosive orange
            projectile.strokeColor = SKColor.yellow
            projectile.glowWidth = 8
        case 2:
            projectile.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0) // Orange
            projectile.strokeColor = SKColor.orange
            projectile.glowWidth = 6
        default:
            projectile.fillColor = SKColor(red: 0.6, green: 0.3, blue: 0.0, alpha: 1.0) // Brown
            projectile.strokeColor = SKColor.red
            projectile.glowWidth = 4
        }
        projectile.lineWidth = CGFloat(2 + level)
        projectile.blendMode = .add
        
        // Add trail effect for higher levels
        if level >= 2 {
            let trail = SKShapeNode(ellipseOf: CGSize(width: projectileSize * 0.5, height: projectileSize * 0.8))
            trail.fillColor = projectile.fillColor.withAlphaComponent(0.3)
            trail.strokeColor = .clear
            trail.position = CGPoint(x: 0, y: -projectileSize)
            projectile.addChild(trail)
        }
        
        projectileLayer.addChild(projectile)
        
        let distance = self.distance(from: tower.position, to: target.position)
        let duration = TimeInterval(distance / 400) // Cannon shots are slower but powerful
        
        // Rotate projectile during flight
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 4, duration: duration)
        projectile.run(rotateAction)
        
        projectile.run(SKAction.sequence([
            SKAction.move(to: target.position, duration: duration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            // Enhanced impact explosion for cannons - INCREASED damage to match kinetic
            self?.createCannonExplosion(at: target.position, level: level)
            self?.dealDamageToTarget(target, damage: 4 + level * 2, type: "cannon")  // 6/8/10 damage
        }
    }
    
    private func createEnhancedPlasmaProjectile(from tower: SKNode, to target: SKNode, level: Int) {
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Plasma projectiles are energy orbs
        let projectileSize = CGFloat(5 + level * 2)
        let projectile = SKShapeNode(circleOfRadius: projectileSize)
        projectile.position = firePosition
        
        switch level {
        case 3:
            projectile.fillColor = SKColor(red: 1.0, green: 0.2, blue: 1.0, alpha: 0.8) // Bright magenta
            projectile.strokeColor = SKColor.white
            projectile.glowWidth = 10
        case 2:
            projectile.fillColor = SKColor(red: 0.8, green: 0.0, blue: 0.8, alpha: 0.8) // Purple
            projectile.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0)
            projectile.glowWidth = 8
        default:
            projectile.fillColor = SKColor(red: 0.6, green: 0.0, blue: 0.6, alpha: 0.8) // Dark purple
            projectile.strokeColor = SKColor.magenta
            projectile.glowWidth = 6
        }
        projectile.lineWidth = CGFloat(1 + level)
        projectile.blendMode = .add
        
        // Add plasma energy effect
        let energyRing = SKShapeNode(circleOfRadius: projectileSize + CGFloat(level))
        energyRing.fillColor = .clear
        energyRing.strokeColor = projectile.fillColor.withAlphaComponent(0.3)
        energyRing.lineWidth = 1
        energyRing.glowWidth = CGFloat(level * 2)
        projectile.addChild(energyRing)
        
        // Pulsing energy
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        energyRing.run(SKAction.repeatForever(pulse))
        
        projectileLayer.addChild(projectile)
        
        let distance = self.distance(from: tower.position, to: target.position)
        let speed = CGFloat(600 + level * 100)
        let duration = TimeInterval(distance / speed) // Fast plasma bolts
        
        projectile.run(SKAction.sequence([
            SKAction.move(to: target.position, duration: duration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            // Plasma energy discharge
            self?.createPlasmaDischarge(at: target.position, level: level)
            self?.dealDamageToTarget(target, damage: 1 + level, type: "plasma")
        }
    }
    
    private func createEnhancedMissileProjectile(from tower: SKNode, to target: SKNode, level: Int) {
        let firePosition = getTurretFirePosition(tower: tower)
        
        // Missiles are elongated and have exhaust trails
        let projectileWidth = CGFloat(4 + level)
        let projectileHeight = CGFloat(12 + level * 2)
        let projectile = SKShapeNode(ellipseOf: CGSize(width: projectileWidth, height: projectileHeight))
        projectile.position = firePosition
        projectile.fillColor = SKColor.gray
        projectile.strokeColor = SKColor.white
        projectile.lineWidth = 1
        
        // Exhaust trail gets more intense with level
        let exhaustTrail = SKShapeNode(ellipseOf: CGSize(width: projectileWidth * 0.5, height: projectileHeight * CGFloat(1 + level)))
        exhaustTrail.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.6)
        exhaustTrail.strokeColor = .clear
        exhaustTrail.blendMode = .add
        exhaustTrail.position = CGPoint(x: 0, y: -projectileHeight)
        projectile.addChild(exhaustTrail)
        
        projectileLayer.addChild(projectile)
        
        let distance = self.distance(from: tower.position, to: target.position)
        let speed = CGFloat(550 + level * 50)
        let duration = TimeInterval(distance / speed)
        
        // Point missile towards target
        let angle = atan2(target.position.y - firePosition.y, target.position.x - firePosition.x)
        projectile.zRotation = angle + CGFloat.pi / 2
        
        projectile.run(SKAction.sequence([
            SKAction.move(to: target.position, duration: duration),
            SKAction.removeFromParent()
        ])) { [weak self] in
            // Missile explosion
            self?.createMissileExplosion(at: target.position, level: level)
            self?.dealDamageToTarget(target, damage: 3 + level * 2, type: "missile")
        }
    }
    
    private func createCannonExplosion(at position: CGPoint, level: Int) {
        let explosionSize = CGFloat(20 + level * 10)
        let explosion = SKShapeNode(circleOfRadius: explosionSize)
        explosion.position = position
        explosion.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
        explosion.strokeColor = SKColor.yellow
        explosion.lineWidth = 3
        explosion.glowWidth = CGFloat(level * 3)
        explosion.blendMode = .add
        effectsLayer.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createPlasmaDischarge(at position: CGPoint, level: Int) {
        for _ in 0..<(3 + level) {
            let arc = SKShapeNode()
            let arcPath = CGMutablePath()
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let length = CGFloat.random(in: 15...30)
            arcPath.move(to: position)
            arcPath.addLine(to: CGPoint(x: position.x + cos(angle) * length, y: position.y + sin(angle) * length))
            arc.path = arcPath
            arc.strokeColor = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.8)
            arc.lineWidth = CGFloat(level * 2)
            arc.glowWidth = CGFloat(level * 2)
            arc.blendMode = .add
            effectsLayer.addChild(arc)
            
            arc.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func createMissileExplosion(at position: CGPoint, level: Int) {
        let explosionSize = CGFloat(25 + level * 12)
        let explosion = SKShapeNode(circleOfRadius: explosionSize)
        explosion.position = position
        explosion.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.9)
        explosion.strokeColor = SKColor.red
        explosion.lineWidth = 4
        explosion.glowWidth = CGFloat(level * 4)
        explosion.blendMode = .add
        effectsLayer.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func dealDamageToTarget(_ target: SKNode?, damage: Int, type: String, fromTower tower: SKNode? = nil) {
        guard let target = target, target.parent != nil else { return }
        
        // Apply damage power-up multiplier
        let damageMultiplier = getPowerUpMultiplier(type: .damageBoost)
        
        // Apply achievement damage bonus
        let achievementBonuses = getActiveAchievementBonuses()
        let achievementDamageBonus = achievementBonuses["damageBonus"] ?? 1.0
        
        // Apply tower synergy damage bonuses
        var synergyDamageMultiplier: Float = 1.0
        var synergyArmorPiercing: Float = 1.0
        if let tower = tower {
            let synergies = calculateTowerSynergies(for: tower)
            synergyDamageMultiplier = synergies.damageBonus
            synergyArmorPiercing = synergies.armorPiercing
        }
        
        // Apply special tile damage bonus (+25% for towers on golden tiles)
        var tileDamageBonus: Float = 1.0
        if let tower = tower, let userData = tower.userData, let damageBonus = userData["tileDamageBonus"] as? Float {
            tileDamageBonus = damageBonus
        }
        
        let finalDamage = Int(Float(damage) * damageMultiplier * achievementDamageBonus * synergyDamageMultiplier * synergyArmorPiercing * tileDamageBonus)
        
        // Deal damage to enemy
        if let currentHealth = target.userData?["health"] as? Int {
            let newHealth = currentHealth - finalDamage
            target.userData?["health"] = newHealth
            
            // Play hit sound
            SoundManager.shared.playSound(.enemyHit)
            
            if newHealth <= 0 {
                // Enemy destroyed
                SoundManager.shared.playSound(.enemyDestroyed)
                self.createDeathEffect(for: target, towerType: type)
                let baseReward = target.userData?["salvageReward"] as? Int ?? 10
                
                // Apply economy scaling bonuses
                let mapBonus = Float(currentMap - 1) * 0.2  // 20% more per map
                let waveBonus = Float(currentWave - 1) * 0.1  // 10% more per wave
                let salvageMultiplier = getPowerUpMultiplier(type: .salvageMultiplier)
                let achievementSalvageBonus = achievementBonuses["salvageBonus"] ?? 1.0
                let finalReward = Int(Float(baseReward) * (1.0 + mapBonus + waveBonus) * salvageMultiplier * achievementSalvageBonus)
                
                target.removeFromParent()
                self.enemiesDestroyed += 1
                self.playerSalvage += finalReward
                
                // Track achievement progress
                self.updateAchievementProgress(.enemiesKilled)
                self.updateAchievementProgress(.salvageEarned, increment: finalReward)
                
                // Show floating salvage text
                self.showFloatingText("+$\(finalReward)", at: target.position, color: .green)
                
                // Check for power-up drop
                self.checkForPowerUpDrop(at: target.position)
                
                // Also add to score
                self.score += finalReward * 10  // Score is 10x the salvage value
                self.addScore(finalReward * 5)  // Bonus score for kill
                
                self.updateHUD()
                
                // Play destruction sound
                let enemyType = target.userData?["type"] as? String ?? ""
                if enemyType.contains("boss") {
                    // SoundManager.shared.playSound(.bossDestroyed)
                } else {
                    // SoundManager.shared.playSound(.enemyDestroyed)
                }
                // SoundManager.shared.playSound(.creditEarned, volume: 0.3)
            } else {
                // CREATE HIT EFFECT - enemy feels the damage!
                createHitEffect(on: target, damageType: type, damage: damage)
                // Show damage number
                createFloatingText("-\(finalDamage)", at: target.position, color: .red)
                // SoundManager.shared.playSound(.enemyHit, volume: 0.5)
                
                // Update health bar
                if let healthBar = target.childNode(withName: "healthBar") as? SKShapeNode,
                   let maxHealth = target.userData?["maxHealth"] as? Int {
                    let healthPercent = CGFloat(newHealth) / CGFloat(maxHealth)
                    healthBar.xScale = healthPercent
                    
                    // Change color based on health
                    if healthPercent > 0.6 {
                        healthBar.fillColor = .green
                    } else if healthPercent > 0.3 {
                        healthBar.fillColor = .yellow
                    } else {
                        healthBar.fillColor = .red
                    }
                }
                
                // Hit effect
                self.createHitEffect(at: target.position, towerType: type)
            }
        }
    }
    
    private func createExplosion(at position: CGPoint, type: String, level: Int) {
        // Create explosion effect based on type
        let explosion = SKNode()
        explosion.position = position
        explosion.zPosition = 500
        effectsLayer.addChild(explosion)
        
        // Main explosion circle
        let blastRadius = CGFloat(20 + level * 10)
        let blast = SKShapeNode(circleOfRadius: blastRadius)
        blast.strokeColor = type == "plasma" ? .purple : (type == "missile" ? .orange : .white)
        blast.lineWidth = 3
        blast.fillColor = blast.strokeColor.withAlphaComponent(0.3)
        blast.glowWidth = CGFloat(10 + level * 5)
        blast.setScale(0.1)
        explosion.addChild(blast)
        
        // Shockwave rings
        for i in 0..<(2 + level) {
            let ring = SKShapeNode(circleOfRadius: blastRadius * CGFloat(1 + i) * 0.5)
            ring.strokeColor = blast.strokeColor.withAlphaComponent(0.5)
            ring.lineWidth = 2
            ring.fillColor = .clear
            ring.glowWidth = 5
            ring.setScale(0.1)
            ring.alpha = 0
            explosion.addChild(ring)
            
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.05),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.1),
                    SKAction.scale(to: 1.5, duration: 0.3)
                ]),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
        
        // Main blast animation
        blast.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.run { explosion.removeFromParent() }
        ]))
        
        // Add debris particles
        for _ in 0..<(5 * level) {
            let debris = SKShapeNode(circleOfRadius: 2)
            debris.fillColor = blast.strokeColor
            debris.strokeColor = .clear
            debris.glowWidth = 3
            debris.position = .zero
            explosion.addChild(debris)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 20...60) * CGFloat(level)
            let endPoint = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            
            debris.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint, duration: 0.4),
                    SKAction.fadeOut(withDuration: 0.4)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = from.x - to.x
        let dy = from.y - to.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func loadNextMap() {
        // Adjust camera zoom for the new map
        adjustCameraForMap()
        
        // Refund all towers before clearing map
        var totalRefund = 0
        towerLayer.enumerateChildNodes(withName: "*") { tower, _ in
            if let cost = tower.userData?["totalCost"] as? Int {
                totalRefund += Int(Float(cost) * 0.8)  // 80% refund
            }
        }
        
        if totalRefund > 0 {
            playerSalvage += totalRefund
            showMessage("+\(totalRefund) tower refund", at: CGPoint(x: 0, y: 0), color: .green)
        }
        
        // Clear all gameplay elements
        towerLayer.removeAllChildren()
        enemyLayer.removeAllChildren()
        projectileLayer.removeAllChildren()
        gameplayLayer.childNode(withName: "path")?.removeFromParent()
        gameplayLayer.enumerateChildNodes(withName: "buildNode*") { node, _ in
            node.removeFromParent()
        }
        effectsLayer.removeAllChildren()
        
        // Reset selected nodes
        selectedBuildNode = nil
        selectedTowerType = nil
        removeTowerSelector()
        
        // Keep salvage but reset station health
        stationHealth = maxStationHealth
        
        // Epic map transition effect with improved visuals
        let transitionContainer = SKNode()
        transitionContainer.zPosition = 1000
        addChild(transitionContainer)
        
        // Dark background with stars
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor.black.withAlphaComponent(0.95)
        background.strokeColor = .clear
        background.alpha = 0
        transitionContainer.addChild(background)
        
        // Add animated stars
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.8)
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            background.addChild(star)
            
            // Twinkle animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 0.5...1.5))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
        
        // Portal effect
        let portal = SKShapeNode(circleOfRadius: 150)
        portal.strokeColor = SKColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 0.8)
        portal.lineWidth = 3
        portal.fillColor = SKColor(red: 0.2, green: 0.0, blue: 0.4, alpha: 0.3)
        portal.glowWidth = 20
        portal.position = CGPoint(x: 0, y: 0)
        portal.setScale(0.1)
        portal.alpha = 0
        transitionContainer.addChild(portal)
        
        // Inner portal rings
        for i in 1...3 {
            let ring = SKShapeNode(circleOfRadius: CGFloat(120 - i * 30))
            ring.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 0.6)
            ring.lineWidth = 2
            ring.fillColor = .clear
            portal.addChild(ring)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double(2 + i))
            ring.run(SKAction.repeatForever(rotate))
        }
        
        // Map title display - more dramatic
        let mapLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        mapLabel.text = "ENTERING SECTOR \(currentMap)"
        mapLabel.fontSize = 48
        mapLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        mapLabel.position = CGPoint(x: 0, y: 120)
        mapLabel.setScale(0.1)
        mapLabel.alpha = 0
        transitionContainer.addChild(mapLabel)
        
        // Map name with planet theme
        let mapName = getMapName(for: currentMap)
        let nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        nameLabel.text = mapName.uppercased()
        nameLabel.fontSize = 36
        nameLabel.fontColor = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        nameLabel.position = CGPoint(x: 0, y: 60)
        nameLabel.alpha = 0
        transitionContainer.addChild(nameLabel)
        
        // Threat level indicator
        let threatLabel = SKLabelNode(fontNamed: "Helvetica")
        let threatLevel = currentMap <= 3 ? "LOW" : currentMap <= 6 ? "MEDIUM" : currentMap <= 9 ? "HIGH" : "EXTREME"
        let threatColor = currentMap <= 3 ? SKColor.green : currentMap <= 6 ? SKColor.yellow : currentMap <= 9 ? SKColor.orange : SKColor.red
        threatLabel.text = "THREAT LEVEL: \(threatLevel)"
        threatLabel.fontSize = 24
        threatLabel.fontColor = threatColor
        threatLabel.position = CGPoint(x: 0, y: -40)
        threatLabel.alpha = 0
        transitionContainer.addChild(threatLabel)
        
        // Loading bar
        let loadingBarBg = SKShapeNode(rectOf: CGSize(width: 300, height: 10), cornerRadius: 5)
        loadingBarBg.fillColor = SKColor.gray.withAlphaComponent(0.3)
        loadingBarBg.strokeColor = SKColor.cyan
        loadingBarBg.lineWidth = 1
        loadingBarBg.position = CGPoint(x: 0, y: -100)
        loadingBarBg.alpha = 0
        transitionContainer.addChild(loadingBarBg)
        
        let loadingBar = SKShapeNode(rectOf: CGSize(width: 0, height: 8), cornerRadius: 4)
        loadingBar.fillColor = SKColor.cyan
        loadingBar.strokeColor = .clear
        loadingBar.position = CGPoint(x: -150, y: 0)
        loadingBarBg.addChild(loadingBar)
        
        // Loading text
        let loadingText = SKLabelNode(fontNamed: "Helvetica")
        loadingText.text = "INITIALIZING DEFENSES..."
        loadingText.fontSize = 16
        loadingText.fontColor = SKColor.white.withAlphaComponent(0.8)
        loadingText.position = CGPoint(x: 0, y: -130)
        loadingText.alpha = 0
        transitionContainer.addChild(loadingText)
        
        // Animate the transition
        background.run(SKAction.fadeIn(withDuration: 0.3))
        
        portal.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.8)
            ])
        ]))
        
        mapLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
        ]))
        
        nameLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        threatLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        loadingBarBg.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        
        loadingText.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        
        // Animate loading bar
        let expandBar = SKAction.resize(toWidth: 300, duration: 2.0)
        loadingBar.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            expandBar
        ]))
        
        // Clean up transition after animation
        transitionContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        // Load the appropriate map layout after a short delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                self?.loadMapLayout()
            }
        ]))
        
        // Increase difficulty for new map
        enemiesPerWave = 8 + (currentMap * 3) + (currentWave * 2)
        
        // Update HUD
        updateHUD()
    }
    
    private func getMapName(for mapNumber: Int) -> String {
        switch mapNumber {
        case 1: return "Alpha Centauri Outpost"
        case 2: return "Proxima B Colony"
        case 3: return "Kepler Station"
        case 4: return "Tau Ceti Base"
        case 5: return "Pluto Defense Line"
        case 6: return "Neptune Fortress"
        case 7: return "Uranus Shield Station"
        case 8: return "Saturn Ring Platform"
        case 9: return "Jupiter Stronghold"
        case 10: return "Mars Command Center"
        case 11: return "Lunar Defense Base"
        case 12: return "EARTH - FINAL STAND"
        default: return "Deep Space \(mapNumber)"
        }
    }
    
    private func updateWavesPerMap() {
        // Update waves per map based on current level (per game design doc)
        switch currentMap {
        case 1...2:
            wavesPerMap = 3  // Maps 1-2: 3 waves
        case 3...4:
            wavesPerMap = 4  // Maps 3-4: 4 waves  
        default:
            wavesPerMap = 5  // Maps 5+: 5 waves
        }
        print("Map \(currentMap) set to \(wavesPerMap) waves")
    }
    
    private func loadMapLayout() {
        // Update waves for this map
        updateWavesPerMap()
        
        // Clear existing map elements including all vector map visuals
        clearMapElements()
        
        print("🗺️ Loading vector map \(currentMap)...")
        
        // Add debug label to show which map is loading
        let debugLabel = SKLabelNode(text: "Loading Vector Map \(currentMap)...")
        debugLabel.fontSize = 24
        debugLabel.fontName = "AvenirNext-Bold"
        debugLabel.fontColor = .cyan
        debugLabel.position = CGPoint(x: 0, y: 300)
        debugLabel.zPosition = 10000
        debugLabel.name = "debugMapLabel"
        uiLayer.addChild(debugLabel)
        
        // Keep debug label visible for 3 seconds
        let wait = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        debugLabel.run(SKAction.sequence([wait, fadeOut, remove]))
        
        // Reload the vector map nodes for the new map
        if SimpleVectorMapLoader.shared.createVectorMapNodes(mapNumber: currentMap, in: gameplayLayer) {
            debugLabel.text = "✅ VECTOR MAP \(currentMap)"
            debugLabel.fontColor = .green
            
            // Get spawn points for the current map
            mapSpawnPoints = SimpleVectorMapLoader.shared.getSpawnPoints(mapNumber: currentMap)
            print("📍 Loaded \(mapSpawnPoints.count) spawn points for map \(currentMap)")
            for (index, point) in mapSpawnPoints.enumerated() {
                print("  Spawn \(index + 1): \(point)")
            }
            
            // Add special effects for specific maps
            if currentMap == 2 {
                addProximaBStarSystem()
            }
        } else {
            print("⚠️ Failed to load vector map \(currentMap)")
            debugLabel.text = "❌ MAP ERROR"
            debugLabel.fontColor = .red
        }
        
        // Set visual theme
        setMapVisualTheme(.training)
        
        // Add planet-specific backgrounds for certain maps
        addMapSpecificBackground()
        
        showMessage("Defend Station \(currentMap)!", at: CGPoint(x: 0, y: -100), color: .yellow)
    }
    
    private func addMapSpecificBackground() {
        print("🌍 Adding map-specific background for map \(currentMap)")
        
        // Remove any existing planet backgrounds from both layers
        backgroundLayer.enumerateChildNodes(withName: "mapPlanet") { node, _ in
            node.removeFromParent()
        }
        gameplayLayer.enumerateChildNodes(withName: "mapPlanet") { node, _ in
            node.removeFromParent()
        }
        
        switch currentMap {
        case 5: // Neptune (The Spiral)
            addNeptuneBackground()
        case 6: // Saturn (Multi-Path Junction)
            addSaturnBackground()
        case 7: // Jupiter (Jupiter's Highways)
            addJupiterBackground()
        case 8: // Mars (Mars Command)
            addMarsBackground()
        case 9: // Moon (Lunar Defense)
            addMoonBackground()
        case 10: // Earth (EARTH - FINAL STAND)
            addEarthBackground()
        default:
            print("ℹ️ No specific planet background for map \(currentMap)")
            break
        }
    }
    
    private func addJupiterBackground() {
        print("🪐 Adding Jupiter background")
        
        // Create Jupiter in the background
        let jupiterContainer = SKNode()
        jupiterContainer.name = "mapPlanet"
        jupiterContainer.position = CGPoint(x: -180, y: -100)
        jupiterContainer.zPosition = 1  // Above background, below paths
        
        // Jupiter sphere - large gas giant
        let jupiter = SKShapeNode(circleOfRadius: 150)
        jupiter.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        jupiter.strokeColor = SKColor(red: 0.9, green: 0.7, blue: 0.5, alpha: 0.8)
        jupiter.lineWidth = 3
        jupiter.glowWidth = 12
        jupiterContainer.addChild(jupiter)
        
        // Add the Great Red Spot
        let redSpot = SKShapeNode(ellipseOf: CGSize(width: 50, height: 35))
        redSpot.position = CGPoint(x: 40, y: -20)
        redSpot.fillColor = SKColor(red: 0.9, green: 0.4, blue: 0.3, alpha: 0.7)
        redSpot.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.8)
        redSpot.lineWidth = 2
        redSpot.blendMode = .alpha
        jupiter.addChild(redSpot)
        
        // Add storm bands
        for i in 0..<8 {
            let band = SKShapeNode(ellipseOf: CGSize(width: 280, height: 25))
            band.position = CGPoint(x: 0, y: CGFloat(i - 4) * 30)
            
            // Alternate between light and dark bands
            if i % 2 == 0 {
                band.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.3)
            } else {
                band.fillColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.3)
            }
            band.strokeColor = .clear
            band.blendMode = .alpha
            jupiter.addChild(band)
            
            // Animate band movement
            let moveSpeed = Double(12 + i * 2)
            let moveAction = SKAction.sequence([
                SKAction.moveBy(x: 30, y: 0, duration: moveSpeed),
                SKAction.moveBy(x: -30, y: 0, duration: moveSpeed)
            ])
            band.run(SKAction.repeatForever(moveAction))
        }
        
        // Add swirling storms
        for _ in 0..<5 {
            let storm = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...15))
            storm.position = CGPoint(
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -100...100)
            )
            storm.fillColor = SKColor(red: 0.85, green: 0.65, blue: 0.45, alpha: 0.5)
            storm.strokeColor = .clear
            storm.blendMode = .add
            jupiter.addChild(storm)
            
            // Storm rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 5...10))
            storm.run(SKAction.repeatForever(rotate))
        }
        
        // Atmosphere glow
        let atmosphere = SKShapeNode(circleOfRadius: 160)
        atmosphere.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 0.1)
        atmosphere.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 0.2)
        atmosphere.lineWidth = 3
        atmosphere.glowWidth = 15
        atmosphere.blendMode = .add
        jupiterContainer.addChild(atmosphere)
        
        // Rotate Jupiter
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        jupiter.run(SKAction.repeatForever(rotate))
        
        // Add Io moon
        let io = SKShapeNode(circleOfRadius: 12)
        io.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0)
        io.strokeColor = SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.8)
        io.lineWidth = 1
        io.position = CGPoint(x: 200, y: 50)
        jupiterContainer.addChild(io)
        
        backgroundLayer.addChild(jupiterContainer)  // Add to background layer for proper visibility
        print("✅ Jupiter background added to backgroundLayer")
    }
    
    private func addEarthBackground() {
        print("🌍 Adding Earth background")
        
        // Create a stunning rotating Earth in the background - centered and prominent
        let earthContainer = SKNode()
        earthContainer.name = "mapPlanet"
        earthContainer.position = CGPoint(x: 0, y: 0)  // Center it on screen
        earthContainer.zPosition = 5  // Above starfield but below gameplay
        
        // Earth sphere - large and beautiful
        let earth = SKShapeNode(circleOfRadius: 150)  // Bigger than before
        earth.fillColor = SKColor(red: 0.05, green: 0.3, blue: 0.65, alpha: 1.0)  // Deep ocean blue
        earth.strokeColor = SKColor(red: 0.1, green: 0.4, blue: 0.75, alpha: 0.9)
        earth.lineWidth = 3
        earth.glowWidth = 20
        earthContainer.addChild(earth)
        
        // Add realistic cloud formations
        createEarthClouds(on: earth)
        
        // Atmosphere glow - beautiful blue halo
        let atmosphere = SKShapeNode(circleOfRadius: 160)
        atmosphere.fillColor = .clear
        atmosphere.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4)
        atmosphere.lineWidth = 5
        atmosphere.glowWidth = 25
        atmosphere.blendMode = .add
        earthContainer.addChild(atmosphere)
        
        // Inner atmosphere layer
        let innerAtmosphere = SKShapeNode(circleOfRadius: 155)
        innerAtmosphere.fillColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.08)
        innerAtmosphere.strokeColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.2)
        innerAtmosphere.lineWidth = 2
        innerAtmosphere.glowWidth = 10
        innerAtmosphere.blendMode = .add
        earthContainer.addChild(innerAtmosphere)
        
        // Add city lights on the dark side
        for _ in 0..<12 {
            let light = SKShapeNode(circleOfRadius: 1)
            light.position = CGPoint(
                x: CGFloat.random(in: -80...80),
                y: CGFloat.random(in: -80...80)
            )
            light.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)
            light.strokeColor = .clear
            light.glowWidth = 2
            light.blendMode = .add
            earth.addChild(light)
            
            // Twinkle
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 0.5...1.5))
            ])
            light.run(SKAction.repeatForever(twinkle))
        }
        
        // Rotate Earth with its features
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
        earth.run(SKAction.repeatForever(rotate))
        
        // Rotate atmosphere slightly
        let atmosphereRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 120)
        atmosphere.run(SKAction.repeatForever(atmosphereRotate))
        
        backgroundLayer.addChild(earthContainer)  // Add to background layer for proper visibility
        print("✅ Earth background added to backgroundLayer at position \(earthContainer.position) with z-position \(earthContainer.zPosition)")
    }
    
    private func createEarthClouds(on earth: SKNode) {
        // Create realistic cloud formations instead of continents
        let cloudColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
        let cloudStrokeColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.4)
        
        // Large cloud system over the Pacific
        let pacificClouds = SKShapeNode(ellipseOf: CGSize(width: 80, height: 60))
        pacificClouds.position = CGPoint(x: -60, y: 10)
        pacificClouds.fillColor = cloudColor
        pacificClouds.strokeColor = cloudStrokeColor
        pacificClouds.lineWidth = 1
        pacificClouds.blendMode = .alpha
        pacificClouds.alpha = 0.8
        earth.addChild(pacificClouds)
        
        // Hurricane system in the Atlantic
        let atlanticStorm = SKShapeNode(ellipseOf: CGSize(width: 45, height: 45))
        atlanticStorm.position = CGPoint(x: -20, y: 25)
        atlanticStorm.fillColor = cloudColor
        atlanticStorm.strokeColor = cloudStrokeColor
        atlanticStorm.lineWidth = 1
        atlanticStorm.blendMode = .alpha
        atlanticStorm.alpha = 0.9
        earth.addChild(atlanticStorm)
        
        // Smaller cloud formations - properly positioned within Earth's radius (150)
        for _ in 0..<12 {
            let cloudSize = CGSize(width: CGFloat.random(in: 25...50), height: CGFloat.random(in: 20...35))
            let cloud = SKShapeNode(ellipseOf: cloudSize)
            
            // Generate position within Earth's radius (150) using circular distribution
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: 0...120) // Keep clouds well within radius
            cloud.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            
            cloud.fillColor = cloudColor
            cloud.strokeColor = .clear
            cloud.alpha = CGFloat.random(in: 0.5...0.9)
            cloud.blendMode = .alpha
            cloud.zRotation = CGFloat.random(in: 0...CGFloat.pi)
            earth.addChild(cloud)
        }
        
        // Polar ice caps as bright white clouds (positioned within Earth's radius)
        let northPolar = SKShapeNode(ellipseOf: CGSize(width: 60, height: 35))
        northPolar.position = CGPoint(x: 0, y: 110) // Within radius but near top
        northPolar.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
        northPolar.strokeColor = .clear
        northPolar.alpha = 0.9
        earth.addChild(northPolar)
        
        let southPolar = SKShapeNode(ellipseOf: CGSize(width: 55, height: 30))
        southPolar.position = CGPoint(x: 0, y: -110) // Within radius but near bottom
        southPolar.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
        southPolar.strokeColor = .clear
        southPolar.alpha = 0.9
        earth.addChild(southPolar)
    }
    
    
    private func addMarsBackground() {
        print("🔴 Adding Mars background")
        
        // Create Mars in the background - larger and more prominent
        let marsContainer = SKNode()
        marsContainer.name = "mapPlanet"
        marsContainer.position = CGPoint(x: -150, y: 50)
        marsContainer.zPosition = 5  // Above starfield but below gameplay
        
        // Mars sphere - bigger and more realistic color
        let mars = SKShapeNode(circleOfRadius: 100)
        mars.fillColor = SKColor(red: 0.75, green: 0.35, blue: 0.25, alpha: 1.0)
        mars.strokeColor = SKColor(red: 0.85, green: 0.4, blue: 0.3, alpha: 0.9)
        mars.lineWidth = 3
        mars.glowWidth = 8
        marsContainer.addChild(mars)
        
        // Add Valles Marineris (giant canyon)
        let canyon = SKShapeNode(ellipseOf: CGSize(width: 80, height: 15))
        canyon.position = CGPoint(x: -10, y: 15)
        canyon.fillColor = SKColor(red: 0.4, green: 0.15, blue: 0.1, alpha: 0.7)
        canyon.strokeColor = SKColor(red: 0.3, green: 0.1, blue: 0.05, alpha: 0.8)
        canyon.lineWidth = 1
        canyon.zRotation = 0.3
        canyon.blendMode = .multiply
        mars.addChild(canyon)
        
        // Add Olympus Mons (largest volcano)
        let olympus = SKShapeNode(circleOfRadius: 18)
        olympus.position = CGPoint(x: 30, y: 40)
        olympus.fillColor = SKColor(red: 0.65, green: 0.3, blue: 0.2, alpha: 0.8)
        olympus.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.15, alpha: 0.9)
        olympus.lineWidth = 2
        mars.addChild(olympus)
        
        // Volcano crater
        let crater = SKShapeNode(circleOfRadius: 5)
        crater.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.05, alpha: 0.9)
        crater.strokeColor = .clear
        olympus.addChild(crater)
        
        // Add polar ice caps - more realistic
        let northCap = SKShapeNode(ellipseOf: CGSize(width: 55, height: 20))
        northCap.position = CGPoint(x: 0, y: 82)
        northCap.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.8)
        northCap.strokeColor = SKColor.white.withAlphaComponent(0.5)
        northCap.lineWidth = 1
        northCap.blendMode = .screen
        mars.addChild(northCap)
        
        let southCap = SKShapeNode(ellipseOf: CGSize(width: 45, height: 18))
        southCap.position = CGPoint(x: 0, y: -85)
        southCap.fillColor = SKColor(red: 0.93, green: 0.93, blue: 0.96, alpha: 0.75)
        southCap.strokeColor = SKColor.white.withAlphaComponent(0.4)
        southCap.lineWidth = 1
        southCap.blendMode = .screen
        mars.addChild(southCap)
        
        // Add various craters and surface features
        let craterData = [
            (pos: CGPoint(x: -40, y: 20), size: 12),
            (pos: CGPoint(x: 50, y: -30), size: 15),
            (pos: CGPoint(x: -20, y: -45), size: 8),
            (pos: CGPoint(x: 35, y: 10), size: 10),
            (pos: CGPoint(x: -55, y: -20), size: 7)
        ]
        
        for crater in craterData {
            let impact = SKShapeNode(circleOfRadius: CGFloat(crater.size))
            impact.position = crater.pos
            impact.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.15, alpha: 0.6)
            impact.strokeColor = SKColor(red: 0.4, green: 0.15, blue: 0.1, alpha: 0.8)
            impact.lineWidth = 1
            impact.blendMode = .multiply
            mars.addChild(impact)
        }
        
        // Add dark regions (ancient lava plains)
        for _ in 0..<4 {
            let plain = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: 25...40),
                height: CGFloat.random(in: 15...25)
            ))
            plain.position = CGPoint(
                x: CGFloat.random(in: -60...60),
                y: CGFloat.random(in: -40...40)
            )
            plain.fillColor = SKColor(red: 0.55, green: 0.25, blue: 0.18, alpha: 0.4)
            plain.strokeColor = .clear
            plain.blendMode = .multiply
            plain.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            mars.addChild(plain)
        }
        
        // Multiple dust storms
        for i in 0..<2 {
            let storm = SKShapeNode(ellipseOf: CGSize(width: 50, height: 25))
            storm.position = CGPoint(x: CGFloat(20 - i * 40), y: CGFloat(-10 + i * 20))
            storm.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.5, alpha: 0.25)
            storm.strokeColor = .clear
            storm.blendMode = .add
            mars.addChild(storm)
            
            // Storm animation
            let stormMove = SKAction.sequence([
                SKAction.moveBy(x: CGFloat(-30 + i * 20), y: CGFloat(15 - i * 10), duration: Double(10 + i * 2)),
                SKAction.moveBy(x: CGFloat(30 - i * 20), y: CGFloat(-15 + i * 10), duration: Double(10 + i * 2))
            ])
            storm.run(SKAction.repeatForever(stormMove))
        }
        
        // Thin but visible atmosphere
        let atmosphere = SKShapeNode(circleOfRadius: 108)
        atmosphere.fillColor = SKColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 0.12)
        atmosphere.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 0.25)
        atmosphere.lineWidth = 3
        atmosphere.glowWidth = 6
        atmosphere.blendMode = .add
        marsContainer.addChild(atmosphere)
        
        // Add Phobos and Deimos (Mars' moons)
        let phobos = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
        phobos.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        phobos.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.8)
        phobos.lineWidth = 0.5
        phobos.position = CGPoint(x: 140, y: 30)
        marsContainer.addChild(phobos)
        
        let deimos = SKShapeNode(circleOfRadius: 4)
        deimos.fillColor = SKColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.0)
        deimos.strokeColor = .clear
        deimos.position = CGPoint(x: -130, y: -40)
        marsContainer.addChild(deimos)
        
        // Rotate Mars with all its features
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 50)
        mars.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(marsContainer)  // Add to background layer for proper visibility
        print("✅ Mars background added to backgroundLayer")
    }
    
    private func addMoonBackground() {
        print("🌙 Adding Moon background")
        
        // Create the Moon in the background
        let moonContainer = SKNode()
        moonContainer.name = "mapPlanet"
        moonContainer.position = CGPoint(x: 200, y: 150)
        moonContainer.zPosition = 10  // Higher zPosition for better visibility
        
        // Moon sphere - bigger and more visible
        let moon = SKShapeNode(circleOfRadius: 120)
        moon.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.92, alpha: 1.0)  // Brighter lunar color
        moon.strokeColor = SKColor(red: 0.9, green: 0.9, blue: 0.88, alpha: 0.8)
        moon.lineWidth = 2
        moon.glowWidth = 8
        moonContainer.addChild(moon)
        
        // Add major maria (seas) - the dark regions visible from Earth
        // Mare Imbrium (Sea of Rains)
        let mareImbrium = SKShapeNode(ellipseOf: CGSize(width: 45, height: 40))
        mareImbrium.position = CGPoint(x: -20, y: 30)
        mareImbrium.fillColor = SKColor(red: 0.45, green: 0.45, blue: 0.47, alpha: 0.7)
        mareImbrium.strokeColor = .clear
        mareImbrium.blendMode = .multiply
        mareImbrium.zRotation = 0.3
        moon.addChild(mareImbrium)
        
        // Mare Serenitatis (Sea of Serenity)
        let mareSerenitatis = SKShapeNode(ellipseOf: CGSize(width: 35, height: 35))
        mareSerenitatis.position = CGPoint(x: 25, y: 25)
        mareSerenitatis.fillColor = SKColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 0.6)
        mareSerenitatis.strokeColor = .clear
        mareSerenitatis.blendMode = .multiply
        moon.addChild(mareSerenitatis)
        
        // Mare Tranquillitatis (Sea of Tranquility - Apollo 11 landing site)
        let mareTranquillitatis = SKShapeNode(ellipseOf: CGSize(width: 30, height: 38))
        mareTranquillitatis.position = CGPoint(x: 35, y: -10)
        mareTranquillitatis.fillColor = SKColor(red: 0.40, green: 0.40, blue: 0.43, alpha: 0.65)
        mareTranquillitatis.strokeColor = .clear
        mareTranquillitatis.blendMode = .multiply
        mareTranquillitatis.zRotation = -0.2
        moon.addChild(mareTranquillitatis)
        
        // Mare Crisium (Sea of Crises)
        let mareCrisium = SKShapeNode(ellipseOf: CGSize(width: 25, height: 30))
        mareCrisium.position = CGPoint(x: 60, y: 15)
        mareCrisium.fillColor = SKColor(red: 0.43, green: 0.43, blue: 0.46, alpha: 0.5)
        mareCrisium.strokeColor = .clear
        mareCrisium.blendMode = .multiply
        moon.addChild(mareCrisium)
        
        // Oceanus Procellarum (Ocean of Storms)
        let oceanusProcellarum = SKShapeNode(ellipseOf: CGSize(width: 40, height: 50))
        oceanusProcellarum.position = CGPoint(x: -45, y: -5)
        oceanusProcellarum.fillColor = SKColor(red: 0.44, green: 0.44, blue: 0.47, alpha: 0.55)
        oceanusProcellarum.strokeColor = .clear
        oceanusProcellarum.blendMode = .multiply
        oceanusProcellarum.zRotation = 0.5
        moon.addChild(oceanusProcellarum)
        
        // Major craters with rays (like Tycho and Copernicus)
        // Tycho crater (prominent with ray system)
        let tycho = SKShapeNode(circleOfRadius: 8)
        tycho.position = CGPoint(x: -15, y: -65)
        tycho.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
        tycho.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.8)
        tycho.lineWidth = 1
        moon.addChild(tycho)
        
        // Tycho's ray system
        for i in 0..<8 {
            let ray = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: tycho.position)
            let angle = CGFloat(i) * CGFloat.pi / 4
            let endPoint = CGPoint(
                x: tycho.position.x + cos(angle) * 100,
                y: tycho.position.y + sin(angle) * 100
            )
            path.addLine(to: endPoint)
            ray.path = path
            ray.strokeColor = SKColor.white.withAlphaComponent(0.15)
            ray.lineWidth = CGFloat.random(in: 1...3)
            ray.lineCap = .round
            moon.addChild(ray)
        }
        
        // Copernicus crater
        let copernicus = SKShapeNode(circleOfRadius: 6)
        copernicus.position = CGPoint(x: -30, y: 10)
        copernicus.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        copernicus.strokeColor = SKColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.7)
        copernicus.lineWidth = 1
        moon.addChild(copernicus)
        
        // Add various sized craters for realism
        let craterData: [(pos: CGPoint, radius: CGFloat)] = [
            (CGPoint(x: 20, y: -35), 5),
            (CGPoint(x: -50, y: 40), 4),
            (CGPoint(x: 45, y: 55), 6),
            (CGPoint(x: -60, y: -30), 7),
            (CGPoint(x: 70, y: -20), 4),
            (CGPoint(x: -10, y: 60), 5),
            (CGPoint(x: 50, y: -50), 3),
            (CGPoint(x: -70, y: 20), 4)
        ]
        
        for data in craterData {
            let crater = SKShapeNode(circleOfRadius: data.radius)
            crater.position = data.pos
            crater.fillColor = SKColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.4)
            crater.strokeColor = SKColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.6)
            crater.lineWidth = 1
            crater.blendMode = .multiply
            moon.addChild(crater)
            
            // Central peak for larger craters
            if data.radius > 4 {
                let peak = SKShapeNode(circleOfRadius: 1)
                peak.fillColor = SKColor.white.withAlphaComponent(0.5)
                peak.strokeColor = .clear
                crater.addChild(peak)
            }
            
            // Rim highlight
            let rim = SKShapeNode(circleOfRadius: data.radius - 0.5)
            rim.strokeColor = SKColor.white.withAlphaComponent(0.25)
            rim.lineWidth = 0.5
            rim.fillColor = .clear
            crater.addChild(rim)
        }
        
        // Add smaller impact craters
        for _ in 0..<25 {
            let smallCrater = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 20...95)
            smallCrater.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            smallCrater.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3)
            smallCrater.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.4)
            smallCrater.lineWidth = 0.5
            smallCrater.blendMode = .multiply
            moon.addChild(smallCrater)
        }
        
        // Highlands texture (lighter areas)
        for _ in 0..<15 {
            let highland = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: 10...20),
                height: CGFloat.random(in: 8...15)
            ))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 30...85)
            highland.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            highland.fillColor = SKColor.white.withAlphaComponent(0.08)
            highland.strokeColor = .clear
            highland.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            moon.addChild(highland)
        }
        
        // Subtle terminator shadow (for 3D effect)
        let terminator = SKShapeNode(circleOfRadius: 110)
        terminator.fillColor = .clear
        terminator.strokeColor = .clear
        
        let gradient = SKShapeNode(circleOfRadius: 110)
        gradient.fillColor = SKColor.black.withAlphaComponent(0.2)
        gradient.strokeColor = .clear
        gradient.position = CGPoint(x: -15, y: 0)
        gradient.blendMode = .multiply
        moon.addChild(gradient)
        
        // Very subtle edge glow (reflected earthshine)
        let earthshine = SKShapeNode(circleOfRadius: 112)
        earthshine.fillColor = .clear
        earthshine.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 0.05)
        earthshine.lineWidth = 2
        earthshine.glowWidth = 4
        moonContainer.addChild(earthshine)
        
        // Slow rotation (tidally locked, but subtle for visual interest)
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 120)
        moon.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(moonContainer)  // Add to background layer for proper visibility
        print("✅ Moon background added to backgroundLayer")
    }
    
    private func addNeptuneBackground() {
        print("🔵 Adding Neptune background")
        
        // Create Neptune in the background
        let neptuneContainer = SKNode()
        neptuneContainer.name = "mapPlanet"
        neptuneContainer.position = CGPoint(x: 200, y: -80)
        neptuneContainer.zPosition = 1  // Above background, below paths
        
        // Neptune sphere - ice giant
        let neptune = SKShapeNode(circleOfRadius: 90)
        neptune.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1.0)
        neptune.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 1.0, alpha: 0.8)
        neptune.lineWidth = 2
        neptune.glowWidth = 12
        neptuneContainer.addChild(neptune)
        
        // Add Great Dark Spot
        let darkSpot = SKShapeNode(ellipseOf: CGSize(width: 35, height: 25))
        darkSpot.position = CGPoint(x: 20, y: 15)
        darkSpot.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 0.7)
        darkSpot.strokeColor = SKColor(red: 0.05, green: 0.15, blue: 0.5, alpha: 0.8)
        darkSpot.lineWidth = 1
        darkSpot.blendMode = .alpha
        neptune.addChild(darkSpot)
        
        // Add storm bands
        for i in 0..<5 {
            let band = SKShapeNode(ellipseOf: CGSize(width: 160, height: 20))
            band.position = CGPoint(x: 0, y: CGFloat(i - 2) * 25)
            band.fillColor = SKColor(red: 0.25, green: 0.35, blue: 0.85, alpha: 0.3)
            band.strokeColor = .clear
            band.blendMode = .alpha
            neptune.addChild(band)
            
            // Animate bands
            let moveSpeed = Double(8 + i * 2)
            let moveAction = SKAction.sequence([
                SKAction.moveBy(x: 20, y: 0, duration: moveSpeed),
                SKAction.moveBy(x: -20, y: 0, duration: moveSpeed)
            ])
            band.run(SKAction.repeatForever(moveAction))
        }
        
        // Add white cloud streaks
        for _ in 0..<3 {
            let streak = SKShapeNode(ellipseOf: CGSize(width: 40, height: 8))
            streak.position = CGPoint(
                x: CGFloat.random(in: -60...60),
                y: CGFloat.random(in: -60...60)
            )
            streak.fillColor = SKColor.white.withAlphaComponent(0.4)
            streak.strokeColor = .clear
            streak.blendMode = .add
            neptune.addChild(streak)
        }
        
        // Atmosphere
        let atmosphere = SKShapeNode(circleOfRadius: 95)
        atmosphere.fillColor = SKColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 0.15)
        atmosphere.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.3)
        atmosphere.lineWidth = 2
        atmosphere.glowWidth = 10
        atmosphere.blendMode = .add
        neptuneContainer.addChild(atmosphere)
        
        // Add Triton (large moon)
        let triton = SKShapeNode(circleOfRadius: 10)
        triton.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        triton.strokeColor = SKColor.white.withAlphaComponent(0.5)
        triton.lineWidth = 1
        triton.position = CGPoint(x: -120, y: 40)
        neptuneContainer.addChild(triton)
        
        // Rotate Neptune
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 40)
        neptune.run(SKAction.repeatForever(rotate))
        
        gameplayLayer.addChild(neptuneContainer)
        print("✅ Neptune background added to gameplayLayer")
    }
    
    private func addSaturnBackground() {
        print("🪐 Adding Saturn background")
        
        // Create Saturn in the background
        let saturnContainer = SKNode()
        saturnContainer.name = "mapPlanet"
        saturnContainer.position = CGPoint(x: -150, y: 100)
        saturnContainer.zPosition = 1  // Above background, below paths
        
        // Saturn sphere
        let saturn = SKShapeNode(circleOfRadius: 100)
        saturn.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        saturn.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)
        saturn.lineWidth = 2
        saturn.glowWidth = 10
        saturnContainer.addChild(saturn)
        
        // Add bands on the planet
        for i in 0..<6 {
            let band = SKShapeNode(ellipseOf: CGSize(width: 180, height: 20))
            band.position = CGPoint(x: 0, y: CGFloat(i - 3) * 25)
            
            // Alternate band colors
            if i % 2 == 0 {
                band.fillColor = SKColor(red: 0.95, green: 0.85, blue: 0.55, alpha: 0.3)
            } else {
                band.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.45, alpha: 0.3)
            }
            band.strokeColor = .clear
            band.blendMode = .alpha
            saturn.addChild(band)
        }
        
        // Create the famous rings - multiple layers
        let ringRadii = [(inner: 110, outer: 130), (inner: 135, outer: 155), (inner: 160, outer: 175)]
        
        for (index, ring) in ringRadii.enumerated() {
            // Create ring path
            let ringPath = CGMutablePath()
            ringPath.addEllipse(in: CGRect(x: -CGFloat(ring.outer), y: -CGFloat(ring.outer)/3,
                                          width: CGFloat(ring.outer) * 2, height: CGFloat(ring.outer) * 2/3))
            
            let ringNode = SKShapeNode(path: ringPath)
            ringNode.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.6 - CGFloat(index) * 0.1)
            ringNode.lineWidth = CGFloat(ring.outer - ring.inner)
            ringNode.fillColor = .clear
            ringNode.zPosition = index % 2 == 0 ? -1 : 1  // Alternate in front/behind planet
            saturnContainer.addChild(ringNode)
            
            // Subtle ring rotation
            let rotateSpeed = Double(20 + index * 5)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotateSpeed)
            ringNode.run(SKAction.repeatForever(rotate))
        }
        
        // Cassini Division (gap in rings)
        let divisionPath = CGMutablePath()
        divisionPath.addEllipse(in: CGRect(x: -145, y: -145/3, width: 290, height: 290/3))
        let cassiniGap = SKShapeNode(path: divisionPath)
        cassiniGap.strokeColor = SKColor.black.withAlphaComponent(0.5)
        cassiniGap.lineWidth = 5
        cassiniGap.fillColor = .clear
        saturnContainer.addChild(cassiniGap)
        
        // Add Titan moon
        let titan = SKShapeNode(circleOfRadius: 12)
        titan.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0)
        titan.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 0.8)
        titan.lineWidth = 1
        titan.position = CGPoint(x: 180, y: -50)
        saturnContainer.addChild(titan)
        
        // Rotate Saturn
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 35)
        saturn.run(SKAction.repeatForever(rotate))
        
        gameplayLayer.addChild(saturnContainer)
        print("✅ Saturn background added to gameplayLayer")
    }
    
    private func clearMapElements() {
        // Clear existing map elements
        gameplayLayer.enumerateChildNodes(withName: "customPath") { node, _ in
            node.removeFromParent()
        }
        gameplayLayer.enumerateChildNodes(withName: "buildNode*") { node, _ in
            node.removeFromParent()
        }
        gameplayLayer.enumerateChildNodes(withName: "enemyPath") { node, _ in
            node.removeFromParent()
        }
    }
    
    // MARK: - Missing HUD Functions (Stubs to fix build errors)
    private func updateHUD() {
        // Update salvage label
        if let salvageLabel = uiLayer.childNode(withName: "salvageLabel") as? SKLabelNode {
            salvageLabel.text = "\(playerSalvage)"
        }
        
        // Update score label
        if let scoreLabel = uiLayer.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "SCORE: \(score)"
        }
        
        // Update wave label
        if let waveLabel = uiLayer.childNode(withName: "waveLabel") as? SKLabelNode {
            waveLabel.text = "WAVE \(currentWave)"
        }
        
        // Update HP label
        if let hpLabel = uiLayer.childNode(withName: "hpLabel") as? SKLabelNode {
            hpLabel.text = "\(stationHealth)"
            // Change color based on health
            if stationHealth <= 1 {
                hpLabel.fontColor = .red
            } else if stationHealth <= 2 {
                hpLabel.fontColor = .yellow
            } else {
                hpLabel.fontColor = .white
            }
        }
        
        // Update hearts display
        if let hpContainer = uiLayer.childNode(withName: "hpContainer") {
            // Update each heart based on current health
            for i in 0..<maxStationHealth {
                if let heart = hpContainer.childNode(withName: "heart_\(i)") as? SKShapeNode {
                    if i < stationHealth {
                        // Full heart
                        heart.fillColor = SKColor(red: 1, green: 0.2, blue: 0.3, alpha: 1)
                        heart.strokeColor = SKColor(red: 1, green: 0.4, blue: 0.5, alpha: 1)
                        heart.glowWidth = 2
                        heart.alpha = 1.0
                    } else {
                        // Empty heart - check if it just changed
                        if heart.fillColor != SKColor.clear {
                            // Heart just lost - animate it breaking
                            let breakEffect = SKAction.sequence([
                                SKAction.scale(to: 1.3, duration: 0.1),
                                SKAction.group([
                                    SKAction.scale(to: 0.8, duration: 0.2),
                                    SKAction.fadeAlpha(to: 0.5, duration: 0.2)
                                ]),
                                SKAction.run {
                                    heart.fillColor = SKColor.clear
                                    heart.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 0.3)
                                    heart.glowWidth = 0
                                },
                                SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                                SKAction.scale(to: 1.0, duration: 0.1)
                            ])
                            heart.run(breakEffect)
                        } else {
                            // Already empty
                            heart.fillColor = SKColor.clear
                            heart.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 0.3)
                            heart.glowWidth = 0
                        }
                    }
                }
            }
        }
    }
    
    private func showAbortConfirmation() {
        // Pause the game
        gameplayLayer.isPaused = true
        enemyLayer.isPaused = true
        towerLayer.isPaused = true
        projectileLayer.isPaused = true
        backgroundLayer.isPaused = true
        
        // Create confirmation overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.8)
        overlay.strokeColor = .clear
        overlay.position = CGPoint.zero
        overlay.zPosition = 3000
        overlay.name = "abortOverlay"
        
        // Confirmation dialog box
        let dialogBox = SKShapeNode(rectOf: CGSize(width: 400, height: 200), cornerRadius: 10)
        dialogBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95)
        dialogBox.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        dialogBox.lineWidth = 2
        dialogBox.position = CGPoint.zero
        overlay.addChild(dialogBox)
        
        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "ABORT MISSION?"
        title.fontSize = 28
        title.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
        title.position = CGPoint(x: 0, y: 50)
        overlay.addChild(title)
        
        // Message
        let message = SKLabelNode(fontNamed: "Helvetica")
        message.text = "All progress in this level will be lost"
        message.fontSize = 18
        message.fontColor = .white
        message.position = CGPoint(x: 0, y: 10)
        overlay.addChild(message)
        
        // Yes button (abort)
        let yesButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 5)
        yesButton.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        yesButton.strokeColor = .clear
        yesButton.position = CGPoint(x: -80, y: -50)
        yesButton.name = "abortYes"
        overlay.addChild(yesButton)
        
        let yesLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        yesLabel.text = "ABORT"
        yesLabel.fontSize = 20
        yesLabel.fontColor = .white
        yesLabel.verticalAlignmentMode = .center
        yesLabel.position = CGPoint(x: -80, y: -50)
        overlay.addChild(yesLabel)
        
        // No button (continue)
        let noButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 5)
        noButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        noButton.strokeColor = .clear
        noButton.position = CGPoint(x: 80, y: -50)
        noButton.name = "abortNo"
        overlay.addChild(noButton)
        
        let noLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        noLabel.text = "CONTINUE"
        noLabel.fontSize = 20
        noLabel.fontColor = .white
        noLabel.verticalAlignmentMode = .center
        noLabel.position = CGPoint(x: 80, y: -50)
        overlay.addChild(noLabel)
        
        uiLayer.addChild(overlay)
    }
    
    
    private func createMassiveExplosion(at position: CGPoint) {
        // Create multiple explosion layers for dramatic effect
        
        // Main explosion flash
        let flash = SKShapeNode(circleOfRadius: 200)
        flash.position = position
        flash.fillColor = SKColor.white
        flash.strokeColor = .clear
        flash.blendMode = .add
        flash.zPosition = 1500
        flash.alpha = 0.9
        uiLayer.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.scale(to: 3.0, duration: 0.2),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 5.0, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Create shockwave ring
        let shockwave = SKShapeNode(circleOfRadius: 50)
        shockwave.position = position
        shockwave.strokeColor = SKColor.cyan
        shockwave.fillColor = .clear
        shockwave.lineWidth = 8
        shockwave.glowWidth = 15
        shockwave.zPosition = 1499
        shockwave.blendMode = .add
        uiLayer.addChild(shockwave)
        
        shockwave.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 8.0, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Create multiple explosion particles
        for i in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...15))
            particle.position = position
            particle.fillColor = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
            particle.strokeColor = .clear
            particle.blendMode = .add
            particle.zPosition = 1498
            uiLayer.addChild(particle)
            
            let angle = CGFloat(i) * (CGFloat.pi * 2.0 / 20.0)
            let distance = CGFloat.random(in: 100...300)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let moveAction = SKAction.move(to: destination, duration: Double.random(in: 0.4...0.8))
            moveAction.timingMode = .easeOut
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    moveAction,
                    SKAction.fadeOut(withDuration: 0.8),
                    SKAction.scale(to: 0.1, duration: 0.8)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // Create debris
        for _ in 0..<15 {
            let debris = SKShapeNode(rectOf: CGSize(
                width: CGFloat.random(in: 3...8),
                height: CGFloat.random(in: 3...8)
            ))
            debris.position = position
            debris.fillColor = SKColor(white: CGFloat.random(in: 0.3...0.7), alpha: 1)
            debris.strokeColor = .clear
            debris.zPosition = 1497
            uiLayer.addChild(debris)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...200)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let moveAction = SKAction.move(to: destination, duration: Double.random(in: 0.5...1.0))
            let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -10...10), duration: 1.0)
            
            debris.run(SKAction.sequence([
                SKAction.group([
                    moveAction,
                    rotateAction,
                    SKAction.fadeOut(withDuration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        
        // Add sound effect placeholder
        // Sound effect handled in specific explosion types
    }
    
    private func shakeScreen() {
        // Create intense screen shake effect
        let shakeIntensity: CGFloat = 20
        let numberOfShakes = 10
        let shakeDuration = 0.04
        
        var shakeActions: [SKAction] = []
        
        for _ in 0..<numberOfShakes {
            let moveX = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            let moveY = CGFloat.random(in: -shakeIntensity...shakeIntensity)
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: shakeDuration)
            let returnAction = SKAction.moveBy(x: -moveX, y: -moveY, duration: shakeDuration)
            shakeActions.append(shakeAction)
            shakeActions.append(returnAction)
        }
        
        // Apply shake to all game layers
        let shakeSequence = SKAction.sequence(shakeActions)
        gameplayLayer.run(shakeSequence)
        enemyLayer.run(shakeSequence)
        towerLayer.run(shakeSequence)
        projectileLayer.run(shakeSequence)
        backgroundLayer.run(shakeSequence)
    }
    
    private func skipToNextLevel() {
        // Skip to next level - stub implementation
        print("Skipping to next level")
    }
    
    private func createNextMapButton() {
        // Position at same level as Score HUD
        let topY = size.height/2 - 20  // Same as Score label position
        
        // LEFT BUTTON: Speed Control
        let speedButton = SKShapeNode(rectOf: CGSize(width: 100, height: 35))
        speedButton.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.8)
        speedButton.strokeColor = .white
        speedButton.lineWidth = 2
        speedButton.position = CGPoint(x: -140, y: -(size.height/2 - 120))  // Bottom left
        speedButton.zPosition = 1000
        speedButton.name = "speedButton"
        
        let speedLabel = SKLabelNode(text: "Speed 1x")
        speedLabel.fontSize = 14
        speedLabel.fontName = "AvenirNext-Bold"
        speedLabel.fontColor = .white
        speedLabel.verticalAlignmentMode = .center
        speedButton.addChild(speedLabel)
        speedButton.userData = NSMutableDictionary()
        speedButton.userData?["currentSpeed"] = 1
        
        uiLayer.addChild(speedButton)
        
        // MIDDLE BUTTON: Next Level (Next Map)
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 35))
        button.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.8)
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: size.width/2 - 100, y: topY)  // Top right, same as Score
        button.zPosition = 1000
        button.name = "nextMapButton"
        
        let label = SKLabelNode(text: "Next Level")
        label.fontSize = 14
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        uiLayer.addChild(button)
        
        // RIGHT BUTTON: Next Wave
        let waveButton = SKShapeNode(rectOf: CGSize(width: 100, height: 35))
        waveButton.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.8)
        waveButton.strokeColor = .white
        waveButton.lineWidth = 2
        waveButton.position = CGPoint(x: 140, y: -(size.height/2 - 120))  // Bottom right
        waveButton.zPosition = 1000
        waveButton.name = "nextWaveButton"
        
        let waveLabel = SKLabelNode(text: "Next Wave")
        waveLabel.fontSize = 14
        waveLabel.fontName = "AvenirNext-Bold"
        waveLabel.fontColor = .white
        waveLabel.verticalAlignmentMode = .center
        waveButton.addChild(waveLabel)
        
        uiLayer.addChild(waveButton)
        
        // Ensure buttons are always visible initially
        speedButton.isHidden = false
        speedButton.alpha = 1.0
        button.isHidden = false
        button.alpha = 1.0
        waveButton.isHidden = false
        waveButton.alpha = 1.0
    }
    
    private func toggleGameSpeed() {
        guard let speedButton = uiLayer.childNode(withName: "speedButton") else { return }
        let currentSpeed = speedButton.userData?["currentSpeed"] as? Int ?? 1
        
        var newSpeed: Int
        var speedText: String
        var speedMultiplier: CGFloat
        
        switch currentSpeed {
        case 1:
            newSpeed = 2
            speedText = "2x"
            speedMultiplier = 2.0
        case 2:
            newSpeed = 3
            speedText = "3x"
            speedMultiplier = 3.0
        case 3:
            newSpeed = 4
            speedText = "4x"
            speedMultiplier = 4.0
        case 4:
            newSpeed = 1
            speedText = "1x"
            speedMultiplier = 1.0
        default:
            newSpeed = 1
            speedText = "1x"
            speedMultiplier = 1.0
        }
        
        // Apply speed to ALL game layers
        self.speed = speedMultiplier
        gameplayLayer.speed = speedMultiplier
        enemyLayer.speed = speedMultiplier
        towerLayer.speed = speedMultiplier
        projectileLayer.speed = speedMultiplier
        effectsLayer.speed = speedMultiplier
        
        // Store for later use
        speedButton.userData?["currentSpeed"] = newSpeed
        
        // Update speed icon label
        if let speedIconLabel = speedButton.childNode(withName: "speedIconLabel") as? SKLabelNode {
            speedIconLabel.text = speedText
        }
        
        // Play a click sound
        SoundManager.shared.playSound(.buttonTap)
        
        print("Game speed changed to \(newSpeed)x")
    }
    
    private func createEarthDefenseBackground() {
        // Create Kepler Station themed background for map 3 - purple and animated
        
        // First, add a dense star field with purple tint
        let starCount = 250
        for _ in 0..<starCount {
            let x = CGFloat.random(in: -size.width/2...size.width/2)
            let y = CGFloat.random(in: -size.height/2...size.height/2)
            
            let starSize = CGFloat.random(in: 0.5...2)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.position = CGPoint(x: x, y: y)
            star.fillColor = SKColor(red: 0.8, green: 0.7, blue: 1.0, alpha: CGFloat.random(in: 0.2...0.7))
            star.strokeColor = .clear
            star.zPosition = 1
            
            // Subtle twinkling
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 3...6)),
                SKAction.fadeAlpha(to: 0.7, duration: Double.random(in: 3...6))
            ])
            star.run(SKAction.repeatForever(twinkle))
            backgroundLayer.addChild(star)
        }
        
        // Add purple nebula clouds
        for _ in 0..<8 {
            let nebula = SKShapeNode(circleOfRadius: CGFloat.random(in: 60...120))
            nebula.position = CGPoint(
                x: CGFloat.random(in: -size.width/3...size.width/3),
                y: CGFloat.random(in: -size.height/3...size.height/3)
            )
            nebula.fillColor = SKColor(
                red: CGFloat.random(in: 0.4...0.6),
                green: CGFloat.random(in: 0.1...0.3),
                blue: CGFloat.random(in: 0.5...0.8),
                alpha: 0.15
            )
            nebula.strokeColor = .clear
            nebula.blendMode = .add
            nebula.zPosition = 0
            
            // Slow pulsing
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: Double.random(in: 10...15)),
                SKAction.scale(to: 1.0, duration: Double.random(in: 10...15))
            ])
            nebula.run(SKAction.repeatForever(pulse))
            backgroundLayer.addChild(nebula)
        }
        
        // Add Kepler Station - large purple animated station
        let stationContainer = SKNode()
        stationContainer.position = CGPoint(x: size.width/3, y: size.height/5)
        stationContainer.zPosition = 3
        
        // Main station core
        let stationCore = SKShapeNode(circleOfRadius: 40)
        stationCore.fillColor = SKColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 0.8)
        stationCore.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0)
        stationCore.lineWidth = 3
        stationCore.glowWidth = 15
        stationCore.blendMode = .add
        stationContainer.addChild(stationCore)
        
        // Rotating outer ring
        let outerRing = SKNode()
        let ring1 = SKShapeNode(ellipseOf: CGSize(width: 120, height: 30))
        ring1.strokeColor = SKColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 0.6)
        ring1.lineWidth = 4
        ring1.fillColor = .clear
        ring1.glowWidth = 8
        outerRing.addChild(ring1)
        
        // Add energy nodes on the ring
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let energyNode = SKShapeNode(circleOfRadius: 3)
            energyNode.position = CGPoint(x: cos(angle) * 60, y: sin(angle) * 15)
            energyNode.fillColor = SKColor.cyan
            energyNode.strokeColor = .clear
            energyNode.glowWidth = 6
            energyNode.blendMode = .add
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.8),
                SKAction.scale(to: 1.0, duration: 0.8)
            ])
            energyNode.run(SKAction.repeatForever(pulse))
            outerRing.addChild(energyNode)
        }
        
        stationContainer.addChild(outerRing)
        
        // Inner rotating ring
        let innerRing = SKNode()
        let ring2 = SKShapeNode(ellipseOf: CGSize(width: 80, height: 20))
        ring2.strokeColor = SKColor(red: 0.8, green: 0.5, blue: 1.0, alpha: 0.8)
        ring2.lineWidth = 2
        ring2.fillColor = .clear
        ring2.glowWidth = 4
        innerRing.addChild(ring2)
        stationContainer.addChild(innerRing)
        
        // Pulsing energy core
        let energyCore = SKShapeNode(circleOfRadius: 15)
        energyCore.fillColor = SKColor(red: 0.9, green: 0.6, blue: 1.0, alpha: 0.9)
        energyCore.strokeColor = .clear
        energyCore.glowWidth = 20
        energyCore.blendMode = .add
        stationContainer.addChild(energyCore)
        
        // Animate rings
        let rotateOuter = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        let rotateInner = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 12)
        outerRing.run(SKAction.repeatForever(rotateOuter))
        innerRing.run(SKAction.repeatForever(rotateInner))
        
        // Animate energy core
        let corePulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2),
            SKAction.scale(to: 1.0, duration: 2)
        ])
        energyCore.run(SKAction.repeatForever(corePulse))
        
        // Station rotation
        let stationRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
        stationContainer.run(SKAction.repeatForever(stationRotate))
        
        backgroundLayer.addChild(stationContainer)
        
        // Add spiral galaxy in background
        let galaxyCenter = CGPoint(x: -size.width/4, y: size.height/5)
        
        // Galaxy core
        let core = SKShapeNode(circleOfRadius: 15)
        core.position = galaxyCenter
        core.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.8)
        core.strokeColor = .clear
        core.glowWidth = 20
        core.blendMode = .add
        core.zPosition = 2
        backgroundLayer.addChild(core)
        
        // Spiral arms
        for arm in 0..<3 {
            let armOffset = CGFloat(arm) * (CGFloat.pi * 2 / 3)
            
            for i in 0..<40 {
                let angle = CGFloat(i) * 0.15 + armOffset
                let radius = CGFloat(i) * 3
                
                let starCluster = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
                starCluster.position = CGPoint(
                    x: galaxyCenter.x + cos(angle) * radius,
                    y: galaxyCenter.y + sin(angle) * radius * 0.4
                )
                starCluster.fillColor = SKColor(red: 0.8, green: 0.8, blue: 1.0, alpha: CGFloat.random(in: 0.3...0.6))
                starCluster.strokeColor = .clear
                starCluster.blendMode = .add
                starCluster.zPosition = 1
                backgroundLayer.addChild(starCluster)
            }
        }
        
        // Add distant planets
        let planets = [
            (pos: CGPoint(x: size.width/3, y: -size.height/4), radius: CGFloat(25), color: SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.9)),
            (pos: CGPoint(x: -size.width/3, y: -size.height/3), radius: CGFloat(18), color: SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.9)),
            (pos: CGPoint(x: size.width/4, y: size.height/3), radius: CGFloat(12), color: SKColor(red: 0.6, green: 0.4, blue: 0.7, alpha: 0.9))
        ]
        
        for planet in planets {
            // Planet shadow/dark side
            let shadow = SKShapeNode(circleOfRadius: planet.radius)
            shadow.position = planet.pos
            shadow.fillColor = SKColor.black.withAlphaComponent(0.7)
            shadow.strokeColor = .clear
            shadow.zPosition = 3
            backgroundLayer.addChild(shadow)
            
            // Planet body
            let planetNode = SKShapeNode(circleOfRadius: planet.radius)
            planetNode.position = planet.pos
            planetNode.fillColor = planet.color
            planetNode.strokeColor = planet.color.withAlphaComponent(0.5)
            planetNode.lineWidth = 2
            planetNode.glowWidth = 4
            planetNode.zPosition = 3
            
            // Add crescent lighting effect
            let crescent = SKShapeNode(circleOfRadius: planet.radius * 0.9)
            crescent.position = CGPoint(x: -planet.radius * 0.3, y: planet.radius * 0.2)
            crescent.fillColor = planet.color.withAlphaComponent(0.3)
            crescent.strokeColor = .clear
            crescent.blendMode = .add
            planetNode.addChild(crescent)
            
            backgroundLayer.addChild(planetNode)
            
            // Add planetary rings for the first planet
            if planet.radius == 25 {
                let ring = SKShapeNode(ellipseOf: CGSize(width: planet.radius * 3, height: planet.radius * 0.8))
                ring.position = planet.pos
                ring.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.5, alpha: 0.4)
                ring.lineWidth = 3
                ring.fillColor = .clear
                ring.zPosition = 2
                backgroundLayer.addChild(ring)
            }
            
            // Very slow rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 60...120))
            planetNode.run(SKAction.repeatForever(rotate))
        }
        
        // Add shooting stars
        for _ in 0..<3 {
            let shootingStar = SKShapeNode(circleOfRadius: 1)
            shootingStar.fillColor = .white
            shootingStar.glowWidth = 3
            
            let startX = CGFloat.random(in: -size.width/2...size.width/2)
            let startY = CGFloat.random(in: 0...size.height/2)
            let endX = startX + CGFloat.random(in: 100...200)
            let endY = startY - CGFloat.random(in: 100...200)
            
            shootingStar.position = CGPoint(x: startX, y: startY)
            shootingStar.zPosition = 5
            
            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 1.5)
            let fade = SKAction.fadeOut(withDuration: 1.5)
            let group = SKAction.group([move, fade])
            let reset = SKAction.run {
                shootingStar.position = CGPoint(x: startX, y: startY)
                shootingStar.alpha = 1.0
            }
            let wait = SKAction.wait(forDuration: Double.random(in: 5...15))
            let sequence = SKAction.sequence([wait, reset, group])
            
            shootingStar.run(SKAction.repeatForever(sequence))
            backgroundLayer.addChild(shootingStar)
        }
    }
    
    private func addBackgroundAnimations() {
        // Detect device type for enhanced animations
        let deviceType = UIDevice.current.userInterfaceIdiom
        let isIPad = deviceType == .pad
        let animationCount = isIPad ? 15 : 8  // More animations for iPad
        
        // Add floating debris in background
        for _ in 0..<animationCount {
            let debris = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 2...6), 
                                                     height: CGFloat.random(in: 2...6)))
            debris.fillColor = SKColor.white.withAlphaComponent(0.1)
            debris.strokeColor = .clear
            debris.position = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2),
                                    y: CGFloat.random(in: -size.height/2...size.height/2))
            debris.zPosition = -90
            backgroundLayer.addChild(debris)
            
            // Floating animation
            let duration = Double.random(in: 20...40)
            let moveX = CGFloat.random(in: -50...50)
            let moveY = CGFloat.random(in: -30...30)
            let float = SKAction.sequence([
                SKAction.moveBy(x: moveX, y: moveY, duration: duration/2),
                SKAction.moveBy(x: -moveX, y: -moveY, duration: duration/2)
            ])
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: duration)
            debris.run(SKAction.repeatForever(SKAction.group([float, rotate])))
        }
        
        // Add distant ships (more for iPad)
        let shipCount = isIPad ? 6 : 3
        for _ in 0..<shipCount {
            let ship = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 8))
            path.addLine(to: CGPoint(x: -4, y: -8))
            path.addLine(to: CGPoint(x: 4, y: -8))
            path.closeSubpath()
            ship.path = path
            ship.fillColor = SKColor.cyan.withAlphaComponent(0.15)
            ship.strokeColor = .clear
            ship.position = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2),
                                   y: CGFloat.random(in: -size.height/2...size.height/2))
            ship.zPosition = -85
            backgroundLayer.addChild(ship)
            
            // Moving across screen
            let duration = Double.random(in: 30...60)
            let startX = -size.width/2 - 50
            let endX = size.width/2 + 50
            ship.position.x = startX
            let move = SKAction.moveTo(x: endX, duration: duration)
            let reset = SKAction.moveTo(x: startX, duration: 0)
            let randomY = SKAction.run {
                ship.position.y = CGFloat.random(in: -self.size.height/2...self.size.height/2)
            }
            ship.run(SKAction.repeatForever(SKAction.sequence([randomY, move, reset])))
        }
        
        // Add floating asteroids (more for iPad)
        let asteroidCount = isIPad ? 10 : 5
        for _ in 0..<asteroidCount {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            asteroid.fillColor = SKColor.brown.withAlphaComponent(0.08)
            asteroid.strokeColor = .clear
            asteroid.position = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2),
                                       y: CGFloat.random(in: -size.height/2...size.height/2))
            asteroid.zPosition = -88
            backgroundLayer.addChild(asteroid)
            
            // Slow rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 60...120))
            asteroid.run(SKAction.repeatForever(rotate))
        }
        
        // iPad-specific enhancements
        if isIPad {
            addIPadEnhancedBackgrounds()
        }
    }
    
    private func addIPadEnhancedBackgrounds() {
        // Add larger space stations in the background
        for _ in 0..<3 {
            let station = createBackgroundStation()
            station.position = CGPoint(
                x: CGFloat.random(in: -size.width*0.8...size.width*0.8),
                y: CGFloat.random(in: -size.height*0.8...size.height*0.8)
            )
            station.zPosition = -95
            backgroundLayer.addChild(station)
        }
        
        // Add nebula clouds
        for _ in 0..<4 {
            let nebula = createNebula()
            nebula.position = CGPoint(
                x: CGFloat.random(in: -size.width*0.4...size.width*0.4),
                y: CGFloat.random(in: -size.height*0.4...size.height*0.4)
            )
            nebula.zPosition = -96  // In front of stars (-99)
            backgroundLayer.addChild(nebula)
        }
        
        // Add more stars for denser background
        for _ in 0..<200 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.5))
            star.fillColor = SKColor.white.withAlphaComponent(CGFloat.random(in: 0.1...0.4))
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width*0.6...size.width*0.6),
                y: CGFloat.random(in: -size.height*0.6...size.height*0.6)
            )
            star.zPosition = -99
            backgroundLayer.addChild(star)
            
            // Twinkling effect
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.1...0.4), duration: Double.random(in: 2...5)),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.4...0.8), duration: Double.random(in: 2...5))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
        
        // Add energy pulses
        for _ in 0..<5 {
            let pulse = createEnergyPulse()
            pulse.position = CGPoint(
                x: CGFloat.random(in: -size.width*0.4...size.width*0.4),
                y: CGFloat.random(in: -size.height*0.4...size.height*0.4)
            )
            pulse.zPosition = -92
            backgroundLayer.addChild(pulse)
        }
    }
    
    private func createBackgroundStation() -> SKNode {
        let station = SKNode()
        
        // Main structure
        let body = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        body.fillColor = SKColor.gray.withAlphaComponent(0.2)
        body.strokeColor = SKColor.white.withAlphaComponent(0.1)
        body.lineWidth = 1
        station.addChild(body)
        
        // Antenna
        let antenna = SKShapeNode(rectOf: CGSize(width: 2, height: 15))
        antenna.fillColor = SKColor.cyan.withAlphaComponent(0.3)
        antenna.strokeColor = .clear
        antenna.position = CGPoint(x: 0, y: 17)
        station.addChild(antenna)
        
        // Blinking lights
        let light = SKShapeNode(circleOfRadius: 2)
        light.fillColor = SKColor.red.withAlphaComponent(0.8)
        light.strokeColor = .clear
        light.position = CGPoint(x: 10, y: 5)
        station.addChild(light)
        
        // Blink animation
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.8),
            SKAction.fadeIn(withDuration: 0.8)
        ])
        light.run(SKAction.repeatForever(blink))
        
        return station
    }
    
    private func createNebula() -> SKNode {
        let nebula = SKNode()
        
        // Create multiple overlapping circles for nebula effect
        let colors: [SKColor] = [
            SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.1),
            SKColor(red: 0.6, green: 0.2, blue: 0.4, alpha: 0.1),
            SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.1)
        ]
        
        for _ in 0..<5 {
            let cloud = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...150))
            cloud.fillColor = colors.randomElement()!
            cloud.strokeColor = .clear
            cloud.position = CGPoint(
                x: CGFloat.random(in: -50...50),
                y: CGFloat.random(in: -50...50)
            )
            cloud.alpha = CGFloat.random(in: 0.05...0.2)
            nebula.addChild(cloud)
            
            // Slow drift - minimal movement to prevent edge visibility
            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -10...10),
                duration: Double.random(in: 40...80)
            )
            cloud.run(SKAction.repeatForever(SKAction.sequence([drift, drift.reversed()])))
        }
        
        return nebula
    }
    
    private func createEnergyPulse() -> SKNode {
        let pulse = SKNode()
        
        // Create expanding ring
        let ring = SKShapeNode(circleOfRadius: 5)
        ring.fillColor = .clear
        ring.strokeColor = SKColor.cyan.withAlphaComponent(0.3)
        ring.lineWidth = 2
        pulse.addChild(ring)
        
        // Pulse animation
        let expand = SKAction.scale(to: 8.0, duration: 4.0)
        let fade = SKAction.fadeOut(withDuration: 4.0)
        let reset = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ])
        let sequence = SKAction.sequence([SKAction.group([expand, fade]), reset])
        
        ring.run(SKAction.repeatForever(sequence))
        
        return pulse
    }
    
    private func createStarBackground() {
        // Create map-specific themed backgrounds
        switch currentMap {
        case 1:
            createMercuryBackground()
        case 2:
            createVenusBackground()
        case 3:
            createEarthDefenseBackground()
        case 4:
            createMarsBackground()
        case 5:
            createAsteroidBeltBackground()
        case 6:
            createNeptuneBackground()
        case 7:
            createSaturnBackground()
        case 8...12:
            createOuterPlanetsBackground()
        default:
            // Default space background
            createDefaultSpaceBackground()
        }
    }
    
    private func createDefaultSpaceBackground() {
        // Create slowly flashing stars background like the old system
        let starCount = 150
        
        for _ in 0..<starCount {
            // Random position across the screen
            let x = CGFloat.random(in: -size.width/2...size.width/2)
            let y = CGFloat.random(in: -size.height/2...size.height/2)
            
            // Create star as a small circle with random size
            let starSize = CGFloat.random(in: 1...3)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.position = CGPoint(x: x, y: y)
            star.fillColor = SKColor.white
            star.strokeColor = .clear
            star.zPosition = 1
            star.alpha = CGFloat.random(in: 0.3...0.8)
            
            // Add slow flashing animation with random timing
            let minDuration = TimeInterval.random(in: 2.0...4.0)
            let maxDuration = TimeInterval.random(in: 4.0...8.0)
            let minAlpha = CGFloat.random(in: 0.1...0.3)
            let maxAlpha = CGFloat.random(in: 0.6...1.0)
            
            let fadeOut = SKAction.fadeAlpha(to: minAlpha, duration: minDuration)
            let fadeIn = SKAction.fadeAlpha(to: maxAlpha, duration: maxDuration)
            let flash = SKAction.sequence([fadeOut, fadeIn])
            
            // Add random delay before starting the flash cycle
            let initialDelay = SKAction.wait(forDuration: TimeInterval.random(in: 0...3))
            let flashCycle = SKAction.repeatForever(flash)
            let starAction = SKAction.sequence([initialDelay, flashCycle])
            
            star.run(starAction)
            backgroundLayer.addChild(star)
        }
        
        // Add a few larger, brighter stars that flash more prominently
        for _ in 0..<20 {
            let x = CGFloat.random(in: -size.width/2...size.width/2)
            let y = CGFloat.random(in: -size.height/2...size.height/2)
            
            let brightStar = SKShapeNode(circleOfRadius: 2)
            brightStar.position = CGPoint(x: x, y: y)
            brightStar.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
            brightStar.strokeColor = .clear
            brightStar.zPosition = 2
            brightStar.glowWidth = 4
            
            // More dramatic flashing for bright stars
            let brightFlash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: 1.5),
                SKAction.fadeAlpha(to: 1.0, duration: 2.5)
            ])
            let delay = SKAction.wait(forDuration: TimeInterval.random(in: 0...2))
            brightStar.run(SKAction.sequence([delay, SKAction.repeatForever(brightFlash)]))
            
            backgroundLayer.addChild(brightStar)
        }
    }
    
    private func createMercuryBackground() {
        // Mercury - Scorched planet closest to the sun with extreme temperatures
        createBasicStarfield(80)  // Fewer stars due to sun's brightness
        
        // Massive sun dominating the view
        let sunContainer = SKNode()
        sunContainer.position = CGPoint(x: -size.width/3, y: size.height/4)
        sunContainer.zPosition = -2
        
        // Sun core - very bright
        let sun = SKShapeNode(circleOfRadius: 80)
        sun.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
        sun.strokeColor = .clear
        sun.glowWidth = 60
        sun.blendMode = .add
        sunContainer.addChild(sun)
        
        // Solar corona
        for i in 1...4 {
            let corona = SKShapeNode(circleOfRadius: 80 + CGFloat(i * 15))
            corona.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.2 / CGFloat(i))
            corona.strokeColor = .clear
            corona.blendMode = .add
            sunContainer.addChild(corona)
        }
        
        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 4),
            SKAction.scale(to: 1.0, duration: 4)
        ])
        sun.run(SKAction.repeatForever(pulse))
        
        backgroundLayer.addChild(sunContainer)
        
        // Solar flares
        createSolarParticles(from: sunContainer.position)
        
        // Mercury planet - gray, cratered surface visible
        let mercury = SKShapeNode(circleOfRadius: 35)
        mercury.position = CGPoint(x: size.width/3, y: -size.height/4)
        mercury.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 0.9)
        mercury.strokeColor = SKColor(red: 0.6, green: 0.55, blue: 0.5, alpha: 1.0)
        mercury.lineWidth = 2
        mercury.glowWidth = 3
        mercury.zPosition = -1
        backgroundLayer.addChild(mercury)
        
        // Add craters to Mercury
        for _ in 0..<5 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 10...25)
            crater.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            crater.fillColor = SKColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 0.7)
            crater.strokeColor = .clear
            mercury.addChild(crater)
        }
        
        // Scorched surface effect - hot side facing sun
        let hotSide = SKShapeNode(circleOfRadius: 34)
        hotSide.position = CGPoint(x: -10, y: 0)
        hotSide.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 0.2)
        hotSide.strokeColor = .clear
        hotSide.blendMode = .add
        mercury.addChild(hotSide)
        
        // Slow rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 88)
        mercury.run(SKAction.repeatForever(rotate))
        
        // Add destroyed mining equipment from failed operations
        createSpaceDebris(at: CGPoint(x: size.width/4, y: size.height/5), type: "mining")
        createBrokenStation(at: CGPoint(x: -size.width/4, y: -size.height/3))
    }
    
    private func createVenusBackground() {
        // Venus - Toxic atmosphere with sulfuric acid clouds
        createBasicStarfield(60)  // Very few stars visible through thick atmosphere
        
        // Sun visible through atmosphere
        let sun = SKNode()
        sun.position = CGPoint(x: -size.width/3, y: size.height/3)
        sun.zPosition = -4
        
        // Dimmer sun core (seen through Venus atmosphere)
        let sunCore = SKShapeNode(circleOfRadius: 45)
        sunCore.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.6)
        sunCore.strokeColor = .clear
        sunCore.glowWidth = 30
        sunCore.blendMode = .add
        sun.addChild(sunCore)
        
        // Sun corona through atmosphere
        for i in 1...2 {
            let corona = SKShapeNode(circleOfRadius: 45 + CGFloat(i * 15))
            corona.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.1 / CGFloat(i))
            corona.strokeColor = .clear
            corona.blendMode = .add
            sun.addChild(corona)
        }
        
        backgroundLayer.addChild(sun)
        
        // Venus planet - large with thick yellowish atmosphere
        let venusContainer = SKNode()
        venusContainer.position = CGPoint(x: size.width/4, y: -size.height/5)
        venusContainer.zPosition = -1
        
        let venus = SKShapeNode(circleOfRadius: 55)
        venus.fillColor = SKColor(red: 0.95, green: 0.85, blue: 0.5, alpha: 0.9)
        venus.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0)
        venus.lineWidth = 3
        venus.glowWidth = 20
        venusContainer.addChild(venus)
        
        // Surface details (barely visible through atmosphere)
        for _ in 0..<3 {
            let detail = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...15))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 20...40)
            detail.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            detail.fillColor = SKColor(red: 0.9, green: 0.75, blue: 0.4, alpha: 0.3)
            detail.strokeColor = .clear
            venus.addChild(detail)
        }
        
        // Swirling atmospheric bands
        for i in 0..<4 {
            let band = SKShapeNode(ellipseOf: CGSize(width: 110, height: 15))
            band.position = CGPoint(x: 0, y: CGFloat(i - 2) * 20)
            band.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 0.2)
            band.strokeColor = .clear
            venus.addChild(band)
            
            // Atmospheric movement
            let drift = SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 10...20))
            let reverse = drift.reversed()
            band.run(SKAction.repeatForever(SKAction.sequence([drift, reverse])))
        }
        
        // Slow retrograde rotation (Venus rotates backwards)
        let rotate = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 243)
        venus.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(venusContainer)
        
        // Thick toxic yellow-orange clouds
        for i in 0..<8 {
            let cloud = SKShapeNode(circleOfRadius: CGFloat.random(in: 40...80))
            cloud.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            cloud.fillColor = SKColor(
                red: 0.9 + CGFloat.random(in: -0.1...0.1),
                green: 0.7 + CGFloat.random(in: -0.1...0.1),
                blue: 0.2,
                alpha: 0.15
            )
            cloud.strokeColor = .clear
            cloud.blendMode = .add
            cloud.zPosition = CGFloat(i) * 0.1 - 2
            backgroundLayer.addChild(cloud)
            
            // Cloud movement
            let cloudDrift = SKAction.moveBy(
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -10...10),
                duration: Double.random(in: 20...40)
            )
            let reverse = cloudDrift.reversed()
            cloud.run(SKAction.repeatForever(SKAction.sequence([cloudDrift, reverse])))
        }
        
        // Lightning in the clouds (Venus has lightning)
        let lightningAction = SKAction.run { [weak self] in
            self?.createVenusLightning()
        }
        let wait = SKAction.wait(forDuration: Double.random(in: 3...8))
        run(SKAction.repeatForever(SKAction.sequence([wait, lightningAction])))
        
        // Destroyed floating cloud city
        createBrokenStation(at: CGPoint(x: -size.width/3, y: size.height/4))
    }
    
    private func createVenusLightning() {
        let lightning = SKShapeNode()
        let path = CGMutablePath()
        
        let startX = CGFloat.random(in: -size.width/2...size.width/2)
        let startY = CGFloat.random(in: -size.height/2...size.height/2)
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        // Create jagged lightning path
        var currentY = startY
        for _ in 0..<4 {
            currentY -= CGFloat.random(in: 20...40)
            let offsetX = startX + CGFloat.random(in: -30...30)
            path.addLine(to: CGPoint(x: offsetX, y: currentY))
        }
        
        lightning.path = path
        lightning.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)
        lightning.lineWidth = 2
        lightning.glowWidth = 8
        lightning.zPosition = 10
        lightning.blendMode = .add
        
        backgroundLayer.addChild(lightning)
        
        // Flash and fade
        let flash = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        lightning.run(flash)
    }
    
    private func createSolarParticles(from position: CGPoint) {
        // Create animated solar particles emanating from the sun
        let particleContainer = SKNode()
        particleContainer.position = position
        particleContainer.zPosition = -2
        backgroundLayer.addChild(particleContainer)
        
        // Create multiple solar flare streams
        for i in 0..<8 {
            let angle = CGFloat(i) * (CGFloat.pi * 2.0 / 8.0)
            
            // Create a stream of particles
            for j in 0..<3 {
                let delay = TimeInterval(j) * 0.5
                
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                particle.fillColor = SKColor(red: 1.0, green: CGFloat.random(in: 0.7...0.9), blue: CGFloat.random(in: 0.2...0.4), alpha: 1.0)
                particle.strokeColor = .clear
                particle.blendMode = .add
                particle.alpha = 0
                particleContainer.addChild(particle)
                
                // Animate particle moving outward from sun
                let distance = CGFloat.random(in: 80...150)
                let duration = TimeInterval.random(in: 4...7)
                let endPosition = CGPoint(
                    x: cos(angle) * distance,
                    y: sin(angle) * distance
                )
                
                let moveAction = SKAction.move(to: endPosition, duration: duration)
                let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1.0)
                let scaleUp = SKAction.scale(to: 1.5, duration: duration)
                
                let particleSequence = SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([fadeIn]),
                    SKAction.group([moveAction, scaleUp, SKAction.sequence([SKAction.wait(forDuration: duration - 1.0), fadeOut])])
                ])
                
                particle.run(SKAction.repeatForever(particleSequence))
            }
        }
        
        // Add occasional solar burst
        let burstAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.createSolarBurst(at: position)
        }
        let waitAction = SKAction.wait(forDuration: TimeInterval.random(in: 5...10))
        let burstSequence = SKAction.sequence([waitAction, burstAction])
        particleContainer.run(SKAction.repeatForever(burstSequence))
    }
    
    private func createSolarBurst(at position: CGPoint) {
        // Create a dramatic solar burst effect
        let burst = SKShapeNode(circleOfRadius: 15)
        burst.position = position
        burst.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.6)
        burst.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        burst.lineWidth = 2
        burst.glowWidth = 10
        burst.blendMode = .add
        burst.zPosition = -2
        burst.setScale(0.1)
        backgroundLayer.addChild(burst)
        
        // Animate the burst
        let scaleUp = SKAction.scale(to: 3.0, duration: 0.8)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.8)
        let remove = SKAction.removeFromParent()
        
        burst.run(SKAction.sequence([SKAction.group([scaleUp, fadeOut]), remove]))
    }
    
    private func createMarsBackground() {
        // Mars - The Red Planet with dust storms and two moons
        createBasicStarfield(150)  // Clear Martian sky
        
        // Mars planet - prominent red planet (moved down for better visibility)
        let marsContainer = SKNode()
        marsContainer.position = CGPoint(x: size.width/3, y: size.height/5 - 75)  // Moved down ~2cm
        marsContainer.zPosition = 1
        
        let mars = SKShapeNode(circleOfRadius: 50)
        mars.fillColor = SKColor(red: 0.75, green: 0.35, blue: 0.25, alpha: 0.9)
        mars.strokeColor = SKColor(red: 0.85, green: 0.45, blue: 0.35, alpha: 1.0)
        mars.lineWidth = 2
        mars.glowWidth = 6
        marsContainer.addChild(mars)
        
        // Polar ice caps
        let northCap = SKShapeNode(ellipseOf: CGSize(width: 25, height: 8))
        northCap.position = CGPoint(x: 0, y: 40)
        northCap.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
        northCap.strokeColor = .clear
        mars.addChild(northCap)
        
        let southCap = SKShapeNode(ellipseOf: CGSize(width: 20, height: 6))
        southCap.position = CGPoint(x: 0, y: -42)
        southCap.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.7)
        southCap.strokeColor = .clear
        mars.addChild(southCap)
        
        // Surface features - Valles Marineris (giant canyon)
        let canyon = SKShapeNode(rectOf: CGSize(width: 35, height: 3))
        canyon.position = CGPoint(x: 0, y: -5)
        canyon.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.15, alpha: 0.7)
        canyon.strokeColor = .clear
        canyon.zRotation = 0.2
        mars.addChild(canyon)
        
        // Olympus Mons (largest volcano)
        let volcano = SKShapeNode(circleOfRadius: 8)
        volcano.position = CGPoint(x: -15, y: 10)
        volcano.fillColor = SKColor(red: 0.6, green: 0.25, blue: 0.2, alpha: 0.8)
        volcano.strokeColor = .clear
        mars.addChild(volcano)
        
        // Dust storm regions
        for _ in 0..<4 {
            let storm = SKShapeNode(circleOfRadius: CGFloat.random(in: 10...20))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 15...35)
            storm.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            storm.fillColor = SKColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 0.3)
            storm.strokeColor = .clear
            storm.blendMode = .alpha
            mars.addChild(storm)
            
            // Swirling dust animation
            let swirl = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: Double.random(in: 8...15)),
                SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: Double.random(in: 8...15))
            ])
            storm.run(SKAction.repeatForever(swirl))
        }
        
        // Mars rotation (24.6 hours - similar to Earth)
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 25)
        mars.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(marsContainer)
        
        // Phobos - larger, closer moon with irregular shape
        let phobosOrbit = SKNode()
        phobosOrbit.position = marsContainer.position
        
        let phobos = SKShapeNode(ellipseOf: CGSize(width: 12, height: 10))
        phobos.position = CGPoint(x: 80, y: 0)
        phobos.fillColor = SKColor(red: 0.6, green: 0.55, blue: 0.5, alpha: 0.9)
        phobos.strokeColor = SKColor.gray
        phobos.lineWidth = 1
        phobosOrbit.addChild(phobos)
        
        // Phobos orbits Mars very quickly (7.6 hours)
        let phobosOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        phobosOrbit.run(SKAction.repeatForever(phobosOrbitAction))
        backgroundLayer.addChild(phobosOrbit)
        
        // Deimos - smaller, farther moon
        let deimosOrbit = SKNode()
        deimosOrbit.position = marsContainer.position
        
        let deimos = SKShapeNode(circleOfRadius: 5)
        deimos.position = CGPoint(x: 120, y: 0)
        deimos.fillColor = SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 0.8)
        deimos.strokeColor = .clear
        deimosOrbit.addChild(deimos)
        
        // Deimos orbits more slowly (30.3 hours)
        let deimosOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        deimosOrbit.run(SKAction.repeatForever(deimosOrbitAction))
        backgroundLayer.addChild(deimosOrbit)
        
        // Dust particles in atmosphere
        for _ in 0..<20 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            dust.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            dust.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 0.3)
            dust.strokeColor = .clear
            dust.zPosition = 2
            backgroundLayer.addChild(dust)
            
            // Floating dust animation
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -20...20), duration: Double.random(in: 10...20)),
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -20...20), duration: Double.random(in: 10...20))
            ])
            dust.run(SKAction.repeatForever(float))
        }
        
        // Destroyed Mars colony and rover
        createBrokenStation(at: CGPoint(x: -size.width/3, y: -size.height/4))
        createSpaceDebris(at: CGPoint(x: size.width/4, y: -size.height/3), type: "rover")
        
        // Add moving meteors (Mars gets hit frequently)
        createMovingMeteors()
    }
    
    private func createAsteroidBeltBackground() {
        // Asteroid Belt - Dense field of asteroids between Mars and Jupiter
        createBasicStarfield(120)
        
        // Create layers of asteroids for depth
        // Background layer - smaller, dimmer asteroids
        for _ in 0..<20 {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            asteroid.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            asteroid.fillColor = SKColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 0.5)
            asteroid.strokeColor = .clear
            asteroid.zPosition = -3
            backgroundLayer.addChild(asteroid)
            
            // Very slow drift
            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -10...10),
                duration: Double.random(in: 60...120)
            )
            asteroid.run(SKAction.repeatForever(SKAction.sequence([drift, drift.reversed()])))
        }
        
        // Main asteroid layer - various sizes and types
        for i in 0..<25 {
            let asteroidSize = CGFloat.random(in: 8...20)
            let asteroid = SKShapeNode(circleOfRadius: asteroidSize)
            asteroid.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            
            // Vary asteroid colors (different mineral compositions)
            let asteroidType = i % 3
            switch asteroidType {
            case 0:  // Carbonaceous (C-type) - most common
                asteroid.fillColor = SKColor(red: 0.3, green: 0.28, blue: 0.25, alpha: 0.9)
                asteroid.strokeColor = SKColor(red: 0.35, green: 0.33, blue: 0.3, alpha: 1.0)
            case 1:  // Silicaceous (S-type) - rocky
                asteroid.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 0.9)
                asteroid.strokeColor = SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 1.0)
            default:  // Metallic (M-type) - rare
                asteroid.fillColor = SKColor(red: 0.6, green: 0.55, blue: 0.5, alpha: 0.9)
                asteroid.strokeColor = SKColor(red: 0.7, green: 0.65, blue: 0.6, alpha: 1.0)
            }
            
            asteroid.lineWidth = 1
            asteroid.zPosition = -2
            backgroundLayer.addChild(asteroid)
            
            // Add craters for detail
            for _ in 0..<2 {
                let crater = SKShapeNode(circleOfRadius: asteroidSize * 0.2)
                crater.position = CGPoint(
                    x: CGFloat.random(in: -asteroidSize/2...asteroidSize/2),
                    y: CGFloat.random(in: -asteroidSize/2...asteroidSize/2)
                )
                crater.fillColor = SKColor.black.withAlphaComponent(0.3)
                crater.strokeColor = .clear
                asteroid.addChild(crater)
            }
            
            // Tumbling rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 20...60))
            asteroid.run(SKAction.repeatForever(rotate))
            
            // Orbital drift
            let orbitRadius = CGFloat.random(in: 20...50)
            let orbitDuration = Double.random(in: 30...90)
            let orbit = SKAction.follow(
                CGPath(ellipseIn: CGRect(x: -orbitRadius, y: -orbitRadius/3, width: orbitRadius*2, height: orbitRadius*2/3), transform: nil),
                asOffset: false,
                orientToPath: false,
                duration: orbitDuration
            )
            asteroid.run(SKAction.repeatForever(orbit))
        }
        
        // Ceres - the largest asteroid (dwarf planet)
        let ceres = SKShapeNode(circleOfRadius: 25)
        ceres.position = CGPoint(x: -size.width/4, y: size.height/4)
        ceres.fillColor = SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 0.95)
        ceres.strokeColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 1.0)
        ceres.lineWidth = 2
        ceres.glowWidth = 3
        ceres.zPosition = -1
        backgroundLayer.addChild(ceres)
        
        // Bright spot on Ceres (real feature)
        let brightSpot = SKShapeNode(circleOfRadius: 3)
        brightSpot.position = CGPoint(x: 5, y: 8)
        brightSpot.fillColor = SKColor.white.withAlphaComponent(0.8)
        brightSpot.strokeColor = .clear
        brightSpot.glowWidth = 2
        ceres.addChild(brightSpot)
        
        let ceresRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 9)
        ceres.run(SKAction.repeatForever(ceresRotate))
        
        // Mining operations debris
        createDestroyedShip(at: CGPoint(x: size.width/4, y: -size.height/3))
        createSpaceDebris(at: CGPoint(x: 0, y: size.height/3), type: "mining")
        createBrokenStation(at: CGPoint(x: -size.width/3, y: -size.height/4))
        
        // Asteroid dust particles
        for _ in 0..<15 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            dust.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            dust.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 0.2)
            dust.strokeColor = .clear
            dust.zPosition = 1
            backgroundLayer.addChild(dust)
            
            let float = SKAction.moveBy(
                x: CGFloat.random(in: -40...40),
                y: CGFloat.random(in: -40...40),
                duration: Double.random(in: 40...80)
            )
            dust.run(SKAction.repeatForever(SKAction.sequence([float, float.reversed()])))
        }
    }
    
    private func createJupiterBackground() {
        // Jupiter - The Solar System's largest planet with storm bands
        createBasicStarfield(140)
        
        // Jupiter container for rotation
        let jupiterContainer = SKNode()
        jupiterContainer.position = CGPoint(x: size.width/4, y: size.height/6)
        jupiterContainer.zPosition = 1
        
        // Jupiter - massive gas giant
        let jupiter = SKShapeNode(circleOfRadius: 90)
        jupiter.fillColor = SKColor(red: 0.85, green: 0.7, blue: 0.5, alpha: 0.9)
        jupiter.strokeColor = SKColor(red: 0.9, green: 0.75, blue: 0.55, alpha: 1.0)
        jupiter.lineWidth = 3
        jupiter.glowWidth = 10
        jupiterContainer.addChild(jupiter)
        
        // Storm bands across Jupiter - properly sized to fit within the planet
        let bandColors = [
            SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.7),   // Light zone
            SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.7),   // Dark belt
            SKColor(red: 0.95, green: 0.85, blue: 0.65, alpha: 0.6), // Light zone
            SKColor(red: 0.65, green: 0.45, blue: 0.25, alpha: 0.7), // Dark belt
            SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.6)    // Light zone
        ]
        
        // Create a crop node to clip bands to planet shape
        let cropNode = SKCropNode()
        let maskCircle = SKShapeNode(circleOfRadius: 88) // Slightly smaller than planet radius
        maskCircle.fillColor = .white
        maskCircle.strokeColor = .clear
        cropNode.maskNode = maskCircle
        jupiter.addChild(cropNode)
        
        for (index, color) in bandColors.enumerated() {
            let yPos = CGFloat(index - 2) * 30
            // Calculate band width based on position to fit within circle
            let distanceFromCenter = abs(yPos)
            let maxWidth = sqrt(max(0, 88 * 88 - distanceFromCenter * distanceFromCenter)) * 2
            
            let band = SKShapeNode(ellipseOf: CGSize(width: min(maxWidth, 170), height: 25))
            band.position = CGPoint(x: 0, y: yPos)
            band.fillColor = color
            band.strokeColor = .clear
            band.blendMode = .alpha
            cropNode.addChild(band)
            
            // Band movement (differential rotation)
            let bandDrift = SKAction.moveBy(
                x: CGFloat.random(in: -10...10),
                y: 0,
                duration: Double.random(in: 15...25)
            )
            band.run(SKAction.repeatForever(SKAction.sequence([bandDrift, bandDrift.reversed()])))
        }
        
        // Great Red Spot - giant storm
        let redSpotContainer = SKNode()
        redSpotContainer.position = CGPoint(x: 25, y: -20)
        
        let redSpot = SKShapeNode(ellipseOf: CGSize(width: 35, height: 25))
        redSpot.fillColor = SKColor(red: 0.75, green: 0.35, blue: 0.25, alpha: 0.8)
        redSpot.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.3, alpha: 1.0)
        redSpot.lineWidth = 2
        redSpotContainer.addChild(redSpot)
        
        // Storm swirl effect
        let swirl = SKShapeNode(ellipseOf: CGSize(width: 20, height: 15))
        swirl.position = CGPoint(x: 0, y: 0)
        swirl.fillColor = SKColor(red: 0.6, green: 0.25, blue: 0.15, alpha: 0.5)
        swirl.strokeColor = .clear
        redSpot.addChild(swirl)
        
        // Animate the storm
        let stormRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 6)
        redSpotContainer.run(SKAction.repeatForever(stormRotate))
        
        jupiter.addChild(redSpotContainer)
        
        // Jupiter rotation (9.9 hours - very fast)
        let jupiterRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 10)
        jupiter.run(SKAction.repeatForever(jupiterRotate))
        
        backgroundLayer.addChild(jupiterContainer)
        
        // Galilean Moons - the four largest moons
        // Io - volcanic moon
        let ioOrbit = SKNode()
        ioOrbit.position = jupiterContainer.position
        
        let io = SKShapeNode(circleOfRadius: 12)
        io.position = CGPoint(x: 140, y: 0)
        io.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.5, alpha: 0.9)
        io.strokeColor = SKColor.yellow
        io.lineWidth = 1
        io.glowWidth = 2
        
        // Volcanic spots on Io
        for _ in 0..<2 {
            let volcano = SKShapeNode(circleOfRadius: 2)
            volcano.position = CGPoint(
                x: CGFloat.random(in: -6...6),
                y: CGFloat.random(in: -6...6)
            )
            volcano.fillColor = SKColor.orange
            volcano.strokeColor = .clear
            io.addChild(volcano)
        }
        
        ioOrbit.addChild(io)
        let ioOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        ioOrbit.run(SKAction.repeatForever(ioOrbitAction))
        backgroundLayer.addChild(ioOrbit)
        
        // Europa - ice moon
        let europaOrbit = SKNode()
        europaOrbit.position = jupiterContainer.position
        
        let europa = SKShapeNode(circleOfRadius: 10)
        europa.position = CGPoint(x: 180, y: 0)
        europa.fillColor = SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.9)
        europa.strokeColor = SKColor.cyan.withAlphaComponent(0.5)
        europa.lineWidth = 1
        europaOrbit.addChild(europa)
        
        let europaOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 35)
        europaOrbit.run(SKAction.repeatForever(europaOrbitAction))
        backgroundLayer.addChild(europaOrbit)
        
        // Ganymede - largest moon
        let ganymedeOrbit = SKNode()
        ganymedeOrbit.position = jupiterContainer.position
        
        let ganymede = SKShapeNode(circleOfRadius: 15)
        ganymede.position = CGPoint(x: 220, y: 0)
        ganymede.fillColor = SKColor(red: 0.6, green: 0.55, blue: 0.5, alpha: 0.9)
        ganymede.strokeColor = SKColor.gray
        ganymede.lineWidth = 1
        ganymedeOrbit.addChild(ganymede)
        
        let ganymedeOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 70)
        ganymedeOrbit.run(SKAction.repeatForever(ganymedeOrbitAction))
        backgroundLayer.addChild(ganymedeOrbit)
        
        // Destroyed research station in Jupiter's magnetosphere
        createBrokenStation(at: CGPoint(x: -size.width/3, y: -size.height/4))
        
        // Add radiation effect (Jupiter has intense radiation)
        for _ in 0..<10 {
            let radiation = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            radiation.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            radiation.fillColor = SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.2)
            radiation.strokeColor = .clear
            radiation.glowWidth = 2
            radiation.zPosition = 3
            backgroundLayer.addChild(radiation)
            
            // Radiation particle movement
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.1, duration: Double.random(in: 0.5...1.5))
            ])
            radiation.run(SKAction.repeatForever(flash))
        }
    }
    
    private func createNeptuneBackground() {
        // Neptune - The deep blue ice giant with powerful winds and storms
        createBasicStarfield(120)
        
        // Neptune container for rotation
        let neptuneContainer = SKNode()
        neptuneContainer.position = CGPoint(x: size.width/3, y: size.height/6)
        neptuneContainer.zPosition = 1
        
        // Neptune - larger ice giant with deep blue color
        let neptune = SKShapeNode(circleOfRadius: 120)  // Larger than Jupiter (90)
        neptune.fillColor = SKColor(red: 0.15, green: 0.3, blue: 0.8, alpha: 0.9)
        neptune.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
        neptune.lineWidth = 4
        neptune.glowWidth = 15
        neptuneContainer.addChild(neptune)
        
        // Atmospheric bands - subtle compared to Jupiter
        let bandColors = [
            SKColor(red: 0.2, green: 0.35, blue: 0.85, alpha: 0.4),   // Light blue
            SKColor(red: 0.1, green: 0.25, blue: 0.7, alpha: 0.5),    // Darker blue
            SKColor(red: 0.25, green: 0.4, blue: 0.9, alpha: 0.3),    // Bright blue
            SKColor(red: 0.05, green: 0.2, blue: 0.6, alpha: 0.6),    // Deep blue
        ]
        
        // Create atmospheric bands
        let bandsContainer = SKNode()
        for (index, color) in bandColors.enumerated() {
            let bandY = CGFloat(index - 1) * 30 - 15
            let band = SKShapeNode(rect: CGRect(x: -115, y: bandY, width: 230, height: 25))
            band.fillColor = color
            band.strokeColor = .clear
            
            // Clip to planet shape
            let cropNode = SKCropNode()
            let maskCircle = SKShapeNode(circleOfRadius: 118)
            maskCircle.fillColor = .white
            maskCircle.strokeColor = .clear
            cropNode.maskNode = maskCircle
            cropNode.addChild(band)
            bandsContainer.addChild(cropNode)
            
            // Animate band drift
            let drift = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 0, duration: Double.random(in: 20...40))
            band.run(SKAction.repeatForever(SKAction.sequence([drift, drift.reversed()])))
        }
        neptune.addChild(bandsContainer)
        
        // Great Dark Spot - Neptune's massive storm
        let darkSpotContainer = SKNode()
        darkSpotContainer.position = CGPoint(x: -30, y: 40)
        
        let darkSpot = SKShapeNode(ellipseOf: CGSize(width: 45, height: 30))
        darkSpot.fillColor = SKColor(red: 0.05, green: 0.15, blue: 0.4, alpha: 0.8)
        darkSpot.strokeColor = SKColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
        darkSpot.lineWidth = 2
        darkSpotContainer.addChild(darkSpot)
        
        // Storm swirl effect
        let swirl = SKShapeNode(ellipseOf: CGSize(width: 25, height: 18))
        swirl.position = CGPoint(x: 0, y: 0)
        swirl.fillColor = SKColor(red: 0.02, green: 0.1, blue: 0.3, alpha: 0.6)
        swirl.strokeColor = .clear
        darkSpot.addChild(swirl)
        
        // Animate the storm
        let stormRotate = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 8) // Counter-clockwise
        darkSpotContainer.run(SKAction.repeatForever(stormRotate))
        
        neptune.addChild(darkSpotContainer)
        
        // Neptune rotation (16 hours)
        let neptuneRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 16)
        neptune.run(SKAction.repeatForever(neptuneRotate))
        
        gameplayLayer.addChild(neptuneContainer)
        
        // Triton - Neptune's largest moon (retrograde orbit)
        let tritonOrbit = SKNode()
        tritonOrbit.position = neptuneContainer.position
        
        let triton = SKShapeNode(circleOfRadius: 18)
        triton.position = CGPoint(x: 180, y: 0)
        triton.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.9)
        triton.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
        triton.lineWidth = 1
        triton.glowWidth = 3
        
        // Triton's nitrogen geysers
        for _ in 0..<3 {
            let geyser = SKShapeNode(circleOfRadius: 1.5)
            geyser.position = CGPoint(
                x: CGFloat.random(in: -8...8),
                y: CGFloat.random(in: -8...8)
            )
            geyser.fillColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.7)
            geyser.strokeColor = .clear
            triton.addChild(geyser)
            
            // Geyser animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 2.0, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.wait(forDuration: Double.random(in: 2...5))
            ])
            geyser.run(SKAction.repeatForever(pulse))
        }
        
        tritonOrbit.addChild(triton)
        backgroundLayer.addChild(tritonOrbit)
        
        // Retrograde orbit animation (opposite direction)
        let tritonOrbitAnimation = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 25)
        tritonOrbit.run(SKAction.repeatForever(tritonOrbitAnimation))
        
        // Distant ice particles and cosmic dust
        for _ in 0..<25 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.0))
            particle.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            particle.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: CGFloat.random(in: 0.2...0.5))
            particle.strokeColor = .clear
            particle.zPosition = 1
            backgroundLayer.addChild(particle)
            
            // Slow drift animation - constrained to prevent edge visibility
            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -20...20),
                duration: Double.random(in: 60...120)
            )
            particle.run(SKAction.repeatForever(SKAction.sequence([drift, drift.reversed()])))
        }
        
        // Add distant stars with blue tint
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            star.fillColor = SKColor(red: 0.7, green: 0.8, blue: 1.0, alpha: CGFloat.random(in: 0.4...0.8))
            star.strokeColor = .clear
            star.zPosition = 1
            backgroundLayer.addChild(star)
            
            // Twinkling animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
    }
    
    private func createSaturnBackground() {
        // Saturn - The ringed planet with magnificent ring system
        createBasicStarfield(140)
        
        // Saturn container
        let saturnContainer = SKNode()
        saturnContainer.position = CGPoint(x: -size.width/4, y: size.height/5)
        saturnContainer.zPosition = 1
        
        // Saturn planet
        let saturn = SKShapeNode(circleOfRadius: 70)
        saturn.fillColor = SKColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 0.9)
        saturn.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.65, alpha: 1.0)
        saturn.lineWidth = 2
        saturn.glowWidth = 8
        saturnContainer.addChild(saturn)
        
        // Saturn's bands (less pronounced than Jupiter)
        for i in 0..<3 {
            let band = SKShapeNode(ellipseOf: CGSize(width: 140, height: 20))
            band.position = CGPoint(x: 0, y: CGFloat(i - 1) * 35)
            band.fillColor = SKColor(
                red: 0.9 + CGFloat.random(in: -0.05...0.05),
                green: 0.8 + CGFloat.random(in: -0.05...0.05),
                blue: 0.55 + CGFloat.random(in: -0.05...0.05),
                alpha: 0.3
            )
            band.strokeColor = .clear
            saturn.addChild(band)
        }
        
        // Hexagonal storm at north pole (real Saturn feature)
        let hexStorm = SKShapeNode()
        let hexPath = CGMutablePath()
        for i in 0...6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let point = CGPoint(x: cos(angle) * 15, y: sin(angle) * 15 + 55)
            if i == 0 {
                hexPath.move(to: point)
            } else {
                hexPath.addLine(to: point)
            }
        }
        hexStorm.path = hexPath
        hexStorm.fillColor = SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 0.5)
        hexStorm.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.8)
        hexStorm.lineWidth = 1
        saturn.addChild(hexStorm)
        
        // Saturn rotation (10.7 hours)
        let saturnRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 11)
        saturn.run(SKAction.repeatForever(saturnRotate))
        
        gameplayLayer.addChild(saturnContainer)
        
        // Saturn's spectacular ring system - multiple rings
        let ringData = [
            (radius: 90, width: 8, alpha: 0.7),   // D Ring (innermost)
            (radius: 100, width: 10, alpha: 0.8),  // C Ring
            (radius: 115, width: 15, alpha: 0.9),  // B Ring (brightest)
            (radius: 135, width: 12, alpha: 0.8),  // A Ring
            (radius: 150, width: 5, alpha: 0.5),   // F Ring
            (radius: 160, width: 3, alpha: 0.3)    // G Ring (faint)
        ]
        
        for (index, ring) in ringData.enumerated() {
            let ringNode = SKShapeNode(ellipseOf: CGSize(width: CGFloat(ring.radius) * 2, height: CGFloat(ring.radius) * 0.5))
            ringNode.position = saturnContainer.position
            ringNode.strokeColor = SKColor(
                red: 0.85 + CGFloat.random(in: -0.1...0.1),
                green: 0.75 + CGFloat.random(in: -0.1...0.1),
                blue: 0.55 + CGFloat.random(in: -0.1...0.1),
                alpha: CGFloat(ring.alpha)
            )
            ringNode.lineWidth = CGFloat(ring.width)
            ringNode.fillColor = .clear
            ringNode.zPosition = index % 2 == 0 ? -3 : -1  // Alternate ring z-positions for Saturn passing effect
            backgroundLayer.addChild(ringNode)
            
            // Subtle ring particle movement
            let ringRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double(20 + index * 3))
            ringNode.run(SKAction.repeatForever(ringRotate))
        }
        
        // Cassini Division (gap between rings)
        let cassiniGap = SKShapeNode(ellipseOf: CGSize(width: 250, height: 62))
        cassiniGap.position = saturnContainer.position
        cassiniGap.strokeColor = SKColor.black.withAlphaComponent(0.5)
        cassiniGap.lineWidth = 4
        cassiniGap.fillColor = .clear
        cassiniGap.zPosition = -0.5
        backgroundLayer.addChild(cassiniGap)
        
        // Titan - Saturn's largest moon
        let titanOrbit = SKNode()
        titanOrbit.position = saturnContainer.position
        
        let titan = SKShapeNode(circleOfRadius: 18)
        titan.position = CGPoint(x: 200, y: 0)
        titan.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 0.9)
        titan.strokeColor = SKColor.orange.withAlphaComponent(0.5)
        titan.lineWidth = 2
        titan.glowWidth = 3
        
        // Titan's thick atmosphere
        let atmosphere = SKShapeNode(circleOfRadius: 20)
        atmosphere.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 0.2)
        atmosphere.strokeColor = .clear
        titan.addChild(atmosphere)
        
        titanOrbit.addChild(titan)
        let titanOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 50)
        titanOrbit.run(SKAction.repeatForever(titanOrbitAction))
        backgroundLayer.addChild(titanOrbit)
        
        // Enceladus - ice moon with geysers
        let enceladusOrbit = SKNode()
        enceladusOrbit.position = saturnContainer.position
        
        let enceladus = SKShapeNode(circleOfRadius: 8)
        enceladus.position = CGPoint(x: 250, y: 0)
        enceladus.fillColor = SKColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 0.95)
        enceladus.strokeColor = SKColor.white
        enceladus.lineWidth = 1
        enceladus.glowWidth = 2
        enceladusOrbit.addChild(enceladus)
        
        let enceladusOrbitAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        enceladusOrbit.run(SKAction.repeatForever(enceladusOrbitAction))
        backgroundLayer.addChild(enceladusOrbit)
        
        // Ring debris and destroyed ships
        createDestroyedShip(at: CGPoint(x: size.width/4, y: -size.height/4))
        createSpaceDebris(at: CGPoint(x: -size.width/3, y: 0), type: "satellite")
    }
    
    private func createOuterPlanetsBackground() {
        // Enhanced outer planets with dynamic animations based on map
        createBasicStarfield(200)
        
        // Create map-specific planetary scenes
        // NOTE: Maps 5-10 have custom planet backgrounds added by addMapSpecificBackground()
        // So we skip creating duplicate planets for those maps
        switch currentMap {
        case 5, 6, 7, 8, 9, 10:
            // These maps have custom planets added by addMapSpecificBackground()
            // Don't create duplicate planets here
            break
        case 11: // Moon (if not handled by addMapSpecificBackground)
            createAnimatedMoon()
        case 12: // Mars (if not handled by addMapSpecificBackground)
            createAnimatedMars()
        default:
            // Generic outer planet
            createGenericOuterPlanet()
        }
        
        // Add dynamic space phenomena for all outer maps
        createSpacePhenomena()
        
        // Alien portal in the distance
        createAlienPortal(at: CGPoint(x: -size.width/3, y: -size.height/3))
        
        // Multiple destroyed ships
        createDestroyedShip(at: CGPoint(x: 0, y: size.height/5))
        createBrokenStation(at: CGPoint(x: size.width/3, y: -size.height/4))
    }
    
    private func createAnimatedSaturn() {
        // Saturn with animated rings
        let planet = SKShapeNode(circleOfRadius: 45)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.7)
        planet.strokeColor = SKColor.yellow.withAlphaComponent(0.8)
        planet.lineWidth = 2
        planet.glowWidth = 8
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
        
        // Animated rings
        for i in 0..<3 {
            let ringRadius = 55 + CGFloat(i * 8)
            let ring = SKShapeNode(ellipseOf: CGSize(width: ringRadius * 2, height: ringRadius * 0.3))
            ring.position = planet.position
            ring.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.4, alpha: 0.6)
            ring.lineWidth = 2
            ring.fillColor = .clear
            ring.zPosition = -2
            backgroundLayer.addChild(ring)
            
            // Ring rotation animation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double(10 + i * 5))
            ring.run(SKAction.repeatForever(rotate))
        }
    }
    
    private func createAnimatedJupiter() {
        // Jupiter with swirling storm bands
        let planet = SKShapeNode(circleOfRadius: 50)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 0.8)
        planet.strokeColor = SKColor.orange.withAlphaComponent(0.8)
        planet.lineWidth = 3
        planet.glowWidth = 10
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
        
        // Create crop node to contain bands within planet
        let cropNode = SKCropNode()
        let maskCircle = SKShapeNode(circleOfRadius: 48)
        maskCircle.fillColor = .white
        maskCircle.strokeColor = .clear
        cropNode.maskNode = maskCircle
        planet.addChild(cropNode)
        
        // Animated storm bands - properly contained
        for i in 0..<5 {
            let yPos = CGFloat(i - 2) * 15
            // Calculate band width to fit within circle
            let distanceFromCenter = abs(yPos)
            let maxWidth = sqrt(max(0, 48 * 48 - distanceFromCenter * distanceFromCenter)) * 2
            
            let band = SKShapeNode(ellipseOf: CGSize(width: min(maxWidth, 95), height: 12))
            band.position = CGPoint(x: 0, y: yPos)
            band.fillColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 0.4)
            band.strokeColor = .clear
            cropNode.addChild(band)
            
            // Band movement animation
            let drift = SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 8...15))
            let reverse = drift.reversed()
            band.run(SKAction.repeatForever(SKAction.sequence([drift, reverse])))
        }
        
        // Great Red Spot
        let redSpot = SKShapeNode(ellipseOf: CGSize(width: 20, height: 15))
        redSpot.position = CGPoint(x: 15, y: -10)
        redSpot.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.8)
        redSpot.strokeColor = .clear
        planet.addChild(redSpot)
        
        let storm = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        redSpot.run(SKAction.repeatForever(storm))
    }
    
    private func createAnimatedMars() {
        // Mars with dust storms
        let planet = SKShapeNode(circleOfRadius: 40)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.8)
        planet.strokeColor = SKColor.red.withAlphaComponent(0.8)
        planet.lineWidth = 2
        planet.glowWidth = 6
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
        
        // Dust storm effects
        for _ in 0..<8 {
            let storm = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...12))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 20...35)
            storm.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            storm.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.3)
            storm.strokeColor = .clear
            planet.addChild(storm)
            
            // Swirling storm animation
            let swirl = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 6...12))
            storm.run(SKAction.repeatForever(swirl))
        }
    }
    
    private func createAnimatedMoon() {
        // Moon with visible craters and phases
        let planet = SKShapeNode(circleOfRadius: 35)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.9)
        planet.strokeColor = SKColor.white.withAlphaComponent(0.8)
        planet.lineWidth = 2
        planet.glowWidth = 4
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
        
        // Add craters
        for _ in 0..<6 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 10...25)
            crater.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            crater.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8)
            crater.strokeColor = .clear
            planet.addChild(crater)
        }
        
        // Phase lighting effect
        let shadow = SKShapeNode(circleOfRadius: 35)
        shadow.position = CGPoint(x: 10, y: 0)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        planet.addChild(shadow)
    }
    
    private func createAnimatedEarth() {
        // Earth with continents and cloud movement
        let planet = SKShapeNode(circleOfRadius: 45)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.9)
        planet.strokeColor = SKColor.blue.withAlphaComponent(0.8)
        planet.lineWidth = 3
        planet.glowWidth = 8
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
        
        // Add continents
        createEarthContinents(on: planet)
        
        // Moving clouds
        let cloudLayer = SKShapeNode(circleOfRadius: 47)
        cloudLayer.fillColor = SKColor.white.withAlphaComponent(0.15)
        cloudLayer.strokeColor = .clear
        cloudLayer.blendMode = .add
        backgroundLayer.addChild(cloudLayer)
        cloudLayer.position = planet.position
        
        let cloudRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        cloudLayer.run(SKAction.repeatForever(cloudRotate))
        
        // Atmospheric glow
        let atmosphere = SKShapeNode(circleOfRadius: 50)
        atmosphere.fillColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.1)
        atmosphere.strokeColor = .clear
        atmosphere.blendMode = .add
        atmosphere.position = planet.position
        backgroundLayer.addChild(atmosphere)
    }
    
    private func createGenericOuterPlanet() {
        // Generic ice planet
        let planet = SKShapeNode(circleOfRadius: 35)
        planet.position = CGPoint(x: size.width/4, y: size.height/4)
        planet.fillColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 0.5)
        planet.strokeColor = SKColor.cyan.withAlphaComponent(0.5)
        planet.lineWidth = 2
        planet.glowWidth = 6
        planet.zPosition = -1
        backgroundLayer.addChild(planet)
    }
    
    private func createSpacePhenomena() {
        // Add nebula effects
        for _ in 0..<3 {
            let nebula = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 60...120), height: CGFloat.random(in: 40...80)))
            nebula.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            nebula.fillColor = SKColor(red: CGFloat.random(in: 0.2...0.8), green: CGFloat.random(in: 0.1...0.6), blue: CGFloat.random(in: 0.4...1.0), alpha: 0.1)
            nebula.strokeColor = .clear
            nebula.blendMode = .add
            nebula.zPosition = -5
            backgroundLayer.addChild(nebula)
            
            // Slow breathing animation
            let breathe = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: Double.random(in: 8...12)),
                SKAction.scale(to: 0.9, duration: Double.random(in: 8...12))
            ])
            nebula.run(SKAction.repeatForever(breathe))
        }
    }
    
    private func createEarthContinents(on planet: SKShapeNode) {
        // Replace continents with clouds for consistency
        // Planet radius is 45, so keep clouds well within bounds
        for _ in 0..<6 {
            let cloud = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 8...15), height: CGFloat.random(in: 6...12)))
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: 0...30) // Well within planet radius of 45
            cloud.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            cloud.fillColor = SKColor.white.withAlphaComponent(0.7)
            cloud.strokeColor = .clear
            cloud.alpha = CGFloat.random(in: 0.5...0.8)
            cloud.blendMode = .alpha
            cloud.zRotation = CGFloat.random(in: 0...CGFloat.pi)
            planet.addChild(cloud)
        }
    }
    
    // Helper functions for creating background elements
    private func createBasicStarfield(_ count: Int) {
        // Add moving space debris
        createMovingSpaceDebris()
        for i in 0..<count {
            let x = CGFloat.random(in: -size.width/2...size.width/2)
            let y = CGFloat.random(in: -size.height/2...size.height/2)
            
            let starSize = CGFloat.random(in: 0.5...2)
            let star = SKShapeNode(circleOfRadius: starSize)
            star.position = CGPoint(x: x, y: y)
            star.fillColor = SKColor.white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.7)
            star.zPosition = -10
            
            // Add occasional bright stars with glow
            if i % 15 == 0 {
                star.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
                star.glowWidth = starSize * 2
                star.blendMode = .add
                
                // Enhanced shining animation for bright stars
                let shine = SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 3...5)),
                        SKAction.scale(to: 0.8, duration: Double.random(in: 3...5))
                    ]),
                    SKAction.group([
                        SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 3...5)),
                        SKAction.scale(to: 1.2, duration: Double.random(in: 3...5))
                    ])
                ])
                star.run(SKAction.repeatForever(shine))
            } else {
                // Regular twinkle animation
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 2...4)),
                    SKAction.fadeAlpha(to: 0.7, duration: Double.random(in: 2...4))
                ])
                star.run(SKAction.repeatForever(twinkle))
            }
            
            backgroundLayer.addChild(star)
        }
    }
    
    private func createAsteroid(at position: CGPoint) {
        let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...15))
        asteroid.position = position
        asteroid.fillColor = SKColor.gray.withAlphaComponent(0.6)
        asteroid.strokeColor = SKColor.darkGray
        asteroid.lineWidth = 1
        asteroid.zPosition = -3
        
        // Slow rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 20...40))
        asteroid.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(asteroid)
    }
    
    private func createDestroyedShip(at position: CGPoint) {
        // Main hull
        let hull = SKShapeNode(rectOf: CGSize(width: 40, height: 15))
        hull.position = position
        hull.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
        hull.strokeColor = SKColor.gray
        hull.lineWidth = 1
        hull.zPosition = -2
        hull.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
        
        // Broken wing
        let wing = SKShapeNode(rectOf: CGSize(width: 20, height: 5))
        wing.position = CGPoint(x: 15, y: 5)
        wing.fillColor = SKColor.darkGray.withAlphaComponent(0.4)
        wing.strokeColor = SKColor.gray
        wing.zRotation = CGFloat.random(in: -0.5...0.5)
        hull.addChild(wing)
        
        // Debris particles
        for _ in 0..<5 {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            debris.position = CGPoint(
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -20...20)
            )
            debris.fillColor = SKColor.gray.withAlphaComponent(0.3)
            debris.strokeColor = .clear
            hull.addChild(debris)
        }
        
        backgroundLayer.addChild(hull)
    }
    
    private func createBrokenStation(at position: CGPoint) {
        // Station core
        let core = SKShapeNode(circleOfRadius: 20)
        core.position = position
        core.fillColor = .clear
        core.strokeColor = SKColor.gray.withAlphaComponent(0.5)
        core.lineWidth = 2
        core.zPosition = -2
        
        // Broken rings
        for i in 0..<2 {
            let ring = SKShapeNode(circleOfRadius: 30 + CGFloat(i * 15))
            ring.strokeColor = SKColor.gray.withAlphaComponent(0.3)
            ring.lineWidth = 1
            ring.fillColor = .clear
            
            // Add breaks in the rings
            let path = CGMutablePath()
            path.addArc(center: .zero, radius: 30 + CGFloat(i * 15), 
                       startAngle: 0, endAngle: CGFloat.pi * 1.5, clockwise: false)
            ring.path = path
            
            core.addChild(ring)
        }
        
        backgroundLayer.addChild(core)
    }
    
    private func createSpaceDebris(at position: CGPoint, type: String) {
        let debris = SKNode()
        debris.position = position
        debris.zPosition = -2
        
        // Different debris based on type
        if type == "mining" {
            // Mining equipment
            let drill = SKShapeNode(rectOf: CGSize(width: 15, height: 5))
            drill.fillColor = SKColor.brown.withAlphaComponent(0.4)
            drill.strokeColor = SKColor.orange.withAlphaComponent(0.5)
            drill.position = CGPoint(x: 0, y: 0)
            drill.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            debris.addChild(drill)
        }
        
        // Add some floating metal pieces
        for _ in 0..<8 {
            let piece = SKShapeNode(rectOf: CGSize(
                width: CGFloat.random(in: 2...8),
                height: CGFloat.random(in: 2...8)
            ))
            piece.position = CGPoint(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -30...30)
            )
            piece.fillColor = SKColor.gray.withAlphaComponent(0.3)
            piece.strokeColor = .clear
            piece.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            debris.addChild(piece)
        }
        
        backgroundLayer.addChild(debris)
    }
    
    private func createAlienPortal(at position: CGPoint) {
        // Portal effect
        let portal = SKShapeNode(circleOfRadius: 25)
        portal.position = position
        portal.fillColor = .clear
        portal.strokeColor = SKColor.purple.withAlphaComponent(0.5)
        portal.lineWidth = 3
        portal.glowWidth = 10
        portal.zPosition = -1
        
        // Inner swirl
        let inner = SKShapeNode(circleOfRadius: 15)
        inner.fillColor = SKColor.purple.withAlphaComponent(0.2)
        inner.strokeColor = SKColor.purple.withAlphaComponent(0.8)
        inner.lineWidth = 2
        inner.glowWidth = 5
        portal.addChild(inner)
        
        // Rotation animation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 5)
        portal.run(SKAction.repeatForever(rotate))
        
        // Pulsing effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2),
            SKAction.scale(to: 1.0, duration: 2)
        ])
        inner.run(SKAction.repeatForever(pulse))
        
        backgroundLayer.addChild(portal)
    }
    
    private func advanceToNextMap() {
        // Stop current activities and reset wave state completely
        isWaveActive = false
        isCheckingWaveCompletion = false  // Reset completion check flag
        removeAction(forKey: "waveSpawning")
        removeAction(forKey: "enemySpawning")
        removeAction(forKey: "waveCompletionCheck")
        
        // Clear all game elements
        enemyLayer.removeAllChildren()
        projectileLayer.removeAllChildren()
        effectsLayer.removeAllChildren()
        towerLayer.removeAllChildren()  // Clear towers too
        
        // Clear the existing map completely but preserve structure
        gameplayLayer.removeAllChildren()
        
        // Re-add the essential layers to their correct parents
        // backgroundLayer should be a child of the scene, NOT gameplayLayer
        if backgroundLayer.parent == nil {
            addChild(backgroundLayer)
        }
        if gameplayLayer.parent == nil {
            addChild(gameplayLayer)
        }
        // These layers should be children of gameplayLayer
        if towerLayer.parent == nil {
            gameplayLayer.addChild(towerLayer)
        }
        if enemyLayer.parent == nil {
            gameplayLayer.addChild(enemyLayer)
        }
        if projectileLayer.parent == nil {
            gameplayLayer.addChild(projectileLayer)
        }
        if effectsLayer.parent == nil {
            gameplayLayer.addChild(effectsLayer)
        }
        
        // Advance to next map
        currentMap += 1
        if currentMap > 17 { // We now have 17 beautiful maps in vector_maps.txt
            currentMap = 1 // Loop back to map 1
        }
        
        // Reset wave for new map
        currentWave = 1
        enemiesSpawned = 0
        enemiesDestroyed = 0
        enemiesPerWave = 10
        
        // Clear and recreate background for new map (especially for map 3 galaxy)
        backgroundLayer.removeAllChildren()
        createStarBackground()
        
        // Re-add map-specific planet backgrounds after clearing
        addMapSpecificBackground()
        
        // Give starting salvage for new map (scales with map number)
        // More generous starting salvage for better upgrades early on
        let startingSalvage = 250 + ((currentMap - 1) * 75)  // 250 for map 1, 325 for map 2, 400 for map 3, etc.
        playerSalvage = startingSalvage
        print("Starting map \(currentMap) with \(startingSalvage) salvage")
        showMessage("Starting salvage: \(startingSalvage)", at: CGPoint(x: 0, y: -50), color: .green)
        
        // Load the new vector map
        if SimpleVectorMapLoader.shared.createVectorMapNodes(mapNumber: currentMap, in: gameplayLayer) {
            print("✅ Successfully loaded vector map \(currentMap)")
            
            // Add Proxima B star system for Map 2
            if currentMap == 2 {
                addProximaBStarSystem()
            }
        } else {
            print("⚠️ Vector map \(currentMap) not found, using fallback")
            createMap()
            loadMapLayout()
        }
        
        // Update waves per map
        updateWavesPerMap()
        
        // Show map change message
        showMessage("Map \(currentMap) Loaded!", at: CGPoint(x: 0, y: 0), color: .cyan)
        
        // Recreate control buttons (speed and next level stay visible)
        createControlButtons()
        
        // Recreate start wave button for the new map
        createStartWaveButton()
        
        // Update HUD
        updateHUD()
        
        // Show ready message for the new map
        showReadyForNextWaveMessage()
        
        print("Advanced to map \(currentMap) - Ready to start!")
    }
    
    private func checkWaveCompletion() {
        // Only check if not already checking to prevent multiple triggers
        guard !isCheckingWaveCompletion else { return }
        
        let enemyCount = enemyLayer.children.count
        
        // Wave is complete when no enemies remain and all have been spawned
        if enemyCount == 0 && enemiesSpawned >= enemiesPerWave && isWaveActive {
            // Set flag to prevent multiple completions
            isCheckingWaveCompletion = true
            completeWave()
        }
    }
    
    private func createFloatingText(_ text: String, at position: CGPoint, color: SKColor) {
        let floatingLabel = SKLabelNode(text: text)
        floatingLabel.fontSize = 16
        floatingLabel.fontName = "AvenirNext-Bold"
        floatingLabel.fontColor = color
        floatingLabel.position = position
        floatingLabel.zPosition = 500
        
        effectsLayer.addChild(floatingLabel)
        
        // Animate floating up and fading out
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        
        floatingLabel.run(SKAction.sequence([group, remove]))
    }
    
    private func createDeathEffect(for target: SKNode, towerType: String) {
        // Create death effect - stub implementation
        print("Death effect created for \(towerType)")
    }
    
    private func createHitEffect(on target: SKNode, damageType: String, damage: Int) {
        // Create hit effect - stub implementation
        print("Hit effect created: \(damageType) for \(damage) damage")
    }
    
    private func createHitEffect(at position: CGPoint, towerType: String) {
        // Create hit effect at position - stub implementation
        print("Hit effect created at \(position) for \(towerType)")
    }
    
    private func createMovingSpaceDebris() {
        // Create 5-8 pieces of floating debris
        for _ in 0..<Int.random(in: 5...8) {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            debris.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            debris.fillColor = SKColor.gray.withAlphaComponent(CGFloat.random(in: 0.2...0.4))
            debris.strokeColor = .clear
            debris.zPosition = -8
            debris.name = "spaceDebris"
            
            // Random rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: Double.random(in: 10...20))
            debris.run(SKAction.repeatForever(rotate))
            
            // Slow drift movement
            let moveX = CGFloat.random(in: -30...30)
            let moveY = CGFloat.random(in: -30...30)
            let duration = Double.random(in: 15...25)
            
            let drift = SKAction.sequence([
                SKAction.moveBy(x: moveX, y: moveY, duration: duration),
                SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            ])
            debris.run(SKAction.repeatForever(drift))
            
            backgroundLayer.addChild(debris)
        }
    }
    
    private func createMovingMeteors() {
        // Create 3-5 moving meteors/asteroids
        for _ in 0..<Int.random(in: 3...5) {
            let meteor = SKNode()
            
            // Create meteor shape with irregular edges
            let meteorBody = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...15))
            meteorBody.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.8)
            meteorBody.strokeColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
            meteorBody.lineWidth = 1
            meteor.addChild(meteorBody)
            
            // Add some crater details
            for _ in 0..<2 {
                let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
                crater.position = CGPoint(
                    x: CGFloat.random(in: -5...5),
                    y: CGFloat.random(in: -5...5)
                )
                crater.fillColor = SKColor.black.withAlphaComponent(0.3)
                crater.strokeColor = .clear
                meteorBody.addChild(crater)
            }
            
            // Start position off-screen
            let startX = Bool.random() ? -size.width/2 - 50 : size.width/2 + 50
            let startY = CGFloat.random(in: -size.height/2...size.height/2)
            meteor.position = CGPoint(x: startX, y: startY)
            meteor.zPosition = -7
            
            // Crossing movement
            let endX = startX < 0 ? size.width/2 + 50 : -size.width/2 - 50
            let endY = CGFloat.random(in: -size.height/2...size.height/2)
            let duration = Double.random(in: 20...30)
            
            // Movement and rotation
            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: duration)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: duration)
            let group = SKAction.group([move, rotate])
            
            // Loop back to start
            let reset = SKAction.run {
                meteor.position = CGPoint(x: startX, y: CGFloat.random(in: -self.size.height/2...self.size.height/2))
            }
            
            let sequence = SKAction.sequence([group, reset])
            meteor.run(SKAction.repeatForever(sequence))
            
            backgroundLayer.addChild(meteor)
        }
    }
    
    private enum MapVisualTheme {
        case training
    }
    
    private func setMapVisualTheme(_ theme: MapVisualTheme) {
        // Set map visual theme - stub implementation
        print("Map theme set to \(theme)")
    }
    
    // MARK: - Tower Unlocking System
    
    private func checkForNewTowerUnlocks() {
        // FIX: Tower unlocks based on MAP not WAVE
        let towerUnlocks: [(map: Int, name: String, color: SKColor)] = [
            (2, "Laser Tower", SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0)),
            (3, "Plasma Tower", SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0)),
            (4, "Missile Tower", SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)),
            (5, "Tesla Tower", SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)),
            (6, "Freeze Tower", SKColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0))
        ]
        
        // Check if this is the first wave of a new map and show unlock
        if currentWave == 1 {
            for unlock in towerUnlocks {
                if unlock.map == currentMap {
                    showTowerUnlockNotification(name: unlock.name, color: unlock.color)
                    break
                }
            }
        }
    }
    
    private func showTowerUnlockNotification(name: String, color: SKColor) {
        // Create notification container
        let notification = SKNode()
        notification.name = "towerUnlockNotification"
        notification.zPosition = 2000
        notification.position = CGPoint(x: 0, y: 100)
        
        // Background panel
        let bg = SKShapeNode(rectOf: CGSize(width: 350, height: 80), cornerRadius: 10)
        bg.fillColor = SKColor.black.withAlphaComponent(0.9)
        bg.strokeColor = color
        bg.lineWidth = 3
        bg.glowWidth = 10
        notification.addChild(bg)
        
        // "NEW TOWER UNLOCKED!" label
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "NEW TOWER UNLOCKED!"
        titleLabel.fontSize = 18
        titleLabel.fontColor = SKColor.yellow
        titleLabel.position = CGPoint(x: 0, y: 20)
        notification.addChild(titleLabel)
        
        // Tower name label
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = name
        nameLabel.fontSize = 24
        nameLabel.fontColor = color
        nameLabel.position = CGPoint(x: 0, y: -10)
        notification.addChild(nameLabel)
        
        // Add sparkle effects
        for _ in 0..<10 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = SKColor.yellow
            sparkle.strokeColor = .clear
            sparkle.blendMode = .add
            sparkle.position = CGPoint(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -30...30)
            )
            notification.addChild(sparkle)
            
            // Sparkle animation
            let sparkleAnim = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 1.0, duration: 0),
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: CGFloat.random(in: 0.5...1.5))
            ])
            sparkle.run(SKAction.repeatForever(sparkleAnim))
        }
        
        // Add to UI
        uiLayer.addChild(notification)
        
        // Entrance animation
        notification.alpha = 0
        notification.setScale(0.5)
        
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        
        // Stay visible for a few seconds then fade out
        let displaySequence = SKAction.sequence([
            appear,
            SKAction.wait(forDuration: 3.0),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 0.8, duration: 0.5)
            ]),
            SKAction.removeFromParent()
        ])
        
        notification.run(displaySequence)
        
        // Play unlock sound if available
        // SoundManager.shared.playSound(.powerUp)
    }
    
    // MARK: - Proxima B Star System
    
    private func addProximaBStarSystem() {
        // Add a glowing red dwarf star with orbiting planets for Map 2
        print("🌟 Adding Proxima B star system to game map")
        
        // Position the star system in a visible location that doesn't interfere with gameplay
        let starPosition = CGPoint(x: 200, y: 100)
        
        // Create star container
        let starSystem = SKNode()
        starSystem.position = starPosition
        starSystem.zPosition = 15  // Above background but below game elements
        starSystem.name = "proximaBStarSystem"
        backgroundLayer.addChild(starSystem)  // Add to background layer instead
        
        // Create the main star (red dwarf) - make it bigger and brighter
        let star = SKShapeNode(circleOfRadius: 30)
        star.fillColor = SKColor(red: 1.0, green: 0.15, blue: 0.0, alpha: 1.0)
        star.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        star.lineWidth = 3
        star.glowWidth = 40
        starSystem.addChild(star)
        
        // Add enhanced corona layers
        let corona1 = SKShapeNode(circleOfRadius: 45)
        corona1.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.4)
        corona1.strokeColor = .clear
        corona1.blendMode = .add
        corona1.zPosition = -1
        starSystem.insertChild(corona1, at: 0)
        
        let corona2 = SKShapeNode(circleOfRadius: 60)
        corona2.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 0.25)
        corona2.strokeColor = .clear
        corona2.blendMode = .add
        corona2.zPosition = -2
        starSystem.insertChild(corona2, at: 0)
        
        let corona3 = SKShapeNode(circleOfRadius: 80)
        corona3.fillColor = SKColor(red: 1.0, green: 0.1, blue: 0.0, alpha: 0.15)
        corona3.strokeColor = .clear
        corona3.blendMode = .add
        corona3.zPosition = -3
        starSystem.insertChild(corona3, at: 0)
        
        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.run { star.glowWidth = 40 },
                SKAction.scale(to: 1.1, duration: 1.5)
            ]),
            SKAction.group([
                SKAction.run { star.glowWidth = 25 },
                SKAction.scale(to: 1.0, duration: 1.5)
            ])
        ])
        star.run(SKAction.repeatForever(pulse))
        
        // Create 3 larger, more visible orbiting planets
        let planetColors = [
            SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),  // Blue
            SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1.0),  // Brown
            SKColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)   // Green
        ]
        
        let orbitRadii: [CGFloat] = [70, 100, 140]
        let orbitSpeeds: [TimeInterval] = [5.0, 8.0, 12.0]
        let planetSizes: [CGFloat] = [8, 10, 7]
        
        for i in 0..<3 {
            // Create orbit path (more visible)
            let orbitPath = SKShapeNode(circleOfRadius: orbitRadii[i])
            orbitPath.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.3)
            orbitPath.lineWidth = 1.5
            orbitPath.fillColor = .clear
            starSystem.addChild(orbitPath)
            
            // Create larger, more visible planet
            let planet = SKShapeNode(circleOfRadius: planetSizes[i])
            planet.fillColor = planetColors[i]
            planet.strokeColor = planetColors[i].withAlphaComponent(0.8)
            planet.lineWidth = 2
            planet.glowWidth = 4
            
            // Position planet on orbit
            let startAngle = CGFloat.random(in: 0...(2 * .pi))
            planet.position = CGPoint(
                x: cos(startAngle) * orbitRadii[i],
                y: sin(startAngle) * orbitRadii[i]
            )
            
            starSystem.addChild(planet)
            
            // Orbit animation
            let orbitAction = SKAction.customAction(withDuration: orbitSpeeds[i]) { node, elapsedTime in
                let angle = startAngle + (elapsedTime / orbitSpeeds[i]) * CGFloat.pi * 2
                node.position = CGPoint(
                    x: cos(angle) * orbitRadii[i],
                    y: sin(angle) * orbitRadii[i]
                )
            }
            planet.run(SKAction.repeatForever(orbitAction))
            
            // Add moon to first planet
            if i == 0 {
                let moon = SKShapeNode(circleOfRadius: 2)
                moon.fillColor = .lightGray
                moon.strokeColor = .clear
                moon.position = CGPoint(x: 8, y: 0)
                planet.addChild(moon)
                
                // Moon orbit
                let moonOrbit = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2.0)
                moon.run(SKAction.repeatForever(moonOrbit))
            }
        }
        
        // Add solar flares
        for _ in 0..<4 {
            let flare = SKShapeNode(circleOfRadius: 3)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 18...22)
            flare.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            flare.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.1, alpha: 0.8)
            flare.strokeColor = .clear
            flare.blendMode = .add
            star.addChild(flare)
            
            // Flare animation
            let flareAnimation = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 1.0, duration: 0),
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: CGFloat.random(in: 3...6))
            ])
            flare.run(SKAction.repeatForever(flareAnimation))
        }
    }
    
    private func showFloatingText(_ text: String, at position: CGPoint, color: SKColor) {
        let label = SKLabelNode(text: text)
        label.fontSize = 18
        label.fontName = "AvenirNext-Bold"
        label.fontColor = color
        label.position = position
        label.zPosition = 1000
        
        uiLayer.addChild(label)
        
        // Floating animation
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        
        let sequence = SKAction.sequence([
            scaleUp,
            SKAction.group([moveUp, fadeOut, scaleDown]),
            SKAction.removeFromParent()
        ])
        
        label.run(sequence)
    }
    
    // MARK: - Tower Synergies System
    
    private func calculateTowerSynergies(for tower: SKNode) -> (damageBonus: Float, rangeBonus: Float, speedBonus: Float, armorPiercing: Float) {
        guard let towerType = tower.userData?["type"] as? String else {
            return (1.0, 1.0, 1.0, 1.0)
        }
        
        var damageBonus: Float = 1.0
        var rangeBonus: Float = 1.0
        var speedBonus: Float = 1.0
        var armorPiercing: Float = 1.0
        
        // Check all synergy providers
        towerLayer.children.forEach { otherTower in
            guard let otherTowerType = otherTower.userData?["type"] as? String,
                  otherTower != tower,
                  otherTower.name?.starts(with: "tower_") == true else { return }
            
            // Check if this tower provides synergies
            for synergy in towerSynergies {
                if synergy.towerType == otherTowerType &&
                   synergy.affectedTypes.contains(towerType) {
                    
                    let distance = distance(from: tower.position, to: otherTower.position)
                    if distance <= synergy.radius {
                        // Apply the synergy bonus with achievement multiplier
                        let achievementBonuses = getActiveAchievementBonuses()
                        let synergyMultiplier = achievementBonuses["synergyBonus"] ?? 1.0
                        let enhancedBonus = 1.0 + ((synergy.bonus - 1.0) * synergyMultiplier)
                        
                        switch synergy.synergyType {
                        case .damageBonus:
                            damageBonus *= enhancedBonus
                        case .rangeBonus:
                            rangeBonus *= enhancedBonus
                        case .speedBonus:
                            speedBonus *= enhancedBonus
                        case .armorPiercing:
                            armorPiercing *= enhancedBonus
                        }
                        
                        // Show synergy effect (subtle visual indicator)
                        showSynergyEffect(from: otherTower, to: tower, type: synergy.synergyType)
                        
                        // Track synergy usage for achievements
                        updateAchievementProgress(.synergyMaster)
                    }
                }
            }
        }
        
        return (damageBonus, rangeBonus, speedBonus, armorPiercing)
    }
    
    private func showSynergyEffect(from source: SKNode, to target: SKNode, type: SynergyType) {
        // Only show effect occasionally to avoid visual clutter
        guard Int.random(in: 1...100) <= 5 else { return }  // 5% chance per update
        
        let effectColor: SKColor
        switch type {
        case .damageBonus:
            effectColor = .red
        case .rangeBonus:
            effectColor = .blue
        case .speedBonus:
            effectColor = .yellow
        case .armorPiercing:
            effectColor = .purple
        }
        
        // Create a subtle line effect
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: source.position)
        path.addLine(to: target.position)
        line.path = path
        line.strokeColor = effectColor.withAlphaComponent(0.3)
        line.lineWidth = 2
        line.glowWidth = 1
        line.zPosition = 180
        effectsLayer.addChild(line)
        
        // Fade out quickly
        line.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func updateTowerSynergyIndicators() {
        // Add subtle glow effects to towers that are providing or receiving synergies
        towerLayer.children.forEach { tower in
            guard let _ = tower.userData?["type"] as? String,
                  tower.name?.starts(with: "tower_") == true else { return }
            
            let synergies = calculateTowerSynergies(for: tower)
            let hasBonuses = synergies.damageBonus > 1.0 || synergies.rangeBonus > 1.0 || 
                           synergies.speedBonus > 1.0 || synergies.armorPiercing > 1.0
            
            // Add/remove synergy indicator
            if hasBonuses {
                if tower.childNode(withName: "synergyGlow") == nil {
                    let glow = SKShapeNode(circleOfRadius: 5)
                    glow.name = "synergyGlow"
                    glow.fillColor = .clear
                    glow.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.4)
                    glow.lineWidth = 1
                    glow.glowWidth = 3
                    glow.zPosition = 5
                    tower.addChild(glow)
                    
                    // Subtle pulsing animation
                    let pulse = SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 1.0),
                        SKAction.scale(to: 0.8, duration: 1.0)
                    ])
                    glow.run(SKAction.repeatForever(pulse))
                }
            } else {
                tower.childNode(withName: "synergyGlow")?.removeFromParent()
            }
        }
    }
    
    // MARK: - Power-ups System
    
    private func checkForPowerUpDrop(at position: CGPoint) {
        // FIX: Power-ups only available from map 5 onwards
        guard currentMap >= 5 else { return }
        
        // Apply achievement power-up drop bonus
        let achievementBonuses = getActiveAchievementBonuses()
        let dropMultiplier = achievementBonuses["powerUpDrop"] ?? 1.0
        let enhancedDropChance = powerUpDropChance * dropMultiplier
        
        let randomChance = Float.random(in: 0...1)
        if randomChance < enhancedDropChance {
            let powerUpTypes: [PowerUpType] = [.speedBoost, .damageBoost, .salvageMultiplier, .shield]
            let randomType = powerUpTypes.randomElement() ?? .speedBoost
            createPowerUpDrop(type: randomType, at: position)
        }
    }
    
    private func createPowerUpDrop(type: PowerUpType, at position: CGPoint) {
        let powerUp = SKShapeNode(circleOfRadius: 12)
        powerUp.name = "powerUp_\(type)"
        powerUp.position = position
        powerUp.zPosition = 250
        
        // Set color and visual effects based on type
        switch type {
        case .speedBoost:
            powerUp.fillColor = SKColor.yellow
            powerUp.strokeColor = SKColor.orange
        case .damageBoost:
            powerUp.fillColor = SKColor.red
            powerUp.strokeColor = SKColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        case .salvageMultiplier:
            powerUp.fillColor = SKColor.green
            powerUp.strokeColor = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        case .shield:
            powerUp.fillColor = SKColor.cyan
            powerUp.strokeColor = SKColor.blue
        }
        
        powerUp.lineWidth = 2
        powerUp.glowWidth = 4
        
        // Add icon in the center
        let icon = SKLabelNode()
        icon.fontSize = 12
        icon.fontName = "AvenirNext-Bold"
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        
        switch type {
        case .speedBoost:
            icon.text = "⚡"
        case .damageBoost:
            icon.text = "💥"
        case .salvageMultiplier:
            icon.text = "$"
        case .shield:
            icon.text = "🛡"
        }
        
        powerUp.addChild(icon)
        effectsLayer.addChild(powerUp)
        
        // Add floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 1.0),
            SKAction.moveBy(x: 0, y: -5, duration: 1.0)
        ])
        powerUp.run(SKAction.repeatForever(float))
        
        // Add pulsing glow
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5)
        ])
        powerUp.run(SKAction.repeatForever(pulse))
        
        // Auto-collect after 10 seconds
        let autoCollect = SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.run { [weak self] in
                self?.collectPowerUp(powerUp)
            }
        ])
        powerUp.run(autoCollect)
    }
    
    private func collectPowerUp(_ powerUp: SKNode) {
        guard let name = powerUp.name, name.hasPrefix("powerUp_") else { return }
        
        let typeString = String(name.dropFirst("powerUp_".count))
        
        var type: PowerUpType
        switch typeString {
        case "speedBoost":
            type = .speedBoost
        case "damageBoost":
            type = .damageBoost
        case "salvageMultiplier":
            type = .salvageMultiplier
        case "shield":
            type = .shield
        default:
            return
        }
        
        // Activate the power-up
        activatePowerUp(type: type)
        
        // Create collection effect
        createPowerUpCollectionEffect(at: powerUp.position, type: type)
        
        // Remove power-up
        powerUp.removeFromParent()
        
        // Play collection sound
        SoundManager.shared.playSound(.powerUp)
    }
    
    private func activatePowerUp(type: PowerUpType) {
        let currentTime = CACurrentMediaTime()
        
        var duration: TimeInterval = 10.0
        var multiplier: Float = 1.5
        
        switch type {
        case .speedBoost:
            duration = 8.0
            multiplier = 2.0
        case .damageBoost:
            duration = 10.0
            multiplier = 1.8
        case .salvageMultiplier:
            duration = 15.0
            multiplier = 2.0
        case .shield:
            duration = 12.0
            multiplier = 1.0  // Shield doesn't use multiplier
        }
        
        let powerUp = ActivePowerUp(
            type: type,
            duration: duration,
            startTime: currentTime,
            multiplier: multiplier
        )
        
        // Remove existing power-up of same type
        activePowerUps.removeAll { $0.type == type }
        
        // Track achievement progress
        updateAchievementProgress(.powerUpCollector)
        
        // Add new power-up
        activePowerUps.append(powerUp)
        
        // Show activation message
        let message: String
        switch type {
        case .speedBoost:
            message = "FIRE RATE BOOST!"
        case .damageBoost:
            message = "DAMAGE BOOST!"
        case .salvageMultiplier:
            message = "SALVAGE BOOST!"
        case .shield:
            message = "SHIELD ACTIVE!"
        }
        
        showFloatingText(message, at: CGPoint(x: 0, y: 100), color: .yellow)
    }
    
    private func createPowerUpCollectionEffect(at position: CGPoint, type: PowerUpType) {
        let effect = SKShapeNode(circleOfRadius: 20)
        effect.position = position
        effect.fillColor = .clear
        effect.strokeColor = .yellow
        effect.lineWidth = 3
        effect.glowWidth = 8
        effect.alpha = 0.8
        effectsLayer.addChild(effect)
        
        let expand = SKAction.scale(to: 2.0, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        effect.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            remove
        ]))
    }
    
    private func updatePowerUps(deltaTime: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        
        // Remove expired power-ups
        activePowerUps.removeAll { powerUp in
            let elapsed = currentTime - powerUp.startTime
            return elapsed >= powerUp.duration
        }
    }
    
    private func getPowerUpMultiplier(type: PowerUpType) -> Float {
        return activePowerUps.first { $0.type == type }?.multiplier ?? 1.0
    }
    
    private func hasPowerUp(type: PowerUpType) -> Bool {
        return activePowerUps.contains { $0.type == type }
    }
}
