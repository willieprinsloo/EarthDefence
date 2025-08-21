import SpriteKit

class ParticleEffectsManager {
    static let shared = ParticleEffectsManager()
    
    private init() {}
    
    // MARK: - Explosion Effects
    
    func createExplosionEffect(at position: CGPoint, size: ExplosionSize = .medium) -> SKEmitterNode {
        let explosion = SKEmitterNode()
        
        explosion.position = position
        explosion.particleTexture = generateParticleTexture(type: .spark)
        
        switch size {
        case .small:
            explosion.numParticlesToEmit = 30
            explosion.particleLifetime = 0.5
            explosion.particleScale = 0.1
            explosion.particleScaleRange = 0.05
            explosion.particleSpeed = 100
            explosion.particleSpeedRange = 50
            
        case .medium:
            explosion.numParticlesToEmit = 60
            explosion.particleLifetime = 1.0
            explosion.particleScale = 0.2
            explosion.particleScaleRange = 0.1
            explosion.particleSpeed = 150
            explosion.particleSpeedRange = 75
            
        case .large:
            explosion.numParticlesToEmit = 120
            explosion.particleLifetime = 1.5
            explosion.particleScale = 0.3
            explosion.particleScaleRange = 0.15
            explosion.particleSpeed = 200
            explosion.particleSpeedRange = 100
        }
        
        // Common explosion properties
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleAlpha = 1.0
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -2.0
        explosion.particleScaleSpeed = -0.5
        explosion.particleColorBlendFactor = 1.0
        explosion.particleColorSequence = createExplosionColorSequence()
        explosion.particleBlendMode = .add
        
        return explosion
    }
    
    func createDebrisEffect(at position: CGPoint, intensity: Float = 1.0) -> SKEmitterNode {
        let debris = SKEmitterNode()
        
        debris.position = position
        debris.particleTexture = generateParticleTexture(type: .debris)
        debris.numParticlesToEmit = Int(20 * intensity)
        debris.particleLifetime = 2.0
        debris.particleLifetimeRange = 1.0
        debris.particleBirthRate = 100
        debris.emissionAngle = CGFloat.pi / 2
        debris.emissionAngleRange = CGFloat.pi * 2
        debris.particleSpeed = 80
        debris.particleSpeedRange = 40
        debris.particleScale = 0.1
        debris.particleScaleRange = 0.05
        debris.particleAlpha = 0.8
        debris.particleAlphaSpeed = -0.4
        debris.particleColorBlendFactor = 1.0
        debris.particleColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        debris.particleColorBlendFactor = 1.0
        debris.yAcceleration = -100  // Gravity effect
        debris.particleBlendMode = .alpha
        
        return debris
    }
    
    // MARK: - Weapon Effects
    
    func createLaserImpactEffect(at position: CGPoint) -> SKEmitterNode {
        let impact = SKEmitterNode()
        
        impact.position = position
        impact.particleTexture = generateParticleTexture(type: .energy)
        impact.numParticlesToEmit = 15
        impact.particleLifetime = 0.3
        impact.particleLifetimeRange = 0.1
        impact.emissionAngle = 0
        impact.emissionAngleRange = CGFloat.pi * 2
        impact.particleSpeed = 50
        impact.particleSpeedRange = 25
        impact.particleScale = 0.1
        impact.particleScaleRange = 0.05
        impact.particleAlpha = 1.0
        impact.particleAlphaSpeed = -3.0
        impact.particleColorBlendFactor = 1.0
        impact.particleColor = AssetManager.Colors.neonCyan
        impact.particleBlendMode = .add
        
        return impact
    }
    
