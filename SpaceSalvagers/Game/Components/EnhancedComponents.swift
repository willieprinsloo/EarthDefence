import Foundation
import SpriteKit
import GameplayKit

// MARK: - Enhanced Targeting Component
class EnhancedTargetingComponent: BaseComponent {
    var range: Float = 100
    var targetingPriority: TargetingPriority = .nearest
    var canTargetAir: Bool = false
    var canTargetGround: Bool = true
    var maxTargets: Int = 1
    var penetratingTargets: Int = 0 // For railgun pierce
    
    private(set) var currentTargets: [Enemy] = []
    private var lastTargetUpdate: TimeInterval = 0
    private let targetUpdateInterval: TimeInterval = 0.1 // Update targets 10 times per second
    
    override func update(deltaTime: TimeInterval) {
        lastTargetUpdate += deltaTime
        
        if lastTargetUpdate >= targetUpdateInterval {
            updateTargets()
            lastTargetUpdate = 0
        }
    }
    
    func getPrimaryTarget() -> Enemy? {
        return currentTargets.first
    }
    
    func getAllTargets() -> [Enemy] {
        return currentTargets
    }
    
    private func updateTargets() {
        // Get all enemies in range
        let enemiesInRange = findEnemiesInRange()
        
        // Filter by targeting capabilities
        let validTargets = enemiesInRange.filter { enemy in
            if !canTargetAir && enemy.isFlying { return false }
            if !canTargetGround && !enemy.isFlying { return false }
            return !enemy.isDead
        }
        
        // Sort by priority
        let sortedTargets = sortTargetsByPriority(validTargets)
        
        // Take max targets
        currentTargets = Array(sortedTargets.prefix(maxTargets))
    }
    
    private func findEnemiesInRange() -> [Enemy] {
        // This would interface with the game scene to get enemies
        // For now, return empty array - will be connected to game scene
        return []
    }
    
    private func sortTargetsByPriority(_ enemies: [Enemy]) -> [Enemy] {
        switch targetingPriority {
        case .nearest:
            return enemies.sorted { distance(to: $0) < distance(to: $1) }
        case .furthest:
            return enemies.sorted { distance(to: $0) > distance(to: $1) }
        case .strongest:
            return enemies.sorted { $0.currentHealth > $1.currentHealth }
        case .weakest:
            return enemies.sorted { $0.currentHealth < $1.currentHealth }
        case .first:
            return enemies.sorted { $0.pathProgress > $1.pathProgress }
        case .last:
            return enemies.sorted { $0.pathProgress < $1.pathProgress }
        case .flying:
            return enemies.sorted { enemy1, enemy2 in
                if enemy1.isFlying && !enemy2.isFlying { return true }
                if !enemy1.isFlying && enemy2.isFlying { return false }
                return distance(to: enemy1) < distance(to: enemy2)
            }
        case .mostClustered:
            return enemies.sorted { getClusterScore($0) > getClusterScore($1) }
        case .leastClustered:
            return enemies.sorted { getClusterScore($0) < getClusterScore($1) }
        }
    }
    
    private func distance(to enemy: Enemy) -> Float {
        guard let myTransform = entity?.getComponent(TransformComponent.self),
              let enemyTransform = enemy.getComponent(TransformComponent.self) else {
            return Float.greatestFiniteMagnitude
        }
        
        return simd_distance(myTransform.position, enemyTransform.position)
    }
    
    private func getClusterScore(_ enemy: Enemy) -> Int {
        // Count enemies within a small radius of this enemy
        return 0 // Placeholder - implement clustering detection
    }
}

// MARK: - Enhanced Weapon Component
class EnhancedWeaponComponent: BaseComponent {
    var damage: Float = 10
    var fireRate: Float = 1.0
    var damageType: DamageType = .kinetic
    var critChance: Float = 0
    var critMultiplier: Float = 1.0
    var armorPierce: Float = 0
    var bonusVsShields: Float = 0
    var isEnabled: Bool = true
    
    // Chain properties
    var chainCount: Int = 0
    var chainDamageReduction: Float = 0.2
    
    // Splash properties
    var splashRadius: Float = 0
    var splashDamagePercent: Float = 0.5
    
