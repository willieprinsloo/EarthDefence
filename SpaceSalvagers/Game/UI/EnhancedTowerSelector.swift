import SpriteKit

// MARK: - Enhanced Tower Selector with Proper Graphics
class EnhancedTowerSelector: SKNode {
    
    private var towerButtons: [TowerSelectionButton] = []
    private var selectedButton: TowerSelectionButton?
    weak var delegate: TowerSelectorDelegate?
    
    init(screenWidth: CGFloat) {
        super.init()
        setupSelector(screenWidth: screenWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelector(screenWidth: CGFloat) {
        // Background panel - make it wider to fit all towers
        let panelWidth = max(screenWidth * 0.95, 720) // Match the tower layout width
        let panel = SKShapeNode(rect: CGRect(x: -panelWidth/2, y: -60, width: panelWidth, height: 120))
        panel.fillColor = SKColor.black.withAlphaComponent(0.7)
        panel.strokeColor = SKColor(red: 0.5, green: 0, blue: 1, alpha: 1) // Purple outline
        panel.lineWidth = 2
        panel.glowWidth = 4
        addChild(panel)
        
        // Tower types with proper colors
        let towers: [(TowerType, String, SKColor, Int)] = [
            (.laserTurret, "Laser", SKColor.red, 100),
            (.kineticCannon, "Cannon", SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1), 140),
            (.railgunEmplacement, "Railgun", SKColor.cyan, 220),
            (.plasmaArcNode, "Plasma", SKColor.purple, 180),
            (.missilePDBattery, "Missile", SKColor.orange, 200),
            (.nanobotSwarmDispenser, "Nano", SKColor.green, 240),
            (.cryoFoamProjector, "Cryo", SKColor(red: 0.5, green: 0.8, blue: 1, alpha: 1), 160),
            (.gravityWellProjector, "Gravity", SKColor(red: 0.8, green: 0.5, blue: 1, alpha: 1), 260),
            (.empShockTower, "EMP", SKColor.yellow, 240)
        ]
        
        // Dynamically calculate spacing to fit all towers
        let towerCount = CGFloat(towers.count)
        let totalWidth = max(screenWidth * 0.95, 720) // Use 95% of screen width, min 720 for all towers
        let spacing = totalWidth / towerCount
        let startX = -(totalWidth / 2) + (spacing / 2)
        
        print("Tower selector: \(towerCount) towers, total width: \(totalWidth), spacing: \(spacing)")
        
        for (index, (type, name, color, cost)) in towers.enumerated() {
            let button = TowerSelectionButton(
                type: type,
                name: name,
                color: color,
                cost: cost,
                position: CGPoint(x: startX + CGFloat(index) * spacing, y: 0)
            )
            button.delegate = self
            addChild(button)
            towerButtons.append(button)
        }
    }
    
    func updateAvailability(resources: Int) {
        for button in towerButtons {
            button.updateAvailability(resources: resources)
        }
    }
}

// MARK: - Tower Selection Button with Proper Visual
class TowerSelectionButton: SKNode {
    
    let type: TowerType
    let towerName: String
    let color: SKColor
    let cost: Int
    weak var delegate: TowerButtonDelegate?
    
    private var background: SKShapeNode!
    private var towerVisual: SKNode!
    private var nameLabel: SKLabelNode!
    private var costLabel: SKLabelNode!
    private var isAvailable: Bool = true
    private var isSelected: Bool = false
    
