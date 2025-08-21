import Foundation
import simd

class MovementComponent: BaseComponent {
    var velocity: SIMD2<Float> = .zero
    var maxSpeed: Float = 100.0
    var acceleration: Float = 200.0
    var deceleration: Float = 150.0
    
    // Status effects
    var speedMultiplier: Float = 1.0
    private var speedModifiers: [(multiplier: Float, duration: TimeInterval)] = []
    
    private var transform: TransformComponent?
    
    override func awake() {
        super.awake()
        transform = entity?.getComponent(TransformComponent.self)
    }
    
    override func update(deltaTime: TimeInterval) {
        guard let transform = transform else { return }
        
        // Update speed modifiers
        updateSpeedModifiers(deltaTime: deltaTime)
        
        // Apply velocity with speed multiplier
        let effectiveVelocity = velocity * speedMultiplier
        transform.position += effectiveVelocity * Float(deltaTime)
        
        // Apply deceleration if no active movement
        if length_squared(velocity) > 0.01 {
            let decelerationAmount = deceleration * Float(deltaTime)
            let currentSpeed = length(velocity)
            
            if currentSpeed > decelerationAmount {
                velocity = normalize(velocity) * (currentSpeed - decelerationAmount)
            } else {
                velocity = .zero
            }
        }
    }
    
    func move(direction: SIMD2<Float>, deltaTime: TimeInterval) {
        let normalizedDirection = length_squared(direction) > 0 ? normalize(direction) : .zero
        let targetVelocity = normalizedDirection * maxSpeed
        
        // Smooth acceleration towards target velocity
        let difference = targetVelocity - velocity
        let accelerationAmount = acceleration * Float(deltaTime)
        
        if length_squared(difference) > accelerationAmount * accelerationAmount {
            velocity += normalize(difference) * accelerationAmount
        } else {
            velocity = targetVelocity
        }
        
        // Clamp to max speed
        if length_squared(velocity) > maxSpeed * maxSpeed {
            velocity = normalize(velocity) * maxSpeed
        }
    }
    
    func applyImpulse(_ impulse: SIMD2<Float>) {
        velocity += impulse
        
        // Clamp to max speed
        if length_squared(velocity) > maxSpeed * maxSpeed {
            velocity = normalize(velocity) * maxSpeed
        }
    }
    
    func applySlow(multiplier: Float, duration: TimeInterval) {
        speedModifiers.append((multiplier: multiplier, duration: duration))
        updateSpeedMultiplier()
    }
    
    func stop() {
        velocity = .zero
    }
    
    private func updateSpeedModifiers(deltaTime: TimeInterval) {
        // Update and remove expired modifiers
        speedModifiers = speedModifiers.compactMap { modifier in
            let remainingDuration = modifier.duration - deltaTime
            if remainingDuration > 0 {
                return (modifier.multiplier, remainingDuration)
            }
            return nil
        }
        
        updateSpeedMultiplier()
    }
    
    private func updateSpeedMultiplier() {
        // Calculate combined speed multiplier (multiplicative stacking)
        speedMultiplier = speedModifiers.reduce(1.0) { result, modifier in
            result * modifier.multiplier
        }
        
        // Clamp between reasonable bounds
        speedMultiplier = max(0.1, min(2.0, speedMultiplier))
    }
}