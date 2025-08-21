import Foundation
import SpriteKit

// MARK: - Game HUD
class GameHUD: SKNode {
    
    // HUD Elements
    private var scoreLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var resourceLabel: SKLabelNode!
    private var powerLabel: SKLabelNode!
    
    // Visual containers
    private var topBar: SKShapeNode!
    private var bottomBar: SKShapeNode!
    private var towerMenu: SKNode!
    
    // Tower selection buttons
    private var towerButtons: [TowerButton] = []
    private var selectedTowerType: TowerType?
    
    // Game state
    private var score: Int = 0 {
        didSet {
            updateScoreDisplay()
        }
    }
    
    private var currentWave: Int = 0 {
        didSet {
            updateWaveDisplay()
        }
    }
    
    private var lives: Int = 20 {
        didSet {
            updateLivesDisplay()
        }
    }
    
    private var resources: Int = 300 {
        didSet {
            updateResourceDisplay()
        }
    }
    
    private var powerAvailable: Float = 5.0 {
        didSet {
            updatePowerDisplay()
        }
    }
    
    private var powerMax: Float = 10.0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupHUD()
    }
    
    // MARK: - Setup
    
    private func setupHUD() {
        setupTopBar()
        setupBottomBar()
        setupTowerMenu()
        setupWaveIndicator()
        
        // Initial display update
        updateAllDisplays()
    }
    
    private func setupTopBar() {
        // Create neon-style top bar
        let barWidth = UIScreen.main.bounds.width
        let barHeight: CGFloat = 60
        
        topBar = createNeonPanel(width: barWidth, height: barHeight)
        topBar.position = CGPoint(x: 0, y: UIScreen.main.bounds.height / 2 - barHeight / 2)
        topBar.zPosition = 1000
        addChild(topBar)
        
        // Score Display
        let scoreContainer = createInfoContainer(icon: "⭐", x: -barWidth/2 + 100)
        topBar.addChild(scoreContainer)
        
        scoreLabel = createNeonLabel(text: "0", fontSize: 24)
        scoreLabel.position = CGPoint(x: 30, y: 0)
        scoreContainer.addChild(scoreLabel)
        
        // Wave Display
        let waveContainer = createInfoContainer(icon: "🌊", x: -barWidth/2 + 250)
        topBar.addChild(waveContainer)
        
        waveLabel = createNeonLabel(text: "Wave 0", fontSize: 20)
        waveLabel.position = CGPoint(x: 40, y: 0)
        waveContainer.addChild(waveLabel)
        
        // Lives Display
        let livesContainer = createInfoContainer(icon: "❤️", x: 0)
        topBar.addChild(livesContainer)
        
        livesLabel = createNeonLabel(text: "20", fontSize: 24)
        livesLabel.position = CGPoint(x: 30, y: 0)
        livesContainer.addChild(livesLabel)
        
        // Resources Display
        let resourceContainer = createInfoContainer(icon: "💰", x: barWidth/2 - 250)
        topBar.addChild(resourceContainer)
        
        resourceLabel = createNeonLabel(text: "300 CR", fontSize: 20)
        resourceLabel.position = CGPoint(x: 50, y: 0)
        resourceContainer.addChild(resourceLabel)
        
        // Power Display
        let powerContainer = createInfoContainer(icon: "⚡", x: barWidth/2 - 100)
        topBar.addChild(powerContainer)
        
        powerLabel = createNeonLabel(text: "5.0/10", fontSize: 20)
        powerLabel.position = CGPoint(x: 50, y: 0)
        powerContainer.addChild(powerLabel)
    }
    
    private func setupBottomBar() {
        // Tower selection bar
        let barWidth = UIScreen.main.bounds.width
        let barHeight: CGFloat = 100
        
        bottomBar = createNeonPanel(width: barWidth, height: barHeight)
        bottomBar.position = CGPoint(x: 0, y: -UIScreen.main.bounds.height / 2 + barHeight / 2)
        bottomBar.zPosition = 1000
        addChild(bottomBar)
        
        // Speed controls
        createSpeedControls()
        
        // Tower selection slots
        createTowerSelectionSlots()
    }
    
    private func createSpeedControls() {
        let speedContainer = SKNode()
        speedContainer.position = CGPoint(x: -UIScreen.main.bounds.width/2 + 80, y: 0)
        bottomBar.addChild(speedContainer)
        
        // Pause button
        let pauseBtn = createControlButton(symbol: "⏸", size: 40)
        pauseBtn.position = CGPoint(x: -30, y: 0)
        pauseBtn.name = "pauseButton"
        speedContainer.addChild(pauseBtn)
        
        // Play button
        let playBtn = createControlButton(symbol: "▶️", size: 40)
        playBtn.position = CGPoint(x: 0, y: 0)
        playBtn.name = "playButton"
        speedContainer.addChild(playBtn)
        
        // Fast forward button
        let ffBtn = createControlButton(symbol: "⏩", size: 40)
        ffBtn.position = CGPoint(x: 30, y: 0)
        ffBtn.name = "fastForwardButton"
        speedContainer.addChild(ffBtn)
    }
    
    private func createTowerSelectionSlots() {
        let towerTypes: [TowerType] = [
            .laserTurret,
            .railgunEmplacement,
            .plasmaArcNode,
            .missilePDBattery,
            .nanobotSwarmDispenser,
            .cryoFoamProjector,
            .gravityWellProjector,
            .empShockTower
        ]
        
        let startX: CGFloat = -200
        let spacing: CGFloat = 60
        
        for (index, towerType) in towerTypes.enumerated() {
            let button = TowerButton(type: towerType)
            button.position = CGPoint(x: startX + CGFloat(index) * spacing, y: 0)
            button.delegate = self
            bottomBar.addChild(button)
            towerButtons.append(button)
        }
    }
    
    private func setupTowerMenu() {
        towerMenu = SKNode()
        towerMenu.zPosition = 999
        addChild(towerMenu)
    }
    
    private func setupWaveIndicator() {
        // Wave progress bar
        let progressContainer = SKNode()
        progressContainer.position = CGPoint(x: 0, y: UIScreen.main.bounds.height / 2 - 100)
        progressContainer.zPosition = 999
        addChild(progressContainer)
        
        // Background bar
        let bgBar = SKShapeNode(rectOf: CGSize(width: 300, height: 8))
        bgBar.fillColor = SKColor.black.withAlphaComponent(0.5)
        bgBar.strokeColor = NeonGraphicsSystem.NeonColors.cyan
        bgBar.lineWidth = 1
        bgBar.glowWidth = 2
        progressContainer.addChild(bgBar)
        
        // Progress fill
        let progressBar = SKShapeNode(rectOf: CGSize(width: 0, height: 6))
        progressBar.fillColor = NeonGraphicsSystem.NeonColors.green
        progressBar.strokeColor = .clear
        progressBar.name = "waveProgress"
        progressContainer.addChild(progressBar)
    }
    
    // MARK: - Helper Methods
    
    private func createNeonPanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: CGSize(width: width, height: height))
        panel.fillColor = SKColor.black.withAlphaComponent(0.7)
        panel.strokeColor = NeonGraphicsSystem.NeonColors.cyan
        panel.lineWidth = 2
        panel.glowWidth = 4
        
        // Add tech lines
        for i in stride(from: -width/2 + 50, to: width/2, by: 100) {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: height * 0.6))
            line.position = CGPoint(x: i, y: 0)
            line.fillColor = NeonGraphicsSystem.NeonColors.cyan.withAlphaComponent(0.2)
            line.strokeColor = .clear
            panel.addChild(line)
        }
        
        return panel
    }
    
    private func createInfoContainer(icon: String, x: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: x, y: 0)
        
        // Icon background
        let iconBg = SKShapeNode(circleOfRadius: 20)
        iconBg.fillColor = SKColor.black.withAlphaComponent(0.5)
        iconBg.strokeColor = NeonGraphicsSystem.NeonColors.cyan
        iconBg.lineWidth = 1
        iconBg.glowWidth = 2
        container.addChild(iconBg)
        
        // Icon
        let iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = 20
        iconLabel.verticalAlignmentMode = .center
        container.addChild(iconLabel)
        
        return container
    }
    
    private func createNeonLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Helvetica Neue")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = NeonGraphicsSystem.NeonColors.white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        
        // Add glow effect
        let glow = label.copy() as! SKLabelNode
        glow.fontColor = NeonGraphicsSystem.NeonColors.cyan
        glow.alpha = 0.5
        glow.zPosition = -1
        glow.blendMode = .add
        label.addChild(glow)
        
        return label
    }
    
    private func createControlButton(symbol: String, size: CGFloat) -> SKNode {
        let button = SKNode()
        
        let bg = SKShapeNode(circleOfRadius: size / 2)
        bg.fillColor = SKColor.black.withAlphaComponent(0.7)
        bg.strokeColor = NeonGraphicsSystem.NeonColors.cyan
        bg.lineWidth = 2
        bg.glowWidth = 3
        button.addChild(bg)
        
        let label = SKLabelNode(text: symbol)
        label.fontSize = size * 0.5
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    // MARK: - Display Updates
    
    private func updateAllDisplays() {
        updateScoreDisplay()
        updateWaveDisplay()
        updateLivesDisplay()
        updateResourceDisplay()
        updatePowerDisplay()
    }
    
    private func updateScoreDisplay() {
        scoreLabel?.text = formatNumber(score)
        
        // Pulse animation on score change
        scoreLabel?.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
    
    private func updateWaveDisplay() {
        waveLabel?.text = "Wave \(currentWave)"
    }
    
    private func updateLivesDisplay() {
        livesLabel?.text = "\(lives)"
        
        // Flash red if low
        if lives <= 5 {
            livesLabel?.fontColor = NeonGraphicsSystem.NeonColors.red
            livesLabel?.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])))
        }
    }
    
    private func updateResourceDisplay() {
        resourceLabel?.text = "\(resources) CR"
        
        // Update tower button availability
        for button in towerButtons {
            button.updateAvailability(resources: resources, power: powerAvailable)
        }
    }
    
    private func updatePowerDisplay() {
        powerLabel?.text = String(format: "%.1f/%.0f", powerAvailable, powerMax)
        
        // Color based on power level
        if powerAvailable < 2 {
            powerLabel?.fontColor = NeonGraphicsSystem.NeonColors.red
        } else if powerAvailable < 4 {
            powerLabel?.fontColor = NeonGraphicsSystem.NeonColors.yellow
        } else {
            powerLabel?.fontColor = NeonGraphicsSystem.NeonColors.green
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }
    
    // MARK: - Public Methods
    
    func setScore(_ newScore: Int) {
        score = newScore
    }
    
    func addScore(_ points: Int) {
        score += points
    }
    
    func setWave(_ wave: Int) {
        currentWave = wave
    }
    
    func setLives(_ newLives: Int) {
        lives = newLives
    }
    
    func setResources(_ newResources: Int) {
        resources = newResources
    }
    
    func addResources(_ amount: Int) {
        resources += amount
    }
    
    func spendResources(_ amount: Int) -> Bool {
        if resources >= amount {
            resources -= amount
            return true
        }
        return false
    }
    
    func setPower(available: Float, max: Float) {
        powerAvailable = available
        powerMax = max
    }
    
    func updateWaveProgress(_ progress: Float) {
        if let progressBar = childNode(withName: "//waveProgress") as? SKShapeNode {
            let newWidth = 300 * progress
            progressBar.path = CGPath(rect: CGRect(x: -150, y: -3, width: newWidth, height: 6), transform: nil)
        }
    }
    
    func showDamageIndicator() {
        // Flash red when taking damage
        let flash = SKShapeNode(rectOf: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        flash.fillColor = NeonGraphicsSystem.NeonColors.red.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.zPosition = 2000
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0.2),
            SKAction.removeFromParent()
        ]))
    }
    
    func showWaveComplete() {
        let label = createNeonLabel(text: "WAVE COMPLETE!", fontSize: 48)
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        label.zPosition = 2000
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.wait(forDuration: 1),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        // Bonus points animation
        let bonus = createNeonLabel(text: "+500", fontSize: 32)
        bonus.position = CGPoint(x: 0, y: 50)
        bonus.horizontalAlignmentMode = .center
        bonus.fontColor = NeonGraphicsSystem.NeonColors.green
        bonus.zPosition = 2000
        addChild(bonus)
        
        bonus.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 1),
            SKAction.fadeAlpha(to: 0, duration: 1),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Tower Button
