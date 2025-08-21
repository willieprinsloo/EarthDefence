import SpriteKit

class StationCore: SKNode {
    
    // MARK: - Properties
    
    private var maxHealth: Int = 20
    private var currentHealth: Int = 20
    private var coreRadius: CGFloat = 50
    
    // Visual components
    private var coreBody: SKSpriteNode!
    private var shieldLayer: SKNode!
    private var energyCore: SKSpriteNode!
    private var damageOverlay: SKSpriteNode!
    private var healthBar: HealthBar!
    
    // Effects
    private var shieldParticles: SKEmitterNode?
    private var energyParticles: SKEmitterNode?
    private var damageParticles: SKEmitterNode?
    
    // Animation states
    private var pulseAction: SKAction!
    private var rotationAction: SKAction!
    private var shieldAction: SKAction!
    
    // Damage state
    enum DamageState {
        case healthy    // 80-100% health
        case damaged    // 40-80% health
        case critical   // 1-40% health
        case destroyed  // 0% health
    }
    
    private var currentDamageState: DamageState = .healthy
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupCore()
        setupVisualEffects()
        setupAnimations()
        updateDamageState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupCore() {
        name = "stationCore"
        zPosition = 100
        
        // Create core body with energy texture
        coreBody = SKSpriteNode(texture: generateCoreTexture())
        coreBody.size = CGSize(width: coreRadius * 2, height: coreRadius * 2)
        coreBody.zPosition = 0
        addChild(coreBody)
        
        // Create energy core overlay
        energyCore = SKSpriteNode(texture: generateEnergyCoreTexture())
        energyCore.size = CGSize(width: coreRadius * 1.5, height: coreRadius * 1.5)
        energyCore.zPosition = 1
        energyCore.blendMode = .add
        addChild(energyCore)
        
        // Create shield layer
        shieldLayer = SKNode()
        shieldLayer.zPosition = 2
        addChild(shieldLayer)
        
        let shieldRing = SKSpriteNode(texture: generateShieldTexture())
        shieldRing.size = CGSize(width: coreRadius * 2.5, height: coreRadius * 2.5)
        shieldRing.alpha = 0.7
        shieldRing.blendMode = .add
        shieldLayer.addChild(shieldRing)
        
        // Create damage overlay (initially hidden)
        damageOverlay = SKSpriteNode(texture: generateDamageTexture())
        damageOverlay.size = CGSize(width: coreRadius * 2, height: coreRadius * 2)
        damageOverlay.zPosition = 3
        damageOverlay.alpha = 0.0
        damageOverlay.blendMode = .multiply
        addChild(damageOverlay)
        
        // Create health bar
        healthBar = HealthBar(maxHealth: maxHealth)
        healthBar.position = CGPoint(x: 0, y: coreRadius + 30)
        healthBar.zPosition = 4
        addChild(healthBar)
    }
    
    private func setupVisualEffects() {
        // Shield energy particles
        shieldParticles = ParticleEffectsManager.shared.createShieldHitEffect(at: CGPoint.zero)
        shieldParticles?.particleBirthRate = 3
        shieldParticles?.numParticlesToEmit = 0  // Continuous
        shieldParticles?.targetNode = self
        shieldLayer.addChild(shieldParticles!)
        
        // Core energy particles
        energyParticles = SKEmitterNode()
        energyParticles?.position = CGPoint.zero
        energyParticles?.particleTexture = ParticleEffectsManager.shared.createParticleTexture(type: .energy)
        energyParticles?.particleBirthRate = 8
        energyParticles?.numParticlesToEmit = 0
        energyParticles?.particleLifetime = 2.0
        energyParticles?.particleLifetimeRange = 1.0
        energyParticles?.emissionAngle = 0
        energyParticles?.emissionAngleRange = CGFloat.pi * 2
        energyParticles?.particleSpeed = 20
        energyParticles?.particleSpeedRange = 10
        energyParticles?.particleScale = 0.05
        energyParticles?.particleScaleRange = 0.02
        energyParticles?.particleAlpha = 0.6
        energyParticles?.particleAlphaSpeed = -0.3
        energyParticles?.particleColorBlendFactor = 1.0
        energyParticles?.particleColor = AssetManager.Colors.neonCyan
        energyParticles?.particleBlendMode = .add
        energyParticles?.targetNode = self
        addChild(energyParticles!)
    }
    
