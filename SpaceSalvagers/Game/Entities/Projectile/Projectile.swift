import Foundation
import SpriteKit
import simd

class Projectile: BaseEntity, Hashable {
    // Hashable conformance
    static func == (lhs: Projectile, rhs: Projectile) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Projectile properties
    var damage: Float
    var projectileType: ProjectileType
    weak var target: Entity?
    weak var source: Entity?
    
    // Components
    private(set) var transform: TransformComponent!
    private(set) var movement: MovementComponent!
    private(set) var sprite: SKSpriteNode?
    
    // Projectile configuration
    private var speed: Float = 300.0
    private var lifetime: TimeInterval = 5.0
    private var currentLifetime: TimeInterval = 0
    private var hasHit = false
    
    enum ProjectileType: Hashable {
        case bullet
        case laser
        case missile
        case plasma
        case nanobots
    }
    
    init(type: ProjectileType, damage: Float, from source: Entity, to target: Entity) {
        self.projectileType = type
        self.damage = damage
        self.source = source
        self.target = target
        
        super.init()
        
        // Setup components
        setupComponents()
        
        // Create visual
        createSprite()
        
        // Set initial trajectory
        if let sourceTransform = source.getComponent(TransformComponent.self),
           let targetTransform = target.getComponent(TransformComponent.self) {
            transform.position = sourceTransform.position
            
            // Calculate initial velocity towards target
            let direction = normalize(targetTransform.position - sourceTransform.position)
            movement.velocity = direction * speed
            transform.rotation = atan2(direction.y, direction.x)
        }
    }
    
    private func setupComponents() {
        // Transform
        transform = TransformComponent()
        addComponent(transform)
        
        // Movement
        movement = MovementComponent()
        movement.maxSpeed = speed
        addComponent(movement)
    }
    
    private func createSprite() {
        let color: SKColor
        let size: CGSize
        
        switch projectileType {
        case .bullet:
            color = .yellow
            size = CGSize(width: 4, height: 4)
            
        case .laser:
            color = .red
            size = CGSize(width: 20, height: 2)
            
        case .missile:
            color = .orange
            size = CGSize(width: 8, height: 4)
            
        case .plasma:
            color = .cyan
            size = CGSize(width: 6, height: 6)
            
        case .nanobots:
            color = .green
            size = CGSize(width: 3, height: 3)
        }
        
        sprite = SKSpriteNode(color: color, size: size)
        sprite?.name = "projectile_\(id.uuidString)"
        
        // Add glow effect
        let glow = SKSpriteNode(color: color, size: CGSize(width: size.width * 2, height: size.height * 2))
        glow.alpha = 0.3
        glow.blendMode = .add
        sprite?.addChild(glow)
        
        // Add trail effect for some projectiles
        if projectileType == .missile || projectileType == .plasma {
            addTrailEffect()
        }
    }
    
