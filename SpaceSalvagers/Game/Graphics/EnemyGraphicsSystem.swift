import Foundation
import SpriteKit
import CoreGraphics

// MARK: - Enemy Graphics System
class EnemyGraphicsSystem {
    
    static let shared = EnemyGraphicsSystem()
    
    private init() {}
    
    // MARK: - Enemy Visual Creation
    func createEnemyVisuals(for enemyType: EnemyType) -> SKNode {
        let container = SKNode()
        
        // Create main body
        let body = createEnemyBody(for: enemyType)
        container.addChild(body)
        
        // Add movement animations
        addMovementAnimation(to: body, enemyType: enemyType)
        
        // Add special effects
        addSpecialEffects(to: container, enemyType: enemyType)
        
        // Add health bar holder
        let healthBarHolder = SKNode()
        healthBarHolder.name = "healthBar"
        healthBarHolder.position = CGPoint(x: 0, y: getEnemySize(enemyType).height / 2 + 10)
        container.addChild(healthBarHolder)
        
        return container
    }
    
    // MARK: - Enemy Body Creation
    private func createEnemyBody(for type: EnemyType) -> SKNode {
        switch type {
        case .alienSwarmer:
            return createAlienSwarmerBody()
        case .rogueRobot:
            return createRogueRobotBody()
        case .aiDrone:
            return createAIDroneBody()
        case .bioTitan:
            return createBioTitanBody()
        case .corruptedMech:
            return createCorruptedMechBody()
        case .plasmaWraith:
            return createPlasmaWraithBody()
        case .nanoSwarm:
            return createNanoSwarmBody()
        case .voidReaper:
            return createVoidReaperBody()
        }
    }
    
    // MARK: - Individual Enemy Bodies
    
    private func createAlienSwarmerBody() -> SKNode {
        let body = SKNode()
        
        // Organic blob-like main body
        let mainBody = createOrganicShape(size: CGSize(width: 20, height: 15))
        mainBody.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1)
        mainBody.strokeColor = SKColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
        mainBody.lineWidth = 2
        mainBody.glowWidth = 2
        body.addChild(mainBody)
        
        // Multiple legs (6 spider-like legs)
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let leg = createInsectLeg()
            leg.position = CGPoint(x: cos(angle) * 8, y: sin(angle) * 6)
            leg.zRotation = angle
            
            // Animate leg movement
            let moveUp = SKAction.moveBy(x: 0, y: 2, duration: 0.2)
            let moveDown = SKAction.moveBy(x: 0, y: -2, duration: 0.2)
            let delay = SKAction.wait(forDuration: Double(i) * 0.05)
            let sequence = SKAction.sequence([delay, moveUp, moveDown])
            leg.run(SKAction.repeatForever(sequence))
            
