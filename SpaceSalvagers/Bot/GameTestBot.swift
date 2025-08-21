import Foundation
import SpriteKit

/// AI Test Bot that can autonomously play Space Salvagers for testing
/// This bot makes intelligent decisions based on game state
public class GameTestBot {
    
    // Bot configuration
    public struct BotConfig {
        var difficulty: BotDifficulty = .medium
        var decisionDelay: TimeInterval = 0.5
        var buildStrategy: BuildStrategy = .balanced
        var useOptimalPlacements: Bool = true
        var debugMode: Bool = false
        
        public init() {}
    }
    
    public enum BotDifficulty {
        case easy      // Makes random decisions
        case medium    // Makes reasonable decisions
        case hard      // Makes optimal decisions
        case perfect   // Frame-perfect execution with full game knowledge
    }
    
    public enum BuildStrategy {
        case rushDPS        // Focus on laser towers
        case controlHeavy   // Focus on slow/stun
        case balanced       // Mix of all tower types
        case economic       // Maximize salvage efficiency
    }
    
    // Game state tracking
    private var currentSalvage: Int = 200
    private var currentWave: Int = 1
    private var stationHealth: Int = 20
    private var placedTowers: [(position: CGPoint, type: TowerType, level: Int)] = []
    private var activeEnemies: [EnemyInfo] = []
    private var availableBuildNodes: [CGPoint] = []
    
    // Bot state
    private var config: BotConfig
    private var lastDecisionTime: TimeInterval = 0
    private var gameScene: SKScene?
    private var isActive: Bool = false
    
    // Decision tracking for replay analysis
    private var decisionHistory: [BotDecision] = []
    
    public struct EnemyInfo {
        let id: String
        let type: String
        let position: CGPoint
        let health: Float
        let distanceToCore: Float
    }
    
    public struct BotDecision {
        let timestamp: TimeInterval
        let action: BotAction
        let reasoning: String
        let gameState: GameSnapshot
    }
    
    public enum BotAction {
        case placeTower(type: TowerType, position: CGPoint)
        case upgradeTower(position: CGPoint)
        case sellTower(position: CGPoint)
        case startWave
        case setGameSpeed(Float)
        case wait
    }
    
    public enum TowerType: String {
        case laser = "LaserTower"
        case gravity = "GravityWell"
        case emp = "EMPTower"
        case nanobot = "NanobotSwarm"
    }
    
    public struct GameSnapshot {
        let salvage: Int
        let wave: Int
        let stationHealth: Int
        let towerCount: Int
        let enemyCount: Int
    }
    
    // MARK: - Initialization
    
    public init(config: BotConfig = BotConfig()) {
        self.config = config
    }
    
    // MARK: - Bot Control
    
    public func start(in scene: SKScene) {
        self.gameScene = scene
        self.isActive = true
        
        // Initialize game state
        scanGameState()
        
        if config.debugMode {
            print("🤖 GameTestBot started with \(config.difficulty) difficulty")
            print("📊 Initial state: Salvage=\(currentSalvage), Wave=\(currentWave)")
        }
    }
    
    public func stop() {
        isActive = false
        
        if config.debugMode {
            print("🤖 GameTestBot stopped")
            printPerformanceReport()
        }
    }
    
    // MARK: - Main Update Loop
    
    public func update(currentTime: TimeInterval) {
        guard isActive else { return }
        
        // Respect decision delay
        if currentTime - lastDecisionTime < config.decisionDelay {
            return
        }
        
        // Update game state
        scanGameState()
        
        // Make decision based on current state
        let action = makeDecision()
        
        // Execute action
        executeAction(action)
        
        // Record decision
        recordDecision(action, at: currentTime)
        
        lastDecisionTime = currentTime
    }
    
    // MARK: - Game State Analysis
    
    private func scanGameState() {
        guard let scene = gameScene else { return }
        
        // Scan for available build nodes
        availableBuildNodes.removeAll()
        scene.enumerateChildNodes(withName: "//buildNode") { node, _ in
            if !self.isNodeOccupied(node) {
                self.availableBuildNodes.append(node.position)
            }
        }
        
        // Scan for enemies
        activeEnemies.removeAll()
        scene.enumerateChildNodes(withName: "//enemy*") { node, _ in
            if let enemy = self.parseEnemyInfo(from: node) {
                self.activeEnemies.append(enemy)
            }
        }
        
        // Update resource info from HUD
        if let salvageLabel = scene.childNode(withName: "//salvageLabel") as? SKLabelNode {
            currentSalvage = parseSalvageFromLabel(salvageLabel.text ?? "")
        }
        
        if let waveLabel = scene.childNode(withName: "//waveLabel") as? SKLabelNode {
            currentWave = parseWaveFromLabel(waveLabel.text ?? "")
        }
        
        if let hpLabel = scene.childNode(withName: "//hpLabel") as? SKLabelNode {
            stationHealth = parseHealthFromLabel(hpLabel.text ?? "")
        }
    }
    
