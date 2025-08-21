import Foundation
import SpriteKit
import GameplayKit

// MARK: - Enhanced Tower Base Class
class EnhancedTower: BaseEntity {
    // Core Properties
    let towerType: TowerType
    private(set) var currentTier: Int = 1
    private let config: TowerConfig
    private var currentStats: TowerStats
    
    // Components
    private(set) var transform: TransformComponent!
    private(set) var targeting: EnhancedTargetingComponent!
    private(set) var weapon: EnhancedWeaponComponent!
    private(set) var statusApplicator: StatusEffectComponent?
    private(set) var auraEmitter: AuraComponent?
    private(set) var ability: TowerAbilityComponent?
    
    // Visual Components
    private(set) var sprite: SKSpriteNode!
    private var rangeIndicator: SKShapeNode?
    private var auraEffect: SKEffectNode?
    private var tierIndicators: [SKSpriteNode] = []
    
    // State
    private var isSelected: Bool = false
    private var powerAvailable: Bool = true
    private var targets: [Enemy] = []
    
    // MARK: - Initialization
    init(type: TowerType, position: CGPoint) {
        self.towerType = type
        
        guard let config = TowerConfiguration.shared.getConfig(for: type) else {
            fatalError("No configuration found for tower type: \(type)")
        }
        
        self.config = config
        self.currentStats = config.baseStats
        
        super.init()
        
        setupComponents(at: position)
        createVisuals()
        applyTierOneEffects()
    }
    
    // MARK: - Component Setup
    private func setupComponents(at position: CGPoint) {
        // Transform
        transform = TransformComponent()
        transform.position = SIMD2<Float>(Float(position.x), Float(position.y))
        addComponent(transform)
        
        // Enhanced Targeting
        targeting = EnhancedTargetingComponent()
        targeting.range = currentStats.range
        targeting.targetingPriority = getTargetingPriority()
        targeting.canTargetAir = canTargetAir()
        targeting.maxTargets = currentStats.chains ?? 1
        addComponent(targeting)
        
        // Enhanced Weapon
        weapon = EnhancedWeaponComponent()
        weapon.damage = currentStats.damage
        weapon.fireRate = currentStats.fireRate
        weapon.damageType = config.damageType
        weapon.critChance = currentStats.critChance
        weapon.critMultiplier = currentStats.critMultiplier
        weapon.armorPierce = currentStats.armorPierce
        addComponent(weapon)
        
        // Special Components based on tower type
        setupSpecialComponents()
    }
    
    private func setupSpecialComponents() {
        switch towerType {
        case .gravityWellProjector:
            let aura = AuraComponent()
            aura.radius = currentStats.auraRadius ?? currentStats.range
            aura.effect = .pullToCenter(strength: 30)
            auraEmitter = aura
            addComponent(aura)
            
        case .nanobotSwarmDispenser:
            let status = StatusEffectComponent()
            status.effect = StatusEffect(
                type: .infection,
                duration: 4.0,
                intensity: 8.0,
                stackable: true,
                maxStacks: 5
            )
            statusApplicator = status
            addComponent(status)
            
        case .empShockTower:
            let status = StatusEffectComponent()
            status.effect = StatusEffect(
                type: .stun,
                duration: 0.6,
                intensity: 1.0,
                stackable: false,
                maxStacks: 1
            )
            statusApplicator = status
            addComponent(status)
            
        case .shieldProjector:
            let aura = AuraComponent()
            aura.radius = currentStats.range
            aura.effect = .shieldAllies(amount: currentStats.shieldHP ?? 120)
            auraEmitter = aura
            addComponent(aura)
            
        case .resourceHarvester:
            let harvester = ResourceGeneratorComponent()
            harvester.resourcePerSecond = currentStats.resourceGeneration ?? 1.2
            addComponent(harvester)
            
        case .droneBay:
            let droneSpawner = DroneSpawnerComponent()
            droneSpawner.maxDrones = currentStats.droneCount ?? 2
            droneSpawner.droneStats = createDroneStats()
            addComponent(droneSpawner)
            
        default:
            break
        }
    }
    
