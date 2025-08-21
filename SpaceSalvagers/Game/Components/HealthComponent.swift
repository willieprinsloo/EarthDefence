import Foundation
import QuartzCore

protocol HealthDelegate: AnyObject {
    func healthDidChange(current: Float, max: Float)
    func entityDidDie()
}

class HealthComponent: BaseComponent {
    // Health properties
    var currentHealth: Float {
        didSet {
            currentHealth = max(0, min(maxHealth, currentHealth))
            delegate?.healthDidChange(current: currentHealth, max: maxHealth)
            
            if currentHealth <= 0 && !isDead {
                die()
            }
        }
    }
    
    var maxHealth: Float {
        didSet {
            maxHealth = max(1, maxHealth)
            if currentHealth > maxHealth {
                currentHealth = maxHealth
            }
        }
    }
    
    // Defense properties
    var armor: Float = 0  // Flat damage reduction
    var resistance: Float = 0  // Percentage damage reduction (0-1)
    var shields: Float = 0
    var maxShields: Float = 0
    
    // Status
    private(set) var isDead = false
    weak var delegate: HealthDelegate?
    
    // Damage tracking
    private var recentDamage: [(amount: Float, timestamp: TimeInterval)] = []
    private let damageTrackingDuration: TimeInterval = 5.0
    
    init(health: Float, armor: Float = 0, resistance: Float = 0) {
        self.maxHealth = health
        self.currentHealth = health
        self.armor = armor
        self.resistance = min(0.9, max(0, resistance))  // Cap at 90% resistance
        super.init()
    }
    
    func takeDamage(_ rawDamage: Float, type: DamageType = .physical, isCritical: Bool = false) {
        guard !isDead else { return }
        
        var damage = rawDamage
        
        // Apply critical multiplier
        if isCritical {
            damage *= 1.5
        }
        
        // Apply damage type modifiers
        damage = applyDamageTypeModifiers(damage, type: type)
        
        // Apply shields first
        if shields > 0 {
            let shieldDamage = min(shields, damage)
            shields -= shieldDamage
            damage -= shieldDamage
        }
        
        // Apply armor (flat reduction)
        damage = max(1, damage - armor)  // Always deal at least 1 damage
        
        // Apply resistance (percentage reduction)
        damage *= (1 - resistance)
        
        // Apply damage
        currentHealth -= damage
        
        // Track damage for analytics
        trackDamage(damage)
        
        // Visual feedback
        showDamageNumber(damage, isCritical: isCritical)
    }
    
    func heal(_ amount: Float) {
        guard !isDead else { return }
        currentHealth += amount
    }
    
    func restoreShields(_ amount: Float) {
        shields = min(maxShields, shields + amount)
    }
    
    private func applyDamageTypeModifiers(_ damage: Float, type: DamageType) -> Float {
        // Can be extended for type-specific resistances
        switch type {
        case .energy:
            // Energy damage bypasses some armor
            return damage
        case .physical:
            return damage
        case .electric:
            // Electric damage is effective against shields
            if shields > 0 {
                return damage * 1.5
            }
            return damage
        case .toxic:
            // Toxic damage ignores armor
            return damage
        }
    }
    
    private func trackDamage(_ amount: Float) {
        let now = CACurrentMediaTime()
        recentDamage.append((amount: amount, timestamp: now))
        
        // Clean old entries
        recentDamage = recentDamage.filter { now - $0.timestamp < damageTrackingDuration }
    }
    
    private func showDamageNumber(_ damage: Float, isCritical: Bool) {
        // This would trigger visual damage numbers in the game
        NotificationCenter.default.post(
            name: .damageDealt,
            object: nil,
            userInfo: [
                "entity": entity as Any,
                "damage": damage,
                "isCritical": isCritical
            ]
        )
    }
    
    private func die() {
        isDead = true
        delegate?.entityDidDie()
        
        // Notify systems
        NotificationCenter.default.post(
            name: .entityDied,
            object: nil,
            userInfo: ["entity": entity as Any]
        )
    }
    
    func getDPS() -> Float {
        let now = CACurrentMediaTime()
        let recentDamageTotal = recentDamage
            .filter { now - $0.timestamp < 1.0 }
            .reduce(0) { $0 + $1.amount }
        return recentDamageTotal
    }
    
    var healthPercentage: Float {
        return currentHealth / maxHealth
    }
    
    var isAlive: Bool {
        return !isDead && currentHealth > 0
    }
}

enum DamageType {
    case physical
    case energy
    case electric
    case toxic
}

// Notification names
extension Notification.Name {
    static let damageDealt = Notification.Name("DamageDealt")
    static let entityDied = Notification.Name("EntityDied")
}