    // MARK: - Decision Making
    
    private func makeDecision() -> BotAction {
        switch config.difficulty {
        case .easy:
            return makeRandomDecision()
        case .medium:
            return makeBalancedDecision()
        case .hard:
            return makeOptimalDecision()
        case .perfect:
            return makePerfectDecision()
        }
    }
    
    private func makeRandomDecision() -> BotAction {
        let actions: [BotAction] = [
            .placeTower(type: .laser, position: availableBuildNodes.randomElement() ?? .zero),
            .startWave,
            .wait
        ]
        return actions.randomElement() ?? .wait
    }
    
    private func makeBalancedDecision() -> BotAction {
        // Priority system for medium difficulty
        
        // 1. Emergency defense if enemies are close to core
        if let closestEnemy = activeEnemies.min(by: { $0.distanceToCore < $1.distanceToCore }),
           closestEnemy.distanceToCore < 200 {
            if let bestNode = findBestNodeForDefense() {
                if canAffordTower(.laser) {
                    return .placeTower(type: .laser, position: bestNode)
                }
            }
        }
        
        // 2. Build towers if we have salvage and space
        if currentSalvage >= 150 && !availableBuildNodes.isEmpty {
            return decideTowerPlacement()
        }
        
        // 3. Upgrade existing towers
        if currentSalvage >= 200 {
            if let towerToUpgrade = findBestTowerToUpgrade() {
                return .upgradeTower(position: towerToUpgrade)
            }
        }
        
        // 4. Start wave if prepared
        if activeEnemies.isEmpty && placedTowers.count >= 3 {
            return .startWave
        }
        
        return .wait
    }
    
    private func makeOptimalDecision() -> BotAction {
        // Advanced decision making with strategy patterns
        
        switch config.buildStrategy {
        case .rushDPS:
            return executeDPSStrategy()
        case .controlHeavy:
            return executeControlStrategy()
        case .balanced:
            return executeBalancedStrategy()
        case .economic:
            return executeEconomicStrategy()
        }
    }
    
    private func makePerfectDecision() -> BotAction {
        // Frame-perfect execution with full game knowledge
        // This would require access to future wave data
        
        // Calculate optimal tower placement using dynamic programming
        if let optimalPlacement = calculateOptimalPlacement() {
            return optimalPlacement
        }
        
        return makeOptimalDecision()  // Fallback to hard difficulty
    }
    
    // MARK: - Strategy Implementations
    
    private func executeDPSStrategy() -> BotAction {
        // Focus on maximizing damage output
        if canAffordTower(.laser) && !availableBuildNodes.isEmpty {
            if let node = findNodeWithBestCoverage() {
                return .placeTower(type: .laser, position: node)
            }
        }
        
        // Upgrade lasers first
        for tower in placedTowers where tower.type == .laser && tower.level < 3 {
            if currentSalvage >= getTowerUpgradeCost(tower.type, level: tower.level) {
                return .upgradeTower(position: tower.position)
            }
        }
        
        return .wait
    }
    
    private func executeControlStrategy() -> BotAction {
        // Focus on slowing and stunning enemies
        let controlTowerRatio = Float(placedTowers.filter { $0.type == .gravity || $0.type == .emp }.count) / Float(max(1, placedTowers.count))
        
        if controlTowerRatio < 0.6 && !availableBuildNodes.isEmpty {
            let towerType: TowerType = currentWave % 2 == 0 ? .emp : .gravity
            if canAffordTower(towerType) {
                if let node = findNodeNearPath() {
                    return .placeTower(type: towerType, position: node)
                }
            }
        }
        
        return executeBalancedStrategy()
    }
    
    private func executeBalancedStrategy() -> BotAction {
        // Maintain a good mix of all tower types
        let towerCounts = Dictionary(grouping: placedTowers, by: { $0.type })
            .mapValues { $0.count }
        
        // Find the least represented tower type
        let towerTypes: [TowerType] = [.laser, .gravity, .emp, .nanobot]
        let leastUsed = towerTypes.min { 
            (towerCounts[$0] ?? 0) < (towerCounts[$1] ?? 0)
        } ?? .laser
        
        if canAffordTower(leastUsed) && !availableBuildNodes.isEmpty {
            if let node = findBestNodeForTower(leastUsed) {
                return .placeTower(type: leastUsed, position: node)
            }
        }
        
        return .wait
    }
    