    func createPlasmaImpactEffect(at position: CGPoint) -> SKEmitterNode {
        let impact = SKEmitterNode()
        
        impact.position = position
        impact.particleTexture = generateParticleTexture(type: .plasma)
        impact.numParticlesToEmit = 25
        impact.particleLifetime = 0.5
        impact.particleLifetimeRange = 0.2
        impact.emissionAngle = 0
        impact.emissionAngleRange = CGFloat.pi * 2
        impact.particleSpeed = 70
        impact.particleSpeedRange = 35
        impact.particleScale = 0.15
        impact.particleScaleRange = 0.08
        impact.particleAlpha = 1.0
        impact.particleAlphaSpeed = -2.0
        impact.particleColorBlendFactor = 1.0
        impact.particleColor = AssetManager.Colors.neonPurple
        impact.particleBlendMode = .add
        
        return impact
    }
    
    func createMissileExplosion(at position: CGPoint) -> SKEmitterNode {
        let explosion = SKEmitterNode()
        
        explosion.position = position
        explosion.particleTexture = generateParticleTexture(type: .fire)
        explosion.numParticlesToEmit = 80
        explosion.particleLifetime = 1.2
        explosion.particleLifetimeRange = 0.4
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 120
        explosion.particleSpeedRange = 60
        explosion.particleScale = 0.2
        explosion.particleScaleRange = 0.1
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -1.5
        explosion.particleScaleSpeed = -0.3
        explosion.particleColorBlendFactor = 1.0
        explosion.particleColorSequence = createFireColorSequence()
        explosion.particleBlendMode = .add
        
        return explosion
    }
    
    func createTeslaDischarge(from start: CGPoint, to end: CGPoint) -> SKEmitterNode {
        let discharge = SKEmitterNode()
        
        let midPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        discharge.position = midPoint
        discharge.particleTexture = generateParticleTexture(type: .lightning)
        discharge.numParticlesToEmit = 20
        discharge.particleLifetime = 0.2
        discharge.particleLifetimeRange = 0.1
        discharge.emissionAngle = atan2(end.y - start.y, end.x - start.x)
        discharge.emissionAngleRange = CGFloat.pi / 6
        discharge.particleSpeed = 0
        discharge.particleScale = 0.3
        discharge.particleScaleRange = 0.15
        discharge.particleAlpha = 1.0
        discharge.particleAlphaSpeed = -5.0
        discharge.particleColorBlendFactor = 1.0
        discharge.particleColor = AssetManager.Colors.neonYellow
        discharge.particleBlendMode = .add
        
        return discharge
    }
    
    // MARK: - Environmental Effects
    
    func createShieldHitEffect(at position: CGPoint) -> SKEmitterNode {
        let shieldHit = SKEmitterNode()
        
        shieldHit.position = position
        shieldHit.particleTexture = generateParticleTexture(type: .energy)
        shieldHit.numParticlesToEmit = 30
        shieldHit.particleLifetime = 0.8
        shieldHit.particleLifetimeRange = 0.2
        shieldHit.emissionAngle = 0
        shieldHit.emissionAngleRange = CGFloat.pi * 2
        shieldHit.particleSpeed = 40
        shieldHit.particleSpeedRange = 20
        shieldHit.particleScale = 0.08
        shieldHit.particleScaleRange = 0.04
        shieldHit.particleAlpha = 1.0
        shieldHit.particleAlphaSpeed = -1.25
        shieldHit.particleColorBlendFactor = 1.0
        shieldHit.particleColor = AssetManager.Colors.neonCyan
        shieldHit.particleColorBlendFactor = 1.0
        shieldHit.particleBlendMode = .add
        
        return shieldHit
    }
    
    func createTowerBuildEffect(at position: CGPoint) -> SKEmitterNode {
        let buildEffect = SKEmitterNode()
        
        buildEffect.position = position
        buildEffect.particleTexture = generateParticleTexture(type: .hologram)
        buildEffect.numParticlesToEmit = 50
        buildEffect.particleLifetime = 1.5
        buildEffect.particleLifetimeRange = 0.5
        buildEffect.emissionAngle = CGFloat.pi / 2
        buildEffect.emissionAngleRange = CGFloat.pi / 4
        buildEffect.particleSpeed = 30
        buildEffect.particleSpeedRange = 15
        buildEffect.particleScale = 0.05
        buildEffect.particleScaleRange = 0.02
        buildEffect.particleAlpha = 0.8
        buildEffect.particleAlphaSpeed = -0.5
        buildEffect.particleColorBlendFactor = 1.0
        buildEffect.particleColor = AssetManager.Colors.hologramBlue
        buildEffect.particleBlendMode = .add
        buildEffect.yAcceleration = 20  // Rising effect
        
        return buildEffect
    }
    
