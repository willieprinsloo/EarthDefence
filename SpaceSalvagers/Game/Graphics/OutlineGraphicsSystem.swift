import Foundation
import SpriteKit
import CoreGraphics

// MARK: - Outline Graphics System
class OutlineGraphicsSystem {
    
    static let shared = OutlineGraphicsSystem()
    
    // Clean outline color palette
    struct OutlineColors {
        static let cyan = SKColor(red: 0, green: 1, blue: 1, alpha: 1)
        static let magenta = SKColor(red: 1, green: 0, blue: 1, alpha: 1)
        static let yellow = SKColor(red: 1, green: 1, blue: 0, alpha: 1)
        static let green = SKColor(red: 0.2, green: 1, blue: 0.4, alpha: 1)
        static let orange = SKColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        static let pink = SKColor(red: 1, green: 0.4, blue: 0.8, alpha: 1)
        static let purple = SKColor(red: 0.7, green: 0.3, blue: 1, alpha: 1)
        static let blue = SKColor(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        static let red = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        static let white = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private init() {}
    
    // MARK: - Enhanced Laser Turret
    func createOutlineLaserTurret(tier: Int = 1) -> SKNode {
        let turret = SKNode()
        let color = OutlineColors.red
        let lineWidth: CGFloat = 2
        
        // Base platform - octagonal outline
        let basePath = createOctagonPath(radius: 20)
        let base = SKShapeNode(path: basePath)
        base.strokeColor = color.withAlphaComponent(0.6)
        base.lineWidth = lineWidth
        base.fillColor = .clear
        turret.addChild(base)
        
        // Inner octagon
        let innerBasePath = createOctagonPath(radius: 15)
        let innerBase = SKShapeNode(path: innerBasePath)
        innerBase.strokeColor = color.withAlphaComponent(0.4)
        innerBase.lineWidth = 1
        innerBase.fillColor = .clear
        turret.addChild(innerBase)
        
        // Rotating turret head
        let turretHead = SKNode()
        turretHead.name = "turretHead"
        
        // Main barrel body - rectangular outline
        let barrelBody = SKShapeNode(rectOf: CGSize(width: 12, height: 30))
        barrelBody.strokeColor = color
        barrelBody.lineWidth = lineWidth
        barrelBody.fillColor = .clear
        barrelBody.position = CGPoint(x: 0, y: 15)
        turretHead.addChild(barrelBody)
        
        // Barrel details - cooling vents
        for i in 0..<3 {
            let vent = SKShapeNode(rectOf: CGSize(width: 8, height: 2))
            vent.strokeColor = color.withAlphaComponent(0.7)
            vent.lineWidth = 1
            vent.fillColor = .clear
            vent.position = CGPoint(x: 0, y: 8 + CGFloat(i) * 6)
            turretHead.addChild(vent)
        }
        
        // Focusing chamber at tip
        let chamber = createHexagonPath(radius: 6)
        let focusChamber = SKShapeNode(path: chamber)
        focusChamber.strokeColor = color
        focusChamber.lineWidth = lineWidth
        focusChamber.fillColor = .clear
        focusChamber.position = CGPoint(x: 0, y: 30)
        turretHead.addChild(focusChamber)
        
        // Laser emitter core (center dot)
        let emitter = SKShapeNode(circleOfRadius: 3)
        emitter.strokeColor = color
        emitter.lineWidth = 1
        emitter.fillColor = .clear
        emitter.position = CGPoint(x: 0, y: 30)
        
        // Pulsing animation for emitter
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        emitter.run(SKAction.repeatForever(pulse))
        turretHead.addChild(emitter)
        
        // Support struts connecting base to turret
        for angle in [45, 135, 225, 315] {
            let rad = CGFloat(angle) * .pi / 180
            let strut = createLine(
                from: CGPoint(x: cos(rad) * 15, y: sin(rad) * 15),
                to: CGPoint(x: cos(rad) * 8, y: sin(rad) * 8 + 5),
                color: color.withAlphaComponent(0.5),
                width: 1
            )
            turretHead.addChild(strut)
        }
        
        turret.addChild(turretHead)
        
        // Tier upgrades
        if tier >= 2 {
            // Add heat sinks
            for side in [-1, 1] {
                let heatSink = createHeatSink()
                heatSink.position = CGPoint(x: CGFloat(side) * 12, y: 10)
                turretHead.addChild(heatSink)
            }
        }
        
        if tier >= 3 {
            // Add power coils
            for i in 0..<2 {
                let coil = createPowerCoil(color: color)
                coil.position = CGPoint(x: 0, y: 5 + CGFloat(i) * 8)
                turretHead.addChild(coil)
            }
        }
        
        // Scanning animation
        let scan = SKAction.sequence([
            SKAction.rotate(toAngle: .pi/6, duration: 2),
            SKAction.rotate(toAngle: -.pi/6, duration: 2)
        ])
        turretHead.run(SKAction.repeatForever(scan))
        
        return turret
    }
    
    // MARK: - Enhanced Cannon/Railgun
    func createOutlineRailgun(tier: Int = 1) -> SKNode {
        let railgun = SKNode()
        let color = OutlineColors.blue
        let lineWidth: CGFloat = 2
        
        // Base - heavy rectangular platform
        let basePath = CGMutablePath()
        basePath.move(to: CGPoint(x: -20, y: -15))
        basePath.addLine(to: CGPoint(x: 20, y: -15))
        basePath.addLine(to: CGPoint(x: 15, y: 15))
        basePath.addLine(to: CGPoint(x: -15, y: 15))
        basePath.closeSubpath()
        
        let base = SKShapeNode(path: basePath)
        base.strokeColor = color.withAlphaComponent(0.7)
        base.lineWidth = lineWidth
        base.fillColor = .clear
        railgun.addChild(base)
        
        // Support frame
        let frame = SKShapeNode(rectOf: CGSize(width: 25, height: 20))
        frame.strokeColor = color.withAlphaComponent(0.5)
        frame.lineWidth = 1
        frame.fillColor = .clear
        frame.position = CGPoint(x: 0, y: 0)
        railgun.addChild(frame)
        
        // Main cannon assembly
        let cannonAssembly = SKNode()
        cannonAssembly.name = "cannonAssembly"
        
        // Twin rail system
        for side in [-1, 1] {
            // Main rail
            let rail = SKShapeNode(rectOf: CGSize(width: 3, height: 45))
            rail.strokeColor = color
            rail.lineWidth = lineWidth
            rail.fillColor = .clear
            rail.position = CGPoint(x: CGFloat(side) * 5, y: 22)
            cannonAssembly.addChild(rail)
            
            // Electromagnetic accelerator rings
            for i in 0..<4 {
                let ring = createHexagonPath(radius: 5)
                let accelerator = SKShapeNode(path: ring)
                accelerator.strokeColor = color.withAlphaComponent(0.8)
                accelerator.lineWidth = 1
                accelerator.fillColor = .clear
                accelerator.position = CGPoint(x: CGFloat(side) * 5, y: 5 + CGFloat(i) * 10)
                cannonAssembly.addChild(accelerator)
            }
        }
        
        // Connecting bridge between rails
        for i in 0..<3 {
            let bridge = createLine(
                from: CGPoint(x: -5, y: 10 + CGFloat(i) * 12),
                to: CGPoint(x: 5, y: 10 + CGFloat(i) * 12),
                color: color.withAlphaComponent(0.6),
                width: 1
            )
            cannonAssembly.addChild(bridge)
        }
        
        // Muzzle brake
        let muzzlePath = CGMutablePath()
        muzzlePath.move(to: CGPoint(x: -8, y: 42))
        muzzlePath.addLine(to: CGPoint(x: -10, y: 48))
        muzzlePath.addLine(to: CGPoint(x: 10, y: 48))
        muzzlePath.addLine(to: CGPoint(x: 8, y: 42))
        muzzlePath.closeSubpath()
        
        let muzzle = SKShapeNode(path: muzzlePath)
        muzzle.strokeColor = color
        muzzle.lineWidth = lineWidth
        muzzle.fillColor = .clear
        cannonAssembly.addChild(muzzle)
        
        // Breach/loading mechanism
        let breach = SKShapeNode(rectOf: CGSize(width: 15, height: 10))
        breach.strokeColor = color.withAlphaComponent(0.7)
        breach.lineWidth = 1
        breach.fillColor = .clear
        breach.position = CGPoint(x: 0, y: -5)
        cannonAssembly.addChild(breach)
        
        // Power capacitors
        for side in [-1, 1] {
            let capacitor = createCapacitor(color: color)
            capacitor.position = CGPoint(x: CGFloat(side) * 15, y: 0)
            cannonAssembly.addChild(capacitor)
        }
        
        railgun.addChild(cannonAssembly)
        
        // Tier upgrades
        if tier >= 2 {
            // Add stabilizers
            for side in [-1, 1] {
                let stabilizer = createStabilizer(color: color)
                stabilizer.position = CGPoint(x: CGFloat(side) * 18, y: 20)
                cannonAssembly.addChild(stabilizer)
            }
        }
        
        if tier >= 3 {
            // Add targeting laser
            let targeting = createTargetingLaser(color: OutlineColors.red)
            targeting.position = CGPoint(x: 0, y: 35)
            cannonAssembly.addChild(targeting)
        }
        
        // Recoil animation
        let recoil = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -3, duration: 0.05),
            SKAction.moveBy(x: 0, y: 3, duration: 0.15),
            SKAction.wait(forDuration: 2)
        ])
        cannonAssembly.run(SKAction.repeatForever(recoil))
        