            body.addChild(leg)
        }
        
        // Glowing eyes (multiple)
        for i in 0..<3 {
            let eye = createGlowingEye(color: .green, size: 3)
            eye.position = CGPoint(x: -4 + CGFloat(i) * 4, y: 3)
            body.addChild(eye)
        }
        
        // Bio-luminescent spots
        for _ in 0..<5 {
            let spot = SKShapeNode(circleOfRadius: 2)
            spot.fillColor = SKColor.green.withAlphaComponent(0.6)
            spot.glowWidth = 3
            spot.position = CGPoint(
                x: CGFloat.random(in: -8...8),
                y: CGFloat.random(in: -5...5)
            )
            
            // Pulsing glow
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 0.5...1.5))
            ])
            spot.run(SKAction.repeatForever(pulse))
            body.addChild(spot)
        }
        
        // Organic texture overlay
        addOrganicTexture(to: mainBody)
        
        return body
    }
    
    private func createRogueRobotBody() -> SKNode {
        let body = SKNode()
        
        // Heavy mechanical chassis
        let chassis = SKShapeNode(rectOf: CGSize(width: 25, height: 30))
        chassis.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1)
        chassis.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
        chassis.lineWidth = 2
        body.addChild(chassis)
        
        // Tank treads
        for side in [-1, 1] {
            let tread = createTankTread()
            tread.position = CGPoint(x: CGFloat(side) * 14, y: -10)
            body.addChild(tread)
        }
        
        // Armor plating
        let frontPlate = SKShapeNode(rectOf: CGSize(width: 20, height: 10))
        frontPlate.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1)
        frontPlate.strokeColor = SKColor.gray
        frontPlate.lineWidth = 1
        frontPlate.position = CGPoint(x: 0, y: 10)
        body.addChild(frontPlate)
        
        // Weapon systems
        for side in [-1, 1] {
            let weapon = createMiniGun()
            weapon.position = CGPoint(x: CGFloat(side) * 10, y: 5)
            weapon.zRotation = CGFloat(side) * .pi / 8
            
            // Rotate barrels
            weapon.run(SKAction.repeatForever(
                SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
            ))
            body.addChild(weapon)
        }
        
        // Sensor array (red scanning eye)
        let sensor = createScannerEye(color: .red)
        sensor.position = CGPoint(x: 0, y: 8)
        body.addChild(sensor)
        
        // Battle damage and rust
        addBattleDamage(to: chassis)
        
        // Exhaust vents with smoke
        for side in [-1, 1] {
            let vent = createExhaustVent()
            vent.position = CGPoint(x: CGFloat(side) * 8, y: -15)
            body.addChild(vent)
        }
        
        return body
    }
    
    private func createAIDroneBody() -> SKNode {
        let body = SKNode()
        
        // Sleek triangular body
        let hull = createTriangularHull(size: CGSize(width: 20, height: 25))
        hull.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 1)
        hull.strokeColor = SKColor.cyan
        hull.lineWidth = 2
        hull.glowWidth = 3
        body.addChild(hull)
        
        // Energy shield bubble
        let shield = createShieldBubble(radius: 18)
        shield.alpha = 0.3
        body.addChild(shield)
        
        // Hover engines (4 corners)
        for x in [-1, 1] {
            for y in [-1, 1] {
                let engine = createHoverEngine()
                engine.position = CGPoint(x: CGFloat(x) * 8, y: CGFloat(y) * 10)
                
                // Add thrust effect
                let thrust = createThrustEffect()
                thrust.position = CGPoint(x: 0, y: -5)
                engine.addChild(thrust)
                
                body.addChild(engine)
            }
        }
        
        // Central AI core (glowing)
        let core = createAICore()
        core.position = CGPoint(x: 0, y: 0)
        body.addChild(core)
        
        // Scanning lasers
        for i in 0..<3 {
            let laser = createScanningLaser()
            laser.position = CGPoint(x: -5 + CGFloat(i) * 5, y: -8)
            laser.alpha = 0
            
            // Scanning animation
            let scan = SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.3),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.rotate(byAngle: .pi / 4, duration: 0.5),
                SKAction.fadeAlpha(to: 0, duration: 0.1),
                SKAction.rotate(byAngle: -.pi / 4, duration: 0)
            ])
            laser.run(SKAction.repeatForever(scan))
            body.addChild(laser)
        }
        
        // Holographic projections
        addHolographicEffect(to: hull)
        
        return body
    }
    
    private func createBioTitanBody() -> SKNode {
        let body = SKNode()
        
        // Massive organic body
        let mainMass = createOrganicShape(size: CGSize(width: 40, height: 45))
        mainMass.fillColor = SKColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1)
        mainMass.strokeColor = SKColor.purple
        mainMass.lineWidth = 3
        mainMass.glowWidth = 4
        body.addChild(mainMass)
        
        // Multiple bio-sacs (will split on death)
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let sac = createBioSac()
            sac.position = CGPoint(x: cos(angle) * 15, y: sin(angle) * 15)
            
            // Pulsing animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.5 + Double(i) * 0.1),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            sac.run(SKAction.repeatForever(pulse))
            body.addChild(sac)
        }
        
        // Massive claws/tentacles
        for side in [-1, 1] {
            let tentacle = createTentacle()
            tentacle.position = CGPoint(x: CGFloat(side) * 20, y: -5)
            tentacle.xScale = CGFloat(side)
            
            // Swaying animation
            let sway = SKAction.sequence([
                SKAction.rotate(toAngle: CGFloat(side) * .pi / 8, duration: 1.5),
                SKAction.rotate(toAngle: CGFloat(side) * -.pi / 8, duration: 1.5)
            ])
            tentacle.run(SKAction.repeatForever(sway))
            body.addChild(tentacle)
        }
        
        // Multiple glowing eyes
        for i in 0..<5 {
            let eye = createGlowingEye(color: .purple, size: 4)
            eye.position = CGPoint(
                x: -10 + CGFloat(i) * 5,
                y: 10 + CGFloat.random(in: -5...5)
            )
            body.addChild(eye)
        }
        
        // Toxic vapor effect
        let vapor = createToxicVapor()
        vapor.position = CGPoint(x: 0, y: -10)
        body.addChild(vapor)
        
        // Bone spikes
        for i in 0..<8 {
            let spike = createBoneSpike()
            let angle = CGFloat(i) * .pi / 4
            spike.position = CGPoint(x: cos(angle) * 22, y: sin(angle) * 22)
            spike.zRotation = angle
            body.addChild(spike)
        }
        
        return body
    }
    
    private func createCorruptedMechBody() -> SKNode {
        let body = SKNode()
        
        // Corrupted mechanical frame
        let frame = SKShapeNode(rectOf: CGSize(width: 30, height: 35))
        frame.fillColor = SKColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1)
        frame.strokeColor = SKColor(red: 0.5, green: 0.1, blue: 0.6, alpha: 1)
        frame.lineWidth = 2
        
        // Add corruption effect
        addCorruptionEffect(to: frame)
        body.addChild(frame)
        
        // Corrupted weapons
        for side in [-1, 1] {
            let arm = createCorruptedArm()
            arm.position = CGPoint(x: CGFloat(side) * 18, y: 0)
            arm.xScale = CGFloat(side)
            body.addChild(arm)
        }
        
        // Virus core
        let core = createVirusCore()
        core.position = CGPoint(x: 0, y: 0)
        body.addChild(core)
        
        // Glitch effects
        addGlitchEffect(to: body)
        
        return body
    }
    
    private func createPlasmaWraithBody() -> SKNode {
        let body = SKNode()
        
        // Ethereal plasma form
        let plasma = createPlasmaForm()
        body.addChild(plasma)
        
        // Energy tendrils
        for i in 0..<4 {
            let tendril = createEnergyTendril()
            let angle = CGFloat(i) * .pi / 2
            tendril.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
            tendril.zRotation = angle
            
            // Floating animation
            let float = SKAction.sequence([
                SKAction.moveBy(x: cos(angle) * 5, y: sin(angle) * 5, duration: 1),
                SKAction.moveBy(x: -cos(angle) * 5, y: -sin(angle) * 5, duration: 1)
            ])
            tendril.run(SKAction.repeatForever(float))
            body.addChild(tendril)
        }
        
        // Phase shift effect
        let phaseShift = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 0.9, duration: 0.5)
        ])
        body.run(SKAction.repeatForever(phaseShift))
        
        return body
    }
    
    private func createNanoSwarmBody() -> SKNode {
        let body = SKNode()
        
        // Cloud of nano particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.8)
            particle.glowWidth = 2
            particle.position = CGPoint(
                x: CGFloat.random(in: -15...15),
                y: CGFloat.random(in: -15...15)
            )
            
            // Swarming movement
            let swarm = SKAction.sequence([
                SKAction.moveBy(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -10...10),
                    duration: Double.random(in: 0.5...1.5)
                ),
                SKAction.moveBy(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -10...10),
                    duration: Double.random(in: 0.5...1.5)
                )
            ])
            particle.run(SKAction.repeatForever(swarm))
            body.addChild(particle)
        }
        
        // Central mass
        let center = SKShapeNode(circleOfRadius: 8)
        center.fillColor = SKColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 0.6)
        center.strokeColor = SKColor.green
        center.glowWidth = 5
        body.addChild(center)
        
        return body
    }
    
    private func createVoidReaperBody() -> SKNode {
        let body = SKNode()
        
        // Dark void core
        let voidCore = SKShapeNode(circleOfRadius: 15)
        voidCore.fillColor = SKColor.black
        voidCore.strokeColor = SKColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        voidCore.lineWidth = 3
        voidCore.glowWidth = 8
        body.addChild(voidCore)
        
        // Void tentacles
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let tentacle = createVoidTentacle()
            tentacle.position = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12)
            tentacle.zRotation = angle
            body.addChild(tentacle)
        }
        
        // Reality distortion effect
        let distortion = createRealityDistortion()
        body.addChild(distortion)
        
        return body
    }
    
    // MARK: - Component Creation Methods
    
    private func createOrganicShape(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let points = 8
        var controlPoints: [CGPoint] = []
        
        for i in 0..<points {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(points)
            let radius = CGFloat.random(in: 0.7...1.0) * min(size.width, size.height) / 2
            controlPoints.append(CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
        }
        
        path.move(to: controlPoints[0])
        for i in 1..<points {
            let nextIndex = (i + 1) % points
            let controlPoint = CGPoint(
                x: (controlPoints[i].x + controlPoints[nextIndex].x) / 2,
                y: (controlPoints[i].y + controlPoints[nextIndex].y) / 2
            )
            path.addQuadCurve(to: controlPoints[nextIndex], control: controlPoint)
        }
        path.closeSubpath()
        
        let shape = SKShapeNode(path: path)
        return shape
    }
    
    private func createInsectLeg() -> SKNode {
        let leg = SKNode()
        
        // Upper segment
        let upper = SKShapeNode(rectOf: CGSize(width: 2, height: 8))
        upper.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1)
        upper.position = CGPoint(x: 0, y: 4)
        leg.addChild(upper)
        
        // Lower segment
        let lower = SKShapeNode(rectOf: CGSize(width: 1.5, height: 6))
        lower.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 1)
        lower.position = CGPoint(x: 0, y: -2)
        lower.zRotation = .pi / 6
        leg.addChild(lower)
        
        return leg
    }
    
    private func createGlowingEye(color: SKColor, size: CGFloat) -> SKNode {
        let eye = SKShapeNode(circleOfRadius: size)
        eye.fillColor = color
        eye.strokeColor = color.withAlphaComponent(0.5)
        eye.glowWidth = size * 2
        
        // Blinking animation
        let blink = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2...4)),
            SKAction.scaleY(to: 0.1, duration: 0.1),
            SKAction.scaleY(to: 1.0, duration: 0.1)
        ])
        eye.run(SKAction.repeatForever(blink))
        
        return eye
    }
    
    private func createTankTread() -> SKNode {
        let tread = SKShapeNode(rectOf: CGSize(width: 8, height: 25))
        tread.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        tread.strokeColor = SKColor.darkGray
        
        // Add tread marks
        for i in 0..<5 {
            let mark = SKShapeNode(rectOf: CGSize(width: 6, height: 2))
            mark.fillColor = SKColor.black
            mark.position = CGPoint(x: 0, y: -10 + CGFloat(i) * 5)
            tread.addChild(mark)
        }
        
        return tread
    }
    
    private func createMiniGun() -> SKNode {
        let gun = SKNode()
        
        // Rotating barrels
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let barrel = SKShapeNode(rectOf: CGSize(width: 1, height: 8))
            barrel.fillColor = SKColor.gray
            barrel.position = CGPoint(x: cos(angle) * 3, y: sin(angle) * 3)
            gun.addChild(barrel)
        }
        
        return gun
    }
    
    private func createScannerEye(color: SKColor) -> SKNode {
        let scanner = SKShapeNode(circleOfRadius: 5)
        scanner.fillColor = color.withAlphaComponent(0.3)
        scanner.strokeColor = color
        scanner.glowWidth = 5
        
        // Scanning line
        let line = SKShapeNode(rectOf: CGSize(width: 10, height: 1))
        line.fillColor = color
        line.glowWidth = 3
        
        let scan = SKAction.sequence([
            SKAction.rotate(toAngle: -.pi / 4, duration: 1),
            SKAction.rotate(toAngle: .pi / 4, duration: 1)
        ])
        line.run(SKAction.repeatForever(scan))
        scanner.addChild(line)
        
        return scanner
    }
    
    private func createTriangularHull(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        path.addLine(to: CGPoint(x: -size.width / 2, y: -size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: -size.height / 2))
        path.closeSubpath()
        
        let hull = SKShapeNode(path: path)
        return hull
    }
    
    private func createShieldBubble(radius: CGFloat) -> SKNode {
        let shield = SKShapeNode(circleOfRadius: radius)
        shield.fillColor = SKColor.cyan.withAlphaComponent(0.1)
        shield.strokeColor = SKColor.cyan.withAlphaComponent(0.5)
        shield.lineWidth = 1
        shield.glowWidth = 3
        
        // Hexagonal pattern
        let hex = createHexagonalPattern(radius: radius)
        shield.addChild(hex)
        
        return shield
    }
    
    private func createHexagonalPattern(radius: CGFloat) -> SKNode {
        let pattern = SKNode()
        // Add hexagonal grid pattern
        return pattern
    }
    
    private func createBioSac() -> SKNode {
        let sac = SKShapeNode(circleOfRadius: 8)
        sac.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.6, alpha: 0.8)
        sac.strokeColor = SKColor.purple
        sac.glowWidth = 2
        return sac
    }
    
    private func createTentacle() -> SKNode {
        let tentacle = SKNode()
        
        for i in 0..<5 {
            let segment = SKShapeNode(circleOfRadius: CGFloat(5 - i))
            segment.fillColor = SKColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1)
            segment.position = CGPoint(x: CGFloat(i) * 4, y: 0)
            tentacle.addChild(segment)
        }
        
        return tentacle
    }
    
    // MARK: - Animation Methods
    
    private func addMovementAnimation(to body: SKNode, enemyType: EnemyType) {
        switch enemyType {
        case .alienSwarmer:
            // Scuttling movement
            let wobble = SKAction.sequence([
                SKAction.rotate(toAngle: .pi / 32, duration: 0.2),
                SKAction.rotate(toAngle: -.pi / 32, duration: 0.2)
            ])
            body.run(SKAction.repeatForever(wobble))
            
        case .rogueRobot:
            // Heavy stomping
            let stomp = SKAction.sequence([
                SKAction.moveBy(x: 0, y: -2, duration: 0.3),
                SKAction.moveBy(x: 0, y: 2, duration: 0.1)
            ])
            body.run(SKAction.repeatForever(stomp))
            
        case .aiDrone:
            // Hovering
            let hover = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 3, duration: 1),
                SKAction.moveBy(x: 0, y: -3, duration: 1)
            ])
            body.run(SKAction.repeatForever(hover))
            
        case .bioTitan:
            // Lumbering movement
            let lumber = SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(toAngle: .pi / 64, duration: 0.5),
                    SKAction.moveBy(x: 0, y: -3, duration: 0.5)
                ]),
                SKAction.group([
                    SKAction.rotate(toAngle: -.pi / 64, duration: 0.5),
                    SKAction.moveBy(x: 0, y: 3, duration: 0.5)
                ])
            ])
            body.run(SKAction.repeatForever(lumber))
            
        default:
            break
        }
    }
    
    private func addSpecialEffects(to container: SKNode, enemyType: EnemyType) {
        switch enemyType {
        case .alienSwarmer:
            // Acid drip effect
            if let emitter = createAcidDripEffect() {
                emitter.position = CGPoint(x: 0, y: -10)
                container.addChild(emitter)
            }
            
        case .aiDrone:
            // Shield shimmer
            let shimmer = createShieldShimmer()
            container.addChild(shimmer)
            
        case .bioTitan:
            // Toxic cloud
            let toxic = createToxicCloud()
            toxic.position = CGPoint(x: 0, y: -20)
            container.addChild(toxic)
            
        default:
            break
        }
    }
    
    // MARK: - Effect Creation Methods
    
    private func addOrganicTexture(to shape: SKShapeNode) {
        // Add veins or organic texture
    }
    
    private func addBattleDamage(to shape: SKShapeNode) {
        // Add scratches and dents
    }
    
    private func addHolographicEffect(to shape: SKShapeNode) {
        // Add holographic shimmer
    }
    
    private func addCorruptionEffect(to shape: SKShapeNode) {
        // Add digital corruption effect
    }
    
    private func addGlitchEffect(to node: SKNode) {
        // Add glitch animation
    }
    
    private func createHoverEngine() -> SKNode { return SKNode() }
    private func createThrustEffect() -> SKNode { return SKNode() }
    private func createAICore() -> SKNode { return SKNode() }
    private func createScanningLaser() -> SKNode { return SKNode() }
    private func createExhaustVent() -> SKNode { return SKNode() }
    private func createToxicVapor() -> SKNode { return SKNode() }
    private func createBoneSpike() -> SKNode { return SKNode() }
    private func createCorruptedArm() -> SKNode { return SKNode() }
    private func createVirusCore() -> SKNode { return SKNode() }
    private func createPlasmaForm() -> SKNode { return SKNode() }
    private func createEnergyTendril() -> SKNode { return SKNode() }
    private func createVoidTentacle() -> SKNode { return SKNode() }
    private func createRealityDistortion() -> SKNode { return SKNode() }
    
    private func createAcidDripEffect() -> SKEmitterNode? { return nil }
    private func createShieldShimmer() -> SKNode { return SKNode() }
    private func createToxicCloud() -> SKNode { return SKNode() }
    
    // MARK: - Helper Methods
    
    private func getEnemySize(_ type: EnemyType) -> CGSize {
        switch type {
        case .alienSwarmer:
            return CGSize(width: 20, height: 15)
        case .rogueRobot:
            return CGSize(width: 25, height: 30)
        case .aiDrone:
            return CGSize(width: 20, height: 25)
        case .bioTitan:
            return CGSize(width: 40, height: 45)
        case .corruptedMech:
            return CGSize(width: 30, height: 35)
        case .plasmaWraith:
            return CGSize(width: 25, height: 25)
        case .nanoSwarm:
            return CGSize(width: 30, height: 30)
        case .voidReaper:
            return CGSize(width: 35, height: 35)
        }
    }
}

