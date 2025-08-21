import Foundation
import SpriteKit
import os.log

enum GameState {
    case menu
    case preparing
    case playing
    case paused
    case waveComplete
    case gameOver
    case victory
}

class GameEngine {
    static let shared = GameEngine()
    private let logger = Logger(subsystem: "com.spacesalvagers", category: "GameEngine")
    
    // Core systems
    private(set) var world: World
    private(set) var currentState: GameState = .menu
    
    // Game systems (will be initialized when game starts)
    private var waveSystem: WaveSystem?
    private var economySystem: EconomySystem?
    private var combatSystem: CombatSystem?
    private var towerSystem: TowerSystem?
    
    // Timing
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0
    private let maxDeltaTime: TimeInterval = 1.0 / 30.0  // Cap at 30 FPS minimum
    
    // Game speed
    private(set) var gameSpeed: Float = 1.0
    
    // Performance tracking
    private var frameCount: Int = 0
    private var performanceTimer: TimeInterval = 0
    
    private init() {
        self.world = World()
        setupSystems()
    }
    
    private func setupSystems() {
        // Systems will be added as they're implemented
        logger.info("Game engine initialized")
    }
    
    func update(currentTime: TimeInterval) {
        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = min(currentTime - lastUpdateTime, maxDeltaTime)
        lastUpdateTime = currentTime
        
        // Apply game speed
        let scaledDeltaTime = deltaTime * Double(self.gameSpeed)
        
        // Don't update if paused or in menu
        guard currentState == .playing || currentState == .preparing else { return }
        
        // Update world and all systems
        world.update(deltaTime: scaledDeltaTime)
        
        // Update performance tracking
        updatePerformanceTracking(deltaTime: deltaTime)
    }
    
    func startNewGame() {
        logger.info("Starting new game")
        
        currentState = .preparing
        
        // Reset all systems
        resetSystems()
        
        // Initialize game with starting values
        initializeGame()
        
        currentState = .playing
    }
    
    func pause() {
        guard currentState == .playing else { return }
        currentState = .paused
        logger.info("Game paused")
    }
    
    func resume() {
        guard currentState == .paused else { return }
        currentState = .playing
        logger.info("Game resumed")
    }
    
    func setGameSpeed(_ speed: Float) {
        gameSpeed = max(0.0, min(3.0, speed))  // Clamp between 0x and 3x
        logger.info("Game speed set to \(self.gameSpeed)x")
    }
    
    func transitionToState(_ newState: GameState) {
        let oldState = currentState
        currentState = newState
        
        logger.info("Game state transition: \(String(describing: oldState)) -> \(String(describing: newState))")
        
        // Handle state-specific logic
        switch newState {
        case .gameOver:
            handleGameOver()
        case .victory:
            handleVictory()
        case .waveComplete:
            handleWaveComplete()
        default:
            break
        }
    }
    
    private func resetSystems() {
        // Clear world
        world = World()
        
        // Reinitialize systems
        waveSystem = WaveSystem()
        economySystem = EconomySystem()
        combatSystem = CombatSystem()
        towerSystem = TowerSystem()
        
        // Add systems to world
        if let waveSystem = waveSystem {
            world.addSystem(waveSystem)
        }
        if let combatSystem = combatSystem {
            world.addSystem(combatSystem)
        }
    }
    
    private func initializeGame() {
        // Set starting salvage
        economySystem?.setSalvage(200)
        
        // Initialize first wave
        waveSystem?.prepareWave(1)
    }
    
    private func handleGameOver() {
        // Save stats
        GameStateManager.shared.saveGameOverState()
        
        // Show game over screen
        NotificationCenter.default.post(name: .gameOver, object: nil)
    }
    
    private func handleVictory() {
        // Save victory stats
        GameStateManager.shared.saveVictoryState()
        
        // Show victory screen
        NotificationCenter.default.post(name: .victory, object: nil)
    }
    
    private func handleWaveComplete() {
        // Award wave completion bonus
        if let currentWave = waveSystem?.currentWave {
            let bonus = 20 + 2 * currentWave
            economySystem?.addSalvage(bonus)
        }
    }
    
    private func updatePerformanceTracking(deltaTime: TimeInterval) {
        frameCount += 1
        performanceTimer += deltaTime
        
        // Log performance every 5 seconds in debug
        #if DEBUG
        if performanceTimer >= 5.0 {
            let fps = Double(frameCount) / performanceTimer
            logger.debug("Performance: \(fps, format: .fixed(precision: 1)) FPS")
            frameCount = 0
            performanceTimer = 0
        }
        #endif
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let gameOver = Notification.Name("GameOver")
    static let victory = Notification.Name("Victory")
    static let waveStarted = Notification.Name("WaveStarted")
    static let waveComplete = Notification.Name("WaveComplete")
    static let salvageUpdated = Notification.Name("SalvageUpdated")
}