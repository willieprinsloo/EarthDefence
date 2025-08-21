import Foundation
import SpriteKit
import simd

class Enemy: BaseEntity {
    // Enemy properties
    var enemyType: EnemyType
    var salvageValue: Int
    var coreDamage: Int
    
    // Components
    private(set) var transform: TransformComponent!
    private(set) var health: HealthComponent!
    private(set) var movement: MovementComponent!
    private(set) var pathFollow: PathFollowComponent!
    private(set) var sprite: SKSpriteNode?
    
    enum EnemyType {
        // Original types
        case swarmer
        case robot
        case drone
        case bioTitan
        
        // New enemy types
        case fast       // Very fast, low health
        case armored    // High armor, slow
        case shielded   // Has regenerating shields
        case swarm      // Spawns more enemies on death
        case regenerator // Heals over time
        case boss       // Large, tough, special abilities
    }
    
    struct EnemyStats {
        var health: Float
        var speed: Float
        var armor: Float
        var resistance: Float
        var salvageValue: Int
        var coreDamage: Int
        var special: SpecialAbility?
    }
    
    enum SpecialAbility {
        case packBonus(speedMultiplier: Float, range: Float)
        case shielded(amount: Float)
        case splitOnDeath(spawnCount: Int, spawnType: EnemyType)
        case regeneration(amount: Float, interval: TimeInterval)
    }
    
    private var stats: EnemyStats
    private var specialAbilityTimer: TimeInterval = 0
    
    init(type: EnemyType, path: [SIMD2<Float>], waveMultiplier: Float = 1.0) {
        self.enemyType = type
        self.stats = Enemy.getBaseStats(for: type)
        
        // Apply wave scaling
        self.stats.health *= waveMultiplier
        self.stats.speed *= (1.0 + (waveMultiplier - 1.0) * 0.2)  // Speed scales slower
        
        self.salvageValue = stats.salvageValue
        self.coreDamage = stats.coreDamage
        
        super.init()
        
        // Setup components
        setupComponents(with: path)
        
        // Create visual representation
        createSprite()
        
        // Setup special abilities
        setupSpecialAbility()
    }
    
    private func setupComponents(with path: [SIMD2<Float>]) {
        // Transform
        transform = TransformComponent()
        if let startPosition = path.first {
            transform.position = startPosition
        }
        addComponent(transform)
        
        // Health
        health = HealthComponent(
            health: stats.health,
            armor: stats.armor,
            resistance: stats.resistance
        )
        health.delegate = self
        addComponent(health)
        
        // Movement
        movement = MovementComponent()
        movement.maxSpeed = stats.speed
        addComponent(movement)
        
        // Path following
        pathFollow = PathFollowComponent()
        pathFollow.setPath(path)
        pathFollow.moveSpeed = stats.speed
        pathFollow.onPathComplete = { [weak self] in
            self?.reachCore()
        }
        addComponent(pathFollow)
        
        // Special case for shielded enemies
        if case .shielded(let amount) = stats.special {
            health.maxShields = amount
            health.shields = amount
        }
    }
    
    private func createSprite() {
        let color: SKColor
        let size: CGSize
        let shape: SKShapeNode
        
        switch enemyType {
        case .swarmer:
            color = .green
            size = CGSize(width: 20, height: 20)
            shape = SKShapeNode(ellipseOf: size)
            
        case .robot:
            color = .orange
            size = CGSize(width: 30, height: 30)
            shape = SKShapeNode(rectOf: size)
            
        case .drone:
            color = .cyan
            size = CGSize(width: 25, height: 25)
            shape = SKShapeNode(circleOfRadius: 12.5)
            
        case .bioTitan:
            color = .purple
            size = CGSize(width: 50, height: 50)
            shape = SKShapeNode(circleOfRadius: 25)
            
        // New enemy types
        case .fast:
            color = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0) // Yellow
            size = CGSize(width: 15, height: 15)
            shape = SKShapeNode(circleOfRadius: 7.5)
            // Add speed trails
            let trail = SKShapeNode(rectOf: CGSize(width: 10, height: 2))
            trail.fillColor = color.withAlphaComponent(0.5)
            trail.strokeColor = .clear
            trail.position = CGPoint(x: -8, y: 0)
            shape.addChild(trail)
            
        case .armored:
            color = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Dark gray
            size = CGSize(width: 35, height: 35)
            shape = SKShapeNode(rectOf: size, cornerRadius: 5)
            // Add armor plates visual
            let plate = SKShapeNode(rectOf: CGSize(width: 25, height: 25))
            plate.fillColor = .clear
            plate.strokeColor = color.withAlphaComponent(0.7)
            plate.lineWidth = 2
            shape.addChild(plate)
            
        case .shielded:
            color = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0) // Light blue
            size = CGSize(width: 28, height: 28)
            shape = SKShapeNode(circleOfRadius: 14)
            