    private func setupAnimations() {
        // Core pulsing animation
        let pulseUp = SKAction.scale(to: 1.1, duration: 2.0)
        let pulseDown = SKAction.scale(to: 1.0, duration: 2.0)
        pulseAction = SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown]))
        energyCore.run(pulseAction)
        
        // Core rotation
        rotationAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0))
        energyCore.run(rotationAction)
        
        // Shield shimmer effect
        let shimmerAlpha = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.5),
            SKAction.fadeAlpha(to: 0.8, duration: 1.5)
        ])
        shieldAction = SKAction.repeatForever(shimmerAlpha)
        shieldLayer.run(shieldAction)
    }
    
    // MARK: - Texture Generation
    
    private func generateCoreTexture() -> SKTexture {
        let size = CGSize(width: coreRadius * 2, height: coreRadius * 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Outer core shell
            let shellGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0).cgColor,
                SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0).cgColor,
                SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                shellGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: coreRadius,
                options: []
            )
            
            // Inner energy chamber
            let energyGradient = CGGradient(colorsSpace: nil, colors: [
                AssetManager.Colors.neonCyan.withAlphaComponent(0.8).cgColor,
                AssetManager.Colors.neonCyan.withAlphaComponent(0.4).cgColor,
                SKColor.clear.cgColor
            ] as CFArray, locations: [0.0, 0.7, 1.0])!
            
            context.cgContext.drawRadialGradient(
                energyGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: coreRadius * 0.8,
                options: []
            )
            
            // Core details - hexagonal pattern
            context.cgContext.setStrokeColor(AssetManager.Colors.neonCyan.withAlphaComponent(0.6).cgColor)
            context.cgContext.setLineWidth(2.0)
            
            for radius in [coreRadius * 0.3, coreRadius * 0.5, coreRadius * 0.7] {
                let hexPath = CGMutablePath()
                for i in 0..<6 {
                    let angle = CGFloat(i) * .pi / 3
                    let x = center.x + radius * cos(angle)
                    let y = center.y + radius * sin(angle)
                    
                    if i == 0 {
                        hexPath.move(to: CGPoint(x: x, y: y))
                    } else {
                        hexPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                hexPath.closeSubpath()
                context.cgContext.addPath(hexPath)
                context.cgContext.strokePath()
            }
            
            // Central power indicator
            context.cgContext.setFillColor(SKColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10))
        }
        
        return SKTexture(image: image)
    }
    
    private func generateEnergyCoreTexture() -> SKTexture {
        let size = CGSize(width: coreRadius * 1.5, height: coreRadius * 1.5)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = min(size.width, size.height) / 2
            
            // Central energy orb
            let energyGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                AssetManager.Colors.neonCyan.cgColor,
                AssetManager.Colors.neonCyan.withAlphaComponent(0.6).cgColor,
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
            
            // Energy streams
            context.cgContext.setStrokeColor(AssetManager.Colors.neonCyan.withAlphaComponent(0.8).cgColor)
            context.cgContext.setLineWidth(1.0)
            
            for angle in stride(from: 0, to: 360, by: 30) {
                let startRadius: CGFloat = radius * 0.3
                let endRadius: CGFloat = radius * 0.9
                let startX = center.x + startRadius * cos(CGFloat(angle) * .pi / 180)
                let startY = center.y + startRadius * sin(CGFloat(angle) * .pi / 180)
                let endX = center.x + endRadius * cos(CGFloat(angle) * .pi / 180)
                let endY = center.y + endRadius * sin(CGFloat(angle) * .pi / 180)
                
                context.cgContext.move(to: CGPoint(x: startX, y: startY))
                context.cgContext.addLine(to: CGPoint(x: endX, y: endY))
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateShieldTexture() -> SKTexture {
        let size = CGSize(width: coreRadius * 2.5, height: coreRadius * 2.5)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = min(size.width, size.height) / 2
            
            // Shield dome effect with hexagonal pattern
            context.cgContext.setStrokeColor(AssetManager.Colors.neonCyan.withAlphaComponent(0.4).cgColor)
            context.cgContext.setLineWidth(1.5)
            
            // Multiple shield layers
            for layerRadius in [radius * 0.8, radius * 0.9, radius] {
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - layerRadius, y: center.y - layerRadius,
                                                          width: layerRadius * 2, height: layerRadius * 2))
            }
            
            // Hexagonal grid pattern
            let hexSize = radius * 0.15
            for angle in stride(from: 0, to: 360, by: 60) {
                let hexCenter = CGPoint(
                    x: center.x + radius * 0.7 * cos(CGFloat(angle) * .pi / 180),
                    y: center.y + radius * 0.7 * sin(CGFloat(angle) * .pi / 180)
                )
                
                let hexPath = CGMutablePath()
                for i in 0..<6 {
                    let hexAngle = CGFloat(i) * .pi / 3
                    let x = hexCenter.x + hexSize * cos(hexAngle)
                    let y = hexCenter.y + hexSize * sin(hexAngle)
                    
                    if i == 0 {
                        hexPath.move(to: CGPoint(x: x, y: y))
                    } else {
                        hexPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                hexPath.closeSubpath()
                context.cgContext.addPath(hexPath)
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateDamageTexture() -> SKTexture {
        let size = CGSize(width: coreRadius * 2, height: coreRadius * 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Damage cracks and scorch marks
            context.cgContext.setStrokeColor(SKColor(red: 0.2, green: 0.1, blue: 0.0, alpha: 0.8).cgColor)
            context.cgContext.setLineWidth(2.0)
            
            // Random crack patterns
            for _ in 0..<8 {
                let startAngle = CGFloat.random(in: 0...(2 * .pi))
                let endAngle = startAngle + CGFloat.random(in: -0.5...0.5)
                let startRadius = CGFloat.random(in: coreRadius * 0.2...coreRadius * 0.6)
                let endRadius = CGFloat.random(in: coreRadius * 0.6...coreRadius * 0.9)
                
                let startX = center.x + startRadius * cos(startAngle)
                let startY = center.y + startRadius * sin(startAngle)
                let endX = center.x + endRadius * cos(endAngle)
                let endY = center.y + endRadius * sin(endAngle)
                
                context.cgContext.move(to: CGPoint(x: startX, y: startY))
                context.cgContext.addLine(to: CGPoint(x: endX, y: endY))
            }
            context.cgContext.strokePath()
            
            // Burn marks
            for _ in 0..<5 {
                let burnAngle = CGFloat.random(in: 0...(2 * .pi))
                let burnRadius = CGFloat.random(in: coreRadius * 0.3...coreRadius * 0.8)
                let burnSize = CGFloat.random(in: 5...15)
                
                let burnX = center.x + burnRadius * cos(burnAngle)
                let burnY = center.y + burnRadius * sin(burnAngle)
                
                context.cgContext.setFillColor(SKColor(red: 0.15, green: 0.05, blue: 0.0, alpha: 0.6).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: burnX - burnSize/2, y: burnY - burnSize/2,
                                                        width: burnSize, height: burnSize))
            }
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Health Management
    
    func takeDamage(_ amount: Int) {
        currentHealth = max(0, currentHealth - amount)
        healthBar.updateHealth(currentHealth)
        
        let newDamageState = getDamageState()
        if newDamageState != currentDamageState {
            currentDamageState = newDamageState
            updateDamageState()
        }
        
        // Create damage effect
        let damageEffect = ParticleEffectsManager.shared.createShieldHitEffect(at: CGPoint.zero)
        addChild(damageEffect)
        
        // Remove effect after animation
        damageEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
        
        // Screen shake on critical damage
        if currentDamageState == .critical {
            createScreenShake()
        }
        
        if currentHealth <= 0 {
            destroyCore()
        }
    }
    
    func healDamage(_ amount: Int) {
        currentHealth = min(maxHealth, currentHealth + amount)
        healthBar.updateHealth(currentHealth)
        
        let newDamageState = getDamageState()
        if newDamageState != currentDamageState {
            currentDamageState = newDamageState
            updateDamageState()
        }
    }
    
    private func getDamageState() -> DamageState {
        let healthPercentage = Float(currentHealth) / Float(maxHealth)
        
        switch healthPercentage {
        case 0.8...1.0:
            return .healthy
        case 0.4...0.8:
            return .damaged
        case 0.01...0.4:
            return .critical
        default:
            return .destroyed
        }
    }
    
    private func updateDamageState() {
        switch currentDamageState {
        case .healthy:
            damageOverlay.alpha = 0.0
            shieldLayer.alpha = 0.8
            energyCore.colorBlendFactor = 0.0
            shieldParticles?.particleBirthRate = 3
            energyParticles?.particleBirthRate = 8
            removeDamageParticles()
            
        case .damaged:
            damageOverlay.alpha = 0.3
            shieldLayer.alpha = 0.6
            energyCore.colorBlendFactor = 0.2
            energyCore.color = AssetManager.Colors.neonYellow
            shieldParticles?.particleBirthRate = 2
            energyParticles?.particleBirthRate = 6
            addSparksEffect()
            
        case .critical:
            damageOverlay.alpha = 0.6
            shieldLayer.alpha = 0.3
            energyCore.colorBlendFactor = 0.4
            energyCore.color = AssetManager.Colors.neonRed
            shieldParticles?.particleBirthRate = 1
            energyParticles?.particleBirthRate = 4
            addCriticalDamageEffect()
            
        case .destroyed:
            destroyCore()
        }
    }
    
    private func addSparksEffect() {
        removeDamageParticles()
        
        damageParticles = SKEmitterNode()
        damageParticles?.position = CGPoint.zero
        damageParticles?.particleTexture = ParticleEffectsManager.shared.createParticleTexture(type: .spark)
        damageParticles?.particleBirthRate = 5
        damageParticles?.numParticlesToEmit = 0
        damageParticles?.particleLifetime = 1.0
        damageParticles?.particleLifetimeRange = 0.5
        damageParticles?.emissionAngle = 0
        damageParticles?.emissionAngleRange = CGFloat.pi * 2
        damageParticles?.particleSpeed = 30
        damageParticles?.particleSpeedRange = 15
        damageParticles?.particleScale = 0.03
        damageParticles?.particleScaleRange = 0.01
        damageParticles?.particleAlpha = 0.8
        damageParticles?.particleAlphaSpeed = -0.8
        damageParticles?.particleColorBlendFactor = 1.0
        damageParticles?.particleColor = AssetManager.Colors.neonYellow
        damageParticles?.particleBlendMode = .add
        damageParticles?.targetNode = self
        
        addChild(damageParticles!)
    }
    
    private func addCriticalDamageEffect() {
        removeDamageParticles()
        
        damageParticles = SKEmitterNode()
        damageParticles?.position = CGPoint.zero
        damageParticles?.particleTexture = ParticleEffectsManager.shared.createParticleTexture(type: .fire)
        damageParticles?.particleBirthRate = 10
        damageParticles?.numParticlesToEmit = 0
        damageParticles?.particleLifetime = 1.5
        damageParticles?.particleLifetimeRange = 0.8
        damageParticles?.emissionAngle = 0
        damageParticles?.emissionAngleRange = CGFloat.pi * 2
        damageParticles?.particleSpeed = 40
        damageParticles?.particleSpeedRange = 20
        damageParticles?.particleScale = 0.05
        damageParticles?.particleScaleRange = 0.02
        damageParticles?.particleAlpha = 1.0
        damageParticles?.particleAlphaSpeed = -0.7
        damageParticles?.particleColorBlendFactor = 1.0
        damageParticles?.particleColor = AssetManager.Colors.neonRed
        damageParticles?.particleBlendMode = .add
        damageParticles?.targetNode = self
        
        addChild(damageParticles!)
        
        // Add flickering effect to core
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        energyCore.run(SKAction.repeatForever(flicker))
    }
    
    private func removeDamageParticles() {
        damageParticles?.removeFromParent()
        damageParticles = nil
    }
    
    private func createScreenShake() {
        guard let scene = scene else { return }
        
        let shakeAmount: CGFloat = 10
        let shakeDuration: TimeInterval = 0.5
        
        let shakeLeft = SKAction.moveBy(x: -shakeAmount, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: shakeAmount * 2, y: 0, duration: 0.05)
        let shakeReturn = SKAction.moveBy(x: -shakeAmount, y: 0, duration: 0.05)
        
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeReturn])
        let repeatShake = SKAction.repeat(shakeSequence, count: Int(shakeDuration / 0.15))
        
        scene.run(repeatShake)
    }
    
    private func destroyCore() {
        // Create massive explosion
        let explosion = ParticleEffectsManager.shared.createExplosionEffect(at: CGPoint.zero, size: .large)
        parent?.addChild(explosion)
        
        // Create debris
        let debris = ParticleEffectsManager.shared.createDebrisEffect(at: CGPoint.zero, intensity: 2.0)
        parent?.addChild(debris)
        
        // Remove core after explosion
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, remove]))
        
        // Notify game of core destruction
        NotificationCenter.default.post(name: NSNotification.Name("CoreDestroyed"), object: nil)
    }
    
    // MARK: - Public Interface
    
    var health: Int {
        return currentHealth
    }
    
    var maxHealthValue: Int {
        return maxHealth
    }
    
    var isDestroyed: Bool {
        return currentHealth <= 0
    }
    
    func setMaxHealth(_ newMaxHealth: Int) {
        maxHealth = newMaxHealth
        currentHealth = newMaxHealth
        healthBar.updateMaxHealth(newMaxHealth)
        healthBar.updateHealth(currentHealth)
    }
}