    init(type: TowerType, name: String, color: SKColor, cost: Int, position: CGPoint) {
        self.type = type
        self.towerName = name
        self.color = color
        self.cost = cost
        super.init()
        
        self.position = position
        self.isUserInteractionEnabled = true
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Button frame
        background = SKShapeNode(rect: CGRect(x: -32, y: -45, width: 64, height: 90))
        background.fillColor = SKColor.black.withAlphaComponent(0.6)
        background.strokeColor = color.withAlphaComponent(0.8)
        background.lineWidth = 1.5
        addChild(background)
        
        // Create proper tower visual
        towerVisual = createDetailedTowerIcon()
        towerVisual.position = CGPoint(x: 0, y: 8)
        addChild(towerVisual)
        
        // Tower name
        nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = towerName
        nameLabel.fontSize = 11
        nameLabel.fontColor = color
        nameLabel.position = CGPoint(x: 0, y: -22)
        addChild(nameLabel)
        
        // Cost with coin icon
        let costContainer = SKNode()
        costContainer.position = CGPoint(x: 0, y: -38)
        addChild(costContainer)
        
        // Coin symbol
        let coinSymbol = SKShapeNode(circleOfRadius: 4)
        coinSymbol.strokeColor = SKColor.yellow
        coinSymbol.lineWidth = 1
        coinSymbol.position = CGPoint(x: -12, y: 0)
        costContainer.addChild(coinSymbol)
        
        costLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        costLabel.text = "\(cost)"
        costLabel.fontSize = 12
        costLabel.fontColor = SKColor.yellow
        costLabel.horizontalAlignmentMode = .left
        costLabel.position = CGPoint(x: -4, y: -4)
        costContainer.addChild(costLabel)
    }
    
