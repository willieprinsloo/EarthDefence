import Foundation
import SpriteKit
import CoreGraphics

// MARK: - Neon Graphics System
class NeonGraphicsSystem {
    
    static let shared = NeonGraphicsSystem()
    
    // Neon color palette
    struct NeonColors {
        static let cyan = SKColor(red: 0, green: 1, blue: 1, alpha: 1)
        static let magenta = SKColor(red: 1, green: 0, blue: 1, alpha: 1)
        static let yellow = SKColor(red: 1, green: 1, blue: 0, alpha: 1)
        static let green = SKColor(red: 0, green: 1, blue: 0.5, alpha: 1)
        static let orange = SKColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        static let pink = SKColor(red: 1, green: 0.2, blue: 0.8, alpha: 1)
        static let purple = SKColor(red: 0.6, green: 0.2, blue: 1, alpha: 1)
        static let blue = SKColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        static let red = SKColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        static let white = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private init() {}
    
    // MARK: - Neon Tower Creation
    func createNeonTower(type: TowerType, tier: Int = 1) -> SKNode {
        let container = SKNode()
        
        // Create base platform with neon glow
        let platform = createNeonPlatform(tier: tier)
        container.addChild(platform)
        
        // Create tower based on type
        let tower = createNeonTowerBody(type: type, tier: tier)
        container.addChild(tower)
        
        // Add pulsing glow effect
        addNeonPulse(to: tower, color: getTowerNeonColor(type))
        
        // Add tier indicators
        if tier > 1 {
            addTierIndicators(to: container, tier: tier, color: getTowerNeonColor(type))
        }
        
        return container
    }
    
    // MARK: - Tower Bodies (Line Art Style)
    
    private func createNeonTowerBody(type: TowerType, tier: Int) -> SKNode {
        switch type {
        case .laserTurret:
            return createNeonLaserTurret(tier: tier)
        case .railgunEmplacement:
            return createNeonRailgun(tier: tier)
        case .plasmaArcNode:
            return createNeonPlasmaArc(tier: tier)
        case .missilePDBattery:
            return createNeonMissilePD(tier: tier)
        case .nanobotSwarmDispenser:
            return createNeonNanobot(tier: tier)
        case .cryoFoamProjector:
            return createNeonCryo(tier: tier)
        case .gravityWellProjector:
            return createNeonGravityWell(tier: tier)
        case .empShockTower:
            return createNeonEMP(tier: tier)
        case .plasmaMortar:
            return createNeonMortar(tier: tier)
        case .droneBay:
            return createNeonDroneBay(tier: tier)
        case .shieldProjector:
            return createNeonShield(tier: tier)
        case .hackingUplink:
            return createNeonHacking(tier: tier)
        case .resourceHarvester:
            return createNeonHarvester(tier: tier)
        case .repairDroneSpire:
            return createNeonRepairSpire(tier: tier)
        case .solarLanceArray:
            return createNeonSolarLance(tier: tier)
        case .singularityCannon:
            return createNeonSingularity(tier: tier)
        }
    }
    
    private func createNeonLaserTurret(tier: Int) -> SKNode {
        let turret = SKNode()
        let color = NeonColors.red
        
        // Base circle with neon glow
        let base = createNeonCircle(radius: 15, color: color, lineWidth: 2)
        turret.addChild(base)
        
        // Rotating barrel (line art)
        let barrel = SKNode()
        barrel.name = "barrel"
        
        // Main barrel lines
        let leftLine = createNeonLine(from: CGPoint(x: -3, y: 0), to: CGPoint(x: -3, y: 25), color: color)
        let rightLine = createNeonLine(from: CGPoint(x: 3, y: 0), to: CGPoint(x: 3, y: 25), color: color)
        let topLine = createNeonLine(from: CGPoint(x: -3, y: 25), to: CGPoint(x: 3, y: 25), color: color)
        
        barrel.addChild(leftLine)
        barrel.addChild(rightLine)
        barrel.addChild(topLine)
        
        // Focusing lens at tip
        let lens = createNeonCircle(radius: 5, color: color, lineWidth: 1)
        lens.position = CGPoint(x: 0, y: 25)
        lens.fillColor = color.withAlphaComponent(0.3)
        barrel.addChild(lens)
        
        // Add tier upgrades
        if tier >= 2 {
            // Add heat sinks
            for side in [-1, 1] {
                let sink = createNeonLine(from: CGPoint(x: CGFloat(side) * 8, y: 5), 
                                         to: CGPoint(x: CGFloat(side) * 12, y: 15), color: color)
                barrel.addChild(sink)
            }
        }
        
        if tier >= 3 {
            // Add power coils
            for i in 0..<3 {
                let coil = createNeonCircle(radius: 4, color: color.withAlphaComponent(0.5), lineWidth: 1)
                coil.position = CGPoint(x: 0, y: 5 + CGFloat(i) * 6)
                barrel.addChild(coil)
            }
        }
        
        turret.addChild(barrel)
        
        // Scanning animation
        let scan = SKAction.sequence([
            SKAction.rotate(toAngle: .pi/4, duration: 2),
            SKAction.rotate(toAngle: -.pi/4, duration: 2)
        ])
        barrel.run(SKAction.repeatForever(scan))
        
        return turret
    }
    