    func createStarField(in rect: CGRect) -> SKEmitterNode {
        let starField = SKEmitterNode()
        
        starField.position = CGPoint(x: rect.midX, y: rect.maxY + 20)
        starField.particleTexture = generateParticleTexture(type: .star)
        starField.particleBirthRate = 2
        starField.numParticlesToEmit = 0  // Continuous emission
        starField.particleLifetime = 10.0
        starField.particleLifetimeRange = 5.0
        starField.emissionAngle = CGFloat.pi * 3 / 2
        starField.emissionAngleRange = CGFloat.pi / 8
        starField.particleSpeed = 20
        starField.particleSpeedRange = 10
        starField.particleScale = 0.02
        starField.particleScaleRange = 0.01
        starField.particleAlpha = 0.6
        starField.particleAlphaRange = 0.4
        starField.particleColorBlendFactor = 1.0
        starField.particleColor = SKColor.white
        starField.particleColorBlendFactor = 1.0
        starField.particleBlendMode = .add
        starField.targetNode = starField.parent
        
        return starField
    }
    
    func createSpaceDust(in rect: CGRect) -> SKEmitterNode {
        let spaceDust = SKEmitterNode()
        
        spaceDust.position = CGPoint(x: rect.minX - 20, y: rect.midY)
        spaceDust.particleTexture = generateParticleTexture(type: .dust)
        spaceDust.particleBirthRate = 5
        spaceDust.numParticlesToEmit = 0  // Continuous emission
        spaceDust.particleLifetime = 8.0
        spaceDust.particleLifetimeRange = 4.0
        spaceDust.emissionAngle = 0
        spaceDust.emissionAngleRange = CGFloat.pi / 6
        spaceDust.particleSpeed = 15
        spaceDust.particleSpeedRange = 8
        spaceDust.particleScale = 0.01
        spaceDust.particleScaleRange = 0.005
        spaceDust.particleAlpha = 0.3
        spaceDust.particleAlphaRange = 0.2
        spaceDust.particleColorBlendFactor = 1.0
        spaceDust.particleColor = SKColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
        spaceDust.particleBlendMode = .add
        spaceDust.targetNode = spaceDust.parent
        
        return spaceDust
    }
    
    // MARK: - Engine Effects
    
    func createEngineTrail(for node: SKNode, enginePositions: [CGPoint]) -> [SKEmitterNode] {
        var engines: [SKEmitterNode] = []
        
        for position in enginePositions {
            let engine = SKEmitterNode()
            
            engine.position = position
            engine.particleTexture = generateParticleTexture(type: .fire)
            engine.particleBirthRate = 20
            engine.numParticlesToEmit = 0  // Continuous emission
            engine.particleLifetime = 0.8
            engine.particleLifetimeRange = 0.2
            engine.emissionAngle = CGFloat.pi
            engine.emissionAngleRange = CGFloat.pi / 8
            engine.particleSpeed = 80
            engine.particleSpeedRange = 20
            engine.particleScale = 0.08
            engine.particleScaleRange = 0.03
            engine.particleAlpha = 0.8
            engine.particleAlphaSpeed = -1.0
            engine.particleScaleSpeed = -0.1
            engine.particleColorBlendFactor = 1.0
            engine.particleColorSequence = createEngineColorSequence()
            engine.particleBlendMode = .add
            engine.targetNode = node
            
            engines.append(engine)
        }
        
        return engines
    }
    
    // MARK: - Helper Methods
    
    enum ExplosionSize {
        case small, medium, large
    }
    
