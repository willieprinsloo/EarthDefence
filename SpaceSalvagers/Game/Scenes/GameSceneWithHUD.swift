import SpriteKit
import GameplayKit

// MARK: - Enhanced Game Scene with HUD
class GameSceneWithHUD: SKScene {
    
    // HUD
    private var gameHUD: GameHUD!
    
    // Game State
    private var score: Int = 0
    private var currentWave: Int = 1
    private var lives: Int = 5
    private var resources: Int = 300
    private var powerAvailable: Float = 5.0
    private var powerMax: Float = 10.0
    
    // Layers
    private var gameLayer: SKNode!
    private var hudLayer: SKNode!
    
    // Tower placement
    private var selectedTowerType: TowerType?
    private var placementIndicator: SKNode?
    
    override func didMove(to view: SKView) {
        setupLayers()
        setupHUD()
        setupGame()
        
        // Start with initial values
        updateHUD()
    }
    
    // MARK: - Setup
    
    private func setupLayers() {
        // Game layer for gameplay elements
        gameLayer = SKNode()
        gameLayer.zPosition = 0
        addChild(gameLayer)
        
        // HUD layer always on top
        hudLayer = SKNode()
        hudLayer.zPosition = 1000
        addChild(hudLayer)
    }
    
    private func setupHUD() {
        gameHUD = EnhancedGameHUD(screenSize: size)
        hudLayer.addChild(gameHUD)
        
        // Set initial values
        gameHUD.setScore(score)
        gameHUD.setWave(currentWave)
        gameHUD.setLives(lives)
        gameHUD.setResources(resources)
        gameHUD.setPower(available: powerAvailable, max: powerMax)
        
        // Set delegate for tower selection
        gameHUD.delegate = self
    }
    
    private func setupGame() {
        // Add background
        let background = SKSpriteNode(color: SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1), size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -100
        gameLayer.addChild(background)
        
        // Add grid pattern
        addGridPattern()
        
        // Start game loop
        startGameLoop()
    }
    
    private func addGridPattern() {
        let gridSize: CGFloat = 40
        let gridColor = SKColor.cyan.withAlphaComponent(0.1)
        
        // Vertical lines
        for x in stride(from: 0, through: size.width, by: gridSize) {
            let line = SKShapeNode(rect: CGRect(x: x, y: 0, width: 1, height: size.height))
            line.fillColor = gridColor
            line.strokeColor = .clear
            line.zPosition = -99
            gameLayer.addChild(line)
        }
        
        // Horizontal lines
        for y in stride(from: 0, through: size.height, by: gridSize) {
            let line = SKShapeNode(rect: CGRect(x: 0, y: y, width: size.width, height: 1))
            line.fillColor = gridColor
            line.strokeColor = .clear
            line.zPosition = -99
            gameLayer.addChild(line)
        }
    }
    
    // MARK: - Game Loop
    