    private var lastFireTime: TimeInterval = 0
    private var targeting: EnhancedTargetingComponent?
    
    override func awake() {
        super.awake()
        targeting = entity?.getComponent(EnhancedTargetingComponent.self)
    }
    
    override func update(deltaTime: TimeInterval) {
        guard isEnabled else { return }
        guard let targeting = targeting else { return }
        
        let currentTime = CACurrentMediaTime()
        let timeSinceLastFire = currentTime - lastFireTime
        let fireInterval = 1.0 / Double(fireRate)
        
        if timeSinceLastFire >= fireInterval {
            if let tower = entity as? EnhancedTower {
                fireWeapon(from: tower, at: targeting.getAllTargets())
                lastFireTime = currentTime
            }
        }
    }
    
    private func fireWeapon(from tower: EnhancedTower, at targets: [Enemy]) {
        guard !targets.isEmpty else { return }
        
        switch tower.towerType {
        case .laserTurret:
            fireLaserBeam(from: tower, at: targets.first!)
        case .railgunEmplacement:
            fireRailgunShot(from: tower, through: targets)
        case .plasmaArcNode:
            firePlasmaArc(from: tower, at: targets.first!, chains: chainCount)
        case .missilePDBattery:
            fireMissiles(from: tower, at: targets)
        case .nanobotSwarmDispenser:
            releaseNanobots(from: tower, at: targets)
        case .cryoFoamProjector:
            sprayCryoFoam(from: tower, at: targets)
        case .gravityWellProjector:
            maintainGravityWell(from: tower)
        case .empShockTower:
            fireEMPBurst(from: tower)
        case .plasmaMortar:
            firePlasmaMortar(from: tower, at: targets.first!)
        case .solarLanceArray:
            fireSolarLance(from: tower, at: targets)
        case .singularityCannon:
            fireSingularity(from: tower, at: targets.first!)
        default:
            fireStandardProjectile(from: tower, at: targets.first!)
        }
    }
    
    // MARK: - Weapon Fire Methods
    private func fireLaserBeam(from tower: EnhancedTower, at target: Enemy) {
        // Calculate damage
        let finalDamage = calculateDamage(against: target)
        
        // Apply instant damage
        target.takeDamage(finalDamage, type: damageType)
        
        // Create visual beam effect
        createBeamEffect(from: tower.sprite.position, to: target.sprite.position, color: .red)
        
        // Apply heat status if upgraded
        if tower.currentTier >= 3 {
            target.applyStatusEffect(StatusEffect(
                type: .heat,
                duration: 3,
                intensity: 0.1,
                stackable: true,
                maxStacks: 3
            ))
        }
    }
    
    private func fireRailgunShot(from tower: EnhancedTower, through targets: [Enemy]) {
        // Create piercing projectile
        let projectile = createProjectile(type: .railgunSlug)
        projectile.position = tower.sprite.position
        projectile.damage = calculateDamage(against: targets.first!)
        projectile.pierce = min(targets.count, Int(tower.currentStats.projectilePierce ?? 1))
        
        // Launch with high velocity
        launchProjectile(projectile, at: targets.first!, speed: 2000)
        
        // Apply slow on hit for tier 4+
        if tower.currentTier >= 4 {
            for target in targets.prefix(projectile.pierce) {
                target.applyStatusEffect(StatusEffect(
                    type: .slow,
                    duration: 1.5,
                    intensity: 0.15,
                    stackable: false,
                    maxStacks: 1
                ))
            }
        }
    }
    
