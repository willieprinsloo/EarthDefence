import Foundation
import SpriteKit
import simd
import QuartzCore

class Tower: BaseEntity {
    // Tower properties
    var towerType: TowerType
    var level: Int = 1
    var baseCost: Int
    
    // Components
    private(set) var transform: TransformComponent!
    private(set) var targeting: TargetingComponent!
    private(set) var weapon: WeaponComponent!
    private(set) var sprite: SKSpriteNode?
    
    // Tower stats
    struct TowerStats {
        var damage: Float
        var fireRate: Float  // Shots per second
        var range: Float
        var specialEffect: SpecialEffect?
    }
    
    enum TowerType {
        case machineGun
        case laser
        case gravity
        case emp
        case nanobot
    }
    
    enum SpecialEffect {
        case slow(multiplier: Float, duration: TimeInterval)
        case stun(duration: TimeInterval)
        case dot(damage: Float, duration: TimeInterval)
        case chain(bounces: Int, damageReduction: Float)
    }
    
    private var baseStats: TowerStats
    private var currentStats: TowerStats
    
    init(type: TowerType, position: SIMD2<Float>) {
        self.towerType = type
        self.baseCost = Tower.getCost(for: type)
        
        // Initialize base stats
        self.baseStats = Tower.getBaseStats(for: type)
        self.currentStats = baseStats
        
        super.init()
        
        // Add components
        setupComponents(at: position)
        
        // Create visual representation
        createSprite()
    }
    
    private func setupComponents(at position: SIMD2<Float>) {
        // Transform
        transform = TransformComponent()
        transform.position = position
        addComponent(transform)
        
        // Targeting
        targeting = TargetingComponent()
        targeting.range = currentStats.range
        targeting.targetingMode = getDefaultTargetingMode()
        addComponent(targeting)
        
        // Weapon
        weapon = WeaponComponent()
        weapon.damage = currentStats.damage
        weapon.fireRate = currentStats.fireRate
        weapon.projectileType = getProjectileType()
        addComponent(weapon)
    }
    
    private func createSprite() {
        let color: SKColor
        let size: CGSize
        
        switch towerType {
        case .machineGun:
            color = .orange
            size = CGSize(width: 35, height: 35)
        case .laser:
            color = .cyan
            size = CGSize(width: 40, height: 40)
        case .gravity:
            color = .purple
            size = CGSize(width: 45, height: 45)
        case .emp:
            color = .yellow
            size = CGSize(width: 42, height: 42)
        case .nanobot:
            color = .green
            size = CGSize(width: 38, height: 38)
        }
        
        sprite = SKSpriteNode(color: color, size: size)
        sprite?.name = "tower_\(id.uuidString)"
        
        // Add base
        let base = SKShapeNode(circleOfRadius: size.width * 0.6)
        base.fillColor = color.withAlphaComponent(0.3)
        base.strokeColor = color
        base.lineWidth = 2
        sprite?.addChild(base)
        
        // Add range indicator (initially hidden)
        let rangeIndicator = SKShapeNode(circleOfRadius: CGFloat(currentStats.range))
        rangeIndicator.fillColor = .clear
        rangeIndicator.strokeColor = color.withAlphaComponent(0.3)
        rangeIndicator.lineWidth = 1
        rangeIndicator.name = "rangeIndicator"
        rangeIndicator.isHidden = true
        sprite?.addChild(rangeIndicator)
    }
    
    func upgrade() {
        guard level < 3 else { return }
        
        level += 1
        
        // Apply upgrade multipliers
        let upgradeMultiplier: Float = 1.25
        currentStats.damage *= upgradeMultiplier
        currentStats.range *= 1.1
        
        if level == 3 {
            // Level 3 special bonuses
            switch towerType {
            case .machineGun:
                currentStats.fireRate *= 1.5  // 50% faster at max level (18 shots/sec)
            case .laser:
                currentStats.fireRate *= 1.5
            case .gravity:
                currentStats.range *= 1.2
            case .emp:
                if case .stun(let duration) = currentStats.specialEffect {
                    currentStats.specialEffect = .stun(duration: duration * 1.5)
                }
            case .nanobot:
                if case .dot(let damage, let duration) = currentStats.specialEffect {
                    currentStats.specialEffect = .dot(damage: damage * 1.5, duration: duration)
                }
            }
        }
        
        // Update components
        targeting.range = currentStats.range
        weapon.damage = currentStats.damage
        weapon.fireRate = currentStats.fireRate
        
        // Update visuals
        updateVisuals()
    }
    