        return railgun
    }
    
    // MARK: - Missile Battery
    func createOutlineMissileBattery(tier: Int = 1) -> SKNode {
        let battery = SKNode()
        let color = OutlineColors.orange
        let lineWidth: CGFloat = 2
        
        // Base platform
        let base = SKShapeNode(rectOf: CGSize(width: 35, height: 25))
        base.strokeColor = color.withAlphaComponent(0.6)
        base.lineWidth = lineWidth
        base.fillColor = .clear
        battery.addChild(base)
        
        // Missile pod array (3x2 grid)
        let podArray = SKNode()
        podArray.name = "podArray"
        
        for row in 0..<2 {
            for col in 0..<3 {
                let pod = createMissilePod(color: color)
                pod.position = CGPoint(
                    x: -12 + CGFloat(col) * 12,
                    y: -5 + CGFloat(row) * 12
                )
                podArray.addChild(pod)
            }
        }
        
        battery.addChild(podArray)
        
        // Radar dish
        let radar = createRadarDish(color: color)
        radar.position = CGPoint(x: 0, y: 20)
        radar.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3)))
        battery.addChild(radar)
        
        return battery
    }
    
    // MARK: - Plasma Arc Tower
    func createOutlinePlasmaArc(tier: Int = 1) -> SKNode {
        let plasma = SKNode()
        let color = OutlineColors.purple
        let lineWidth: CGFloat = 2
        
        // Central pylon
        let pylon = createTrianglePath(size: 25)
        let pylonShape = SKShapeNode(path: pylon)
        pylonShape.strokeColor = color
        pylonShape.lineWidth = lineWidth
        pylonShape.fillColor = .clear
        plasma.addChild(pylonShape)
        
        // Tesla coils
        let coilCount = 3 + (tier - 1)
        for i in 0..<coilCount {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(coilCount)
            let distance: CGFloat = 18
            
            // Coil rod
            let rod = createLine(
                from: .zero,
                to: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                color: color,
                width: 1.5
            )
            plasma.addChild(rod)
            
            // Coil tip with rings
            let tip = createCoilTip(color: color)
            tip.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            plasma.addChild(tip)
            
            // Electric arc between coils
            if i < coilCount - 1 {
                let nextAngle = CGFloat(i + 1) * 2 * .pi / CGFloat(coilCount)
                let arc = createAnimatedArc(
                    from: CGPoint(x: cos(angle) * distance, y: sin(angle) * distance),
                    to: CGPoint(x: cos(nextAngle) * distance, y: sin(nextAngle) * distance),
                    color: color
                )
                plasma.addChild(arc)
            }
        }
        
        // Central energy core
        let core = createEnergyCore(color: color)
        plasma.addChild(core)
        
        return plasma
    }
    
    // MARK: - Gravity Well
    func createOutlineGravityWell(tier: Int = 1) -> SKNode {
        let gravity = SKNode()
        let color = OutlineColors.purple
        
        // Multiple concentric rings
        for i in 0..<(3 + tier) {
            let radius = CGFloat(10 + i * 6)
            let ring = createDashedCircle(radius: radius, dashes: 12, color: color.withAlphaComponent(0.9 - CGFloat(i) * 0.15))
            
            // Rotate at different speeds and directions
            let rotation = SKAction.rotate(byAngle: i % 2 == 0 ? .pi * 2 : -.pi * 2,
                                          duration: TimeInterval(3 + i))
            ring.run(SKAction.repeatForever(rotation))
            gravity.addChild(ring)
        }
        
        // Central singularity
        let core = SKShapeNode(circleOfRadius: 5)
        core.strokeColor = OutlineColors.white
        core.lineWidth = 2
        core.fillColor = .clear
        
        // Inner void
        let void = SKShapeNode(circleOfRadius: 3)
        void.strokeColor = color
        void.lineWidth = 1
        void.fillColor = .clear
        core.addChild(void)
        
        gravity.addChild(core)
        
        // Orbiting particles
        for i in 0..<6 {
            let particle = createOrbitingParticle(color: color)
            let angle = CGFloat(i) * .pi / 3
            particle.position = CGPoint(x: cos(angle) * 25, y: sin(angle) * 25)
            
            // Spiral orbit animation
            let orbit = createSpiralOrbit(startRadius: 25, endRadius: 8, duration: 2 + Double(i) * 0.2)
            particle.run(SKAction.repeatForever(orbit))
            gravity.addChild(particle)
        }
        
        return gravity
    }
    
    // MARK: - Enemy Outlines
    func createOutlineEnemy(type: EnemyType) -> SKNode {
        switch type {
        case .alienSwarmer:
            return createOutlineSwarmer()
        case .rogueRobot:
            return createOutlineRobot()
        case .aiDrone:
            return createOutlineDrone()
        case .bioTitan:
            return createOutlineTitan()
        default:
            return createOutlineSwarmer()
        }
    }
    
    private func createOutlineSwarmer() -> SKNode {
        let swarmer = SKNode()
        let color = OutlineColors.green
        
        // Main body - diamond outline
        let bodyPath = createDiamondPath(width: 16, height: 20)
        let body = SKShapeNode(path: bodyPath)
        body.strokeColor = color
        body.lineWidth = 2
        body.fillColor = .clear
        swarmer.addChild(body)
        
        // Inner details
        let inner = createDiamondPath(width: 10, height: 14)
        let innerBody = SKShapeNode(path: inner)
        innerBody.strokeColor = color.withAlphaComponent(0.5)
        innerBody.lineWidth = 1
        innerBody.fillColor = .clear
        swarmer.addChild(innerBody)
        
        // Legs - simple lines
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let leg = createLine(
                from: .zero,
                to: CGPoint(x: cos(angle) * 12, y: sin(angle) * 10),
                color: color.withAlphaComponent(0.7),
                width: 1
            )
            
            // Animate legs
            let wiggle = SKAction.sequence([
                SKAction.rotate(toAngle: angle - 0.1, duration: 0.2),
                SKAction.rotate(toAngle: angle + 0.1, duration: 0.2)
            ])
            leg.run(SKAction.repeatForever(wiggle))
            swarmer.addChild(leg)
        }
        
        // Eye
        let eye = SKShapeNode(circleOfRadius: 2)
        eye.strokeColor = OutlineColors.red
        eye.lineWidth = 1
        eye.fillColor = .clear
        eye.position = CGPoint(x: 0, y: 3)
        swarmer.addChild(eye)
        
        return swarmer
    }
    
    private func createOutlineRobot() -> SKNode {
        let robot = SKNode()
        let color = OutlineColors.orange
        
        // Main chassis
        let chassis = SKShapeNode(rectOf: CGSize(width: 22, height: 26))
        chassis.strokeColor = color
        chassis.lineWidth = 2
        chassis.fillColor = .clear
        robot.addChild(chassis)
        
        // Armor plating details
        let plate = SKShapeNode(rectOf: CGSize(width: 18, height: 10))
        plate.strokeColor = color.withAlphaComponent(0.6)
        plate.lineWidth = 1
        plate.fillColor = .clear
        plate.position = CGPoint(x: 0, y: 5)
        robot.addChild(plate)
        
        // Tank treads
        for side in [-1, 1] {
            let tread = createTankTread(color: color)
            tread.position = CGPoint(x: CGFloat(side) * 14, y: -5)
            robot.addChild(tread)
        }
        
        // Weapon mount
        let weapon = createWeaponMount(color: OutlineColors.red)
        weapon.position = CGPoint(x: 0, y: 10)
        robot.addChild(weapon)
        
        // Sensor
        let sensor = createSensor(color: OutlineColors.red)
        sensor.position = CGPoint(x: 0, y: 0)
        robot.addChild(sensor)
        
        return robot
    }
    
    private func createOutlineDrone() -> SKNode {
        let drone = SKNode()
        let color = OutlineColors.cyan
        
        // Main body - hexagon
        let body = createHexagonPath(radius: 12)
        let bodyShape = SKShapeNode(path: body)
        bodyShape.strokeColor = color
        bodyShape.lineWidth = 2
        bodyShape.fillColor = .clear
        drone.addChild(bodyShape)
        
        // Inner hex
        let inner = createHexagonPath(radius: 8)
        let innerShape = SKShapeNode(path: inner)
        innerShape.strokeColor = color.withAlphaComponent(0.5)
        innerShape.lineWidth = 1
        innerShape.fillColor = .clear
        drone.addChild(innerShape)
        
        // Rotors
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2 + .pi / 4
            let rotor = createRotor(color: color)
            rotor.position = CGPoint(x: cos(angle) * 15, y: sin(angle) * 15)
            
            // Spin animation
            rotor.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 0.3)))
            drone.addChild(rotor)
        }
        
        // Shield indicator
        let shield = createHexagonPath(radius: 18)
        let shieldShape = SKShapeNode(path: shield)
        shieldShape.strokeColor = OutlineColors.blue.withAlphaComponent(0.3)
        shieldShape.lineWidth = 1
        shieldShape.fillColor = .clear
        shieldShape.lineCap = .round
        
        // Shimmer effect
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 1),
            SKAction.fadeAlpha(to: 0.3, duration: 1)
        ])
        shieldShape.run(SKAction.repeatForever(shimmer))
        drone.addChild(shieldShape)
        
        return drone
    }
    
    private func createOutlineTitan() -> SKNode {
        let titan = SKNode()
        let color = OutlineColors.magenta
        
        // Large body - octagon
        let body = createOctagonPath(radius: 28)
        let bodyShape = SKShapeNode(path: body)
        bodyShape.strokeColor = color
        bodyShape.lineWidth = 3
        bodyShape.fillColor = .clear
        titan.addChild(bodyShape)
        
        // Inner layers
        let inner1 = createOctagonPath(radius: 20)
        let innerShape1 = SKShapeNode(path: inner1)
        innerShape1.strokeColor = color.withAlphaComponent(0.7)
        innerShape1.lineWidth = 2
        innerShape1.fillColor = .clear
        titan.addChild(innerShape1)
        
        let inner2 = createOctagonPath(radius: 12)
        let innerShape2 = SKShapeNode(path: inner2)
        innerShape2.strokeColor = color.withAlphaComponent(0.5)
        innerShape2.lineWidth = 1
        innerShape2.fillColor = .clear
        titan.addChild(innerShape2)
        
        // Spikes
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let spike = createSpike(color: color)
            spike.position = CGPoint(x: cos(angle) * 28, y: sin(angle) * 28)
            spike.zRotation = angle
            titan.addChild(spike)
        }
        
        // Multiple eyes
        for i in 0..<3 {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.strokeColor = OutlineColors.red
            eye.lineWidth = 1
            eye.fillColor = .clear
            eye.position = CGPoint(x: -8 + CGFloat(i) * 8, y: 5)
            
            // Glow pulse
            let glow = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            eye.run(SKAction.repeatForever(glow))
            titan.addChild(eye)
        }
        
        return titan
    }
    
    // MARK: - Helper Methods for Components
    
    private func createHexagonPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func createOctagonPath(radius: CGFloat) -> CGPath {
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
        return path
    }
    
    private func createTrianglePath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: -size * 0.866, y: -size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.866, y: -size * 0.5))
        path.closeSubpath()
        return path
    }
    
    private func createDiamondPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height/2))
        path.addLine(to: CGPoint(x: width/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height/2))
        path.addLine(to: CGPoint(x: -width/2, y: 0))
        path.closeSubpath()
        return path
    }
    
    private func createLine(from: CGPoint, to: CGPoint, color: SKColor, width: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = color
        line.lineWidth = width
        line.lineCap = .round
        return line
    }
    
    private func createDashedCircle(radius: CGFloat, dashes: Int, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        let dashLength = (2 * .pi) / CGFloat(dashes * 2)
        
        for i in 0..<dashes {
            let startAngle = CGFloat(i) * 2 * dashLength
            let endAngle = startAngle + dashLength
            
            path.move(to: CGPoint(x: cos(startAngle) * radius, y: sin(startAngle) * radius))
            
            for t in stride(from: 0, through: 1, by: 0.1) {
                let angle = startAngle + (endAngle - startAngle) * CGFloat(t)
                path.addLine(to: CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
            }
        }
        
        let circle = SKShapeNode(path: path)
        circle.strokeColor = color
        circle.lineWidth = 2
        circle.lineCap = .round
        return circle
    }
    
    private func createHeatSink() -> SKNode {
        let sink = SKNode()
        
        for i in 0..<3 {
            let fin = SKShapeNode(rectOf: CGSize(width: 2, height: 8))
            fin.strokeColor = OutlineColors.cyan.withAlphaComponent(0.6)
            fin.lineWidth = 1
            fin.fillColor = .clear
            fin.position = CGPoint(x: -2 + CGFloat(i) * 2, y: 0)
            sink.addChild(fin)
        }
        
        return sink
    }
    
    private func createPowerCoil(color: SKColor) -> SKNode {
        let coil = SKShapeNode(circleOfRadius: 4)
        coil.strokeColor = color.withAlphaComponent(0.8)
        coil.lineWidth = 1
        coil.fillColor = .clear
        
        // Inner ring
        let inner = SKShapeNode(circleOfRadius: 2)
        inner.strokeColor = color.withAlphaComponent(0.5)
        inner.lineWidth = 1
        inner.fillColor = .clear
        coil.addChild(inner)
        
        return coil
    }
    
    private func createCapacitor(color: SKColor) -> SKNode {
        let cap = SKNode()
        
        let body = SKShapeNode(rectOf: CGSize(width: 6, height: 10))
        body.strokeColor = color.withAlphaComponent(0.7)
        body.lineWidth = 1
        body.fillColor = .clear
        cap.addChild(body)
        
        // Energy indicator
        for i in 0..<3 {
            let bar = SKShapeNode(rectOf: CGSize(width: 4, height: 1))
            bar.strokeColor = color.withAlphaComponent(0.5)
            bar.lineWidth = 0.5
            bar.fillColor = .clear
            bar.position = CGPoint(x: 0, y: -3 + CGFloat(i) * 3)
            cap.addChild(bar)
        }
        
        return cap
    }
    
    private func createStabilizer(color: SKColor) -> SKNode {
        let stabilizer = SKNode()
        
        let arm = createLine(from: .zero, to: CGPoint(x: 0, y: -10), color: color, width: 1)
        stabilizer.addChild(arm)
        
        let pad = SKShapeNode(circleOfRadius: 3)
        pad.strokeColor = color
        pad.lineWidth = 1
        pad.fillColor = .clear
        pad.position = CGPoint(x: 0, y: -10)
        stabilizer.addChild(pad)
        
        return stabilizer
    }
    
    private func createTargetingLaser(color: SKColor) -> SKNode {
        let laser = SKNode()
        
        let mount = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
        mount.strokeColor = color
        mount.lineWidth = 1
        mount.fillColor = .clear
        laser.addChild(mount)
        
        // Laser beam
        let beam = createLine(from: .zero, to: CGPoint(x: 0, y: 50), color: color.withAlphaComponent(0.3), width: 0.5)
        beam.alpha = 0
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.5),
            SKAction.fadeAlpha(to: 0, duration: 0.5)
        ])
        beam.run(SKAction.repeatForever(pulse))
        laser.addChild(beam)
        
        return laser
    }
    
    private func createMissilePod(color: SKColor) -> SKNode {
        let pod = SKNode()
        
        // Hexagonal tube
        let tube = createHexagonPath(radius: 4)
        let tubeShape = SKShapeNode(path: tube)
        tubeShape.strokeColor = color
        tubeShape.lineWidth = 1
        tubeShape.fillColor = .clear
        pod.addChild(tubeShape)
        
        // Inner details
        let inner = SKShapeNode(circleOfRadius: 2)
        inner.strokeColor = color.withAlphaComponent(0.5)
        inner.lineWidth = 0.5
        inner.fillColor = .clear
        pod.addChild(inner)
        
        return pod
    }
    
    private func createRadarDish(color: SKColor) -> SKNode {
        let radar = SKNode()
        
        // Dish outline
        let dish = SKShapeNode(circleOfRadius: 8)
        dish.strokeColor = color
        dish.lineWidth = 1
        dish.fillColor = .clear
        radar.addChild(dish)
        
        // Grid lines
        for i in 1...2 {
            let ring = SKShapeNode(circleOfRadius: CGFloat(i) * 3)
            ring.strokeColor = color.withAlphaComponent(0.3)
            ring.lineWidth = 0.5
            ring.fillColor = .clear
            radar.addChild(ring)
        }
        
        // Cross hairs
        let hLine = createLine(from: CGPoint(x: -8, y: 0), to: CGPoint(x: 8, y: 0), color: color.withAlphaComponent(0.5), width: 0.5)
        let vLine = createLine(from: CGPoint(x: 0, y: -8), to: CGPoint(x: 0, y: 8), color: color.withAlphaComponent(0.5), width: 0.5)
        radar.addChild(hLine)
        radar.addChild(vLine)
        
        return radar
    }
    
    private func createCoilTip(color: SKColor) -> SKNode {
        let tip = SKNode()
        
        // Multiple rings
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: CGFloat(4 - i))
            ring.strokeColor = color.withAlphaComponent(0.8 - CGFloat(i) * 0.2)
            ring.lineWidth = 1
            ring.fillColor = .clear
            tip.addChild(ring)
        }
        
        return tip
    }
    
    private func createAnimatedArc(from: CGPoint, to: CGPoint, color: SKColor) -> SKNode {
        let arc = SKNode()
        
        // Create jagged path
        let path = CGMutablePath()
        path.move(to: from)
        
        let segments = 4
        for i in 1...segments {
            let t = CGFloat(i) / CGFloat(segments)
            let baseX = from.x + (to.x - from.x) * t
            let baseY = from.y + (to.y - from.y) * t
            
            if i < segments {
                let offset = CGFloat.random(in: -3...3)
                path.addLine(to: CGPoint(x: baseX + offset, y: baseY + offset))
            } else {
                path.addLine(to: to)
            }
        }
        
        let lightning = SKShapeNode(path: path)
        lightning.strokeColor = color
        lightning.lineWidth = 1
        lightning.lineCap = .round
        lightning.alpha = 0
        
        // Flicker
        let flicker = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 0.5...2)),
            SKAction.fadeAlpha(to: 0.8, duration: 0.05),
            SKAction.fadeAlpha(to: 0, duration: 0.15)
        ])
        lightning.run(SKAction.repeatForever(flicker))
        
        arc.addChild(lightning)
        return arc
    }
    
    private func createEnergyCore(color: SKColor) -> SKNode {
        let core = SKNode()
        
        // Outer ring
        let outer = SKShapeNode(circleOfRadius: 6)
        outer.strokeColor = color
        outer.lineWidth = 2
        outer.fillColor = .clear
        core.addChild(outer)
        
        // Inner ring
        let inner = SKShapeNode(circleOfRadius: 3)
        inner.strokeColor = color.withAlphaComponent(0.7)
        inner.lineWidth = 1
        inner.fillColor = .clear
        core.addChild(inner)
        
        // Center dot
        let center = SKShapeNode(circleOfRadius: 1)
        center.strokeColor = color
        center.lineWidth = 1
        center.fillColor = .clear
        
        // Pulse
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        center.run(SKAction.repeatForever(pulse))
        core.addChild(center)
        
        return core
    }
    
    private func createOrbitingParticle(color: SKColor) -> SKNode {
        let particle = SKShapeNode(circleOfRadius: 2)
        particle.strokeColor = color
        particle.lineWidth = 1
        particle.fillColor = .clear
        return particle
    }
    
    private func createSpiralOrbit(startRadius: CGFloat, endRadius: CGFloat, duration: TimeInterval) -> SKAction {
        var actions: [SKAction] = []
        let steps = 50
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let radius = startRadius + (endRadius - startRadius) * t
            let angle = t * .pi * 4
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            
            actions.append(SKAction.move(to: CGPoint(x: x, y: y), duration: duration / Double(steps)))
        }
        
        return SKAction.sequence(actions)
    }
    
    private func createTankTread(color: SKColor) -> SKNode {
        let tread = SKNode()
        
        // Tread outline
        let outline = SKShapeNode(rectOf: CGSize(width: 6, height: 20))
        outline.strokeColor = color.withAlphaComponent(0.7)
        outline.lineWidth = 1
        outline.fillColor = .clear
        tread.addChild(outline)
        
        // Tread segments
        for i in 0..<4 {
            let segment = createLine(
                from: CGPoint(x: -3, y: -8 + CGFloat(i) * 5),
                to: CGPoint(x: 3, y: -8 + CGFloat(i) * 5),
                color: color.withAlphaComponent(0.4),
                width: 0.5
            )
            tread.addChild(segment)
        }
        
        return tread
    }
    
    private func createWeaponMount(color: SKColor) -> SKNode {
        let mount = SKNode()
        
        let base = SKShapeNode(circleOfRadius: 4)
        base.strokeColor = color
        base.lineWidth = 1
        base.fillColor = .clear
        mount.addChild(base)
        
        // Barrel
        let barrel = createLine(from: .zero, to: CGPoint(x: 0, y: 8), color: color, width: 1.5)
        mount.addChild(barrel)
        
        return mount
    }
    
    private func createSensor(color: SKColor) -> SKNode {
        let sensor = SKNode()
        
        let eye = SKShapeNode(rectOf: CGSize(width: 8, height: 3))
        eye.strokeColor = color
        eye.lineWidth = 1
        eye.fillColor = .clear
        sensor.addChild(eye)
        
        // Scan line
        let scan = createLine(from: CGPoint(x: -4, y: 0), to: CGPoint(x: 4, y: 0), color: color.withAlphaComponent(0.5), width: 0.5)
        let scanAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.5),
            SKAction.moveBy(x: 0, y: -4, duration: 1),
            SKAction.moveBy(x: 0, y: 2, duration: 0.5)
        ])
        scan.run(SKAction.repeatForever(scanAction))
        sensor.addChild(scan)
        
        return sensor
    }
    
    private func createRotor(color: SKColor) -> SKNode {
        let rotor = SKNode()
        
        // Cross shape
        let h = createLine(from: CGPoint(x: -4, y: 0), to: CGPoint(x: 4, y: 0), color: color, width: 1)
        let v = createLine(from: CGPoint(x: 0, y: -4), to: CGPoint(x: 0, y: 4), color: color, width: 1)
        rotor.addChild(h)
        rotor.addChild(v)
        
        return rotor
    }
    
    private func createSpike(color: SKColor) -> SKNode {
        let spike = createTrianglePath(size: 6)
        let spikeShape = SKShapeNode(path: spike)
        spikeShape.strokeColor = color
        spikeShape.lineWidth = 1
        spikeShape.fillColor = .clear
        return spikeShape
    }
}