    enum ParticleType {
        case spark, debris, energy, plasma, fire, lightning, hologram, star, dust
    }
    
    // Make createParticleTexture method public for use in other classes
    func createParticleTexture(type: ParticleType) -> SKTexture {
        return generateParticleTexture(type: type)
    }
    
    private func generateParticleTexture(type: ParticleType) -> SKTexture {
        let size: CGSize
        
        switch type {
        case .spark, .energy, .lightning:
            size = CGSize(width: 8, height: 8)
        case .debris:
            size = CGSize(width: 4, height: 4)
        case .plasma:
            size = CGSize(width: 12, height: 12)
        case .fire:
            size = CGSize(width: 16, height: 16)
        case .hologram:
            size = CGSize(width: 6, height: 6)
        case .star, .dust:
            size = CGSize(width: 2, height: 2)
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = min(size.width, size.height) / 2
            
            switch type {
            case .spark:
                // Bright spark particle
                let sparkGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    AssetManager.Colors.neonCyan.cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.5, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    sparkGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .debris:
                // Irregular debris chunk
                context.cgContext.setFillColor(SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0).cgColor)
                let debrisRect = CGRect(x: center.x - radius/2, y: center.y - radius/2, 
                                      width: radius, height: radius)
                context.cgContext.fill(debrisRect)
                
            case .energy:
                // Energy particle with glow
                let energyGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    AssetManager.Colors.neonCyan.cgColor,
                    AssetManager.Colors.neonCyan.withAlphaComponent(0.5).cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.3, 0.7, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    energyGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .plasma:
                // Plasma orb particle
                let plasmaGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    AssetManager.Colors.neonPurple.cgColor,
                    AssetManager.Colors.neonPurple.withAlphaComponent(0.6).cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.4, 0.8, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    plasmaGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .fire:
                // Fire particle
                let fireGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    AssetManager.Colors.neonOrange.cgColor,
                    AssetManager.Colors.neonRed.cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.3, 0.7, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    fireGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .lightning:
                // Lightning particle
                let lightningGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    AssetManager.Colors.neonYellow.cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.6, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    lightningGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .hologram:
                // Holographic particle
                let hologramGradient = CGGradient(colorsSpace: nil, colors: [
                    AssetManager.Colors.hologramBlue.cgColor,
                    AssetManager.Colors.hologramBlue.withAlphaComponent(0.5).cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.5, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    hologramGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
            case .star:
                // Star particle
                context.cgContext.setFillColor(SKColor.white.cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                                        width: radius * 2, height: radius * 2))
                
            case .dust:
                // Space dust particle
                context.cgContext.setFillColor(SKColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 0.6).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                                        width: radius * 2, height: radius * 2))
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func createExplosionColorSequence() -> SKKeyframeSequence {
        let colors = [
            SKColor.white,
            AssetManager.Colors.neonOrange,
            AssetManager.Colors.neonRed,
            SKColor(red: 0.3, green: 0.1, blue: 0.0, alpha: 1.0)
        ]
        
        return SKKeyframeSequence(keyframeValues: colors, times: [0.0, 0.2, 0.6, 1.0])
    }
    
    private func createFireColorSequence() -> SKKeyframeSequence {
        let colors = [
            SKColor.white,
            AssetManager.Colors.neonOrange,
            AssetManager.Colors.neonRed,
            SKColor(red: 0.2, green: 0.0, blue: 0.0, alpha: 1.0)
        ]
        
        return SKKeyframeSequence(keyframeValues: colors, times: [0.0, 0.3, 0.7, 1.0])
    }
    
    private func createEngineColorSequence() -> SKKeyframeSequence {
        let colors = [
            SKColor.white,
            AssetManager.Colors.neonOrange,
            AssetManager.Colors.neonRed.withAlphaComponent(0.8),
            SKColor.clear
        ]
        
        return SKKeyframeSequence(keyframeValues: colors, times: [0.0, 0.2, 0.8, 1.0])
    }
}