    private func executeEconomicStrategy() -> BotAction {
        // Maximize salvage efficiency
        
        // Only build when absolutely necessary
        if activeEnemies.count > 5 || stationHealth < 10 {
            if let cheapestEffective = findCheapestEffectiveTower() {
                return cheapestEffective
            }
        }
        
        // Focus on upgrading for better ROI
        if let bestROI = findBestROIUpgrade() {
            return .upgradeTower(position: bestROI)
        }
        
        return .wait
    }
    
    // MARK: - Helper Methods
    
    private func canAffordTower(_ type: TowerType) -> Bool {
        return currentSalvage >= getTowerCost(type)
    }
    
    private func getTowerCost(_ type: TowerType) -> Int {
        switch type {
        case .laser: return 100
        case .gravity: return 140
        case .emp: return 160
        case .nanobot: return 120
        }
    }
    
    private func getTowerUpgradeCost(_ type: TowerType, level: Int) -> Int {
        let baseCost = getTowerCost(type)
        switch level {
        case 1: return Int(Float(baseCost) * 1.2)
        case 2: return Int(Float(baseCost) * 1.8)
        default: return 999999
        }
    }
    
    private func decideTowerPlacement() -> BotAction {
        // Decide which tower to place based on current needs
        
        // Check enemy composition
        let hasShielded = activeEnemies.contains { $0.type.contains("Drone") }
        let hasSwarm = activeEnemies.contains { $0.type.contains("Swarm") }
        
        let towerType: TowerType
        if hasShielded {
            towerType = .emp
        } else if hasSwarm {
            towerType = .nanobot
        } else {
            towerType = .laser
        }
        
        if let position = availableBuildNodes.first {
            return .placeTower(type: towerType, position: position)
        }
        
        return .wait
    }
    
    private func findBestNodeForDefense() -> CGPoint? {
        // Find node closest to enemies
        guard !availableBuildNodes.isEmpty, !activeEnemies.isEmpty else { return nil }
        
        return availableBuildNodes.min { node1, node2 in
            let dist1 = activeEnemies.map { distance(from: node1, to: $0.position) }.min() ?? Float.infinity
            let dist2 = activeEnemies.map { distance(from: node2, to: $0.position) }.min() ?? Float.infinity
            return dist1 < dist2
        }
    }
    
    private func findNodeWithBestCoverage() -> CGPoint? {
        // Find node that covers the most path area
        return availableBuildNodes.first  // Simplified for now
    }
    
    private func findNodeNearPath() -> CGPoint? {
        // Find node closest to enemy path
        return availableBuildNodes.first  // Simplified for now
    }
    
    private func findBestNodeForTower(_ type: TowerType) -> CGPoint? {
        switch type {
        case .laser, .nanobot:
            return findNodeWithBestCoverage()
        case .gravity, .emp:
            return findNodeNearPath()
        }
    }
    
    private func findBestTowerToUpgrade() -> CGPoint? {
        return placedTowers
            .filter { $0.level < 3 }
            .first?.position
    }
    
    private func findCheapestEffectiveTower() -> BotAction? {
        let cheapest = TowerType.nanobot
        if canAffordTower(cheapest) && !availableBuildNodes.isEmpty {
            return .placeTower(type: cheapest, position: availableBuildNodes.first!)
        }
        return nil
    }
    
    private func findBestROIUpgrade() -> CGPoint? {
        // Find upgrade with best return on investment
        return placedTowers
            .filter { $0.level < 3 }
            .filter { currentSalvage >= getTowerUpgradeCost($0.type, level: $0.level) }
            .max { tower1, tower2 in
                // Prioritize high-damage towers for upgrades
                tower1.type == .laser && tower2.type != .laser
            }?.position
    }
    
    private func calculateOptimalPlacement() -> BotAction? {
        // Would implement dynamic programming solution here
        return nil
    }
    
    private func isNodeOccupied(_ node: SKNode) -> Bool {
        return placedTowers.contains { 
            distance(from: $0.position, to: node.position) < 10
        }
    }
    