    private func firePlasmaArc(from tower: EnhancedTower, at target: Enemy, chains: Int) {
        // Hit primary target
        let primaryDamage = calculateDamage(against: target)
        target.takeDamage(primaryDamage, type: damageType)
        
        // Create arc effect
        createArcEffect(from: tower.sprite.position, to: target.sprite.position)
        
        // Chain to nearby enemies
        var previousTarget = target
        var chainDamage = primaryDamage
        var chainedTargets = [target]
        
        for _ in 0..<chains {
            chainDamage *= (1 - chainDamageReduction)
            
            // Find next target
            if let nextTarget = findNearestEnemy(to: previousTarget, excluding: chainedTargets, maxDistance: 150) {
                // Apply chain damage
                nextTarget.takeDamage(chainDamage, type: damageType)
                
                // Create chain effect
                createArcEffect(from: previousTarget.sprite.position, to: nextTarget.sprite.position)
                
                // Apply shock chance
                if Float.random(in: 0...1) < 0.1 {
                    nextTarget.applyStatusEffect(StatusEffect(
                        type: .shock,
                        duration: 0.5,
                        intensity: 1,
                        stackable: false,
                        maxStacks: 1
                    ))
                }
                
                chainedTargets.append(nextTarget)
                previousTarget = nextTarget
            } else {
                break
            }
        }
    }
    
