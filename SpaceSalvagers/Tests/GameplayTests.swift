import XCTest
import SpriteKit
@testable import SpaceSalvagersCore
@testable import SpaceSalvagersBot

class GameplayTests: XCTestCase {
    
    var gameScene: GameScene!
    var testBot: GameTestBot!
    var gameEngine: GameEngine!
    
    override func setUp() {
        super.setUp()
        
        // Create test scene
        gameScene = GameScene(size: CGSize(width: 1024, height: 768))
        
        // Initialize game engine
        gameEngine = GameEngine.shared
        
        // Create test bot with perfect difficulty
        let config = GameTestBot.BotConfig(
            difficulty: .perfect,
            decisionDelay: 0.1,  // Fast decisions for testing
            buildStrategy: .balanced,
            useOptimalPlacements: true,
            debugMode: true
        )
        testBot = GameTestBot(config: config)
    }
    
    override func tearDown() {
        testBot.stop()
        testBot = nil
        gameScene = nil
        super.tearDown()
    }
    
    // MARK: - Automated Gameplay Tests
    
    func testBotCanPlayFullGame() throws {
        // Start the bot in the scene
        testBot.start(in: gameScene)
        
        // Simulate game loop for 20 waves
        let expectation = XCTestExpectation(description: "Bot completes game")
        
        var frameCount = 0
        let maxFrames = 36000  // 10 minutes at 60 FPS
        
        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            frameCount += 1
            
            // Update game engine
            let currentTime = TimeInterval(frameCount) / 60.0
            self.gameEngine.update(currentTime: currentTime)
            
            // Update bot
            self.testBot.update(currentTime: currentTime)
            
            // Check end conditions
            let state = self.testBot.getCurrentGameState()
            
            if state.wave >= 20 || state.stationHealth <= 0 || frameCount >= maxFrames {
                timer.invalidate()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 650)  // 10 minutes + buffer
        
        // Verify bot performance
        let finalState = testBot.getCurrentGameState()
        let decisions = testBot.getDecisionHistory()
        
        XCTAssertGreaterThan(finalState.wave, 10, "Bot should reach at least wave 10")
        XCTAssertGreaterThan(finalState.stationHealth, 0, "Station should survive")
        XCTAssertGreaterThan(decisions.count, 50, "Bot should make many decisions")
    }
    
    func testBotTowerPlacementStrategy() {
        testBot.start(in: gameScene)
        
        // Force specific game state
        testBot.forceAction(.placeTower(type: .laser, position: CGPoint(x: 200, y: 300)))
        
        // Verify tower was placed
        let state = testBot.getCurrentGameState()
        XCTAssertEqual(state.towerCount, 1, "Tower should be placed")
    }
    