    // MARK: - Visual Creation
    private func createVisuals() {
        // Main sprite with texture or colored square
        let textureName = "\(towerType.rawValue)_t1"
        if let texture = SKTexture(imageNamed: textureName) {
            sprite = SKSpriteNode(texture: texture)
        } else {
            // Fallback to colored sprite
            sprite = SKSpriteNode(color: getTowerColor(), size: getTowerSize())
        }
        
        sprite.name = "tower_\(id.uuidString)"
        sprite.zPosition = 100
        
        // Add base platform
        createBasePlatform()
        
        // Add range indicator
        createRangeIndicator()
        
        // Add special effects
        createSpecialEffects()
        
        // Update position
        updateSpritePosition()
    }
    
    private func createBasePlatform() {
        let platform = SKShapeNode(circleOfRadius: getTowerSize().width * 0.7)
        platform.fillColor = getTowerColor().withAlphaComponent(0.3)
        platform.strokeColor = getTowerColor()
        platform.lineWidth = 2
        platform.zPosition = -1
        sprite.addChild(platform)
        
        // Add energy rings for higher tier towers
        if towerType.category == .ultimate {
            let energyRing = SKShapeNode(circleOfRadius: getTowerSize().width * 0.9)
            energyRing.strokeColor = SKColor.cyan
            energyRing.lineWidth = 1
            energyRing.glowWidth = 2
            energyRing.zPosition = -2
            
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4)
            energyRing.run(SKAction.repeatForever(rotate))
            sprite.addChild(energyRing)
        }
    }
    
    private func createRangeIndicator() {
        rangeIndicator = SKShapeNode(circleOfRadius: CGFloat(currentStats.range))
        rangeIndicator?.fillColor = .clear
        rangeIndicator?.strokeColor = getTowerColor().withAlphaComponent(0.3)
        rangeIndicator?.lineWidth = 1
        rangeIndicator?.isHidden = true
        rangeIndicator?.zPosition = 50
        sprite.addChild(rangeIndicator!)
    }
    
    private func createSpecialEffects() {
        switch towerType {
        case .gravityWellProjector:
            createGravityWellEffect()
        case .plasmaArcNode:
            createPlasmaArcEffect()
        case .solarLanceArray:
            createSolarLanceEffect()
        case .empShockTower:
            createEMPChargeEffect()
        default:
            break
        }
    }
    
    // MARK: - Special Visual Effects
    private func createGravityWellEffect() {
        // Create swirling particle effect
        if let emitter = SKEmitterNode(fileNamed: "GravityWell") {
            emitter.position = .zero
            emitter.zPosition = 150
            sprite.addChild(emitter)
        } else {
            // Fallback: Create programmatic swirl
            let swirl = SKShapeNode(circleOfRadius: CGFloat(currentStats.range * 0.8))
            swirl.strokeColor = SKColor.purple.withAlphaComponent(0.5)
            swirl.lineWidth = 2
            swirl.glowWidth = 4
            
            let rotate = SKAction.rotate(byAngle: -.pi * 2, duration: 2)
            let scale = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 1),
                SKAction.scale(to: 0.8, duration: 1)
            ])
            
            swirl.run(SKAction.repeatForever(SKAction.group([rotate, scale])))
            sprite.addChild(swirl)
        }
    }
    
    private func createPlasmaArcEffect() {
        // Create electric arc particles
        for _ in 0..<3 {
            let arc = SKShapeNode()
            let path = CGMutablePath()
            
            // Create lightning bolt path
            path.move(to: .zero)
            for i in 1...5 {
                let x = CGFloat.random(in: -10...10)
                let y = CGFloat(i) * 10
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            arc.path = path
            arc.strokeColor = SKColor.cyan
            arc.lineWidth = 1
            arc.glowWidth = 3
            arc.alpha = 0
            
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 1, duration: 0.1),
                SKAction.fadeAlpha(to: 0, duration: 0.3),
                SKAction.wait(forDuration: Double.random(in: 0.5...1.5))
            ])
            
            arc.run(SKAction.repeatForever(flash))
            sprite.addChild(arc)
        }
    }
    
    private func createSolarLanceEffect() {
        // Create rotating prism effect
        let prism = SKShapeNode(rectOf: CGSize(width: 20, height: 60))
        prism.fillColor = SKColor.yellow.withAlphaComponent(0.3)
        prism.strokeColor = SKColor.yellow
        prism.lineWidth = 2
        prism.glowWidth = 5
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 8)
        prism.run(SKAction.repeatForever(rotate))
        sprite.addChild(prism)
        
        // Add lens flare
        let flare = SKSpriteNode(color: .white, size: CGSize(width: 80, height: 2))
        flare.alpha = 0.5
        flare.blendMode = .add
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 2),
            SKAction.scale(to: 1.0, duration: 2)
        ])
        flare.run(SKAction.repeatForever(pulse))
        sprite.addChild(flare)
    }
    
    private func createEMPChargeEffect() {
        // Create charging capacitor effect
        let chargeRing = SKShapeNode(circleOfRadius: 30)
        chargeRing.strokeColor = SKColor.yellow
        chargeRing.lineWidth = 3
        chargeRing.alpha = 0
        
        let charge = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 0),
                SKAction.fadeAlpha(to: 1, duration: 0)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 1.5),
                SKAction.fadeAlpha(to: 0, duration: 1.5)
            ])
        ])
        
        chargeRing.run(SKAction.repeatForever(SKAction.sequence([
            charge,
            SKAction.wait(forDuration: 1.0 / currentStats.fireRate)
        ])))
        
        sprite.addChild(chargeRing)
    }
    
    // MARK: - Upgrade System
    func upgradeTo(tier: Int) {
        guard tier > currentTier && tier <= 5 else { return }
        guard tier - 1 < config.upgrades.count else { return }
        
        let upgrade = config.upgrades[tier - 2] // Tier 2 is at index 0
        
        // Apply stat modifiers
        if let mods = upgrade.statModifiers {
            applyStatModifiers(mods)
        }
        
        // Add status effect
        if let status = upgrade.addsStatus {
            let component = StatusEffectComponent()
            component.effect = status
            statusApplicator = component
            addComponent(component)
        }
        
        // Add ability
        if let abilityData = upgrade.addsAbility {
            let component = TowerAbilityComponent()
            component.ability = abilityData
            ability = component
            addComponent(component)
        }
        
        currentTier = tier
        
        // Update visuals
        updateVisualsForTier()
        
        // Play upgrade effect
        playUpgradeAnimation()
    }
    
    private func applyStatModifiers(_ mods: TowerStatModifiers) {
        if let dmgPercent = mods.damagePercent {
            currentStats.damage *= (1 + dmgPercent / 100)
        }
        if let dmgFlat = mods.damageFlat {
            currentStats.damage += dmgFlat
        }
        if let ratePercent = mods.fireRatePercent {
            currentStats.fireRate *= (1 + ratePercent / 100)
        }
        if let rateFlat = mods.fireRateFlat {
            currentStats.fireRate += rateFlat
        }
        if let rangePercent = mods.rangePercent {
            currentStats.range *= (1 + rangePercent / 100)
        }
        if let rangeFlat = mods.rangeFlat {
            currentStats.range += rangeFlat
        }
        if let critFlat = mods.critChanceFlat {
            currentStats.critChance += critFlat
        }
        if let critMultFlat = mods.critMultiplierFlat {
            currentStats.critMultiplier += critMultFlat
        }
        if let pierceFlat = mods.armorPierceFlat {
            currentStats.armorPierce += pierceFlat
        }
        
        // Update components
        weapon.damage = currentStats.damage
        weapon.fireRate = currentStats.fireRate
        weapon.critChance = currentStats.critChance
        weapon.critMultiplier = currentStats.critMultiplier
        weapon.armorPierce = currentStats.armorPierce
        targeting.range = currentStats.range
        
        // Update range indicator
        updateRangeIndicator()
    }
    
    private func updateVisualsForTier() {
        // Update sprite texture
        let textureName = "\(towerType.rawValue)_t\(currentTier)"
        if let texture = SKTexture(imageNamed: textureName) {
            sprite.texture = texture
        }
        
        // Scale up slightly
        let scale = 1.0 + Float(currentTier - 1) * 0.1
        sprite.setScale(CGFloat(scale))
        
        // Add tier indicators
        updateTierIndicators()
        
        // Add tier-specific effects
        addTierEffects()
    }
    
    private func updateTierIndicators() {
        // Remove old indicators
        tierIndicators.forEach { $0.removeFromParent() }
        tierIndicators.removeAll()
        
        // Add new indicators
        for i in 0..<currentTier {
            let indicator = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 4))
            indicator.position = CGPoint(x: -15 + i * 8, y: -30)
            indicator.zPosition = 200
            sprite.addChild(indicator)
            tierIndicators.append(indicator)
        }
    }
    
    private func addTierEffects() {
        switch currentTier {
        case 3:
            // Add glow effect
            sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.run { self.sprite.alpha = 0.8 },
                SKAction.wait(forDuration: 0.5),
                SKAction.run { self.sprite.alpha = 1.0 },
                SKAction.wait(forDuration: 0.5)
            ])))
            
        case 4:
            // Add particle trail
            if let particles = SKEmitterNode(fileNamed: "TowerAura") {
                particles.position = .zero
                particles.zPosition = 90
                sprite.addChild(particles)
            }
            
        case 5:
            // Add rotating energy field
            let field = SKShapeNode(circleOfRadius: getTowerSize().width)
            field.strokeColor = getTowerColor()
            field.lineWidth = 2
            field.glowWidth = 5
            field.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2)))
            sprite.addChild(field)
            
        default:
            break
        }
    }
    
    private func playUpgradeAnimation() {
        // Flash effect
        let flash = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
        flash.alpha = 0
        flash.zPosition = 300
        flash.blendMode = .add
        sprite.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1, duration: 0.1),
            SKAction.group([
                SKAction.scale(to: 2, duration: 0.3),
                SKAction.fadeAlpha(to: 0, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // Particle burst
        if let burst = SKEmitterNode(fileNamed: "UpgradeBurst") {
            burst.position = .zero
            burst.zPosition = 250
            sprite.addChild(burst)
            
            burst.run(SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    // MARK: - Helper Methods
    private func getTowerColor() -> SKColor {
        return config.damageType.color
    }
    
    private func getTowerSize() -> CGSize {
        switch towerType.category {
        case .damage:
            return CGSize(width: 40, height: 40)
        case .support:
            return CGSize(width: 35, height: 35)
        case .ultimate:
            return CGSize(width: 50, height: 50)
        }
    }
    
    private func getTargetingPriority() -> TargetingPriority {
        switch towerType {
        case .laserTurret, .plasmaArcNode:
            return .nearest
        case .railgunEmplacement, .empShockTower:
            return .strongest
        case .nanobotSwarmDispenser, .cryoFoamProjector:
            return .weakest
        case .missilePDBattery:
            return .flying
        case .gravityWellProjector:
            return .mostClustered
        default:
            return .first
        }
    }
    
    private func canTargetAir() -> Bool {
        switch towerType {
        case .missilePDBattery, .plasmaArcNode, .empShockTower:
            return true
        default:
            return currentTier >= 3 // Most towers can target air at tier 3+
        }
    }
    
    private func createDroneStats() -> DroneStats {
        return DroneStats(
            damage: 12,
            range: 6,
            speed: 150,
            hp: 150
        )
    }
    
    private func applyTierOneEffects() {
        // Apply any tier 1 special effects
        switch towerType {
        case .laserTurret:
            // +10% damage vs shields passive
            weapon.bonusVsShields = 0.1
            
        default:
            break
        }
    }
    
    private func updateRangeIndicator() {
        rangeIndicator?.removeFromParent()
        createRangeIndicator()
    }
    
    private func updateSpritePosition() {
        sprite.position = CGPoint(
            x: CGFloat(transform.position.x),
            y: CGFloat(transform.position.y)
        )
    }
    
    // MARK: - Public Methods
    func showRangeIndicator(_ show: Bool) {
        rangeIndicator?.isHidden = !show
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        showRangeIndicator(selected)
        
        if selected {
            sprite.run(SKAction.scale(to: 1.1, duration: 0.1))
        } else {
            sprite.run(SKAction.scale(to: CGFloat(1.0 + Float(currentTier - 1) * 0.1), duration: 0.1))
        }
    }
    
    func activateAbility() {
        ability?.activate()
    }
    
    func setPowerAvailable(_ available: Bool) {
        powerAvailable = available
        sprite.alpha = available ? 1.0 : 0.5
        
        // Disable weapon if no power
        weapon.isEnabled = available
    }
    
    func getSellValue() -> Int {
        var totalCost = config.costCr
        
        for i in 0..<(currentTier - 1) {
            if i < config.upgrades.count {
                totalCost += config.upgrades[i].cost
            }
        }
        
        return Int(Float(totalCost) * 0.8) // 80% refund
    }
}

// MARK: - Support Structures
struct DroneStats {
    let damage: Float
    let range: Float
    let speed: Float
    let hp: Float
}

enum TargetingPriority {
    case nearest
    case furthest
    case strongest
    case weakest
    case first
    case last
    case flying
    case mostClustered
    case leastClustered
}