    private func createDetailedTowerIcon() -> SKNode {
        let icon = SKNode()
        
        switch type {
        case .laserTurret:
            // Laser turret with rotating barrel
            let base = createHexagonBase(size: 12, color: color)
            icon.addChild(base)
            
            let mount = SKShapeNode(circleOfRadius: 6)
            mount.strokeColor = color
            mount.lineWidth = 1
            mount.fillColor = .clear
            icon.addChild(mount)
            
            // Laser barrel
            let barrel = SKShapeNode(rect: CGRect(x: -2, y: 0, width: 4, height: 16))
            barrel.strokeColor = color
            barrel.lineWidth = 1
            barrel.fillColor = .clear
            icon.addChild(barrel)
            
            // Focusing lens
            let lens = SKShapeNode(circleOfRadius: 3)
            lens.strokeColor = color.withAlphaComponent(0.6)
            lens.lineWidth = 0.5
            lens.position = CGPoint(x: 0, y: 14)
            icon.addChild(lens)
            
        case .railgunEmplacement:
            // Railgun with parallel rails
            let base = SKShapeNode(rect: CGRect(x: -10, y: -8, width: 20, height: 10))
            base.strokeColor = color
            base.lineWidth = 1
            base.fillColor = .clear
            icon.addChild(base)
            
            // Rails
            for x in [-4, 4] {
                let rail = SKShapeNode(rect: CGRect(x: x - 1, y: -2, width: 2, height: 20))
                rail.strokeColor = color
                rail.lineWidth = 1
                rail.fillColor = .clear
                icon.addChild(rail)
                
                // Electromagnetic coils
                for y in stride(from: 2, to: 18, by: 4) {
                    let coil = SKShapeNode(circleOfRadius: 2)
                    coil.strokeColor = color.withAlphaComponent(0.5)
                    coil.lineWidth = 0.5
                    coil.position = CGPoint(x: x, y: y)
                    icon.addChild(coil)
                }
            }
            
        case .plasmaArcNode:
            // Plasma gun with charging chamber and emitter
            // Base mount
            let mount = SKShapeNode(circleOfRadius: 8)
            mount.strokeColor = color.withAlphaComponent(0.6)
            mount.lineWidth = 1
            mount.fillColor = .clear
            icon.addChild(mount)
            
            // Plasma chamber (cylindrical)
            let chamber = SKShapeNode(rect: CGRect(x: -6, y: -4, width: 12, height: 14))
            chamber.strokeColor = color
            chamber.lineWidth = 1
            chamber.fillColor = .clear
            icon.addChild(chamber)
            
            // Energy coils inside chamber
            for y in stride(from: 0, to: 10, by: 3) {
                let coil = SKShapeNode(ellipseOf: CGSize(width: 10, height: 2))
                coil.strokeColor = color.withAlphaComponent(0.5)
                coil.lineWidth = 0.5
                coil.position = CGPoint(x: 0, y: y)
                icon.addChild(coil)
            }
            
            // Plasma emitter barrel
            let barrel = SKShapeNode(rect: CGRect(x: -3, y: 10, width: 6, height: 8))
            barrel.strokeColor = color
            barrel.lineWidth = 1
            barrel.fillColor = .clear
            icon.addChild(barrel)
            
            // Emitter focus rings
            for i in 0..<3 {
                let ring = SKShapeNode(circleOfRadius: CGFloat(4 - i))
                ring.strokeColor = color.withAlphaComponent(0.8 - Float(i) * 0.2)
                ring.lineWidth = 0.5
                ring.position = CGPoint(x: 0, y: 16)
                icon.addChild(ring)
            }
            
        case .missilePDBattery:
            // Vertical launch missile system
            // Launch platform
            let platform = SKShapeNode(rect: CGRect(x: -14, y: -8, width: 28, height: 6))
            platform.strokeColor = color
            platform.lineWidth = 1
            platform.fillColor = .clear
            icon.addChild(platform)
            
            // Missile silos (vertical launch tubes)
            for (index, x) in [-9, -3, 3, 9].enumerated() {
                // Silo tube
                let silo = SKShapeNode(rect: CGRect(x: x - 3, y: -2, width: 6, height: 14))
                silo.strokeColor = color
                silo.lineWidth = 1
                silo.fillColor = .clear
                icon.addChild(silo)
                
                // Missile inside (visible top)
                let missile = SKNode()
                missile.position = CGPoint(x: x, y: 6)
                
                // Missile body
                let body = SKShapeNode(rect: CGRect(x: -2, y: -4, width: 4, height: 8))
                body.strokeColor = color.withAlphaComponent(0.8)
                body.lineWidth = 0.8
                body.fillColor = .clear
                missile.addChild(body)
                
                // Missile warhead (pointed tip)
                let warheadPath = CGMutablePath()
                warheadPath.move(to: CGPoint(x: -2, y: 4))
                warheadPath.addLine(to: CGPoint(x: 0, y: 8))
                warheadPath.addLine(to: CGPoint(x: 2, y: 4))
                let warhead = SKShapeNode(path: warheadPath)
                warhead.strokeColor = color
                warhead.lineWidth = 0.8
                missile.addChild(warhead)
                
                // Fins at base
                for side in [-1, 1] {
                    let fin = SKShapeNode(rect: CGRect(x: CGFloat(side) * 2, y: -4, width: 1, height: 3))
                    fin.strokeColor = color.withAlphaComponent(0.6)
                    fin.lineWidth = 0.5
                    missile.addChild(fin)
                }
                
                icon.addChild(missile)
                
                // Launch doors (open state)
                if index % 2 == 0 {
                    let door = SKShapeNode(rect: CGRect(x: x - 3, y: 10, width: 6, height: 1))
                    door.strokeColor = color.withAlphaComponent(0.4)
                    door.lineWidth = 0.5
                    icon.addChild(door)
                }
            }
            
            // Targeting radar dish
            let radar = SKShapeNode(circleOfRadius: 3)
            radar.strokeColor = color.withAlphaComponent(0.6)
            radar.lineWidth = 0.5
            radar.position = CGPoint(x: 0, y: -5)
            icon.addChild(radar)
            
        case .nanobotSwarmDispenser:
            // Nanobot dispenser with swarm particles
            let dispenser = createHexagonBase(size: 10, color: color)
            icon.addChild(dispenser)
            
            // Swarm particles
            for _ in 0..<8 {
                let particle = SKShapeNode(circleOfRadius: 1)
                particle.strokeColor = color.withAlphaComponent(0.6)
                particle.lineWidth = 0.5
                particle.position = CGPoint(
                    x: CGFloat.random(in: -12...12),
                    y: CGFloat.random(in: -8...15)
                )
                icon.addChild(particle)
            }
            
            // Central hive
            let hive = SKShapeNode(rect: CGRect(x: -6, y: -4, width: 12, height: 12))
            hive.strokeColor = color
            hive.lineWidth = 1
            hive.fillColor = .clear
            icon.addChild(hive)
            
        case .cryoFoamProjector:
            // Cryo projector with cooling vents
            let tank = SKShapeNode(ellipseOf: CGSize(width: 14, height: 18))
            tank.strokeColor = color
            tank.lineWidth = 1
            tank.fillColor = .clear
            icon.addChild(tank)
            
            // Nozzle
            let nozzle = createTriangle(at: CGPoint(x: 0, y: 12), size: 6, color: color)
            icon.addChild(nozzle)
            
            // Cooling vents
            for angle in stride(from: 0, to: 360, by: 60) {
                let rad = angle * .pi / 180
                let x = cos(rad) * 8
                let y = sin(rad) * 8
                let vent = SKShapeNode(circleOfRadius: 2)
                vent.strokeColor = color.withAlphaComponent(0.5)
                vent.lineWidth = 0.5
                vent.position = CGPoint(x: x, y: y)
                icon.addChild(vent)
            }
            
        case .gravityWellProjector:
            // Gravity well with distortion rings
            let projector = SKShapeNode(circleOfRadius: 8)
            projector.strokeColor = color
            projector.lineWidth = 1
            projector.fillColor = .clear
            icon.addChild(projector)
            
            // Gravity distortion rings
            for radius in stride(from: 4, to: 16, by: 3) {
                let ring = SKShapeNode(circleOfRadius: CGFloat(radius))
                ring.strokeColor = color.withAlphaComponent(0.6 - Float(radius) * 0.03)
                ring.lineWidth = 0.5
                ring.fillColor = .clear
                let dashPattern: [CGFloat] = [2, 2]
                ring.lineCap = .round
                icon.addChild(ring)
            }
            
            // Central singularity
            let core = SKShapeNode(circleOfRadius: 2)
            core.strokeColor = color
            core.lineWidth = 1
            core.glowWidth = 3
            icon.addChild(core)
            
        case .empShockTower:
            // EMP tower with electrical arcs
            let tower = SKShapeNode(rect: CGRect(x: -6, y: -8, width: 12, height: 20))
            tower.strokeColor = color
            tower.lineWidth = 1
            tower.fillColor = .clear
            icon.addChild(tower)
            
            // Tesla coils
            for y in [-4, 4, 12] {
                let coil = SKShapeNode(circleOfRadius: 4)
                coil.strokeColor = color
                coil.lineWidth = 1
                coil.position = CGPoint(x: 0, y: y)
                icon.addChild(coil)
            }
            
            // Electric arcs
            for _ in 0..<3 {
                let arc = createLightningArc(from: CGPoint(x: 0, y: 12), length: 8, color: color)
                icon.addChild(arc)
            }
            
        case .kineticCannon:
            // Kinetic cannon with robust barrel and tripod base
            // Tripod base
            let base = SKShapeNode(circleOfRadius: 8)
            base.strokeColor = color
            base.lineWidth = 1
            base.fillColor = .clear
            icon.addChild(base)
            
            // Support legs
            for angle in stride(from: 0, to: 360, by: 120) {
                let rad = angle * .pi / 180
                let x = cos(rad) * 10
                let y = sin(rad) * 10
                let leg = SKShapeNode(rect: CGRect(x: x - 1, y: y - 1, width: 2, height: 8))
                leg.strokeColor = color.withAlphaComponent(0.7)
                leg.lineWidth = 0.8
                leg.fillColor = .clear
                icon.addChild(leg)
            }
            
            // Main cannon barrel (thick and robust)
            let barrel = SKShapeNode(rect: CGRect(x: -3, y: 0, width: 6, height: 18))
            barrel.strokeColor = color
            barrel.lineWidth = 1.5
            barrel.fillColor = .clear
            icon.addChild(barrel)
            
            // Barrel reinforcement bands
            for y in [4, 8, 12] {
                let band = SKShapeNode(rect: CGRect(x: -4, y: y, width: 8, height: 1))
                band.strokeColor = color.withAlphaComponent(0.8)
                band.lineWidth = 0.8
                icon.addChild(band)
            }
            
            // Muzzle brake
            let muzzle = SKShapeNode(rect: CGRect(x: -4, y: 16, width: 8, height: 3))
            muzzle.strokeColor = color
            muzzle.lineWidth = 1
            muzzle.fillColor = .clear
            icon.addChild(muzzle)
            
            // Recoil compensator fins
            for x in [-5, 5] {
                let fin = SKShapeNode(rect: CGRect(x: x, y: 16, width: 1, height: 3))
                fin.strokeColor = color.withAlphaComponent(0.6)
                fin.lineWidth = 0.5
                icon.addChild(fin)
            }
            
        default:
            // Generic tower
            let base = SKShapeNode(rect: CGRect(x: -8, y: -8, width: 16, height: 16))
            base.strokeColor = color
            base.lineWidth = 1
            base.fillColor = .clear
            icon.addChild(base)
        }
        
        return icon
    }
    