    private func startGameLoop() {
        // Simulate score increase
        let scoreAction = SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run { [weak self] in
                self?.addScore(10)
            }
        ])
        run(SKAction.repeatForever(scoreAction))
        
        // Simulate resource generation
        let resourceAction = SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.run { [weak self] in
                self?.addResources(5)
            }
        ])
        run(SKAction.repeatForever(resourceAction))
    }
    
    // MARK: - Game State Updates
    
    private func addScore(_ points: Int) {
        score += points
        gameHUD.setScore(score)
    }
    
    private func addResources(_ amount: Int) {
        resources += amount
        gameHUD.setResources(resources)
    }
    
    private func takeDamage(_ damage: Int) {
        lives -= damage
        gameHUD.setLives(lives)
        gameHUD.showDamageIndicator()
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func completeWave() {
        currentWave += 1
        gameHUD.setWave(currentWave)
        gameHUD.showWaveComplete()
        
        // Bonus resources for wave completion
        addResources(50)
        addScore(100)
    }
    
    private func gameOver() {
        // Game over logic
        print("Game Over!")
    }
    
    private func updateHUD() {
        gameHUD.setScore(score)
        gameHUD.setWave(currentWave)
        gameHUD.setLives(lives)
        gameHUD.setResources(resources)
        gameHUD.setPower(available: powerAvailable, max: powerMax)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is in HUD
        if location.y < 120 || location.y > size.height - 80 {
            // Let HUD handle it
            return
        }
        
        // Handle tower placement
        if let towerType = selectedTowerType {
            placeTower(type: towerType, at: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Update placement indicator
        if selectedTowerType != nil {
            updatePlacementIndicator(at: location)
        }
    }
    
    private func placeTower(type: TowerType, at location: CGPoint) {
        // Check if we have enough resources
        let cost = getTowerCost(type: type)
        guard resources >= cost else {
            // Show insufficient resources indicator
            return
        }
        
        // Check if location is valid
        guard isValidPlacement(at: location) else {
            return
        }
        
        // Deduct resources
        resources -= cost
        gameHUD.setResources(resources)
        
        // Create and place tower
        let tower = OutlineGraphicsSystem.shared.createOutlineLaserTurret(tier: 1)
        tower.position = location
        gameLayer.addChild(tower)
        
        // Add score for placing tower
        addScore(5)
    }
    
    private func updatePlacementIndicator(at location: CGPoint) {
        if placementIndicator == nil {
            placementIndicator = SKShapeNode(circleOfRadius: 30)
            if let indicator = placementIndicator as? SKShapeNode {
                indicator.strokeColor = .green
                indicator.lineWidth = 2
                indicator.fillColor = .clear
                indicator.alpha = 0.5
            }
            gameLayer.addChild(placementIndicator!)
        }
        
        placementIndicator?.position = location
        
        // Change color based on validity
        if let indicator = placementIndicator as? SKShapeNode {
            indicator.strokeColor = isValidPlacement(at: location) ? .green : .red
        }
    }
    
    private func isValidPlacement(at location: CGPoint) -> Bool {
        // Check if location is within game area and not on path
        return location.y > 120 && location.y < size.height - 80
    }
    
    private func getTowerCost(type: TowerType) -> Int {
        switch type {
        case .laserTurret: return 100
        case .railgunEmplacement: return 220
        case .plasmaArcNode: return 180
        case .missilePDBattery: return 200
        case .nanobotSwarmDispenser: return 240
        case .cryoFoamProjector: return 160
        case .gravityWellProjector: return 260
        case .empShockTower: return 240
        default: return 100
        }
    }
}

// MARK: - Enhanced Game HUD
class EnhancedGameHUD: SKNode {
    
    weak var delegate: GameHUDDelegate?
    
    private let screenSize: CGSize
    
    // Display elements
    private var scoreLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var resourceLabel: SKLabelNode!
    private var powerLabel: SKLabelNode!
    
    // Tower selection
    private var towerButtons: [TowerSelectionButton] = []
    private var selectedButton: TowerSelectionButton?
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        super.init()
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        setupTopBar()
        setupBottomBar()
    }
    
    private func setupTopBar() {
        // Top bar background
        let topBar = SKShapeNode(rect: CGRect(x: 0, y: screenSize.height - 80, width: screenSize.width, height: 80))
        topBar.fillColor = SKColor.black.withAlphaComponent(0.8)
        topBar.strokeColor = OutlineGraphicsSystem.OutlineColors.cyan
        topBar.lineWidth = 2
        addChild(topBar)
        
        // Score
        let scoreIcon = createIcon("⭐", at: CGPoint(x: 50, y: screenSize.height - 40))
        addChild(scoreIcon)
        
        scoreLabel = createLabel("0", at: CGPoint(x: 100, y: screenSize.height - 40))
        addChild(scoreLabel)
        
        // Wave
        let waveIcon = createIcon("🌊", at: CGPoint(x: 200, y: screenSize.height - 40))
        addChild(waveIcon)
        
        waveLabel = createLabel("Wave 1", at: CGPoint(x: 250, y: screenSize.height - 40))
        addChild(waveLabel)
        
        // Lives (center)
        let livesIcon = createIcon("❤️", at: CGPoint(x: screenSize.width / 2 - 30, y: screenSize.height - 40))
        addChild(livesIcon)
        
        livesLabel = createLabel("20", at: CGPoint(x: screenSize.width / 2 + 10, y: screenSize.height - 40))
        livesLabel.fontSize = 28
        addChild(livesLabel)
        
        // Resources
        let resourceIcon = createIcon("💰", at: CGPoint(x: screenSize.width - 200, y: screenSize.height - 40))
        addChild(resourceIcon)
        
        resourceLabel = createLabel("300 CR", at: CGPoint(x: screenSize.width - 150, y: screenSize.height - 40))
        addChild(resourceLabel)
        
        // Power
        let powerIcon = createIcon("⚡", at: CGPoint(x: screenSize.width - 100, y: screenSize.height - 40))
        addChild(powerIcon)
        
        powerLabel = createLabel("5/10", at: CGPoint(x: screenSize.width - 50, y: screenSize.height - 40))
        addChild(powerLabel)
    }
    
    private func setupBottomBar() {
        // Bottom bar background
        let bottomBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: screenSize.width, height: 120))
        bottomBar.fillColor = SKColor.black.withAlphaComponent(0.8)
        bottomBar.strokeColor = OutlineGraphicsSystem.OutlineColors.cyan
        bottomBar.lineWidth = 2
        addChild(bottomBar)
        
        // Speed controls
        setupSpeedControls()
        
        // Tower selection buttons
        setupTowerButtons()
    }
    
    private func setupSpeedControls() {
        let controls = ["⏸", "▶️", "⏩"]
        for (index, symbol) in controls.enumerated() {
            let button = createSpeedButton(symbol, at: CGPoint(x: 40 + index * 40, y: 60))
            button.name = "speed_\(index)"
            addChild(button)
        }
    }
    
    private func setupTowerButtons() {
        let towerTypes: [(TowerType, String, SKColor)] = [
            (.laserTurret, "Laser", OutlineGraphicsSystem.OutlineColors.red),
            (.railgunEmplacement, "Rail", OutlineGraphicsSystem.OutlineColors.blue),
            (.plasmaArcNode, "Arc", OutlineGraphicsSystem.OutlineColors.purple),
            (.missilePDBattery, "PD", OutlineGraphicsSystem.OutlineColors.orange),
            (.nanobotSwarmDispenser, "Nano", OutlineGraphicsSystem.OutlineColors.green),
            (.cryoFoamProjector, "Cryo", OutlineGraphicsSystem.OutlineColors.cyan),
            (.gravityWellProjector, "Grav", OutlineGraphicsSystem.OutlineColors.purple),
            (.empShockTower, "EMP", OutlineGraphicsSystem.OutlineColors.yellow)
        ]
        
        let startX: CGFloat = 200
        let spacing: CGFloat = 70
        
        for (index, (type, name, color)) in towerTypes.enumerated() {
            let button = TowerSelectionButton(
                type: type,
                name: name,
                color: color,
                position: CGPoint(x: startX + CGFloat(index) * spacing, y: 60)
            )
            button.delegate = self
            addChild(button)
            towerButtons.append(button)
        }
    }
    
    private func createIcon(_ text: String, at position: CGPoint) -> SKLabelNode {
        let icon = SKLabelNode(text: text)
        icon.fontSize = 24
        icon.position = position
        return icon
    }
    
    private func createLabel(_ text: String, at position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.position = position
        return label
    }
    
    private func createSpeedButton(_ symbol: String, at position: CGPoint) -> SKNode {
        let button = SKShapeNode(circleOfRadius: 15)
        button.position = position
        button.fillColor = SKColor.black.withAlphaComponent(0.5)
        button.strokeColor = OutlineGraphicsSystem.OutlineColors.cyan
        button.lineWidth = 2
        
        let label = SKLabelNode(text: symbol)
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    // MARK: - Public Methods
    
    func setScore(_ score: Int) {
        scoreLabel.text = "\(score)"
        animateLabel(scoreLabel)
    }
    
    func setWave(_ wave: Int) {
        waveLabel.text = "Wave \(wave)"
    }
    
    func setLives(_ lives: Int) {
        livesLabel.text = "\(lives)"
        
        if lives <= 5 {
            livesLabel.fontColor = OutlineGraphicsSystem.OutlineColors.red
        } else if lives <= 10 {
            livesLabel.fontColor = OutlineGraphicsSystem.OutlineColors.yellow
        } else {
            livesLabel.fontColor = .white
        }
    }
    
    func setResources(_ resources: Int) {
        resourceLabel.text = "\(resources) CR"
        
        // Update button availability
        for button in towerButtons {
            button.updateAvailability(resources: resources)
        }
    }
    
    func setPower(available: Float, max: Float) {
        powerLabel.text = "\(Int(available))/\(Int(max))"
        
        if available < 2 {
            powerLabel.fontColor = OutlineGraphicsSystem.OutlineColors.red
        } else if available < 4 {
            powerLabel.fontColor = OutlineGraphicsSystem.OutlineColors.yellow
        } else {
            powerLabel.fontColor = OutlineGraphicsSystem.OutlineColors.green
        }
    }
    
    func showDamageIndicator() {
        let flash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        flash.fillColor = OutlineGraphicsSystem.OutlineColors.red.withAlphaComponent(0.2)
        flash.strokeColor = .clear
        flash.zPosition = 2000
        addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    func showWaveComplete() {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "WAVE COMPLETE!"
        label.fontSize = 48
        label.fontColor = OutlineGraphicsSystem.OutlineColors.green
        label.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        label.zPosition = 2000
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.wait(forDuration: 1),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func animateLabel(_ label: SKLabelNode) {
        label.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
}

// MARK: - Tower Selection Button
class TowerSelectionButton: SKNode {
    
    let type: TowerType
    let towerName: String
    let color: SKColor
    weak var delegate: TowerButtonDelegate?
    
    private var background: SKShapeNode!
    private var iconNode: SKNode!
    private var nameLabel: SKLabelNode!
    private var costLabel: SKLabelNode!
    private var isAvailable: Bool = true
    private var isSelected: Bool = false
    
    init(type: TowerType, name: String, color: SKColor, position: CGPoint) {
        self.type = type
        self.towerName = name
        self.color = color
        super.init()
        
        self.position = position
        self.isUserInteractionEnabled = true
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Background frame
        background = SKShapeNode(rect: CGRect(x: -30, y: -40, width: 60, height: 80))
        background.fillColor = SKColor.black.withAlphaComponent(0.5)
        background.strokeColor = color
        background.lineWidth = 2
        addChild(background)
        
        // Tower icon (simplified representation)
        iconNode = createTowerIcon()
        iconNode.position = CGPoint(x: 0, y: 5)
        addChild(iconNode)
        
        // Tower name
        nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = towerName
        nameLabel.fontSize = 10
        nameLabel.fontColor = color
        nameLabel.position = CGPoint(x: 0, y: -20)
        addChild(nameLabel)
        
        // Cost
        costLabel = SKLabelNode(fontNamed: "Helvetica")
        costLabel.text = "\(getTowerCost())"
        costLabel.fontSize = 12
        costLabel.fontColor = OutlineGraphicsSystem.OutlineColors.yellow
        costLabel.position = CGPoint(x: 0, y: -35)
        addChild(costLabel)
    }
    
    private func createTowerIcon() -> SKNode {
        // Create simplified tower icon based on type
        switch type {
        case .laserTurret:
            return createLaserIcon()
        case .railgunEmplacement:
            return createRailgunIcon()
        case .plasmaArcNode:
            return createPlasmaIcon()
        case .missilePDBattery:
            return createMissileIcon()
        default:
            return createDefaultIcon()
        }
    }
    
    private func createLaserIcon() -> SKNode {
        let icon = SKNode()
        
        // Simplified laser turret
        let base = SKShapeNode(circleOfRadius: 8)
        base.strokeColor = color
        base.lineWidth = 1
        base.fillColor = .clear
        icon.addChild(base)
        
        let barrel = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 12))
        barrel.strokeColor = color
        barrel.lineWidth = 1
        barrel.fillColor = .clear
        icon.addChild(barrel)
        
        return icon
    }
    
    private func createRailgunIcon() -> SKNode {
        let icon = SKNode()
        
        // Simplified railgun
        let base = SKShapeNode(rect: CGRect(x: -8, y: -6, width: 16, height: 12))
        base.strokeColor = color
        base.lineWidth = 1
        base.fillColor = .clear
        icon.addChild(base)
        
        for side in [-1, 1] {
            let rail = SKShapeNode(rect: CGRect(x: CGFloat(side) * 3 - 1, y: 0, width: 2, height: 15))
            rail.strokeColor = color
            rail.lineWidth = 1
            rail.fillColor = .clear
            icon.addChild(rail)
        }
        
        return icon
    }
    
    private func createPlasmaIcon() -> SKNode {
        let icon = SKNode()
        
        // Triangle base
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: -8, y: -5))
        path.addLine(to: CGPoint(x: 8, y: -5))
        path.closeSubpath()
        
        let triangle = SKShapeNode(path: path)
        triangle.strokeColor = color
        triangle.lineWidth = 1
        triangle.fillColor = .clear
        icon.addChild(triangle)
        
        return icon
    }
    
    private func createMissileIcon() -> SKNode {
        let icon = SKNode()
        
        // Missile pods
        for x in [-6, 0, 6] {
            let pod = SKShapeNode(circleOfRadius: 3)
            pod.strokeColor = color
            pod.lineWidth = 1
            pod.fillColor = .clear
            pod.position = CGPoint(x: CGFloat(x), y: 0)
            icon.addChild(pod)
        }
        
        return icon
    }
    
    private func createDefaultIcon() -> SKNode {
        let icon = SKShapeNode(rect: CGRect(x: -8, y: -8, width: 16, height: 16))
        icon.strokeColor = color
        icon.lineWidth = 1
        icon.fillColor = .clear
        return icon
    }
    
    private func getTowerCost() -> Int {
        switch type {
        case .laserTurret: return 100
        case .railgunEmplacement: return 220
        case .plasmaArcNode: return 180
        case .missilePDBattery: return 200
        case .nanobotSwarmDispenser: return 240
        case .cryoFoamProjector: return 160
        case .gravityWellProjector: return 260
        case .empShockTower: return 240
        default: return 100
        }
    }
    
    func updateAvailability(resources: Int) {
        isAvailable = resources >= getTowerCost()
        
        if isAvailable {
            background.strokeColor = isSelected ? .white : color
            iconNode.alpha = 1.0
            nameLabel.fontColor = color
        } else {
            background.strokeColor = .gray
            iconNode.alpha = 0.3
            nameLabel.fontColor = .gray
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        background.strokeColor = selected ? .white : color
        background.lineWidth = selected ? 3 : 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailable else { return }
        
        // Visual feedback
        run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ]))
        
        delegate?.towerButtonTapped(self)
    }
}