    private func updateVisuals() {
        // Scale up sprite
        let scale = 1.0 + Float(level - 1) * 0.15
        sprite?.setScale(CGFloat(scale))
        
        // Update range indicator
        if let rangeIndicator = sprite?.childNode(withName: "rangeIndicator") as? SKShapeNode {
            rangeIndicator.path = CGPath(ellipseIn: CGRect(
                x: -CGFloat(currentStats.range),
                y: -CGFloat(currentStats.range),
                width: CGFloat(currentStats.range * 2),
                height: CGFloat(currentStats.range * 2)
            ), transform: nil)
        }
        
        // Add level indicators
        addLevelIndicators()
    }
    
    private func addLevelIndicators() {
        // Remove old indicators
        sprite?.children
            .filter { $0.name == "levelIndicator" }
            .forEach { $0.removeFromParent() }
        
        // Add new indicators
        for i in 0..<level {
            let indicator = SKShapeNode(circleOfRadius: 3)
            indicator.fillColor = .white
            indicator.strokeColor = .clear
            indicator.name = "levelIndicator"
            indicator.position = CGPoint(
                x: -10 + i * 10,
                y: -25
            )
            sprite?.addChild(indicator)
        }
    }
    
    func showRangeIndicator(_ show: Bool) {
        sprite?.childNode(withName: "rangeIndicator")?.isHidden = !show
    }
    
    func sell() -> Int {
        // Return 80% of total investment
        let totalCost = baseCost + getUpgradeCosts()
        return Int(Float(totalCost) * 0.8)
    }
    
    private func getUpgradeCosts() -> Int {
        var cost = 0
        for i in 1..<level {
            cost += Tower.getUpgradeCost(for: towerType, level: i)
        }
        return cost
    }
    
    // MARK: - Static Methods
    
    static func getCost(for type: TowerType) -> Int {
        switch type {
        case .machineGun: return 75  // Cheaper than laser
        case .laser: return 100
        case .gravity: return 140
        case .emp: return 160
        case .nanobot: return 120
        }
    }
    
    static func getUpgradeCost(for type: TowerType, level: Int) -> Int {
        let baseCost = getCost(for: type)
        switch level {
        case 1: return Int(Float(baseCost) * 1.2)
        case 2: return Int(Float(baseCost) * 1.8)
        default: return 99999
        }
    }
    
    static func getBaseStats(for type: TowerType) -> TowerStats {
        switch type {
        case .machineGun:
            return TowerStats(
                damage: 1,  // Minimal damage per shot (much weaker than cannon)
                fireRate: 5,  // EXTREMELY fast fire rate - true machine gun
                range: 60,  // Slightly shorter range
                specialEffect: nil
            )
        case .laser:
            return TowerStats(
                damage: 15,
                fireRate: 1.0,
                range: 150,
                specialEffect: nil
            )
            
        case .gravity:
            return TowerStats(
                damage: 0,
                fireRate: 0,  // Continuous effect
                range: 120,
                specialEffect: .slow(multiplier: 0.35, duration: 0.75)
            )
            
        case .emp:
            return TowerStats(
                damage: 10,
                fireRate: 0.25,  // Every 4 seconds
                range: 100,
                specialEffect: .stun(duration: 0.6)
            )
            
        case .nanobot:
            return TowerStats(
                damage: 8,
                fireRate: 0.8,
                range: 130,
                specialEffect: .dot(damage: 8, duration: 3.0)
            )
        }
    }
    
    private func getDefaultTargetingMode() -> TargetingComponent.TargetingMode {
        switch towerType {
        case .machineGun: return .weakest  // Target weak enemies first
        case .laser: return .nearest
        case .gravity: return .first
        case .emp: return .strongest
        case .nanobot: return .weakest
        }
    }
    