    private func createNeonRailgun(tier: Int) -> SKNode {
        let railgun = SKNode()
        let color = NeonColors.blue
        
        // Hexagonal base
        let base = createNeonHexagon(radius: 18, color: color, lineWidth: 2)
        railgun.addChild(base)
        
        // Twin rails
        let barrel = SKNode()
        barrel.name = "barrel"
        
        for side in [-1, 1] {
            // Main rail
            let rail = createNeonLine(from: CGPoint(x: CGFloat(side) * 4, y: 0),
                                     to: CGPoint(x: CGFloat(side) * 4, y: 40), 
                                     color: color, lineWidth: 2)
            barrel.addChild(rail)
            
            // Electromagnetic coils
            for i in 0..<4 {
                let coil = createNeonSquare(size: 6, color: color.withAlphaComponent(0.6), lineWidth: 1)
                coil.position = CGPoint(x: CGFloat(side) * 4, y: 5 + CGFloat(i) * 10)
                coil.zRotation = .pi/4
                barrel.addChild(coil)
            }
        }
        
        // Connecting elements
        for i in 0..<3 {
            let connector = createNeonLine(from: CGPoint(x: -4, y: 10 + CGFloat(i) * 10),
                                          to: CGPoint(x: 4, y: 10 + CGFloat(i) * 10),
                                          color: color.withAlphaComponent(0.5))
            barrel.addChild(connector)
        }
        
        // Muzzle
        let muzzle = createNeonDiamond(size: 10, color: color, lineWidth: 2)
        muzzle.position = CGPoint(x: 0, y: 40)
        barrel.addChild(muzzle)
        
        railgun.addChild(barrel)
        
        // Charging effect
        if tier >= 2 {
            let chargeEffect = createChargingEffect(color: color)
            chargeEffect.position = CGPoint(x: 0, y: 20)
            barrel.addChild(chargeEffect)
        }
        
        return railgun
    }
    
    private func createNeonPlasmaArc(tier: Int) -> SKNode {
        let plasma = SKNode()
        let color = NeonColors.purple
        
        // Triangular base
        let base = createNeonTriangle(size: 20, color: color, lineWidth: 2)
        plasma.addChild(base)
        
        // Tesla coils (3 or more based on tier)
        let coilCount = 3 + tier - 1
        for i in 0..<coilCount {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(coilCount)
            let distance: CGFloat = 15
            
            // Coil rod
            let rod = createNeonLine(from: CGPoint(x: 0, y: 0),
                                    to: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                                    color: color, lineWidth: 1.5)
            plasma.addChild(rod)
            
            // Coil tip
            let tip = createNeonCircle(radius: 3, color: color, lineWidth: 1)
            tip.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            tip.fillColor = color.withAlphaComponent(0.4)
            plasma.addChild(tip)
            
            // Arc between tips
            if i < coilCount - 1 {
                let nextAngle = CGFloat(i + 1) * 2 * .pi / CGFloat(coilCount)
                let arc = createElectricArc(
                    from: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                    to: CGPoint(x: cos(nextAngle) * distance, y: sin(nextAngle) * distance),
                    color: color
                )
                plasma.addChild(arc)
            }
        }
        
        // Central energy core
        let core = createNeonCircle(radius: 5, color: color, lineWidth: 2)
        core.fillColor = color.withAlphaComponent(0.5)
        plasma.addChild(core)
        
        // Pulsing energy
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        core.run(SKAction.repeatForever(pulse))
        
        return plasma
    }
    