        case .swarm:
            color = SKColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 1.0) // Magenta
            size = CGSize(width: 22, height: 22)
            shape = SKShapeNode(ellipseOf: size)
            // Add mini swarmers visual
            for i in 0..<3 {
                let mini = SKShapeNode(circleOfRadius: 3)
                mini.fillColor = color.withAlphaComponent(0.5)
                mini.strokeColor = .clear
                let angle = CGFloat(i) * (CGFloat.pi * 2 / 3)
                mini.position = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
                shape.addChild(mini)
            }
            
        case .regenerator:
            color = SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1.0) // Bright green
            size = CGSize(width: 26, height: 26)
            shape = SKShapeNode(circleOfRadius: 13)
            // Add healing aura
            let aura = SKShapeNode(circleOfRadius: 18)
            aura.fillColor = .clear
            aura.strokeColor = color.withAlphaComponent(0.3)
            aura.lineWidth = 2
            aura.glowWidth = 4
            shape.addChild(aura)
            
        case .boss:
            color = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0) // Red
            size = CGSize(width: 60, height: 60)
            shape = SKShapeNode(circleOfRadius: 30)
            // Add boss crown/spikes
            for i in 0..<8 {
                let spike = SKShapeNode(rectOf: CGSize(width: 4, height: 12))
                spike.fillColor = color.withAlphaComponent(0.8)
                spike.strokeColor = .clear
                let angle = CGFloat(i) * (CGFloat.pi * 2 / 8)
                spike.position = CGPoint(x: cos(angle) * 25, y: sin(angle) * 25)
                spike.zRotation = angle
                shape.addChild(spike)
            }
        }
        
        shape.fillColor = color
        shape.strokeColor = color.withAlphaComponent(0.8)
        shape.lineWidth = 2
        
        sprite = SKSpriteNode(texture: nil, color: .clear, size: size)
        sprite?.name = "enemy_\(id.uuidString)"
        sprite?.addChild(shape)
        
        // Add health bar
        addHealthBar()
        
        // Add shield indicator if applicable
        if case .shielded = stats.special {
            addShieldIndicator()
        }
    }
    
    private func addHealthBar() {
        let barBackground = SKShapeNode(rectOf: CGSize(width: 30, height: 4))
        barBackground.fillColor = .red
        barBackground.strokeColor = .clear
        barBackground.position = CGPoint(x: 0, y: 20)
        barBackground.name = "healthBarBg"
        sprite?.addChild(barBackground)
        
        let barFill = SKShapeNode(rectOf: CGSize(width: 30, height: 4))
        barFill.fillColor = .green
        barFill.strokeColor = .clear
        barFill.position = CGPoint(x: 0, y: 20)
        barFill.name = "healthBarFill"
        sprite?.addChild(barFill)
    }
    
    private func addShieldIndicator() {
        let shield = SKShapeNode(circleOfRadius: 20)
        shield.fillColor = .clear
        shield.strokeColor = .cyan
        shield.lineWidth = 2
        shield.alpha = 0.5
        shield.name = "shieldIndicator"
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        shield.run(SKAction.repeatForever(pulse))
        
        sprite?.addChild(shield)
    }
    
    private func setupSpecialAbility() {
        guard let special = stats.special else { return }
        
        switch special {
        case .packBonus:
            // Check for nearby allies periodically
            break
            
        case .regeneration(_, let interval):
            // Setup regeneration timer
            specialAbilityTimer = interval
            
        default:
            break
        }
    }
    
    func update(deltaTime: TimeInterval) {
        // Update special abilities
        updateSpecialAbilities(deltaTime: deltaTime)
        
        // Update health bar
        updateHealthBar()
        
        // Update shield indicator
        updateShieldIndicator()
    }
    
    private func updateSpecialAbilities(deltaTime: TimeInterval) {
        guard let special = stats.special else { return }
        
        switch special {
        case .packBonus(let speedMultiplier, let range):
            updatePackBonus(speedMultiplier: speedMultiplier, range: range)
            
        case .regeneration(let amount, let interval):
            specialAbilityTimer -= deltaTime
            if specialAbilityTimer <= 0 {
                health.heal(amount)
                specialAbilityTimer = interval
            }
            
        default:
            break
        }
    }
    
    private func updatePackBonus(speedMultiplier: Float, range: Float) {
        // Count nearby swarmers
        let nearbyCount = 0
        
        // This would query the world for nearby enemies
        // For now, simplified implementation
        
        let bonus = Float(nearbyCount / 5) * speedMultiplier
        movement.speedMultiplier = 1.0 + bonus
    }
    
    private func updateHealthBar() {
        guard let healthBarFill = sprite?.childNode(withName: "healthBarFill") as? SKShapeNode else { return }
        
        let healthPercent = health.healthPercentage
        let fullWidth: CGFloat = 30
        let currentWidth = fullWidth * CGFloat(healthPercent)
        
        healthBarFill.path = CGPath(rect: CGRect(
            x: -fullWidth/2,
            y: -2,
            width: currentWidth,
            height: 4
        ), transform: nil)
        
        // Change color based on health
        if healthPercent > 0.6 {
            healthBarFill.fillColor = .green
        } else if healthPercent > 0.3 {
            healthBarFill.fillColor = .yellow
        } else {
            healthBarFill.fillColor = .red
        }
    }
    
    private func updateShieldIndicator() {
        guard let shieldIndicator = sprite?.childNode(withName: "shieldIndicator") else { return }
        
        if health.shields > 0 {
            shieldIndicator.isHidden = false
            shieldIndicator.alpha = CGFloat(0.3 + 0.2 * (health.shields / health.maxShields))
        } else {
            shieldIndicator.isHidden = true
        }
    }
    
    private func reachCore() {
        // Deal damage to station
        NotificationCenter.default.post(
            name: .enemyReachedCore,
            object: nil,
            userInfo: [
                "damage": coreDamage,
                "enemy": self
            ]
        )
        
        // Remove enemy
        die()
    }
    
    private func die() {
        // Award salvage
        NotificationCenter.default.post(
            name: .enemyKilled,
            object: nil,
            userInfo: [
                "salvage": salvageValue,
                "enemy": self
            ]
        )
        
        // Handle death special abilities
        if case .splitOnDeath(let count, let spawnType) = stats.special {
            spawnSplitEnemies(count: count, type: spawnType)
        }
        
        // Create death effect
        createDeathEffect()
        
        // Remove from scene
        sprite?.removeFromParent()
        isActive = false
    }
    
    private func spawnSplitEnemies(count: Int, type: EnemyType) {
        for i in 0..<count {
            let angle = Float(i) * (2.0 * .pi / Float(count))
            let offset = SIMD2<Float>(cos(angle), sin(angle)) * 30
            let spawnPosition = transform.position + offset
            
            // Create spawn notification
            NotificationCenter.default.post(
                name: .spawnEnemy,
                object: nil,
                userInfo: [
                    "type": type,
                    "position": spawnPosition,
                    "pathProgress": pathFollow.progress
                ]
            )
        }
    }
    
    private func createDeathEffect() {
        let effectType: String
        switch enemyType {
        case .swarmer:
            effectType = "gooSplash"
        case .robot:
            effectType = "metalDebris"
        case .drone:
            effectType = "energyBurst"
        case .bioTitan:
            effectType = "massiveExplosion"
        case .fast:
            effectType = "speedTrail"
        case .armored:
            effectType = "armorShatter"
        case .shielded:
            effectType = "shieldCollapse"
        case .swarm:
            effectType = "swarmBurst"
        case .regenerator:
            effectType = "healingPulse"
        case .boss:
            effectType = "bossExplosion"
        }
        
        NotificationCenter.default.post(
            name: .createDeathEffect,
            object: nil,
            userInfo: [
                "type": effectType,
                "position": transform.position
            ]
        )
    }
    
    // MARK: - Static Methods
    
    static func getBaseStats(for type: EnemyType) -> EnemyStats {
        switch type {
        case .swarmer:
            return EnemyStats(
                health: 40,
                speed: 120,
                armor: 0,
                resistance: 0,
                salvageValue: 6,
                coreDamage: 1,
                special: .packBonus(speedMultiplier: 0.05, range: 100)
            )
            
        case .robot:
            return EnemyStats(
                health: 150,
                speed: 60,
                armor: 5,
                resistance: 0.3,
                salvageValue: 12,
                coreDamage: 2,
                special: nil
            )
            
        case .drone:
            return EnemyStats(
                health: 80,
                speed: 100,
                armor: 0,
                resistance: 0,
                salvageValue: 10,
                coreDamage: 1,
                special: .shielded(amount: 60)
            )
            
        case .bioTitan:
            return EnemyStats(
                health: 1200,
                speed: 40,
                armor: 10,
                resistance: 0.2,
                salvageValue: 80,
                coreDamage: 3,
                special: .splitOnDeath(spawnCount: 6, spawnType: .swarmer)
            )
            
        // New enemy types
        case .fast:
            return EnemyStats(
                health: 30,      // Very low health
                speed: 200,      // Very fast
                armor: 0,
                resistance: 0,
                salvageValue: 8,
                coreDamage: 1,
                special: nil
            )
            
        case .armored:
            return EnemyStats(
                health: 200,
                speed: 40,       // Very slow
                armor: 15,       // High armor
                resistance: 0.6, // High resistance
                salvageValue: 20,
                coreDamage: 2,
                special: nil
            )
            
        case .shielded:
            return EnemyStats(
                health: 100,
                speed: 80,
                armor: 2,
                resistance: 0.2,
                salvageValue: 15,
                coreDamage: 1,
                special: .shielded(amount: 50)  // Has shields
            )
            
        case .swarm:
            return EnemyStats(
                health: 60,
                speed: 100,
                armor: 0,
                resistance: 0,
                salvageValue: 5,
                coreDamage: 1,
                special: .splitOnDeath(spawnCount: 4, spawnType: .swarmer)
            )
            
        case .regenerator:
            return EnemyStats(
                health: 120,
                speed: 70,
                armor: 3,
                resistance: 0.3,
                salvageValue: 18,
                coreDamage: 2,
                special: .regeneration(amount: 5, interval: 1.0)  // Heals 5 HP per second
            )
            
        case .boss:
            return EnemyStats(
                health: 1000,    // Very high health
                speed: 30,       // Slow but steady
                armor: 20,       // Heavy armor
                resistance: 0.7, // High resistance
                salvageValue: 100,
                coreDamage: 5,   // Devastating if reaches core
                special: .regeneration(amount: 10, interval: 2.0)  // Also regenerates
            )
        }
    }
}

// MARK: - Health Delegate
extension Enemy: HealthDelegate {
    func healthDidChange(current: Float, max: Float) {
        // Update health bar when health changes
        updateHealthBar()
    }
    
    func entityDidDie() {
        die()
    }
}

// Notification names
extension Notification.Name {
    static let enemyReachedCore = Notification.Name("EnemyReachedCore")
    static let enemyKilled = Notification.Name("EnemyKilled")
    static let spawnEnemy = Notification.Name("SpawnEnemy")
    static let createDeathEffect = Notification.Name("CreateDeathEffect")
}