// MARK: - Enemy Type Definition
enum EnemyType: String, CaseIterable {
    case alienSwarmer = "alien_swarmer"
    case rogueRobot = "rogue_robot"
    case aiDrone = "ai_drone"
    case bioTitan = "bio_titan"
    case corruptedMech = "corrupted_mech"
    case plasmaWraith = "plasma_wraith"
    case nanoSwarm = "nano_swarm"
    case voidReaper = "void_reaper"
    
    var health: Float {
        switch self {
        case .alienSwarmer: return 40
        case .rogueRobot: return 120
        case .aiDrone: return 80
        case .bioTitan: return 500
        case .corruptedMech: return 200
        case .plasmaWraith: return 150
        case .nanoSwarm: return 100
        case .voidReaper: return 300
        }
    }
    
    var speed: Float {
        switch self {
        case .alienSwarmer: return 80
        case .rogueRobot: return 40
        case .aiDrone: return 100
        case .bioTitan: return 30
        case .corruptedMech: return 50
        case .plasmaWraith: return 90
        case .nanoSwarm: return 70
        case .voidReaper: return 60
        }
    }
    
    var reward: Int {
        switch self {
        case .alienSwarmer: return 10
        case .rogueRobot: return 25
        case .aiDrone: return 20
        case .bioTitan: return 100
        case .corruptedMech: return 40
        case .plasmaWraith: return 35
        case .nanoSwarm: return 30
        case .voidReaper: return 75
        }
    }
}