    private func createNeonGravityWell(tier: Int) -> SKNode {
        let gravity = SKNode()
        let color = NeonColors.purple
        
        // Multiple rotating rings
        let ringCount = 2 + tier
        for i in 0..<ringCount {
            let radius = CGFloat(12 + i * 5)
            let ring = createNeonCircle(radius: radius, color: color.withAlphaComponent(0.8 - CGFloat(i) * 0.1), lineWidth: 2)
            
            // Add dashed pattern
            if let shape = ring as? SKShapeNode {
                shape.lineCap = .round
                shape.path = createDashedCircle(radius: radius)
                shape.strokeColor = color
                shape.glowWidth = 3
            }
            
            // Rotate at different speeds
            let rotation = SKAction.rotate(byAngle: i % 2 == 0 ? .pi * 2 : -.pi * 2, 
                                          duration: TimeInterval(3 + i))
            ring.run(SKAction.repeatForever(rotation))
            
            gravity.addChild(ring)
        }
        
        // Central black hole
        let core = createNeonCircle(radius: 6, color: NeonColors.white, lineWidth: 1)
        core.fillColor = SKColor.black
        gravity.addChild(core)
        
        // Swirling particles
        for i in 0..<8 {
            let particle = createNeonCircle(radius: 1, color: color, lineWidth: 1)
            let angle = CGFloat(i) * .pi / 4
            let radius: CGFloat = 20
            particle.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            
            // Spiral inward animation
            let spiral = createSpiralAnimation(duration: 2)
            particle.run(SKAction.repeatForever(spiral))
            gravity.addChild(particle)
        }
        
        return gravity
    }
    
    private func createNeonEMP(tier: Int) -> SKNode {
        let emp = SKNode()
        let color = NeonColors.yellow
        
        // Octagonal base
        let base = createNeonOctagon(radius: 16, color: color, lineWidth: 2)
        emp.addChild(base)
        
        // Capacitor banks
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let distance: CGFloat = 12
            
            // Capacitor
            let cap = createNeonRectangle(width: 8, height: 12, color: color, lineWidth: 1.5)
            cap.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            cap.zRotation = angle
            emp.addChild(cap)
            
            // Energy link
            let link = createNeonLine(from: .zero, 
                                     to: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                                     color: color.withAlphaComponent(0.5))
            emp.addChild(link)
        }
        
        // Central discharge node
        let node = createNeonCircle(radius: 6, color: color, lineWidth: 2)
        node.fillColor = color.withAlphaComponent(0.3)
        emp.addChild(node)
        