    private func getProjectileType() -> WeaponComponent.ProjectileType {
        switch towerType {
        case .machineGun: return .bullet
        case .laser: return .beam
        case .gravity: return .aura
        case .emp: return .pulse
        case .nanobot: return .swarm
        }
    }
}

// MARK: - Weapon Component
class WeaponComponent: BaseComponent {
    var damage: Float = 10
    var fireRate: Float = 1.0  // Shots per second
    var projectileType: ProjectileType = .projectile
    
    private var lastFireTime: TimeInterval = 0
    private var targeting: TargetingComponent?
    
    enum ProjectileType {
        case bullet     // Fast small bullets for machine gun
        case projectile  // Standard projectile
        case beam       // Instant hit beam
        case aura       // Area effect
        case pulse      // Radial pulse
        case swarm      // Multiple small projectiles
    }
    
    override func awake() {
        super.awake()
        targeting = entity?.getComponent(TargetingComponent.self)
    }
    
    override func update(deltaTime: TimeInterval) {
        guard let targeting = targeting,
              let target = targeting.getPrimaryTarget() else { return }
        
        let currentTime = CACurrentMediaTime()
        let timeSinceLastFire = currentTime - lastFireTime
        let fireInterval = 1.0 / Double(fireRate)
        
        if timeSinceLastFire >= fireInterval {
            fire(at: target)
            lastFireTime = currentTime
        }
    }
    
    private func fire(at target: Entity) {
        // Create projectile or apply instant damage based on type
        switch projectileType {
        case .bullet:
            // Fast small projectiles for machine gun
            createBulletProjectile(towards: target)
            
        case .beam:
            // Instant damage
            applyInstantDamage(to: target)
            createBeamEffect(to: target)
            
        case .projectile:
            createProjectile(towards: target)
            
        case .aura:
            applyAuraEffect()
            
        case .pulse:
            createPulseEffect()
            
        case .swarm:
            createSwarmProjectiles(towards: target)
        }
    }
    
    private func applyInstantDamage(to target: Entity) {
        if let health = target.getComponent(HealthComponent.self) {
            health.takeDamage(damage, type: .energy)
        }
    }
    
    private func createBeamEffect(to target: Entity) {
        // Visual beam effect
        NotificationCenter.default.post(
            name: .createBeamEffect,
            object: nil,
            userInfo: [
                "source": entity as Any,
                "target": target
            ]
        )
    }
    
    private func createBulletProjectile(towards target: Entity) {
        // Create small fast bullet for machine gun
        NotificationCenter.default.post(
            name: .createProjectile,
            object: nil,
            userInfo: [
                "source": entity as Any,
                "target": target,
                "damage": damage,
                "type": ProjectileType.bullet,
                "speed": 500.0  // Faster than normal projectiles
            ]
        )
    }
    
    private func createProjectile(towards target: Entity) {
        // Create projectile entity
        NotificationCenter.default.post(
            name: .createProjectile,
            object: nil,
            userInfo: [
                "source": entity as Any,
                "target": target,
                "damage": damage,
                "type": projectileType
            ]
        )
    }
    
    private func applyAuraEffect() {
        // Apply effect to all enemies in range
        if let targeting = targeting {
            for target in targeting.currentTargets {
                if let movement = target.getComponent(MovementComponent.self) {
                    movement.applySlow(multiplier: 0.35, duration: 0.75)
                }
            }
        }
    }
    
    private func createPulseEffect() {
        // Create radial pulse
        NotificationCenter.default.post(
            name: .createPulseEffect,
            object: nil,
            userInfo: [
                "source": entity as Any,
                "damage": damage,
                "radius": targeting?.range ?? 100
            ]
        )
    }
    
    private func createSwarmProjectiles(towards target: Entity) {
        // Create multiple small projectiles
        for _ in 0..<3 {
            createProjectile(towards: target)
        }
    }
}

// Notification names
extension Notification.Name {
    static let createBeamEffect = Notification.Name("CreateBeamEffect")
    static let createProjectile = Notification.Name("CreateProjectile")
    static let createPulseEffect = Notification.Name("CreatePulseEffect")
}