    private func fireMissiles(from tower: EnhancedTower, at targets: [Enemy]) {
        let missileCount = tower.currentTier >= 3 ? 2 : 1
        
        for i in 0..<missileCount {
            let target = targets.count > i ? targets[i] : targets.first!
            
            let missile = createProjectile(type: .missile)
            missile.position = tower.sprite.position
            missile.damage = calculateDamage(against: target) / Float(missileCount)
            missile.splashRadius = splashRadius
            missile.splashDamage = missile.damage * splashDamagePercent
            missile.isHoming = tower.currentTier >= 4
            
            // Stagger launch
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.launchProjectile(missile, at: target, speed: 400)
            }
        }
    }
    
    private func releaseNanobots(from tower: EnhancedTower, at targets: [Enemy]) {
        // Create cone area effect
        let coneAngle: CGFloat = .pi / 3 // 60 degree cone
        let coneRange = CGFloat(tower.currentStats.range)
        
        // Apply infection to all enemies in cone
        for target in targets {
            let infection = StatusEffect(
                type: .infection,
                duration: 4 + Double(tower.currentTier - 1),
                intensity: 8,
                stackable: true,
                maxStacks: 5,
                damagePerSecond: damage / 4
            )
            
            target.applyStatusEffect(infection)
            
            // Create swarm visual
            createSwarmEffect(from: tower.sprite.position, to: target.sprite.position)
            
            // Apply corrosion at tier 3+
            if tower.currentTier >= 3 {
                target.applyStatusEffect(StatusEffect(
                    type: .corrode,
                    duration: 2,
                    intensity: 2,
                    stackable: true,
                    maxStacks: 10,
                    armorReduction: 2
                ))
            }
        }
    }
    
    private func sprayCryoFoam(from tower: EnhancedTower, at targets: [Enemy]) {
        // Create spray cone effect
        createSprayEffect(from: tower.sprite.position, color: .cyan, range: tower.currentStats.range)
        
        for target in targets {
            // Apply damage
            target.takeDamage(damage, type: damageType)
            
            // Apply slow
            let slowIntensity = 0.25 + Float(tower.currentTier - 1) * 0.1
            target.applyStatusEffect(StatusEffect(
                type: .slow,
                duration: 2.5,
                intensity: slowIntensity,
                stackable: false,
                maxStacks: 1
            ))
            
            // Chance to freeze at tier 3+
            if tower.currentTier >= 3 && Float.random(in: 0...1) < 0.08 {
                target.applyStatusEffect(StatusEffect(
                    type: .freeze,
                    duration: 1,
                    intensity: 1,
                    stackable: false,
                    maxStacks: 1
                ))
            }
        }
    }
    
    private func maintainGravityWell(from tower: EnhancedTower) {
        // Gravity well is maintained by the AuraComponent
        // This just triggers visual updates
        if let aura = tower.auraEmitter {
            aura.pulse()
        }
    }
    
    private func fireEMPBurst(from tower: EnhancedTower) {
        // Create expanding ring effect
        createEMPBurstEffect(at: tower.sprite.position, radius: CGFloat(tower.currentStats.range))
        
        // Get all enemies in radius
        let enemies = findEnemiesInRadius(center: tower.sprite.position, radius: CGFloat(tower.currentStats.range))
        
        for enemy in enemies {
            // Apply damage
            enemy.takeDamage(damage, type: damageType)
            
            // Strip shields
            enemy.stripShields(amount: 150 + Float(tower.currentTier - 1) * 50)
            
            // Apply stun
            let stunDuration = 0.6 + Double(tower.currentTier - 1) * 0.1
            enemy.applyStatusEffect(StatusEffect(
                type: .stun,
                duration: stunDuration,
                intensity: 1,
                stackable: false,
                maxStacks: 1
            ))
        }
    }
    
    private func firePlasmaMortar(from tower: EnhancedTower, at target: Enemy) {
        // Create arcing projectile
        let mortar = createProjectile(type: .mortarShell)
        mortar.position = tower.sprite.position
        mortar.damage = calculateDamage(against: target)
        mortar.splashRadius = 2.0 + Float(tower.currentTier - 1) * 0.5
        mortar.splashDamage = mortar.damage * splashDamagePercent
        mortar.isArcing = true
        
        // Launch with arc trajectory
        launchArcingProjectile(mortar, at: target.sprite.position, arcHeight: 200)
        
        // Leave plasma pool at tier 3+
        if tower.currentTier >= 3 {
            // This will be handled when projectile impacts
            mortar.leavesPool = true
            mortar.poolDuration = 3
            mortar.poolDPS = 20
        }
    }
    
    private func fireSolarLance(from tower: EnhancedTower, at targets: [Enemy]) {
        // Charge up animation
        chargeSolarLance(tower: tower) {
            // Fire piercing beam across map
            let beamEnd = self.calculateBeamEndpoint(from: tower.sprite.position, towards: targets.first!.sprite.position)
            
            // Create massive beam effect
            self.createSolarBeamEffect(from: tower.sprite.position, to: beamEnd)
            
            // Damage all enemies in line
            let enemiesInLine = self.findEnemiesInLine(from: tower.sprite.position, to: beamEnd, width: 50)
            
            for enemy in enemiesInLine {
                enemy.takeDamage(self.damage, type: self.damageType)
                
                // Apply heat at tier 3+
                if tower.currentTier >= 3 {
                    enemy.applyStatusEffect(StatusEffect(
                        type: .heat,
                        duration: 6,
                        intensity: 0.25,
                        stackable: true,
                        maxStacks: 1
                    ))
                }
            }
        }
    }
    
    private func fireSingularity(from tower: EnhancedTower, at target: Enemy) {
        // Create singularity at target location
        let singularity = createSingularityEffect(at: target.sprite.position, duration: 3)
        
        // Apply pull effect to all nearby enemies
        let pullRadius: CGFloat = 200
        let enemies = findEnemiesInRadius(center: target.sprite.position, radius: pullRadius)
        
        for enemy in enemies {
            // Apply gravity pull
            enemy.applyStatusEffect(StatusEffect(
                type: .gravity,
                duration: 3,
                intensity: 0.6,
                stackable: false,
                maxStacks: 1
            ))
            
            // Apply vulnerability at tier 2+
            if tower.currentTier >= 2 {
                enemy.applyStatusEffect(StatusEffect(
                    type: .vulnerable,
                    duration: 3,
                    intensity: 0.25,
                    stackable: false,
                    maxStacks: 1,
                    vulnerabilityPercent: 25
                ))
            }
        }
        
        // Collapse damage after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Apply collapse damage
            let remainingEnemies = self.findEnemiesInRadius(center: target.sprite.position, radius: pullRadius * 0.5)
            for enemy in remainingEnemies {
                enemy.takeDamage(self.damage, type: .trueDamage)
            }
            
            // Create collapse effect
            self.createCollapseEffect(at: target.sprite.position)
        }
    }
    
    private func fireStandardProjectile(from tower: EnhancedTower, at target: Enemy) {
        let projectile = createProjectile(type: .standard)
        projectile.position = tower.sprite.position
        projectile.damage = calculateDamage(against: target)
        
        launchProjectile(projectile, at: target, speed: 500)
    }
    
    // MARK: - Helper Methods
    private func calculateDamage(against target: Enemy) -> Float {
        var finalDamage = damage
        
        // Apply crit
        if Float.random(in: 0...1) < critChance {
            finalDamage *= critMultiplier
            // Show crit indicator
            showCritIndicator(at: target.sprite.position)
        }
        
        // Apply armor pierce
        let effectiveArmor = max(0, target.armor - armorPierce)
        finalDamage *= (1 - effectiveArmor / 100)
        
        // Apply shield bonus
        if target.hasShield && bonusVsShields > 0 {
            finalDamage *= (1 + bonusVsShields)
        }
        
        return finalDamage
    }
    
    // Placeholder methods - these would be implemented with actual game scene integration
    private func createProjectile(type: ProjectileType) -> Projectile {
        return Projectile(type: type)
    }
    
    private func launchProjectile(_ projectile: Projectile, at target: Enemy, speed: Float) {
        // Launch projectile towards target
    }
    
    private func launchArcingProjectile(_ projectile: Projectile, at position: CGPoint, arcHeight: CGFloat) {
        // Launch projectile in arc
    }
    
    private func createBeamEffect(from: CGPoint, to: CGPoint, color: SKColor) {
        // Create laser beam visual
    }
    
    private func createArcEffect(from: CGPoint, to: CGPoint) {
        // Create lightning arc visual
    }
    
    private func createSwarmEffect(from: CGPoint, to: CGPoint) {
        // Create nanobot swarm visual
    }
    
    private func createSprayEffect(from: CGPoint, color: SKColor, range: Float) {
        // Create cone spray visual
    }
    
    private func createEMPBurstEffect(at: CGPoint, radius: CGFloat) {
        // Create EMP ring expansion
    }
    
    private func createSolarBeamEffect(from: CGPoint, to: CGPoint) {
        // Create massive solar beam
    }
    
    private func createSingularityEffect(at: CGPoint, duration: TimeInterval) -> SKNode {
        // Create black hole visual
        return SKNode()
    }
    
    private func createCollapseEffect(at: CGPoint) {
        // Create singularity collapse
    }
    
    private func chargeSolarLance(tower: EnhancedTower, completion: @escaping () -> Void) {
        // Charge animation then fire
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion()
        }
    }
    
    private func calculateBeamEndpoint(from: CGPoint, towards: CGPoint) -> CGPoint {
        // Calculate beam endpoint across map
        return CGPoint(x: towards.x * 10, y: towards.y * 10)
    }
    
    private func findNearestEnemy(to enemy: Enemy, excluding: [Enemy], maxDistance: Float) -> Enemy? {
        // Find nearest enemy for chaining
        return nil
    }
    
    private func findEnemiesInRadius(center: CGPoint, radius: CGFloat) -> [Enemy] {
        // Find all enemies in radius
        return []
    }
    
    private func findEnemiesInLine(from: CGPoint, to: CGPoint, width: CGFloat) -> [Enemy] {
        // Find all enemies in line
        return []
    }
    
    private func showCritIndicator(at position: CGPoint) {
        // Show critical hit indicator
    }
}