    private func parseEnemyInfo(from node: SKNode) -> EnemyInfo? {
        guard let scene = gameScene,
              let core = scene.childNode(withName: "//stationCore") else { return nil }
        
        return EnemyInfo(
            id: node.name ?? UUID().uuidString,
            type: node.name ?? "Unknown",
            position: node.position,
            health: 100,  // Would read from component
            distanceToCore: distance(from: node.position, to: core.position)
        )
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> Float {
        let dx = Float(point1.x - point2.x)
        let dy = Float(point1.y - point2.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    // MARK: - Action Execution
    
    private func executeAction(_ action: BotAction) {
        guard let scene = gameScene else { return }
        
        switch action {
        case .placeTower(let type, let position):
            simulateTap(at: position, in: scene)
            // Would then select tower type from menu
            if config.debugMode {
                print("🏗 Placing \(type) at \(position)")
            }
            
        case .upgradeTower(let position):
            simulateTap(at: position, in: scene)
            // Would then select upgrade option
            if config.debugMode {
                print("⬆️ Upgrading tower at \(position)")
            }
            
        case .sellTower(let position):
            simulateTap(at: position, in: scene)
            // Would then select sell option
            if config.debugMode {
                print("💰 Selling tower at \(position)")
            }
            
        case .startWave:
            // Find and tap start wave button
            if let startButton = scene.childNode(withName: "//startWaveButton") {
                simulateTap(at: startButton.position, in: scene)
            }
            if config.debugMode {
                print("🌊 Starting wave")
            }
            
        case .setGameSpeed(let speed):
            // Would interact with speed control
            if config.debugMode {
                print("⏩ Setting game speed to \(speed)x")
            }
            
        case .wait:
            // Do nothing this frame
            break
        }
    }
    
    private func simulateTap(at position: CGPoint, in scene: SKScene) {
        // Simulate touch input
        let touchDown = UITouch()
        let touchUp = UITouch()
        
        // This would integrate with the actual touch handling
        scene.touchesBegan([touchDown], with: nil)
        scene.touchesEnded([touchUp], with: nil)
    }
    
    // MARK: - Parsing Helpers
    
    private func parseSalvageFromLabel(_ text: String) -> Int {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(numbers) ?? 200
    }
    
    private func parseWaveFromLabel(_ text: String) -> Int {
        let components = text.components(separatedBy: "/")
        if let first = components.first {
            let numbers = first.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(numbers) ?? 1
        }
        return 1
    }
    
    private func parseHealthFromLabel(_ text: String) -> Int {
        let components = text.components(separatedBy: "/")
        if let first = components.first {
            let numbers = first.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(numbers) ?? 20
        }
        return 20
    }
    
    // MARK: - Performance Tracking
    
    private func recordDecision(_ action: BotAction, at timestamp: TimeInterval) {
        let snapshot = GameSnapshot(
            salvage: currentSalvage,
            wave: currentWave,
            stationHealth: stationHealth,
            towerCount: placedTowers.count,
            enemyCount: activeEnemies.count
        )
        
        let reasoning = generateReasoning(for: action)
        
        let decision = BotDecision(
            timestamp: timestamp,
            action: action,
            reasoning: reasoning,
            gameState: snapshot
        )
        
        decisionHistory.append(decision)
    }
    
    private func generateReasoning(for action: BotAction) -> String {
        switch action {
        case .placeTower(let type, _):
            return "Placing \(type) - Salvage: \(currentSalvage), Enemies: \(activeEnemies.count)"
        case .upgradeTower:
            return "Upgrading for increased DPS"
        case .sellTower:
            return "Selling for salvage recovery"
        case .startWave:
            return "Starting wave - Prepared with \(placedTowers.count) towers"
        case .setGameSpeed(let speed):
            return "Adjusting speed to \(speed)x"
        case .wait:
            return "Waiting for resources or enemies"
        }
    }
    
    private func printPerformanceReport() {
        print("\n📊 Bot Performance Report")
        print("========================")
        print("Total decisions: \(decisionHistory.count)")
        print("Final wave reached: \(currentWave)")
        print("Final station health: \(stationHealth)")
        print("Towers placed: \(placedTowers.count)")
        
        // Action breakdown
        let actionCounts = Dictionary(grouping: decisionHistory, by: { 
            switch $0.action {
            case .placeTower: return "Place"
            case .upgradeTower: return "Upgrade"
            case .sellTower: return "Sell"
            case .startWave: return "Start"
            case .setGameSpeed: return "Speed"
            case .wait: return "Wait"
            }
        }).mapValues { $0.count }
        
        print("\nAction Distribution:")
        for (action, count) in actionCounts.sorted(by: { $0.value > $1.value }) {
            let percentage = Float(count) / Float(decisionHistory.count) * 100
            print("  \(action): \(count) (\(String(format: "%.1f", percentage))%)")
        }
    }
    
    // MARK: - Public Interface for Testing
    
    public func getDecisionHistory() -> [BotDecision] {
        return decisionHistory
    }
    
    public func getCurrentGameState() -> GameSnapshot {
        return GameSnapshot(
            salvage: currentSalvage,
            wave: currentWave,
            stationHealth: stationHealth,
            towerCount: placedTowers.count,
            enemyCount: activeEnemies.count
        )
    }
    
    public func forceAction(_ action: BotAction) {
        executeAction(action)
    }
}