import Foundation
import simd

protocol TargetingDelegate: AnyObject {
    func targetAcquired(_ target: Entity)
    func targetLost()
}

class TargetingComponent: BaseComponent {
    // Targeting configuration
    var range: Float = 100.0
    var targetingMode: TargetingMode = .nearest
    var maxTargets: Int = 1
    var requiresLineOfSight: Bool = false
    
    // Current targets
    private(set) var currentTargets: [Entity] = []
    weak var delegate: TargetingDelegate?
    
    // Target filtering
    var targetTags: Set<String> = ["enemy"]
    var priorityTargetTypes: [String] = []
    
    private var transform: TransformComponent?
    
    enum TargetingMode {
        case nearest        // Closest to tower
        case furthest      // Furthest from tower (still in range)
        case strongest     // Highest max health
        case weakest       // Lowest current health
        case first         // First in path (closest to goal)
        case last          // Last in path (furthest from goal)
        case mostDangerous // Highest threat score
        case random        // Random valid target
    }
    
    override func awake() {
        super.awake()
        transform = entity?.getComponent(TransformComponent.self)
    }
    
    override func update(deltaTime: TimeInterval) {
        guard let transform = transform else { return }
        
        // Get all potential targets
        let potentialTargets = findPotentialTargets()
        
        // Filter by range
        let targetsInRange = potentialTargets.filter { target in
            guard let targetTransform = target.getComponent(TransformComponent.self) else { return false }
            let distance = simd_distance(transform.position, targetTransform.position)
            return distance <= range
        }
        
        // Filter by line of sight if required
        let validTargets = requiresLineOfSight ? 
            filterByLineOfSight(targetsInRange, from: transform.position) : 
            targetsInRange
        
        // Select targets based on mode
        let selectedTargets = selectTargets(from: validTargets, mode: targetingMode, count: maxTargets)
        
        // Update current targets
        updateCurrentTargets(selectedTargets)
    }
    
    private func findPotentialTargets() -> [Entity] {
        // Query the world for entities with enemy components
        let world = GameEngine.shared.world
        
        // Get all entities with HealthComponent (enemies should have health)
        let _ = world.query(withComponent: HealthComponent.self)
        
        // Filter for actual enemies based on tags or groups
        // For now, we'll assume entities in the "enemy" group are enemies
        let enemyEntities = world.getEntities(inGroup: "enemy")
        
        // Return enemies that match our targeting criteria
        return enemyEntities.filter { enemy in
            // Check if entity has the required tags
            return targetTags.contains("enemy") && enemy.isActive
        }
    }
    
    private func filterByLineOfSight(_ targets: [Entity], from position: SIMD2<Float>) -> [Entity] {
        // Simplified - would use raycasting in full implementation
        return targets
    }
    
    private func selectTargets(from targets: [Entity], mode: TargetingMode, count: Int) -> [Entity] {
        guard !targets.isEmpty else { return [] }
        
        let sorted: [Entity]
        
        switch mode {
        case .nearest:
            sorted = sortByDistance(targets, ascending: true)
            
        case .furthest:
            sorted = sortByDistance(targets, ascending: false)
            
        case .strongest:
            sorted = targets.sorted { entity1, entity2 in
                let health1 = entity1.getComponent(HealthComponent.self)?.maxHealth ?? 0
                let health2 = entity2.getComponent(HealthComponent.self)?.maxHealth ?? 0
                return health1 > health2
            }
            
        case .weakest:
            sorted = targets.sorted { entity1, entity2 in
                let health1 = entity1.getComponent(HealthComponent.self)?.currentHealth ?? Float.infinity
                let health2 = entity2.getComponent(HealthComponent.self)?.currentHealth ?? Float.infinity
                return health1 < health2
            }
            
        case .first:
            sorted = sortByPathProgress(targets, ascending: false)
            
        case .last:
            sorted = sortByPathProgress(targets, ascending: true)
            
        case .mostDangerous:
            sorted = sortByThreatLevel(targets)
            
        case .random:
            sorted = targets.shuffled()
        }
        
        return Array(sorted.prefix(count))
    }
    
    private func sortByDistance(_ targets: [Entity], ascending: Bool) -> [Entity] {
        guard transform != nil else { return targets }
        
        return targets.sorted { entity1, entity2 in
            let dist1 = distanceToEntity(entity1) ?? Float.infinity
            let dist2 = distanceToEntity(entity2) ?? Float.infinity
            return ascending ? dist1 < dist2 : dist1 > dist2
        }
    }
    
    private func sortByPathProgress(_ targets: [Entity], ascending: Bool) -> [Entity] {
        return targets.sorted { entity1, entity2 in
            let progress1 = entity1.getComponent(PathFollowComponent.self)?.progress ?? 0
            let progress2 = entity2.getComponent(PathFollowComponent.self)?.progress ?? 0
            return ascending ? progress1 < progress2 : progress1 > progress2
        }
    }
    
    private func sortByThreatLevel(_ targets: [Entity]) -> [Entity] {
        return targets.sorted { entity1, entity2 in
            let threat1 = calculateThreatLevel(for: entity1)
            let threat2 = calculateThreatLevel(for: entity2)
            return threat1 > threat2
        }
    }
    
    private func calculateThreatLevel(for entity: Entity) -> Float {
        var threat: Float = 0
        
        // Factor in health
        if let health = entity.getComponent(HealthComponent.self) {
            threat += health.currentHealth * 0.5
        }
        
        // Factor in speed
        if let movement = entity.getComponent(MovementComponent.self) {
            threat += movement.maxSpeed * 0.3
        }
        
        // Factor in distance to goal
        if let pathFollow = entity.getComponent(PathFollowComponent.self) {
            threat += (1.0 - pathFollow.progress) * 100
        }
        
        // Factor in distance to tower (closer = more threatening)
        if let distance = distanceToEntity(entity) {
            threat += max(0, 100 - distance)
        }
        
        return threat
    }
    
    private func distanceToEntity(_ target: Entity) -> Float? {
        guard let transform = transform,
              let targetTransform = target.getComponent(TransformComponent.self) else {
            return nil
        }
        return simd_distance(transform.position, targetTransform.position)
    }
    
    private func updateCurrentTargets(_ newTargets: [Entity]) {
        let oldTargets = Set(currentTargets.map { ObjectIdentifier($0) })
        let newTargetSet = Set(newTargets.map { ObjectIdentifier($0) })
        
        // Notify about lost targets
        for target in currentTargets {
            if !newTargetSet.contains(ObjectIdentifier(target)) {
                delegate?.targetLost()
            }
        }
        
        // Notify about new targets
        for target in newTargets {
            if !oldTargets.contains(ObjectIdentifier(target)) {
                delegate?.targetAcquired(target)
            }
        }
        
        currentTargets = newTargets
    }
    
    func hasTarget() -> Bool {
        return !currentTargets.isEmpty
    }
    
    func getPrimaryTarget() -> Entity? {
        return currentTargets.first
    }
    
    func isInRange(_ entity: Entity) -> Bool {
        guard let distance = distanceToEntity(entity) else { return false }
        return distance <= range
    }
    
    func clearTargets() {
        currentTargets.removeAll()
        delegate?.targetLost()
    }
}