// MARK: - Status Effect Component
class StatusEffectComponent: BaseComponent {
    var effect: StatusEffect?
    
    func applyTo(_ target: Enemy) {
        guard let effect = effect else { return }
        target.applyStatusEffect(effect)
    }
}

// MARK: - Aura Component
class AuraComponent: BaseComponent {
    enum AuraEffect {
        case pullToCenter(strength: Float)
        case shieldAllies(amount: Float)
        case healAllies(perSecond: Float)
        case damageEnemies(perSecond: Float)
        case slowEnemies(percent: Float)
    }
    
    var radius: Float = 100
    var effect: AuraEffect = .pullToCenter(strength: 30)
    
    private var affectedEntities: Set<Entity> = []
    private var pulseTimer: TimeInterval = 0
    
    override func update(deltaTime: TimeInterval) {
        pulseTimer += deltaTime
        
        // Update affected entities
        updateAffectedEntities()
        
        // Apply continuous effects
        applyContinuousEffects(deltaTime: deltaTime)
        
        // Pulse visual every second
        if pulseTimer >= 1.0 {
            pulse()
            pulseTimer = 0
        }
    }
    
    func pulse() {
        // Create visual pulse effect
        createPulseEffect()
    }
    
    private func updateAffectedEntities() {
        // Find entities in aura radius
    }
    