        // Charging animation
        let charge = SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 1.5),
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeAlpha(to: 0.3, duration: 0.2)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            ])
        ])
        
        // Create pulse ring
        let pulseRing = createNeonCircle(radius: 25, color: color, lineWidth: 3)
        pulseRing.alpha = 0
        emp.addChild(pulseRing)
        
        pulseRing.run(SKAction.repeatForever(charge))
        
        return emp
    }
    
    // MARK: - Enemy Creation (Neon Style)
    
    func createNeonEnemy(type: EnemyType) -> SKNode {
        let container = SKNode()
        
        let enemy = createNeonEnemyBody(type: type)
        container.addChild(enemy)
        
        // Add glow effect
        addNeonPulse(to: enemy, color: getEnemyNeonColor(type))
        
        // Add health bar position
        let healthBarHolder = SKNode()
        healthBarHolder.name = "healthBar"
        healthBarHolder.position = CGPoint(x: 0, y: getEnemySize(type) + 10)
        container.addChild(healthBarHolder)
        
        return container
    }
    
    private func createNeonEnemyBody(type: EnemyType) -> SKNode {
        switch type {
        case .alienSwarmer:
            return createNeonSwarmer()
        case .rogueRobot:
            return createNeonRobot()
        case .aiDrone:
            return createNeonDrone()
        case .bioTitan:
            return createNeonTitan()
        default:
            return createNeonSwarmer()
        }
    }
    
    private func createNeonSwarmer() -> SKNode {
        let swarmer = SKNode()
        let color = NeonColors.green
        
        // Diamond-shaped body
        let body = createNeonDiamond(size: 15, color: color, lineWidth: 2)
        swarmer.addChild(body)
        
        // Animated legs (simple lines)
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2 + .pi / 4
            let leg = createNeonLine(from: .zero,
                                    to: CGPoint(x: cos(angle) * 12, y: sin(angle) * 12),
                                    color: color.withAlphaComponent(0.7), lineWidth: 1)
            
            // Wiggle animation
            let wiggle = SKAction.sequence([
                SKAction.rotate(toAngle: angle - 0.2, duration: 0.2),
                SKAction.rotate(toAngle: angle + 0.2, duration: 0.2)
            ])
            leg.run(SKAction.repeatForever(wiggle))
            swarmer.addChild(leg)
        }
        
        // Eye
        let eye = createNeonCircle(radius: 3, color: NeonColors.red, lineWidth: 1)
        eye.fillColor = NeonColors.red.withAlphaComponent(0.5)
        eye.position = CGPoint(x: 0, y: 2)
        swarmer.addChild(eye)
        
        return swarmer
    }
    
    private func createNeonRobot() -> SKNode {
        let robot = SKNode()
        let color = NeonColors.orange
        
        // Square body
        let body = createNeonSquare(size: 20, color: color, lineWidth: 2)
        robot.addChild(body)
        
        // Tank treads (simplified)
        for side in [-1, 1] {
            let tread = createNeonRectangle(width: 6, height: 25, color: color.withAlphaComponent(0.7), lineWidth: 1)
            tread.position = CGPoint(x: CGFloat(side) * 13, y: 0)
            robot.addChild(tread)
            
            // Tread animation
            for i in 0..<3 {
                let mark = createNeonLine(from: CGPoint(x: CGFloat(side) * 13 - 3, y: -10 + CGFloat(i) * 10),
                                         to: CGPoint(x: CGFloat(side) * 13 + 3, y: -10 + CGFloat(i) * 10),
                                         color: color.withAlphaComponent(0.5))
                robot.addChild(mark)
            }
        }
        
        // Weapon
        let weapon = createNeonCircle(radius: 4, color: NeonColors.red, lineWidth: 1)
        weapon.position = CGPoint(x: 0, y: 12)
        weapon.fillColor = NeonColors.red.withAlphaComponent(0.3)
        robot.addChild(weapon)
        
        // Scanner
        let scanner = createNeonLine(from: CGPoint(x: -8, y: 5), to: CGPoint(x: 8, y: 5), color: NeonColors.red)
        let scan = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -10, duration: 1),
            SKAction.moveBy(x: 0, y: 10, duration: 1)
        ])
        scanner.run(SKAction.repeatForever(scan))
        robot.addChild(scanner)
        
        return robot
    }
    
    private func createNeonDrone() -> SKNode {
        let drone = SKNode()
        let color = NeonColors.cyan
        
        // Triangular body
        let body = createNeonTriangle(size: 18, color: color, lineWidth: 2)
        drone.addChild(body)
        
        // Rotor circles (4 corners)
        for x in [-1, 1] {
            for y in [-1, 1] {
                let rotor = createNeonCircle(radius: 4, color: color.withAlphaComponent(0.7), lineWidth: 1)
                rotor.position = CGPoint(x: CGFloat(x) * 10, y: CGFloat(y) * 8)
                
                // Spinning animation
                let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
                rotor.run(SKAction.repeatForever(spin))
                drone.addChild(rotor)
            }
        }
        
        // Shield indicator
        let shield = createNeonHexagon(radius: 20, color: NeonColors.blue.withAlphaComponent(0.3), lineWidth: 1)
        shield.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 1),
            SKAction.fadeAlpha(to: 0.3, duration: 1)
        ])))
        drone.addChild(shield)
        
        // Core
        let core = createNeonCircle(radius: 3, color: NeonColors.white, lineWidth: 1)
        core.fillColor = color.withAlphaComponent(0.5)
        drone.addChild(core)
        
        return drone
    }
    
    private func createNeonTitan() -> SKNode {
        let titan = SKNode()
        let color = NeonColors.magenta
        
        // Large hexagonal body
        let body = createNeonHexagon(radius: 25, color: color, lineWidth: 3)
        titan.addChild(body)
        
        // Inner hexagon
        let inner = createNeonHexagon(radius: 15, color: color.withAlphaComponent(0.7), lineWidth: 2)
        titan.addChild(inner)
        
        // Spikes
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let spike = createNeonTriangle(size: 10, color: color, lineWidth: 1.5)
            spike.position = CGPoint(x: cos(angle) * 25, y: sin(angle) * 25)
            spike.zRotation = angle
            titan.addChild(spike)
        }
        
        // Multiple eyes
        for i in 0..<3 {
            let eye = createNeonCircle(radius: 3, color: NeonColors.red, lineWidth: 1)
            eye.fillColor = NeonColors.red.withAlphaComponent(0.5)
            eye.position = CGPoint(x: -8 + CGFloat(i) * 8, y: 5)
            titan.addChild(eye)
        }
        
        // Energy field
        let field = createNeonCircle(radius: 30, color: color.withAlphaComponent(0.2), lineWidth: 1)
        field.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1),
            SKAction.scale(to: 0.9, duration: 1)
        ])))
        titan.addChild(field)
        
        return titan
    }
    
    // MARK: - Helper Shape Methods
    
    private func createNeonCircle(radius: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = .clear
        circle.strokeColor = color
        circle.lineWidth = lineWidth
        circle.glowWidth = lineWidth * 2
        return circle
    }
    
    private func createNeonSquare(size: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let square = SKShapeNode(rectOf: CGSize(width: size, height: size))
        square.fillColor = .clear
        square.strokeColor = color
        square.lineWidth = lineWidth
        square.glowWidth = lineWidth * 2
        return square
    }
    
    private func createNeonRectangle(width: CGFloat, height: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: width, height: height))
        rect.fillColor = .clear
        rect.strokeColor = color
        rect.lineWidth = lineWidth
        rect.glowWidth = lineWidth * 2
        return rect
    }
    
    private func createNeonHexagon(radius: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        let hexagon = SKShapeNode(path: path)
        hexagon.fillColor = .clear
        hexagon.strokeColor = color
        hexagon.lineWidth = lineWidth
        hexagon.glowWidth = lineWidth * 2
        return hexagon
    }
    
    private func createNeonOctagon(radius: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        let octagon = SKShapeNode(path: path)
        octagon.fillColor = .clear
        octagon.strokeColor = color
        octagon.lineWidth = lineWidth
        octagon.glowWidth = lineWidth * 2
        return octagon
    }
    
    private func createNeonTriangle(size: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: -size * 0.866, y: -size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.866, y: -size * 0.5))
        path.closeSubpath()
        
        let triangle = SKShapeNode(path: path)
        triangle.fillColor = .clear
        triangle.strokeColor = color
        triangle.lineWidth = lineWidth
        triangle.glowWidth = lineWidth * 2
        return triangle
    }
    
    private func createNeonDiamond(size: CGFloat, color: SKColor, lineWidth: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: size, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size))
        path.addLine(to: CGPoint(x: -size, y: 0))
        path.closeSubpath()
        
        let diamond = SKShapeNode(path: path)
        diamond.fillColor = .clear
        diamond.strokeColor = color
        diamond.lineWidth = lineWidth
        diamond.glowWidth = lineWidth * 2
        return diamond
    }
    
    private func createNeonLine(from: CGPoint, to: CGPoint, color: SKColor, lineWidth: CGFloat = 1) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = color
        line.lineWidth = lineWidth
        line.glowWidth = lineWidth * 2
        line.lineCap = .round
        return line
    }
    
    private func createNeonPlatform(tier: Int) -> SKNode {
        let platform = SKNode()
        let baseColor = NeonColors.cyan.withAlphaComponent(0.5)
        
        // Outer hexagon
        let outer = createNeonHexagon(radius: 30, color: baseColor, lineWidth: 2)
        platform.addChild(outer)
        
        // Inner hexagon
        let inner = createNeonHexagon(radius: 25, color: baseColor.withAlphaComponent(0.7), lineWidth: 1)
        platform.addChild(inner)
        
        // Tech lines
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let line = createNeonLine(
                from: CGPoint(x: cos(angle) * 25, y: sin(angle) * 25),
                to: CGPoint(x: cos(angle) * 30, y: sin(angle) * 30),
                color: baseColor
            )
            platform.addChild(line)
        }
        
        // Tier glow
        if tier > 1 {
            let glow = createNeonHexagon(radius: 32, color: NeonColors.white.withAlphaComponent(0.3), lineWidth: 1)
            platform.addChild(glow)
        }
        
        return platform
    }
    
    // MARK: - Effects
    
    private func addNeonPulse(to node: SKNode, color: SKColor) {
        let pulse = SKShapeNode(circleOfRadius: 30)
        pulse.strokeColor = color
        pulse.lineWidth = 2
        pulse.glowWidth = 4
        pulse.alpha = 0
        
        let pulseAction = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.fadeAlpha(to: 0.8, duration: 0)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 1),
                SKAction.fadeAlpha(to: 0, duration: 1)
            ])
        ])
        
        pulse.run(SKAction.repeatForever(SKAction.sequence([
            pulseAction,
            SKAction.wait(forDuration: 1)
        ])))
        
        node.addChild(pulse)
    }
    
    private func createElectricArc(from: CGPoint, to: CGPoint, color: SKColor) -> SKNode {
        let arc = SKNode()
        
        // Create jagged lightning path
        let path = CGMutablePath()
        path.move(to: from)
        
        let segments = 5
        for i in 1...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let baseX = from.x + (to.x - from.x) * t
            let baseY = from.y + (to.y - from.y) * t
            let offsetX = CGFloat.random(in: -5...5)
            let offsetY = CGFloat.random(in: -5...5)
            
            path.addLine(to: CGPoint(x: baseX + offsetX, y: baseY + offsetY))
        }
        path.addLine(to: to)
        
        let lightning = SKShapeNode(path: path)
        lightning.strokeColor = color
        lightning.lineWidth = 1
        lightning.glowWidth = 3
        
        // Flicker animation
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.05),
            SKAction.fadeAlpha(to: 1, duration: 0.05),
            SKAction.wait(forDuration: Double.random(in: 0.1...0.5))
        ])
        lightning.run(SKAction.repeatForever(flicker))
        
        arc.addChild(lightning)
        return arc
    }
    
    private func createChargingEffect(color: SKColor) -> SKNode {
        let charge = SKNode()
        
        for _ in 0..<3 {
            let particle = createNeonCircle(radius: 2, color: color, lineWidth: 1)
            particle.position = CGPoint(x: CGFloat.random(in: -10...10), y: 0)
            
            let move = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 20, duration: 0.5),
                SKAction.moveBy(x: 0, y: -20, duration: 0)
            ])
            particle.run(SKAction.repeatForever(move))
            charge.addChild(particle)
        }
        
        return charge
    }
    
    private func createSpiralAnimation(duration: TimeInterval) -> SKAction {
        let path = CGMutablePath()
        let center = CGPoint.zero
        var radius: CGFloat = 20
        var angle: CGFloat = 0
        
        path.move(to: CGPoint(x: center.x + radius, y: center.y))
        
        for _ in 0..<50 {
            angle += .pi / 10
            radius -= 0.4
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return SKAction.follow(path, asOffset: false, orientToPath: false, duration: duration)
    }
    
    private func createDashedCircle(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let segments = 12
        let dashLength = (2 * .pi * radius) / CGFloat(segments * 2)
        
        for i in 0..<segments {
            let startAngle = CGFloat(i) * 2 * .pi / CGFloat(segments)
            let endAngle = startAngle + (.pi / CGFloat(segments))
            
            path.move(to: CGPoint(x: cos(startAngle) * radius, y: sin(startAngle) * radius))
            
            for j in stride(from: 0, to: 1, by: 0.1) {
                let angle = startAngle + (endAngle - startAngle) * CGFloat(j)
                path.addLine(to: CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
            }
        }
        
        return path
    }
    
    private func addTierIndicators(to node: SKNode, tier: Int, color: SKColor) {
        for i in 0..<tier {
            let star = createNeonStar(size: 4, color: color)
            star.position = CGPoint(x: -20 + CGFloat(i) * 10, y: -40)
            star.zPosition = 100
            node.addChild(star)
        }
    }
    
    private func createNeonStar(size: CGFloat, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<5 {
            let angle = CGFloat(i) * 2 * .pi / 5 - .pi / 2
            let outerPoint = CGPoint(x: cos(angle) * size, y: sin(angle) * size)
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: cos(innerAngle) * size * 0.5, y: sin(innerAngle) * size * 0.5)
            
            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.addLine(to: outerPoint)
            }
            path.addLine(to: innerPoint)
        }
        path.closeSubpath()
        
        let star = SKShapeNode(path: path)
        star.fillColor = color.withAlphaComponent(0.5)
        star.strokeColor = color
        star.lineWidth = 1
        star.glowWidth = 2
        return star
    }
    
    // MARK: - Color Helpers
    
    private func getTowerNeonColor(_ type: TowerType) -> SKColor {
        switch type {
        case .laserTurret, .solarLanceArray:
            return NeonColors.red
        case .railgunEmplacement:
            return NeonColors.blue
        case .plasmaArcNode, .plasmaMortar:
            return NeonColors.purple
        case .missilePDBattery:
            return NeonColors.orange
        case .nanobotSwarmDispenser:
            return NeonColors.green
        case .cryoFoamProjector:
            return NeonColors.cyan
        case .gravityWellProjector, .singularityCannon:
            return NeonColors.purple
        case .empShockTower:
            return NeonColors.yellow
        case .droneBay:
            return NeonColors.blue
        case .shieldProjector:
            return NeonColors.cyan
        case .hackingUplink:
            return NeonColors.green
        case .resourceHarvester:
            return NeonColors.yellow
        case .repairDroneSpire:
            return NeonColors.orange
        }
    }
    
    private func getEnemyNeonColor(_ type: EnemyType) -> SKColor {
        switch type {
        case .alienSwarmer:
            return NeonColors.green
        case .rogueRobot:
            return NeonColors.orange
        case .aiDrone:
            return NeonColors.cyan
        case .bioTitan:
            return NeonColors.magenta
        default:
            return NeonColors.pink
        }
    }
    
    private func getEnemySize(_ type: EnemyType) -> CGFloat {
        switch type {
        case .alienSwarmer: return 15
        case .rogueRobot: return 20
        case .aiDrone: return 18
        case .bioTitan: return 25
        default: return 15
        }
    }
    
    // Additional tower types (simplified for space)
    private func createNeonMissilePD(tier: Int) -> SKNode { return createNeonSquare(size: 20, color: NeonColors.orange, lineWidth: 2) }
    private func createNeonNanobot(tier: Int) -> SKNode { return createNeonHexagon(radius: 15, color: NeonColors.green, lineWidth: 2) }
    private func createNeonCryo(tier: Int) -> SKNode { return createNeonOctagon(radius: 15, color: NeonColors.cyan, lineWidth: 2) }
    private func createNeonMortar(tier: Int) -> SKNode { return createNeonSquare(size: 22, color: NeonColors.purple, lineWidth: 2) }
    private func createNeonDroneBay(tier: Int) -> SKNode { return createNeonRectangle(width: 25, height: 20, color: NeonColors.blue, lineWidth: 2) }
    private func createNeonShield(tier: Int) -> SKNode { return createNeonCircle(radius: 18, color: NeonColors.cyan, lineWidth: 2) }
    private func createNeonHacking(tier: Int) -> SKNode { return createNeonTriangle(size: 18, color: NeonColors.green, lineWidth: 2) }
    private func createNeonHarvester(tier: Int) -> SKNode { return createNeonDiamond(size: 16, color: NeonColors.yellow, lineWidth: 2) }
    private func createNeonRepairSpire(tier: Int) -> SKNode { return createNeonTriangle(size: 20, color: NeonColors.orange, lineWidth: 2) }
    private func createNeonSolarLance(tier: Int) -> SKNode { return createNeonOctagon(radius: 25, color: NeonColors.yellow, lineWidth: 3) }
    private func createNeonSingularity(tier: Int) -> SKNode { return createNeonCircle(radius: 25, color: NeonColors.purple, lineWidth: 3) }
}