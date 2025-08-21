import Foundation
import SpriteKit
import CoreGraphics

// MARK: - Tower Graphics System
class TowerGraphicsSystem {
    
    static let shared = TowerGraphicsSystem()
    
    private init() {}
    
    // MARK: - Tower Visual Creation
    func createTowerVisuals(for tower: EnhancedTower) -> SKNode {
        let container = SKNode()
        
        // Create base platform
        let platform = createPlatform(for: tower)
        container.addChild(platform)
        
        // Create main tower body
        let body = createTowerBody(for: tower)
        container.addChild(body)
        
        // Create turret/top component
        let turret = createTurretComponent(for: tower)
        container.addChild(turret)
        
        // Add tier-specific enhancements
        addTierEnhancements(to: container, tower: tower)
        
        // Add idle animation
        addIdleAnimation(to: container, tower: tower)
        
        return container
    }
    
    // MARK: - Platform Creation
    private func createPlatform(for tower: EnhancedTower) -> SKNode {
        let platform = SKNode()
        
        // Base hexagon
        let hexagon = createHexagon(radius: 25, fillColor: SKColor.darkGray, strokeColor: getTowerAccentColor(tower))
        platform.addChild(hexagon)
        
        // Energy rings for different platform types
        switch tower.towerType.category {
        case .ultimate:
            // Add rotating energy rings
            let ring1 = createEnergyRing(radius: 30, color: .cyan)
            let ring2 = createEnergyRing(radius: 35, color: .purple)
            ring1.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 4)))
            ring2.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi * 2, duration: 6)))
            platform.addChild(ring1)
            platform.addChild(ring2)
            
        case .support:
            // Add pulsing support ring
            let supportRing = createEnergyRing(radius: 28, color: .green)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 1),
                SKAction.scale(to: 1.0, duration: 1)
            ])
            supportRing.run(SKAction.repeatForever(pulse))
            platform.addChild(supportRing)
            
        default:
            // Standard platform with tech details
            addTechDetails(to: hexagon)
        }
        
        // Add power indicator lights
        addPowerLights(to: platform, tower: tower)
        
        return platform
    }
    
    // MARK: - Tower Body Creation
    private func createTowerBody(for tower: EnhancedTower) -> SKNode {
        switch tower.towerType {
        case .laserTurret:
            return createLaserTurretBody()
        case .railgunEmplacement:
            return createRailgunBody()
        case .plasmaArcNode:
            return createPlasmaArcBody()
        case .missilePDBattery:
            return createMissileBatteryBody()
        case .nanobotSwarmDispenser:
            return createNanobotDispenserBody()
        case .cryoFoamProjector:
            return createCryoProjectorBody()
        case .gravityWellProjector:
            return createGravityWellBody()
        case .empShockTower:
            return createEMPTowerBody()
        case .plasmaMortar:
            return createMortarBody()
        case .droneBay:
            return createDroneBayBody()
        case .shieldProjector:
            return createShieldProjectorBody()
        case .hackingUplink:
            return createHackingUplinkBody()
        case .resourceHarvester:
            return createHarvesterBody()
        case .repairDroneSpire:
            return createRepairSpireBody()
        case .solarLanceArray:
            return createSolarLanceBody()
        case .singularityCannon:
            return createSingularityCannonBody()
        }
    }
    
    // MARK: - Individual Tower Bodies
    
    private func createLaserTurretBody() -> SKNode {
        let body = SKNode()
        
        // Cylindrical base
        let base = SKShapeNode(circleOfRadius: 15)
        base.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1)
        base.strokeColor = SKColor.cyan
        base.lineWidth = 1
        body.addChild(base)
        
        // Heat sink fins
        for i in 0..<4 {
            let fin = SKShapeNode(rectOf: CGSize(width: 3, height: 20))
            fin.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
            fin.position = CGPoint(x: cos(CGFloat(i) * .pi/2) * 12,
                                  y: sin(CGFloat(i) * .pi/2) * 12)
            fin.zRotation = CGFloat(i) * .pi/2
            body.addChild(fin)
        }
        
        // Central focusing crystal
        let crystal = createCrystal(size: CGSize(width: 8, height: 12), color: .red)
        crystal.position = CGPoint(x: 0, y: 0)
        body.addChild(crystal)
        
        return body
    }
    
    private func createRailgunBody() -> SKNode {
        let body = SKNode()
        
        // Rectangular base with reinforced corners
        let base = SKShapeNode(rectOf: CGSize(width: 25, height: 35))
        base.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1)
        base.strokeColor = SKColor.gray
        base.lineWidth = 2
        body.addChild(base)
        
        // Electromagnetic coils
        for i in 0..<3 {
            let coil = createCoil(radius: 10 - CGFloat(i) * 2)
            coil.position = CGPoint(x: 0, y: -10 + CGFloat(i) * 10)
            body.addChild(coil)
        }
        
        // Power capacitors
        for side in [-1, 1] {
            let capacitor = SKShapeNode(rectOf: CGSize(width: 5, height: 15))
            capacitor.fillColor = SKColor.blue
            capacitor.strokeColor = SKColor.cyan
            capacitor.lineWidth = 1
            capacitor.position = CGPoint(x: CGFloat(side) * 15, y: 0)
            
            // Add electric effect
            let electric = createElectricArc()
            electric.position = capacitor.position
            body.addChild(electric)
            body.addChild(capacitor)
        }
        
        return body
    }
    
    private func createPlasmaArcBody() -> SKNode {
        let body = SKNode()
        
        // Tesla coil base
        let base = SKShapeNode(circleOfRadius: 12)
        base.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 1)
        base.strokeColor = SKColor.purple
        base.lineWidth = 2
        body.addChild(base)
        
        // Multiple conductor rods
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let rod = SKShapeNode(rectOf: CGSize(width: 2, height: 15))
            rod.fillColor = SKColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1)
            rod.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
            rod.zRotation = angle
            
            // Add arc endpoints
            let endpoint = SKShapeNode(circleOfRadius: 3)
            endpoint.fillColor = SKColor.cyan
            endpoint.glowWidth = 2
            endpoint.position = CGPoint(x: 0, y: 7.5)
            rod.addChild(endpoint)
            
            body.addChild(rod)
        }
        
        // Central plasma orb
        let orb = createPlasmaOrb(radius: 6)
        body.addChild(orb)
        
        return body
    }
    
    private func createMissileBatteryBody() -> SKNode {
        let body = SKNode()
        
        // Rectangular launcher base
        let base = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        base.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1)
        base.strokeColor = SKColor.orange
        base.lineWidth = 1
        body.addChild(base)
        
        // Missile tubes (2x3 grid)
        for row in 0..<2 {
            for col in 0..<3 {
                let tube = createMissileTube()
                tube.position = CGPoint(x: -10 + CGFloat(col) * 10,
                                       y: -5 + CGFloat(row) * 10)
                body.addChild(tube)
            }
        }
        
        // Radar dish
        let radar = createRadarDish(radius: 8)
        radar.position = CGPoint(x: 0, y: 15)
        radar.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3)))
        body.addChild(radar)
        
        return body
    }
    
    private func createNanobotDispenserBody() -> SKNode {
        let body = SKNode()
        
        // Hexagonal hive structure
        let hive = createHexagon(radius: 18, fillColor: SKColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 1), strokeColor: .green)
        body.addChild(hive)
        
        // Honeycomb pattern inside
        for row in -1...1 {
            for col in -1...1 {
                if abs(row) + abs(col) <= 1 {
                    let cell = createHexagon(radius: 5,
                                            fillColor: SKColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 0.8),
                                            strokeColor: SKColor.green.withAlphaComponent(0.5))
                    cell.position = CGPoint(x: CGFloat(col) * 10, y: CGFloat(row) * 10)
                    
                    // Add pulsing glow
                    let glow = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.5, duration: Double.random(in: 0.5...1.5)),
                        SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.5...1.5))
                    ])
                    cell.run(SKAction.repeatForever(glow))
                    
                    body.addChild(cell)
                }
            }
        }
        
        // Nanobot swarm particles
        let swarm = createNanoSwarmEffect()
        body.addChild(swarm)
        
        return body
    }
    
    private func createCryoProjectorBody() -> SKNode {
        let body = SKNode()
        
        // Cylindrical tank
        let tank = SKShapeNode(ellipseOf: CGSize(width: 20, height: 25))
        tank.fillColor = SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1)
        tank.strokeColor = SKColor.cyan
        tank.lineWidth = 2
        body.addChild(tank)
        
        // Frost crystals
        for i in 0..<6 {
            let crystal = createIceCrystal()
            let angle = CGFloat(i) * .pi / 3
            crystal.position = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12)
            body.addChild(crystal)
        }
        
        // Coolant pipes
        for side in [-1, 1] {
            let pipe = SKShapeNode(rectOf: CGSize(width: 3, height: 20))
            pipe.fillColor = SKColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1)
            pipe.strokeColor = SKColor.blue
            pipe.position = CGPoint(x: CGFloat(side) * 12, y: 0)
            
            // Add frost effect
            let frost = createFrostEffect()
            frost.position = pipe.position
            body.addChild(frost)
            body.addChild(pipe)
        }
        
        // Central nozzle
        let nozzle = createConeShape(baseRadius: 8, height: 15)
        nozzle.fillColor = SKColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1)
        nozzle.position = CGPoint(x: 0, y: 5)
        body.addChild(nozzle)
        
        return body
    }
    
    private func createGravityWellBody() -> SKNode {
        let body = SKNode()
        
        // Spherical containment field
        let field = SKShapeNode(circleOfRadius: 20)
        field.fillColor = SKColor.clear
        field.strokeColor = SKColor.purple
        field.lineWidth = 2
        field.glowWidth = 3
        body.addChild(field)
        
        // Inner rings (gyroscopic)
        for i in 0..<3 {
            let ring = createEnergyRing(radius: CGFloat(15 - i * 4), color: SKColor.purple.withAlphaComponent(0.7))
            ring.lineWidth = CGFloat(3 - i)
            
            let rotation = SKAction.rotate(byAngle: CGFloat(i % 2 == 0 ? 1 : -1) * .pi * 2,
                                          duration: TimeInterval(3 + i))
            ring.run(SKAction.repeatForever(rotation))
            body.addChild(ring)
        }
        
        // Dark matter core
        let core = SKShapeNode(circleOfRadius: 5)
        core.fillColor = SKColor.black
        core.strokeColor = SKColor.purple
        core.lineWidth = 1
        core.glowWidth = 5
        
        // Add swirling effect
        let swirl = createSwirlEffect()
        core.addChild(swirl)
        body.addChild(core)
        
        // Gravitational distortion effect
        let distortion = createDistortionField()
        body.addChild(distortion)
        
        return body
    }
    
    private func createEMPTowerBody() -> SKNode {
        let body = SKNode()
        
        // Central capacitor
        let capacitor = SKShapeNode(rectOf: CGSize(width: 15, height: 25))
        capacitor.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1)
        capacitor.strokeColor = SKColor.yellow
        capacitor.lineWidth = 2
        body.addChild(capacitor)
        
        // Discharge rods in circle
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let rod = createDischargeRod()
            rod.position = CGPoint(x: cos(angle) * 15, y: sin(angle) * 15)
            rod.zRotation = angle
            body.addChild(rod)
            
            // Add sparks between rods
            if i % 2 == 0 {
                let spark = createSparkEffect()
                spark.position = rod.position
                body.addChild(spark)
            }
        }
        
        // Charging indicator
        let chargeIndicator = createChargeIndicator()
        chargeIndicator.position = CGPoint(x: 0, y: -20)
        body.addChild(chargeIndicator)
        
        return body
    }
    
    private func createMortarBody() -> SKNode {
        let body = SKNode()
        
        // Mortar tube
        let tube = SKShapeNode(rectOf: CGSize(width: 25, height: 30))
        tube.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1)
        tube.strokeColor = SKColor.darkGray
        tube.lineWidth = 3
        body.addChild(tube)
        
        // Reinforcement bands
        for i in 0..<3 {
            let band = SKShapeNode(rectOf: CGSize(width: 30, height: 3))
            band.fillColor = SKColor(red: 0.6, green: 0.5, blue: 0.5, alpha: 1)
            band.position = CGPoint(x: 0, y: -10 + CGFloat(i) * 10)
            body.addChild(band)
        }
        
        // Plasma chamber glow
        let chamber = SKShapeNode(circleOfRadius: 10)
        chamber.fillColor = SKColor.purple.withAlphaComponent(0.3)
        chamber.strokeColor = SKColor.purple
        chamber.glowWidth = 5
        chamber.position = CGPoint(x: 0, y: -5)
        
        // Pulsing effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        chamber.run(SKAction.repeatForever(pulse))
        body.addChild(chamber)
        
        // Aiming mechanism
        let pivot = SKShapeNode(circleOfRadius: 5)
        pivot.fillColor = SKColor.gray
        pivot.position = CGPoint(x: 0, y: -15)
        body.addChild(pivot)
        
        return body
    }
    
    private func createDroneBayBody() -> SKNode {
        let body = SKNode()
        
        // Hangar structure
        let hangar = SKShapeNode(rectOf: CGSize(width: 35, height: 25))
        hangar.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1)
        hangar.strokeColor = SKColor.blue
        hangar.lineWidth = 2
        body.addChild(hangar)
        
        // Launch rails
        for i in 0..<2 {
            let rail = SKShapeNode(rectOf: CGSize(width: 2, height: 20))
            rail.fillColor = SKColor.lightGray
            rail.position = CGPoint(x: -8 + CGFloat(i) * 16, y: 0)
            
            // Add energy flow effect
            let energy = createEnergyFlow()
            energy.position = rail.position
            body.addChild(energy)
            body.addChild(rail)
        }
        
        // Drone parking spots
        for i in 0..<4 {
            let spot = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            spot.fillColor = SKColor.clear
            spot.strokeColor = SKColor.blue.withAlphaComponent(0.5)
            spot.lineWidth = 1
            spot.position = CGPoint(x: -12 + CGFloat(i % 2) * 24,
                                   y: -6 + CGFloat(i / 2) * 12)
            body.addChild(spot)
        }
        
        // Control antenna
        let antenna = createAntenna()
        antenna.position = CGPoint(x: 0, y: 15)
        body.addChild(antenna)
        
        return body
    }
    
    private func createShieldProjectorBody() -> SKNode {
        let body = SKNode()
        
        // Central projector core
        let core = SKShapeNode(circleOfRadius: 12)
        core.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1)
        core.strokeColor = SKColor.cyan
        core.lineWidth = 2
        core.glowWidth = 3
        body.addChild(core)
        
        // Shield emitters (hexagonal arrangement)
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let emitter = createShieldEmitter()
            emitter.position = CGPoint(x: cos(angle) * 15, y: sin(angle) * 15)
            emitter.zRotation = angle
            body.addChild(emitter)
        }
        
        // Shield bubble effect
        let bubble = createShieldBubble(radius: 25)
        body.addChild(bubble)
        
        // Energy conduits
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let conduit = createEnergyConduit(from: .zero,
                                             to: CGPoint(x: cos(angle) * 15, y: sin(angle) * 15))
            body.addChild(conduit)
        }
        
        return body
    }
    
    private func createHackingUplinkBody() -> SKNode {
        let body = SKNode()
        
        // Main server rack
        let rack = SKShapeNode(rectOf: CGSize(width: 20, height: 30))
        rack.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1)
        rack.strokeColor = SKColor.green
        rack.lineWidth = 1
        body.addChild(rack)
        
        // Data ports (blinking lights)
        for row in 0..<4 {
            for col in 0..<3 {
                let port = SKShapeNode(circleOfRadius: 2)
                port.fillColor = SKColor.green
                port.glowWidth = 1
                port.position = CGPoint(x: -6 + CGFloat(col) * 6,
                                       y: -10 + CGFloat(row) * 7)
                
                // Random blinking
                let blink = SKAction.sequence([
                    SKAction.wait(forDuration: Double.random(in: 0.1...2.0)),
                    SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                ])
                port.run(SKAction.repeatForever(blink))
                body.addChild(port)
            }
        }
        
        // Satellite dish
        let dish = createSatelliteDish()
        dish.position = CGPoint(x: 0, y: 18)
        body.addChild(dish)
        
        // Data stream effect
        let dataStream = createDataStreamEffect()
        body.addChild(dataStream)
        
        return body
    }
    
    private func createHarvesterBody() -> SKNode {
        let body = SKNode()
        
        // Mining drill base
        let base = SKShapeNode(rectOf: CGSize(width: 25, height: 20))
        base.fillColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1)
        base.strokeColor = SKColor.orange
        base.lineWidth = 2
        body.addChild(base)
        
        // Drill bit
        let drill = createDrillBit()
        drill.position = CGPoint(x: 0, y: -10)
        drill.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 1)))
        body.addChild(drill)
        
        // Collection container
        let container = SKShapeNode(rectOf: CGSize(width: 15, height: 10))
        container.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        container.strokeColor = SKColor.gray
        container.position = CGPoint(x: 0, y: 10)
        body.addChild(container)
        
        // Resource particles
        let resources = createResourceParticles()
        resources.position = CGPoint(x: 0, y: 5)
        body.addChild(resources)
        
        // Conveyor belt effect
        let conveyor = createConveyorEffect()
        conveyor.position = CGPoint(x: 0, y: 0)
        body.addChild(conveyor)
        
        return body
    }
    
    private func createRepairSpireBody() -> SKNode {
        let body = SKNode()
        
        // Spire tower
        let spire = createSpireShape()
        spire.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1)
        spire.strokeColor = SKColor.orange
        spire.lineWidth = 2
        body.addChild(spire)
        
        // Repair beam emitters
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let emitter = createRepairEmitter()
            emitter.position = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12 + 5)
            emitter.zRotation = angle
            body.addChild(emitter)
        }
        
        // Nano-repair particles
        let nanoRepair = createNanoRepairEffect()
        body.addChild(nanoRepair)
        
        // Tool rack
        for i in 0..<3 {
            let tool = createRepairTool(type: i)
            tool.position = CGPoint(x: -10 + CGFloat(i) * 10, y: -10)
            body.addChild(tool)
        }
        
        return body
    }
    
    private func createSolarLanceBody() -> SKNode {
        let body = SKNode()
        
        // Main focusing array
        let array = SKShapeNode(rectOf: CGSize(width: 40, height: 50))
        array.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 1)
        array.strokeColor = SKColor.yellow
        array.lineWidth = 3
        array.glowWidth = 5
        body.addChild(array)
        
        // Solar panels
        for side in [-1, 1] {
            let panel = createSolarPanel()
            panel.position = CGPoint(x: CGFloat(side) * 25, y: 0)
            panel.zRotation = CGFloat(side) * .pi / 8
            body.addChild(panel)
        }
        
        // Focusing prisms
        for i in 0..<3 {
            let prism = createPrism()
            prism.position = CGPoint(x: 0, y: -15 + CGFloat(i) * 15)
            
            // Rotating prism effect
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: TimeInterval(4 + i))
            prism.run(SKAction.repeatForever(rotate))
            body.addChild(prism)
        }
        
        // Charging capacitor ring
        let capacitorRing = createCapacitorRing(radius: 30)
        body.addChild(capacitorRing)
        
        // Lens flare effect
        let lensFlare = createLensFlareEffect()
        lensFlare.position = CGPoint(x: 0, y: 20)
        body.addChild(lensFlare)
        
        return body
    }
    
    private func createSingularityCannonBody() -> SKNode {
        let body = SKNode()
        
        // Containment chamber
        let chamber = SKShapeNode(circleOfRadius: 25)
        chamber.fillColor = SKColor.black.withAlphaComponent(0.8)
        chamber.strokeColor = SKColor.purple
        chamber.lineWidth = 3
        chamber.glowWidth = 8
        body.addChild(chamber)
        
        // Containment rings
        for i in 0..<4 {
            let ring = createContainmentRing(radius: CGFloat(20 - i * 4))
            let speed = TimeInterval(2 + i)
            let direction = i % 2 == 0 ? 1.0 : -1.0
            ring.run(SKAction.repeatForever(
                SKAction.rotate(byAngle: CGFloat(direction) * .pi * 2, duration: speed)
            ))
            body.addChild(ring)
        }
        
        // Singularity core
        let singularity = createSingularityCore()
        body.addChild(singularity)
        
        // Gravitational lensing effect
        let lensing = createGravitationalLensing()
        body.addChild(lensing)
        
        // Power regulators
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let regulator = createPowerRegulator()
            regulator.position = CGPoint(x: cos(angle) * 30, y: sin(angle) * 30)
            body.addChild(regulator)
        }
        
        // Event horizon indicator
        let horizon = createEventHorizon(radius: 15)
        body.addChild(horizon)
        
        return body
    }
    
    // MARK: - Turret Components
    private func createTurretComponent(for tower: EnhancedTower) -> SKNode {
        switch tower.towerType {
        case .laserTurret:
            return createLaserTurret()
        case .railgunEmplacement:
            return createRailgunBarrel()
        case .plasmaArcNode:
            return createPlasmaEmitter()
        case .missilePDBattery:
            return createMissileLauncher()
        case .nanobotSwarmDispenser:
            return createNanobotNozzles()
        case .cryoFoamProjector:
            return createCryoNozzle()
        case .plasmaMortar:
            return createMortarBarrel()
        default:
            return SKNode() // Some towers don't have turrets
        }
    }
    
    private func createLaserTurret() -> SKNode {
        let turret = SKNode()
        
        // Rotating barrel
        let barrel = SKShapeNode(rectOf: CGSize(width: 5, height: 25))
        barrel.fillColor = SKColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
        barrel.strokeColor = SKColor.red
        barrel.lineWidth = 1
        barrel.position = CGPoint(x: 0, y: 12)
        
        // Focusing lens
        let lens = SKShapeNode(circleOfRadius: 4)
        lens.fillColor = SKColor.red.withAlphaComponent(0.5)
        lens.strokeColor = SKColor.red
        lens.glowWidth = 3
        lens.position = CGPoint(x: 0, y: 12)
        barrel.addChild(lens)
        
        turret.addChild(barrel)
        turret.name = "turret"
        
        return turret
    }
    
    private func createRailgunBarrel() -> SKNode {
        let turret = SKNode()
        
        // Long barrel with rails
        let barrel = SKNode()
        
        // Rails
        for side in [-1, 1] {
            let rail = SKShapeNode(rectOf: CGSize(width: 2, height: 40))
            rail.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1)
            rail.strokeColor = SKColor.cyan
            rail.position = CGPoint(x: CGFloat(side) * 3, y: 20)
            barrel.addChild(rail)
        }
        
        // Muzzle brake
        let muzzle = SKShapeNode(rectOf: CGSize(width: 10, height: 5))
        muzzle.fillColor = SKColor.darkGray
        muzzle.position = CGPoint(x: 0, y: 40)
        barrel.addChild(muzzle)
        
        turret.addChild(barrel)
        turret.name = "turret"
        
        return turret
    }
    
    // MARK: - Helper Shape Creation Methods
    private func createHexagon(radius: CGFloat, fillColor: SKColor, strokeColor: SKColor) -> SKShapeNode {
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
        hexagon.fillColor = fillColor
        hexagon.strokeColor = strokeColor
        hexagon.lineWidth = 2
        
        return hexagon
    }
    
    private func createEnergyRing(radius: CGFloat, color: SKColor) -> SKShapeNode {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = 2
        ring.glowWidth = 3
        return ring
    }
    
    private func createCrystal(size: CGSize, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height/2))
        path.addLine(to: CGPoint(x: -size.width/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size.height/2))
        path.addLine(to: CGPoint(x: size.width/2, y: 0))
        path.closeSubpath()
        
        let crystal = SKShapeNode(path: path)
        crystal.fillColor = color.withAlphaComponent(0.7)
        crystal.strokeColor = color
        crystal.lineWidth = 1
        crystal.glowWidth = 2
        
        return crystal
    }
    
    // MARK: - Particle Effects
    private func createPlasmaOrb(radius: CGFloat) -> SKNode {
        let orb = SKShapeNode(circleOfRadius: radius)
        orb.fillColor = SKColor.purple.withAlphaComponent(0.5)
        orb.strokeColor = SKColor.cyan
        orb.lineWidth = 1
        orb.glowWidth = radius
        
        // Add pulsing
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        orb.run(SKAction.repeatForever(pulse))
        
        return orb
    }
    
    // MARK: - Animation Methods
    private func addIdleAnimation(to node: SKNode, tower: EnhancedTower) {
        switch tower.towerType {
        case .laserTurret, .railgunEmplacement:
            // Scanning rotation
            if let turret = node.childNode(withName: "//turret") {
                let scan = SKAction.sequence([
                    SKAction.rotate(byAngle: .pi/4, duration: 2),
                    SKAction.rotate(byAngle: -.pi/2, duration: 4),
                    SKAction.rotate(byAngle: .pi/4, duration: 2)
                ])
                turret.run(SKAction.repeatForever(scan))
            }
            
        case .gravityWellProjector:
            // Constant swirl effect already added
            break
            
        case .shieldProjector:
            // Pulsing shield effect
            if let bubble = node.childNode(withName: "//shieldBubble") {
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 1.5),
                    SKAction.fadeAlpha(to: 0.1, duration: 1.5)
                ])
                bubble.run(SKAction.repeatForever(pulse))
            }
            
        default:
            break
        }
    }
    
    // MARK: - Tier Enhancement Visuals
    private func addTierEnhancements(to node: SKNode, tower: EnhancedTower) {
        let tier = tower.currentTier
        
        // Add tier stars
        for i in 0..<tier {
            let star = createTierStar()
            star.position = CGPoint(x: -20 + CGFloat(i) * 10, y: -35)
            star.zPosition = 100
            node.addChild(star)
        }
        
        // Add tier-specific effects
        switch tier {
        case 2:
            addTier2Effects(to: node, tower: tower)
        case 3:
            addTier3Effects(to: node, tower: tower)
        case 4:
            addTier4Effects(to: node, tower: tower)
        case 5:
            addTier5Effects(to: node, tower: tower)
        default:
            break
        }
    }
    
    private func addTier2Effects(to node: SKNode, tower: EnhancedTower) {
        // Add enhanced glow
        if let body = node.children.first {
            body.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.run { 
                    if let shape = body as? SKShapeNode {
                        shape.glowWidth = 3
                    }
                },
                SKAction.wait(forDuration: 1),
                SKAction.run {
                    if let shape = body as? SKShapeNode {
                        shape.glowWidth = 5
                    }
                },
                SKAction.wait(forDuration: 1)
            ])))
        }
    }
    
    private func addTier3Effects(to node: SKNode, tower: EnhancedTower) {
        // Add particle aura
        if let emitter = SKEmitterNode(fileNamed: "TowerAura") {
            emitter.position = .zero
            emitter.zPosition = -10
            emitter.particleColor = getTowerAccentColor(tower)
            node.addChild(emitter)
        }
    }
    
    private func addTier4Effects(to node: SKNode, tower: EnhancedTower) {
        // Add rotating energy field
        let field = createEnergyRing(radius: 35, color: getTowerAccentColor(tower))
        field.alpha = 0.5
        field.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3)))
        node.addChild(field)
    }
    
    private func addTier5Effects(to node: SKNode, tower: EnhancedTower) {
        // Add ultimate power effect
        let ultimateAura = SKShapeNode(circleOfRadius: 40)
        ultimateAura.fillColor = .clear
        ultimateAura.strokeColor = getTowerAccentColor(tower)
        ultimateAura.lineWidth = 3
        ultimateAura.glowWidth = 10
        ultimateAura.alpha = 0
        
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 0.8, duration: 0.5),
                SKAction.scale(to: 0.5, duration: 0.5)
            ]),
            SKAction.group([
                SKAction.fadeAlpha(to: 0, duration: 1),
                SKAction.scale(to: 1.5, duration: 1)
            ]),
            SKAction.scale(to: 1, duration: 0),
            SKAction.wait(forDuration: 2)
        ])
        
        ultimateAura.run(SKAction.repeatForever(pulse))
        node.addChild(ultimateAura)
    }
    
    // MARK: - Utility Methods
    private func getTowerAccentColor(_ tower: EnhancedTower) -> SKColor {
        return tower.towerType.damageType.color
    }
    
    private func createTierStar() -> SKShapeNode {
        let star = SKShapeNode()
        let path = CGMutablePath()
        
        for i in 0..<5 {
            let angle = CGFloat(i) * 2 * .pi / 5 - .pi / 2
            let outerRadius: CGFloat = 4
            let innerRadius: CGFloat = 2
            
            let outerPoint = CGPoint(x: cos(angle) * outerRadius, y: sin(angle) * outerRadius)
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: cos(innerAngle) * innerRadius, y: sin(innerAngle) * innerRadius)
            
            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.addLine(to: outerPoint)
            }
            path.addLine(to: innerPoint)
        }
        path.closeSubpath()
        
        star.path = path
        star.fillColor = SKColor.yellow
        star.strokeColor = SKColor.orange
        star.lineWidth = 1
        
        return star
    }
    
    // Additional helper methods for specific components
    private func createCoil(radius: CGFloat) -> SKShapeNode {
        let coil = SKShapeNode(circleOfRadius: radius)
        coil.fillColor = .clear
        coil.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1)
        coil.lineWidth = 2
        coil.glowWidth = 1
        return coil
    }
    
    private func createElectricArc() -> SKNode {
        let arc = SKNode()
        // Implementation for electric arc effect
        return arc
    }
    
    private func createMissileTube() -> SKShapeNode {
        let tube = SKShapeNode(circleOfRadius: 3)
        tube.fillColor = SKColor.darkGray
        tube.strokeColor = SKColor.gray
        tube.lineWidth = 1
        return tube
    }
    
    private func createRadarDish(radius: CGFloat) -> SKNode {
        let dish = SKNode()
        let base = SKShapeNode(circleOfRadius: radius)
        base.fillColor = SKColor.gray
        base.strokeColor = SKColor.lightGray
        dish.addChild(base)
        
        // Add grid lines
        for i in 1...3 {
            let ring = SKShapeNode(circleOfRadius: radius * CGFloat(i) / 3)
            ring.strokeColor = SKColor.darkGray
            ring.lineWidth = 0.5
            dish.addChild(ring)
        }
        
        return dish
    }
    
    private func addTechDetails(to node: SKShapeNode) {
        // Add technological details to platform
    }
    
    private func addPowerLights(to platform: SKNode, tower: EnhancedTower) {
        // Add power indicator lights
    }
    
    // Stub methods for additional effects
    private func createNanoSwarmEffect() -> SKNode { return SKNode() }
    private func createIceCrystal() -> SKNode { return SKNode() }
    private func createFrostEffect() -> SKNode { return SKNode() }
    private func createConeShape(baseRadius: CGFloat, height: CGFloat) -> SKShapeNode { return SKShapeNode() }
    private func createSwirlEffect() -> SKNode { return SKNode() }
    private func createDistortionField() -> SKNode { return SKNode() }
    private func createDischargeRod() -> SKNode { return SKNode() }
    private func createSparkEffect() -> SKNode { return SKNode() }
    private func createChargeIndicator() -> SKNode { return SKNode() }
    private func createEnergyFlow() -> SKNode { return SKNode() }
    private func createAntenna() -> SKNode { return SKNode() }
    private func createShieldEmitter() -> SKNode { return SKNode() }
    private func createShieldBubble(radius: CGFloat) -> SKNode { return SKNode() }
    private func createEnergyConduit(from: CGPoint, to: CGPoint) -> SKNode { return SKNode() }
    private func createSatelliteDish() -> SKNode { return SKNode() }
    private func createDataStreamEffect() -> SKNode { return SKNode() }
    private func createDrillBit() -> SKNode { return SKNode() }
    private func createResourceParticles() -> SKNode { return SKNode() }
    private func createConveyorEffect() -> SKNode { return SKNode() }
    private func createSpireShape() -> SKShapeNode { return SKShapeNode() }
    private func createRepairEmitter() -> SKNode { return SKNode() }
    private func createNanoRepairEffect() -> SKNode { return SKNode() }
    private func createRepairTool(type: Int) -> SKNode { return SKNode() }
    private func createSolarPanel() -> SKNode { return SKNode() }
    private func createPrism() -> SKNode { return SKNode() }
    private func createCapacitorRing(radius: CGFloat) -> SKNode { return SKNode() }
    private func createLensFlareEffect() -> SKNode { return SKNode() }
    private func createContainmentRing(radius: CGFloat) -> SKNode { return SKNode() }
    private func createSingularityCore() -> SKNode { return SKNode() }
    private func createGravitationalLensing() -> SKNode { return SKNode() }
    private func createPowerRegulator() -> SKNode { return SKNode() }
    private func createEventHorizon(radius: CGFloat) -> SKNode { return SKNode() }
    private func createPlasmaEmitter() -> SKNode { return SKNode() }
    private func createMissileLauncher() -> SKNode { return SKNode() }
    private func createNanobotNozzles() -> SKNode { return SKNode() }
    private func createCryoNozzle() -> SKNode { return SKNode() }
    private func createMortarBarrel() -> SKNode { return SKNode() }
}

// MARK: - Tower Type Extension for Graphics
extension TowerType {
    var damageType: DamageType {
        switch self {
        case .laserTurret, .solarLanceArray:
            return .laser
        case .railgunEmplacement:
            return .kinetic
        case .plasmaArcNode, .plasmaMortar:
            return .plasma
        case .missilePDBattery:
            return .explosive
        case .nanobotSwarmDispenser:
            return .nano
        case .cryoFoamProjector:
            return .cryo
        case .gravityWellProjector, .singularityCannon:
            return .gravity
        case .empShockTower:
            return .electric
        case .hackingUplink:
            return .corrupt
        default:
            return .kinetic
        }
    }
}