    func testBotEconomicDecisions() {
        // Configure bot for economic strategy
        let config = GameTestBot.BotConfig(
            difficulty: .hard,
            buildStrategy: .economic,
            debugMode: true
        )
        let econBot = GameTestBot(config: config)
        econBot.start(in: gameScene)
        
        // Run for 100 frames
        for i in 0..<100 {
            econBot.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        // Check that bot is being economical
        let decisions = econBot.getDecisionHistory()
        let placeActions = decisions.filter {
            if case .placeTower = $0.action { return true }
            return false
        }
        
        XCTAssertLessThan(placeActions.count, 5, "Economic bot should place fewer towers initially")
    }
    
    // MARK: - Deterministic Tests
    
    func testDeterministicGameplay() {
        // Set fixed seed
        RandomManager.shared.setSeed(12345)
        
        // Run game with bot
        let bot1 = GameTestBot(config: GameTestBot.BotConfig(difficulty: .medium))
        bot1.start(in: gameScene)
        
        for i in 0..<1000 {
            gameEngine.update(currentTime: TimeInterval(i) * 0.016)
            bot1.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        let decisions1 = bot1.getDecisionHistory()
        let state1 = bot1.getCurrentGameState()
        
        // Reset and run again with same seed
        RandomManager.shared.setSeed(12345)
        gameScene = GameScene(size: CGSize(width: 1024, height: 768))
        
        let bot2 = GameTestBot(config: GameTestBot.BotConfig(difficulty: .medium))
        bot2.start(in: gameScene)
        
        for i in 0..<1000 {
            gameEngine.update(currentTime: TimeInterval(i) * 0.016)
            bot2.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        let decisions2 = bot2.getDecisionHistory()
        let state2 = bot2.getCurrentGameState()
        
        // Verify identical outcomes
        XCTAssertEqual(decisions1.count, decisions2.count, "Same number of decisions")
        XCTAssertEqual(state1.wave, state2.wave, "Same wave reached")
        XCTAssertEqual(state1.salvage, state2.salvage, "Same salvage amount")
    }
    
    // MARK: - Performance Tests
    
    func testBotPerformanceWith200Enemies() {
        measure {
            // Create scenario with many enemies
            for _ in 0..<200 {
                // Simulate enemy spawn
                let enemy = SKNode()
                enemy.name = "enemy_swarmer"
                enemy.position = CGPoint(
                    x: CGFloat.random(in: 0...1024),
                    y: CGFloat.random(in: 0...768)
                )
                gameScene.addChild(enemy)
            }
            
            // Run bot for 100 frames
            for i in 0..<100 {
                testBot.update(currentTime: TimeInterval(i) * 0.016)
            }
        }
    }
    
    // MARK: - Strategy Tests
    
    func testDPSRushStrategy() {
        let config = GameTestBot.BotConfig(
            difficulty: .hard,
            buildStrategy: .rushDPS,
            debugMode: true
        )
        let dpsBot = GameTestBot(config: config)
        dpsBot.start(in: gameScene)
        
        // Simulate early game
        for i in 0..<300 {
            dpsBot.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        let decisions = dpsBot.getDecisionHistory()
        let laserPlacements = decisions.filter {
            if case .placeTower(let type, _) = $0.action {
                return type == .laser
            }
            return false
        }
        
        let otherPlacements = decisions.filter {
            if case .placeTower(let type, _) = $0.action {
                return type != .laser
            }
            return false
        }
        
        XCTAssertGreaterThan(laserPlacements.count, otherPlacements.count, 
                             "DPS strategy should prioritize laser towers")
    }
    
    func testControlHeavyStrategy() {
        let config = GameTestBot.BotConfig(
            difficulty: .hard,
            buildStrategy: .controlHeavy,
            debugMode: true
        )
        let controlBot = GameTestBot(config: config)
        controlBot.start(in: gameScene)
        
        // Simulate early game
        for i in 0..<300 {
            controlBot.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        let decisions = controlBot.getDecisionHistory()
        let controlPlacements = decisions.filter {
            if case .placeTower(let type, _) = $0.action {
                return type == .gravity || type == .emp
            }
            return false
        }
        
        XCTAssertGreaterThan(controlPlacements.count, 0, 
                             "Control strategy should place slow/stun towers")
    }
    
    // MARK: - Regression Tests
    
    func testBotDoesNotCrashOnEmptyScene() {
        let emptyScene = SKScene(size: CGSize(width: 1024, height: 768))
        testBot.start(in: emptyScene)
        
        // Should not crash
        for i in 0..<100 {
            testBot.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        XCTAssertTrue(true, "Bot handled empty scene without crashing")
    }
    
    func testBotHandlesRapidStateChanges() {
        testBot.start(in: gameScene)
        
        // Rapidly change game state
        for i in 0..<100 {
            if i % 10 == 0 {
                // Add enemy
                let enemy = SKNode()
                enemy.name = "enemy_\(i)"
                gameScene.addChild(enemy)
            }
            
            if i % 15 == 0 {
                // Remove enemy
                gameScene.children.first { $0.name?.contains("enemy") ?? false }?.removeFromParent()
            }
            
            testBot.update(currentTime: TimeInterval(i) * 0.016)
        }
        
        XCTAssertTrue(true, "Bot handled rapid state changes")
    }
}