// MARK: - Health Bar Component

class HealthBar: SKNode {
    
    private var background: SKSpriteNode!
    private var fillBar: SKSpriteNode!
    private var maxHealth: Int
    private var currentHealth: Int
    
    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        super.init()
        setupHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHealthBar() {
        // Background
        background = SKSpriteNode(texture: AssetManager.shared.getTexture(named: "ui_health_background"))
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        
        // Fill bar
        fillBar = SKSpriteNode(texture: AssetManager.shared.getTexture(named: "ui_health_fill_green"))
        fillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillBar.position = CGPoint(x: -background.size.width/2 + 1, y: 0)
        addChild(fillBar)
    }
    
    func updateHealth(_ newHealth: Int) {
        currentHealth = max(0, min(maxHealth, newHealth))
        
        let healthPercentage = Float(currentHealth) / Float(maxHealth)
        let newWidth = background.size.width * CGFloat(healthPercentage) - 2
        
        // Update fill bar width
        fillBar.size.width = max(0, newWidth)
        
        // Update color based on health percentage
        let fillTexture: String
        if healthPercentage > 0.6 {
            fillTexture = "ui_health_fill_green"
        } else if healthPercentage > 0.3 {
            fillTexture = "ui_health_fill_yellow"
        } else {
            fillTexture = "ui_health_fill_red"
        }
        
        fillBar.texture = AssetManager.shared.getTexture(named: fillTexture)
        
        // Add pulse effect on damage
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        run(pulse)
    }
    
    func updateMaxHealth(_ newMaxHealth: Int) {
        maxHealth = newMaxHealth
    }
}