class TowerButton: SKNode {
    
    let type: TowerType
    weak var delegate: TowerButtonDelegate?
    
    private var background: SKShapeNode!
    private var icon: SKNode!
    private var costLabel: SKLabelNode!
    private var isAvailable: Bool = true
    
    init(type: TowerType) {
        self.type = type
        super.init()
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Background
        background = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = getTowerColor()
        background.lineWidth = 2
        background.glowWidth = 3
        addChild(background)
        
        // Tower icon (simplified neon version)
        icon = NeonGraphicsSystem.shared.createNeonTower(type: type, tier: 1)
        icon.setScale(0.5)
        addChild(icon)
        
        // Cost label
        costLabel = SKLabelNode(fontNamed: "Helvetica Neue")
        costLabel.text = "\(getTowerCost())"
        costLabel.fontSize = 10
        costLabel.fontColor = NeonGraphicsSystem.NeonColors.yellow
        costLabel.position = CGPoint(x: 0, y: -30)
        addChild(costLabel)
        
        isUserInteractionEnabled = true
    }
    
    private func getTowerColor() -> SKColor {
        // Use tower type's associated color
        return NeonGraphicsSystem.NeonColors.cyan
    }
    
    private func getTowerCost() -> Int {
        // Get from tower configuration
        return 100 // Placeholder
    }
    
    func updateAvailability(resources: Int, power: Float) {
        isAvailable = resources >= getTowerCost()
        
        if isAvailable {
            background.strokeColor = getTowerColor()
            icon.alpha = 1.0
        } else {
            background.strokeColor = SKColor.gray
            icon.alpha = 0.3
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailable else { return }
        
        // Visual feedback
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        delegate?.towerButtonTapped(self)
    }
}

// MARK: - Protocols
protocol TowerButtonDelegate: AnyObject {
    func towerButtonTapped(_ button: TowerButton)
}

extension GameHUD: TowerButtonDelegate {
    func towerButtonTapped(_ button: TowerButton) {
        selectedTowerType = button.type
        
        // Visual feedback
        for btn in towerButtons {
            btn.background.strokeColor = btn == button ? 
                NeonGraphicsSystem.NeonColors.white : 
                btn.getTowerColor()
        }
    }
}