    private func applyContinuousEffects(deltaTime: TimeInterval) {
        // Apply aura effects to affected entities
    }
    
    private func createPulseEffect() {
        // Create visual pulse
    }
}

// MARK: - Tower Ability Component
class TowerAbilityComponent: BaseComponent {
    var ability: TowerAbility?
    private var lastActivation: TimeInterval = 0
    private var isActive: Bool = false
    
    func activate() {
        guard let ability = ability else { return }
        
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastActivation >= ability.cooldown else { return }
        
        isActive = true
        lastActivation = currentTime
        
        // Execute ability
        executeAbility()
        
        // Deactivate after duration if applicable
        if let duration = ability.duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isActive = false
            }
        } else {
            isActive = false
        }
    }
    
    private func executeAbility() {
        // Execute ability effects
    }
}

// MARK: - Resource Generator Component
class ResourceGeneratorComponent: BaseComponent {
    var resourcePerSecond: Float = 1.0
    private var accumulatedResource: Float = 0
    
    override func update(deltaTime: TimeInterval) {
        accumulatedResource += resourcePerSecond * Float(deltaTime)
        
        if accumulatedResource >= 1.0 {
            let wholeResource = Int(accumulatedResource)
            // Add resources to player
            NotificationCenter.default.post(
                name: .addResources,
                object: nil,
                userInfo: ["amount": wholeResource]
            )
            accumulatedResource -= Float(wholeResource)
        }
    }
}

// MARK: - Drone Spawner Component
class DroneSpawnerComponent: BaseComponent {
    var maxDrones: Int = 2
    var droneStats: DroneStats?
    private var drones: [Drone] = []
    
    override func awake() {
        super.awake()
        spawnDrones()
    }
    
    override func update(deltaTime: TimeInterval) {
        // Remove dead drones
        drones.removeAll { $0.isDead }
        
        // Spawn new drones if needed
        while drones.count < maxDrones {
            spawnDrone()
        }
        
        // Update drones
        for drone in drones {
            drone.update(deltaTime: deltaTime)
        }
    }
    
    private func spawnDrones() {
        for _ in 0..<maxDrones {
            spawnDrone()
        }
    }
    
    private func spawnDrone() {
        guard let stats = droneStats else { return }
        let drone = Drone(stats: stats)
        drones.append(drone)
    }
}

// MARK: - Support Classes
class Drone {
    let stats: DroneStats
    var isDead: Bool = false
    
    init(stats: DroneStats) {
        self.stats = stats
    }
    
    func update(deltaTime: TimeInterval) {
        // Update drone behavior
    }
}

enum ProjectileType {
    case standard
    case laserBeam
    case railgunSlug
    case missile
    case mortarShell
    case plasmaOrb
}

class Projectile {
    let type: ProjectileType
    var position: CGPoint = .zero
    var damage: Float = 0
    var pierce: Int = 1
    var splashRadius: Float = 0
    var splashDamage: Float = 0
    var isHoming: Bool = false
    var isArcing: Bool = false
    var leavesPool: Bool = false
    var poolDuration: TimeInterval = 0
    var poolDPS: Float = 0
    
    init(type: ProjectileType) {
        self.type = type
    }
}

// MARK: - Placeholder Enemy Class
class Enemy {
    var sprite: SKSpriteNode = SKSpriteNode()
    var currentHealth: Float = 100
    var maxHealth: Float = 100
    var armor: Float = 0
    var isFlying: Bool = false
    var isDead: Bool = false
    var pathProgress: Float = 0
    var hasShield: Bool = false
    
    func takeDamage(_ damage: Float, type: DamageType) {
        currentHealth -= damage
        if currentHealth <= 0 {
            isDead = true
        }
    }
    
    func applyStatusEffect(_ effect: StatusEffect) {
        // Apply status effect
    }
    
    func stripShields(amount: Float) {
        // Remove shields
    }
    
    func getComponent<T: BaseComponent>(_ type: T.Type) -> T? {
        return nil
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let addResources = Notification.Name("AddResources")
}