// MARK: - Protocols
protocol GameHUDDelegate: AnyObject {
    func didSelectTower(type: TowerType)
    func didTapSpeedControl(speed: Int)
}

protocol TowerButtonDelegate: AnyObject {
    func towerButtonTapped(_ button: TowerSelectionButton)
}

// MARK: - Extensions
extension EnhancedGameHUD: TowerButtonDelegate {
    func towerButtonTapped(_ button: TowerSelectionButton) {
        // Deselect previous
        selectedButton?.setSelected(false)
        
        // Select new
        button.setSelected(true)
        selectedButton = button
        
        // Notify delegate
        delegate?.didSelectTower(type: button.type)
    }
}

extension GameSceneWithHUD: GameHUDDelegate {
    func didSelectTower(type: TowerType) {
        selectedTowerType = type
        
        // Create placement indicator
        updatePlacementIndicator(at: CGPoint(x: size.width / 2, y: size.height / 2))
    }
    
    func didTapSpeedControl(speed: Int) {
        // Handle speed control
        switch speed {
        case 0: // Pause
            isPaused = true
        case 1: // Play
            isPaused = false
            physicsWorld.speed = 1.0
        case 2: // Fast forward
            isPaused = false
            physicsWorld.speed = 2.0
        default:
            break
        }
    }
}