    private func addTrailEffect() {
        guard let sprite = sprite else { return }
        
        if let emitter = SKEmitterNode(fileNamed: "ProjectileTrail") {
            emitter.position = CGPoint(x: -5, y: 0)
            emitter.targetNode = sprite.parent
            sprite.addChild(emitter)
        } else {
            // Create simple trail if particle file doesn't exist
            let trail = SKShapeNode(circleOfRadius: 2)
            trail.fillColor = sprite.color.withAlphaComponent(0.5)
            trail.strokeColor = .clear
            trail.position = CGPoint(x: -5, y: 0)
            
            let fade = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ])
            trail.run(fade)
            sprite.addChild(trail)
        }
    }
    
    func update(deltaTime: TimeInterval) {
        // Update lifetime
        currentLifetime += deltaTime
        if currentLifetime >= lifetime {
            destroy()
            return
        }
        
        // Home towards target if it still exists
        if let target = target, target.isActive {
            homeTowardsTarget(deltaTime: deltaTime)
            checkCollision(with: target)
        } else {
            // Target lost, continue in straight line
            // or find new target for smart projectiles
            if projectileType == .missile {
                findNewTarget()
            }
        }
    }
    
    private func homeTowardsTarget(deltaTime: TimeInterval) {
        guard let targetTransform = target?.getComponent(TransformComponent.self) else { return }
        
        let toTarget = targetTransform.position - transform.position
        let distance = length(toTarget)
        
        // Check if close enough to hit
        if distance < 10 {
            hit()
            return
        }
        
        // Calculate homing strength based on projectile type
        let homingStrength: Float = projectileType == .missile ? 5.0 : 2.0
        
        // Update velocity to home towards target
        let desiredDirection = normalize(toTarget)
        let currentDirection = normalize(movement.velocity)
        
        // Smoothly rotate towards target
        let newDirection = normalize(currentDirection + desiredDirection * homingStrength * Float(deltaTime))
        movement.velocity = newDirection * speed
        
        // Update rotation
        transform.rotation = atan2(newDirection.y, newDirection.x)
    }
    
    private func checkCollision(with target: Entity) {
        guard !hasHit,
              let targetTransform = target.getComponent(TransformComponent.self) else { return }
        
        let distance = simd_distance(transform.position, targetTransform.position)
        
        // Hit threshold based on target size
        let hitThreshold: Float = 15.0
        
        if distance < hitThreshold {
            hit()
        }
    }
    
    private func findNewTarget() {
        // Query world for nearest enemy
        // This would be implemented with world system
        // For now, continue straight
    }
    
    private func hit() {
        guard !hasHit else { return }
        hasHit = true
        
        // Apply damage to target
        if let target = target,
           let health = target.getComponent(HealthComponent.self) {
            
            // Determine damage type based on projectile
            let damageType: DamageType
            switch projectileType {
            case .laser, .plasma:
                damageType = .energy
            case .nanobots:
                damageType = .toxic
            default:
                damageType = .physical
            }
            
            health.takeDamage(damage, type: damageType)
            
            // Apply special effects
            applySpecialEffects(to: target)
        }
        
        // Create impact effect
        createImpactEffect()
        
        // Destroy projectile
        destroy()
    }
    
    private func applySpecialEffects(to target: Entity) {
        // Apply effects based on source tower type
        if let tower = source as? Tower {
            switch tower.towerType {
            case .nanobot:
                // Apply DoT
                if let health = target.getComponent(HealthComponent.self) {
                    applyDoT(to: health, damage: damage * 0.5, duration: 3.0)
                }
            default:
                break
            }
        }
    }
    
    private func applyDoT(to health: HealthComponent, damage: Float, duration: TimeInterval) {
        // This would create a DoT effect component
        // Simplified for now
        let tickDamage = damage / Float(duration)
        var remainingDuration = duration
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if remainingDuration <= 0 || !health.isAlive {
                timer.invalidate()
                return
            }
            
            health.takeDamage(tickDamage * 0.5, type: .toxic)
            remainingDuration -= 0.5
        }
    }
    
    private func createImpactEffect() {
        NotificationCenter.default.post(
            name: .createImpactEffect,
            object: nil,
            userInfo: [
                "position": transform.position,
                "type": projectileType
            ]
        )
    }
    
    private func destroy() {
        sprite?.removeFromParent()
        isActive = false
    }
}

// MARK: - Projectile Pool
class ProjectilePool {
    static let shared = ProjectilePool()
    
    private var availableProjectiles: [Projectile.ProjectileType: [Projectile]] = [:]
    private var activeProjectiles: Set<Projectile> = []
    private let maxPoolSize = 100
    
    private init() {
        // Pre-warm pools
        for type in [Projectile.ProjectileType.bullet, .laser, .missile, .plasma, .nanobots] {
            availableProjectiles[type] = []
        }
    }
    
    func getProjectile(type: Projectile.ProjectileType, damage: Float, from source: Entity, to target: Entity) -> Projectile {
        // Try to reuse from pool
        if var available = availableProjectiles[type], !available.isEmpty {
            let projectile = available.removeLast()
            availableProjectiles[type] = available
            projectile.reset(damage: damage, from: source, to: target)
            activeProjectiles.insert(projectile)
            return projectile
        }
        
        // Create new projectile
        let projectile = Projectile(type: type, damage: damage, from: source, to: target)
        activeProjectiles.insert(projectile)
        return projectile
    }
    
    func returnProjectile(_ projectile: Projectile) {
        guard activeProjectiles.contains(projectile) else { return }
        
        activeProjectiles.remove(projectile)
        
        // Add back to pool if not at capacity
        if let pool = availableProjectiles[projectile.projectileType],
           pool.count < maxPoolSize {
            availableProjectiles[projectile.projectileType]?.append(projectile)
        }
    }
    
    func update(deltaTime: TimeInterval) {
        for projectile in activeProjectiles {
            if projectile.isActive {
                projectile.update(deltaTime: deltaTime)
            } else {
                returnProjectile(projectile)
            }
        }
    }
}

// Extension for resetting pooled projectiles
extension Projectile {
    func reset(damage: Float, from source: Entity, to target: Entity) {
        self.damage = damage
        self.source = source
        self.target = target
        self.hasHit = false
        self.currentLifetime = 0
        self.isActive = true
        
        // Reset position and velocity
        if let sourceTransform = source.getComponent(TransformComponent.self),
           let targetTransform = target.getComponent(TransformComponent.self) {
            transform.position = sourceTransform.position
            
            let direction = normalize(targetTransform.position - sourceTransform.position)
            movement.velocity = direction * speed
            transform.rotation = atan2(direction.y, direction.x)
        }
    }
}

// Notification names
extension Notification.Name {
    static let createImpactEffect = Notification.Name("CreateImpactEffect")
}