    // Helper functions for creating shapes
    private func createHexagonBase(size: CGFloat, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let x = cos(angle) * size
            let y = sin(angle) * size
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        let hexagon = SKShapeNode(path: path)
        hexagon.strokeColor = color
        hexagon.lineWidth = 1
        hexagon.fillColor = .clear
        return hexagon
    }
    
    private func createTriangleBase(size: CGFloat, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: -size * 0.866, y: -size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.866, y: -size * 0.5))
        path.closeSubpath()
        
        let triangle = SKShapeNode(path: path)
        triangle.strokeColor = color
        triangle.lineWidth = 1
        triangle.fillColor = .clear
        return triangle
    }
    
    private func createTriangle(at position: CGPoint, size: CGFloat, color: SKColor) -> SKShapeNode {
        let triangle = createTriangleBase(size: size, color: color)
        triangle.position = position
        return triangle
    }
    
    private func createLightningArc(from: CGPoint, length: CGFloat, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        
        let segments = 4
        for i in 1...segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let x = from.x + CGFloat.random(in: -4...4)
            let y = from.y - (length * progress)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        let arc = SKShapeNode(path: path)
        arc.strokeColor = color.withAlphaComponent(0.6)
        arc.lineWidth = 0.5
        arc.glowWidth = 1
        return arc
    }
    
    func updateAvailability(resources: Int) {
        isAvailable = resources >= cost
        
        if isAvailable {
            background.strokeColor = isSelected ? .white : color.withAlphaComponent(0.8)
            towerVisual.alpha = 1.0
            nameLabel.fontColor = color
            costLabel.fontColor = .yellow
        } else {
            background.strokeColor = .gray
            towerVisual.alpha = 0.3
            nameLabel.fontColor = .gray
            costLabel.fontColor = .gray
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        background.strokeColor = selected ? .white : color.withAlphaComponent(0.8)
        background.lineWidth = selected ? 2.5 : 1.5
        
        if selected {
            // Pulse animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            run(pulse)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailable else { return }
        delegate?.towerButtonTapped(self)
    }
}

// MARK: - Protocols
protocol TowerSelectorDelegate: AnyObject {
    func didSelectTower(type: TowerType)
}

protocol TowerButtonDelegate: AnyObject {
    func towerButtonTapped(_ button: TowerSelectionButton)
}

// MARK: - Extension
extension EnhancedTowerSelector: TowerButtonDelegate {
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