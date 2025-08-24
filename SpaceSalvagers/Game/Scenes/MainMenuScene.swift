import SpriteKit

class MainMenuScene: SKScene {
    
    private var playButton: SKShapeNode!
    private var settingsButton: SKShapeNode!
    private var titleLabel: SKLabelNode!
    
    // Background layers
    private var backgroundLayer: SKNode!
    private var galaxyLayer: SKNode!
    private var planetLayer: SKNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Use center anchor point for consistent positioning
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        
        // Start background music for main menu
        // SoundManager.shared.playBackgroundMusic(.menuMusic)  // Disabled startup sound
        
        // Create background layers
        setupBackgroundLayers()
        createGalaxyBackground()
        createPlanets()
        
        createTitle()
        createButtons()
        addBackgroundEffects()
        addSpaceDebris()
        addCosmicDust()
    }
    
    private func createTitle() {
        // Create logo container for all elements
        let logoContainer = SKNode()
        logoContainer.position = CGPoint(x: 0, y: size.height * 0.25)
        logoContainer.zPosition = 100
        
        // Main title with metallic gradient effect
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "STELLAR INVASION"
        titleLabel.fontSize = 64
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.85, alpha: 1.0)
        titleLabel.horizontalAlignmentMode = .center
        
        // Add metallic shine effect with red invasion tint
        let shineLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        shineLabel.text = "STELLAR INVASION"
        shineLabel.fontSize = 64
        shineLabel.fontColor = SKColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 0.6)
        shineLabel.position = CGPoint(x: -2, y: 2)
        shineLabel.blendMode = .add
        titleLabel.addChild(shineLabel)
        
        // Add deep space glow layers with invasion theme (red-orange)
        for i in 1...4 {
            let glow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            glow.text = "STELLAR INVASION"
            glow.fontSize = 64
            let glowIntensity = 0.6 / CGFloat(i)
            glow.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.2, alpha: glowIntensity)
            glow.position = .zero
            glow.blendMode = .add
            glow.setScale(1.0 + (CGFloat(i) * 0.03))
            glow.zPosition = -CGFloat(i)
            titleLabel.addChild(glow)
        }
        
        // Add cosmic energy effect behind text
        let energyRing = SKShapeNode(circleOfRadius: 180)
        energyRing.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3)
        energyRing.lineWidth = 2
        energyRing.glowWidth = 15
        energyRing.position = CGPoint(x: 0, y: 10)
        energyRing.zPosition = -10
        energyRing.xScale = 2.0
        energyRing.yScale = 0.4
        logoContainer.addChild(energyRing)
        
        // Add planet icon elements
        let planetIcon = SKShapeNode(circleOfRadius: 25)
        planetIcon.position = CGPoint(x: -240, y: 5)
        planetIcon.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8)
        planetIcon.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        planetIcon.lineWidth = 2
        planetIcon.glowWidth = 8
        logoContainer.addChild(planetIcon)
        
        // Add ring around planet
        let ring = SKShapeNode(ellipseOf: CGSize(width: 60, height: 20))
        ring.position = planetIcon.position
        ring.strokeColor = SKColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 0.7)
        ring.lineWidth = 1.5
        ring.glowWidth = 3
        ring.zRotation = -0.3
        logoContainer.addChild(ring)
        
        // Mirror planet on right side
        let planetIcon2 = planetIcon.copy() as! SKShapeNode
        planetIcon2.position = CGPoint(x: 240, y: 5)
        logoContainer.addChild(planetIcon2)
        
        let ring2 = ring.copy() as! SKShapeNode
        ring2.position = planetIcon2.position
        ring2.zRotation = 0.3
        logoContainer.addChild(ring2)
        
        // Enhanced subtitle with better styling
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitle.text = "EARTH'S LAST DEFENSE"
        subtitle.fontSize = 20
        subtitle.fontColor = SKColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)
        subtitle.position = CGPoint(x: 0, y: -45)
        
        // Subtitle glow
        let subtitleGlow = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitleGlow.text = "EARTH'S LAST DEFENSE"
        subtitleGlow.fontSize = 20
        subtitleGlow.fontColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.4)
        subtitleGlow.position = .zero
        subtitleGlow.blendMode = .add
        subtitleGlow.setScale(1.05)
        subtitle.addChild(subtitleGlow)
        
        logoContainer.addChild(titleLabel)
        logoContainer.addChild(subtitle)
        addChild(logoContainer)
        
        // Animate the entire logo
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 3.0),
            SKAction.scale(to: 1.0, duration: 3.0)
        ])
        logoContainer.run(SKAction.repeatForever(pulse))
        
        // Animate energy ring rotation
        let rotateRing = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        energyRing.run(SKAction.repeatForever(rotateRing))
        
        // Animate planet icons
        let planetPulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        planetIcon.run(SKAction.repeatForever(planetPulse))
        planetIcon2.run(SKAction.repeatForever(planetPulse))
        
        // Rotate rings around planets
        let rotateRings = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        ring.run(SKAction.repeatForever(rotateRings))
        let rotateRingsReverse = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 8)
        ring2.run(SKAction.repeatForever(rotateRingsReverse))
    }
    
    private func createButtons() {
        // Play Button
        playButton = createButton(text: "PLAY", position: CGPoint(x: 0, y: -size.height * 0.1))
        playButton.name = "playButton"
        addChild(playButton)
        
        // Settings Button
        settingsButton = createButton(text: "SETTINGS", position: CGPoint(x: 0, y: -size.height * 0.25))
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
    }
    
    private func createAlienShip() {
        // Create a small alien ship flying across the background
        let spawnShip = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            let ship = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: -5, y: -5))
            path.addLine(to: CGPoint(x: 5, y: -5))
            path.closeSubpath()
            ship.path = path
            ship.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 0.8)
            ship.strokeColor = SKColor.purple
            ship.lineWidth = 1
            ship.glowWidth = 3
            ship.setScale(2)
            ship.zPosition = -15
            
            // Engine glow
            let engine = SKShapeNode(circleOfRadius: 2)
            engine.position = CGPoint(x: 0, y: -5)
            engine.fillColor = .cyan
            engine.strokeColor = .clear
            engine.glowWidth = 4
            engine.blendMode = .add
            ship.addChild(engine)
            
            // Pulse engine
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 0.8, duration: 0.2)
            ])
            engine.run(SKAction.repeatForever(pulse))
            
            // Random path across screen
            let startingSide = Int.random(in: 0...1)
            let startX = startingSide == 0 ? -self.size.width/2 - 50 : self.size.width/2 + 50
            let endX = -startX
            let startY = CGFloat.random(in: -self.size.height/4...self.size.height/4)
            let midY = startY + CGFloat.random(in: -100...100)
            
            ship.position = CGPoint(x: startX, y: startY)
            self.planetLayer.addChild(ship)
            
            // Create curved path
            let path1 = SKAction.move(to: CGPoint(x: 0, y: midY), duration: 4)
            let path2 = SKAction.move(to: CGPoint(x: endX, y: startY), duration: 4)
            let rotation = SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 8)
            
            let move = SKAction.sequence([path1, path2])
            ship.run(SKAction.group([move, rotation])) {
                ship.removeFromParent()
            }
        }
        
        // Spawn ships periodically
        let wait = SKAction.wait(forDuration: 15, withRange: 10)
        let sequence = SKAction.sequence([wait, spawnShip])
        run(SKAction.repeatForever(sequence))
    }
    
    private func createButton(text: String, position: CGPoint) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        button.position = position
        button.strokeColor = .cyan
        button.lineWidth = 2
        button.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.3)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    private func addBackgroundEffects() {
        // Add floating particles for ambiance
        if let particles = SKEmitterNode(fileNamed: "StarField") {
            particles.position = CGPoint(x: 0, y: size.height/2)
            particles.zPosition = -1
            addChild(particles)
        } else {
            // Create simple particle effect if file doesn't exist
            createStarField()
        }
    }
    
    private func setupBackgroundLayers() {
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -30
        addChild(backgroundLayer)
        
        galaxyLayer = SKNode()
        galaxyLayer.zPosition = -20
        addChild(galaxyLayer)
        
        planetLayer = SKNode()
        planetLayer.zPosition = -10
        addChild(planetLayer)
    }
    
    private func createGalaxyBackground() {
        // Create spiral galaxy in background
        let galaxyCenter = CGPoint(x: size.width * 0.3, y: -size.height * 0.2)
        
        // Galaxy core
        let core = SKShapeNode(circleOfRadius: 40)
        core.position = galaxyCenter
        core.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.6)
        core.strokeColor = .clear
        core.glowWidth = 50
        core.blendMode = .add
        galaxyLayer.addChild(core)
        
        // Spiral arms
        for arm in 0..<4 {
            let armOffset = CGFloat(arm) * (CGFloat.pi / 2)
            for i in 0..<60 {
                let angle = CGFloat(i) * 0.12 + armOffset
                let radius = CGFloat(i) * 4
                
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
                star.position = CGPoint(
                    x: galaxyCenter.x + cos(angle) * radius,
                    y: galaxyCenter.y + sin(angle) * radius * 0.3
                )
                star.fillColor = SKColor(red: 0.8, green: 0.8, blue: 1.0, alpha: CGFloat.random(in: 0.2...0.5))
                star.strokeColor = .clear
                star.blendMode = .add
                galaxyLayer.addChild(star)
            }
        }
        
        // Slow rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 300)
        galaxyLayer.run(SKAction.repeatForever(rotate))
    }
    
    private func createPlanets() {
        // Map 11: Earth - FINAL STAND (center, large)
        let earthContainer = SKNode()
        earthContainer.position = CGPoint(x: 0, y: 0)
        
        if let _ = UIImage(named: "planet-earth") {
            let earthTexture = SKTexture(imageNamed: "planet-earth")
            let earth = SKSpriteNode(texture: earthTexture)
            earth.size = CGSize(width: 180, height: 180)
            earthContainer.addChild(earth)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
            earth.run(SKAction.repeatForever(rotate))
            
            let atmosphere = SKShapeNode(circleOfRadius: 92)
            atmosphere.fillColor = .clear
            atmosphere.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.15)
            atmosphere.lineWidth = 1
            atmosphere.glowWidth = 3
            earthContainer.addChild(atmosphere)
        }
        planetLayer.addChild(earthContainer)
        
        // Map 10: Moon Base
        let moonContainer = SKNode()
        moonContainer.position = CGPoint(x: 120, y: 80)
        
        if let _ = UIImage(named: "planet-moon") {
            let moonTexture = SKTexture(imageNamed: "planet-moon")
            let moon = SKSpriteNode(texture: moonTexture)
            moon.size = CGSize(width: 50, height: 50)
            moonContainer.addChild(moon)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 40)
            moon.run(SKAction.repeatForever(rotate))
        }
        planetLayer.addChild(moonContainer)
        
        // Map 9: Mars
        let marsContainer = SKNode()
        marsContainer.position = CGPoint(x: -200, y: -100)
        
        if let _ = UIImage(named: "planet-mars") {
            let marsTexture = SKTexture(imageNamed: "planet-mars")
            let mars = SKSpriteNode(texture: marsTexture)
            mars.size = CGSize(width: 80, height: 80)
            marsContainer.addChild(mars)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 45)
            mars.run(SKAction.repeatForever(rotate))
        }
        planetLayer.addChild(marsContainer)
        
        // Map 8: Io (Jupiter's volcanic moon)
        let ioContainer = SKNode()
        ioContainer.position = CGPoint(x: 280, y: -80)
        
        if let _ = UIImage(named: "planet-io") {
            let ioTexture = SKTexture(imageNamed: "planet-io")
            let io = SKSpriteNode(texture: ioTexture)
            io.size = CGSize(width: 45, height: 45)
            ioContainer.addChild(io)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
            io.run(SKAction.repeatForever(rotate))
        } else {
            // Fallback to volcanic moon drawing
            let io = SKShapeNode(circleOfRadius: 22)
            io.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0)
            io.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
            io.lineWidth = 2
            io.glowWidth = 4
            ioContainer.addChild(io)
            
            // Add volcanic spots
            for _ in 0..<3 {
                let volcano = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...5))
                volcano.position = CGPoint(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -10...10)
                )
                volcano.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.8)
                volcano.strokeColor = .clear
                volcano.glowWidth = 2
                io.addChild(volcano)
            }
        }
        planetLayer.addChild(ioContainer)
        
        // Map 7: Jupiter
        let jupiterContainer = SKNode()
        jupiterContainer.position = CGPoint(x: 300, y: -150)
        
        if let _ = UIImage(named: "planet-jupiter") {
            let jupiterTexture = SKTexture(imageNamed: "planet-jupiter")
            let jupiter = SKSpriteNode(texture: jupiterTexture)
            jupiter.size = CGSize(width: 120, height: 120)
            jupiterContainer.addChild(jupiter)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
            jupiter.run(SKAction.repeatForever(rotate))
        }
        planetLayer.addChild(jupiterContainer)
        
        // Map 6: Saturn
        let saturnContainer = SKNode()
        saturnContainer.position = CGPoint(x: -320, y: 120)
        
        if let _ = UIImage(named: "planet-saturn") {
            let saturnTexture = SKTexture(imageNamed: "planet-saturn")
            let saturn = SKSpriteNode(texture: saturnTexture)
            saturn.size = CGSize(width: 100, height: 70)
            saturnContainer.addChild(saturn)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 70)
            saturn.run(SKAction.repeatForever(rotate))
        }
        planetLayer.addChild(saturnContainer)
        
        // Map 5: Neptune
        let neptuneContainer = SKNode()
        neptuneContainer.position = CGPoint(x: 200, y: 180)
        
        if let _ = UIImage(named: "planet-neptune") {
            let neptuneTexture = SKTexture(imageNamed: "planet-neptune")
            let neptune = SKSpriteNode(texture: neptuneTexture)
            neptune.size = CGSize(width: 70, height: 70)
            neptuneContainer.addChild(neptune)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 50)
            neptune.run(SKAction.repeatForever(rotate))
        }
        planetLayer.addChild(neptuneContainer)
        
        // Map 5: Pluto (moved to right side and made bigger)
        let plutoContainer = SKNode()
        plutoContainer.position = CGPoint(x: 350, y: 150)
        
        if let _ = UIImage(named: "planet-pluto") {
            let plutoTexture = SKTexture(imageNamed: "planet-pluto")
            let pluto = SKSpriteNode(texture: plutoTexture)
            pluto.size = CGSize(width: 60, height: 60)
            plutoContainer.addChild(pluto)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 35)
            pluto.run(SKAction.repeatForever(rotate))
        } else {
            // Fallback to icy dwarf planet drawing
            let pluto = SKShapeNode(circleOfRadius: 30)
            pluto.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
            pluto.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
            pluto.lineWidth = 2
            pluto.glowWidth = 3
            plutoContainer.addChild(pluto)
            
            // Add icy patches
            for _ in 0..<2 {
                let ice = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
                ice.position = CGPoint(
                    x: CGFloat.random(in: -8...8),
                    y: CGFloat.random(in: -8...8)
                )
                ice.fillColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.6)
                ice.strokeColor = .clear
                pluto.addChild(ice)
            }
        }
        planetLayer.addChild(plutoContainer)
        
        // Map 3: Kepler Station (space station)
        let keplerStation = SKShapeNode(rectOf: CGSize(width: 15, height: 8))
        keplerStation.position = CGPoint(x: 100, y: -200)
        keplerStation.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.9)
        keplerStation.strokeColor = .cyan
        keplerStation.lineWidth = 1
        keplerStation.glowWidth = 3
        planetLayer.addChild(keplerStation)
        
        // Map 4: Tau Ceti (binary star system)
        let tauCetiContainer = SKNode()
        tauCetiContainer.position = CGPoint(x: -150, y: -250)
        
        let tauCeti = SKShapeNode(circleOfRadius: 35)
        tauCeti.fillColor = SKColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
        tauCeti.strokeColor = SKColor(red: 0.5, green: 0.9, blue: 0.7, alpha: 1.0)
        tauCeti.lineWidth = 2
        tauCeti.glowWidth = 15
        tauCetiContainer.addChild(tauCeti)
        
        // Secondary star companion
        let companion = SKShapeNode(circleOfRadius: 20)
        companion.position = CGPoint(x: 30, y: 0)
        companion.fillColor = SKColor(red: 0.6, green: 0.9, blue: 0.7, alpha: 0.8)
        companion.strokeColor = SKColor(red: 0.7, green: 1.0, blue: 0.8, alpha: 1.0)
        companion.lineWidth = 1
        companion.glowWidth = 8
        tauCeti.addChild(companion)
        
        planetLayer.addChild(tauCetiContainer)
        
        // Map 2: Proxima B (exoplanet)
        let proximaB = SKShapeNode(circleOfRadius: 35)
        proximaB.position = CGPoint(x: -100, y: -200)
        proximaB.fillColor = SKColor(red: 0.6, green: 0.3, blue: 0.5, alpha: 0.9)
        proximaB.strokeColor = SKColor(red: 0.7, green: 0.4, blue: 0.6, alpha: 1.0)
        proximaB.lineWidth = 2
        proximaB.glowWidth = 5
        planetLayer.addChild(proximaB)
        
        // Map 1: Alpha Centauri A (star)
        let alphaCentauri = SKShapeNode(circleOfRadius: 25)
        alphaCentauri.position = CGPoint(x: -350, y: -50)
        alphaCentauri.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0)
        alphaCentauri.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0)
        alphaCentauri.lineWidth = 3
        alphaCentauri.glowWidth = 15
        planetLayer.addChild(alphaCentauri)
        
        // Add distant alien ship
        createAlienShip()
    }
    
    private func createStarField() {
        // Create a denser star field with varied animations
        for _ in 0..<200 {  // More stars for denser field
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.5))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.8)
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            star.zPosition = -40
            
            // Different animation types for variety
            let animationType = Int.random(in: 0...2)
            switch animationType {
            case 0:  // Twinkle
                let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: Double.random(in: 1...3))
                let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
                let sequence = SKAction.sequence([fadeOut, fadeIn])
                star.run(SKAction.repeatForever(sequence))
            case 1:  // Pulse
                let scale = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: Double.random(in: 2...4)),
                    SKAction.scale(to: 1.0, duration: Double.random(in: 2...4))
                ])
                star.run(SKAction.repeatForever(scale))
            default:  // Shimmer
                let shimmer = SKAction.group([
                    SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 0.5...1.5)),
                        SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 0.5...1.5))
                    ]),
                    SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: Double.random(in: 1...2)),
                        SKAction.scale(to: 0.8, duration: Double.random(in: 1...2))
                    ])
                ])
                star.run(SKAction.repeatForever(shimmer))
            }
            
            backgroundLayer.addChild(star)
        }
        
        // Add shooting stars
        createShootingStars()
        
        // Add animated nebula clouds
        for i in 0..<8 {  // More nebulas
            let nebula = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...200))
            nebula.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            
            // Varied nebula colors
            let colorChoice = i % 3
            switch colorChoice {
            case 0:  // Purple/Blue
                nebula.fillColor = SKColor(
                    red: CGFloat.random(in: 0.2...0.4),
                    green: CGFloat.random(in: 0.0...0.2),
                    blue: CGFloat.random(in: 0.4...0.6),
                    alpha: 0.15
                )
            case 1:  // Green/Cyan
                nebula.fillColor = SKColor(
                    red: CGFloat.random(in: 0.0...0.1),
                    green: CGFloat.random(in: 0.3...0.5),
                    blue: CGFloat.random(in: 0.4...0.6),
                    alpha: 0.12
                )
            default:  // Red/Orange
                nebula.fillColor = SKColor(
                    red: CGFloat.random(in: 0.4...0.6),
                    green: CGFloat.random(in: 0.1...0.3),
                    blue: CGFloat.random(in: 0.0...0.2),
                    alpha: 0.1
                )
            }
            
            nebula.strokeColor = .clear
            nebula.blendMode = .add
            nebula.zPosition = -35
            
            // Animate nebula drift and morph
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30),
                               y: CGFloat.random(in: -30...30),
                               duration: Double.random(in: 20...40)),
                SKAction.moveBy(x: CGFloat.random(in: -30...30),
                               y: CGFloat.random(in: -30...30),
                               duration: Double.random(in: 20...40))
            ])
            
            let morph = SKAction.sequence([
                SKAction.scale(to: CGFloat.random(in: 0.8...1.2), duration: Double.random(in: 15...25)),
                SKAction.scale(to: 1.0, duration: Double.random(in: 15...25))
            ])
            
            nebula.run(SKAction.repeatForever(SKAction.group([drift, morph])))
            backgroundLayer.addChild(nebula)
        }
    }
    
    private func createShootingStars() {
        // Create periodic shooting stars
        let createShootingStar = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            let shootingStar = SKShapeNode(circleOfRadius: 2)
            shootingStar.fillColor = .white
            shootingStar.strokeColor = .clear
            shootingStar.glowWidth = 4
            shootingStar.zPosition = -30
            
            // Create a trail
            let trail = SKShapeNode(rectOf: CGSize(width: 50, height: 1))
            trail.fillColor = SKColor.white.withAlphaComponent(0.5)
            trail.strokeColor = .clear
            trail.position = CGPoint(x: -25, y: 0)
            trail.blendMode = .add
            shootingStar.addChild(trail)
            
            // Random starting position at edge of screen
            let startX = CGFloat.random(in: -self.size.width/2...self.size.width/2)
            let startY = self.size.height/2 + 50
            shootingStar.position = CGPoint(x: startX, y: startY)
            
            // Random angle and destination
            let endX = startX + CGFloat.random(in: -200...200)
            let endY = -self.size.height/2 - 50
            
            // Calculate rotation
            let angle = atan2(endY - startY, endX - startX)
            shootingStar.zRotation = angle
            
            self.backgroundLayer.addChild(shootingStar)
            
            // Animate shooting star
            let move = SKAction.move(to: CGPoint(x: endX, y: endY),
                                    duration: Double.random(in: 0.5...1.5))
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let group = SKAction.group([move, SKAction.sequence([SKAction.wait(forDuration: 0.2), fade])])
            
            shootingStar.run(group) {
                shootingStar.removeFromParent()
            }
        }
        
        let wait = SKAction.wait(forDuration: 3.0, withRange: 4.0)
        let sequence = SKAction.sequence([wait, createShootingStar])
        run(SKAction.repeatForever(sequence))
    }
    
    private func addSpaceDebris() {
        // Add floating space debris/asteroids
        for _ in 0..<5 {
            let debris = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            debris.fillColor = SKColor.darkGray
            debris.strokeColor = SKColor.gray
            debris.lineWidth = 1
            debris.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            debris.zPosition = -25
            
            // Add craters to make it look like an asteroid
            for _ in 0..<2 {
                let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
                crater.fillColor = SKColor.black.withAlphaComponent(0.5)
                crater.strokeColor = .clear
                crater.position = CGPoint(
                    x: CGFloat.random(in: -3...3),
                    y: CGFloat.random(in: -3...3)
                )
                debris.addChild(crater)
            }
            
            // Slow rotation and drift
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2,
                                        duration: Double.random(in: 30...60))
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -100...100),
                               y: CGFloat.random(in: -50...50),
                               duration: Double.random(in: 40...80)),
                SKAction.moveBy(x: CGFloat.random(in: -100...100),
                               y: CGFloat.random(in: -50...50),
                               duration: Double.random(in: 40...80))
            ])
            
            debris.run(SKAction.repeatForever(SKAction.group([rotate, drift])))
            backgroundLayer.addChild(debris)
        }
    }
    
    private func addCosmicDust() {
        // Add slowly drifting cosmic dust particles
        for _ in 0..<30 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            dust.fillColor = SKColor.white.withAlphaComponent(CGFloat.random(in: 0.1...0.3))
            dust.strokeColor = .clear
            dust.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            dust.zPosition = -32
            dust.blendMode = .add
            
            // Very slow drift
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                               y: CGFloat.random(in: -20...20),
                               duration: Double.random(in: 60...120)),
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                               y: CGFloat.random(in: -20...20),
                               duration: Double.random(in: 60...120))
            ])
            
            dust.run(SKAction.repeatForever(drift))
            backgroundLayer.addChild(dust)
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "playButton" || node.parent?.name == "playButton" {
                SoundManager.shared.playSound(.buttonTap)
                SoundManager.shared.playHaptic(.light)
                animateButtonPress(playButton) {
                    self.startGame()
                }
            } else if node.name == "settingsButton" || node.parent?.name == "settingsButton" {
                SoundManager.shared.playSound(.buttonTap)
                SoundManager.shared.playHaptic(.light)
                animateButtonPress(settingsButton) {
                    self.showSettings()
                }
            }
        }
    }
    
    private func animateButtonPress(_ button: SKShapeNode, completion: @escaping () -> Void) {
        // FASTER: Reduced animation time
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        button.run(sequence) {
            completion()
        }
    }
    
    private func startGame() {
        // Go to map selection instead of directly to game
        showMapSelection()
    }
    
    private func showMapSelection() {
        // Transition to map selection scene
        guard let view = self.view else { return }
        let mapScene = MapSelectionScene(size: view.bounds.size)
        mapScene.scaleMode = .aspectFill
        
        // FASTER: Instant transition
        let transition = SKTransition.fade(withDuration: 0.2)
        view.presentScene(mapScene, transition: transition)
    }
    
    private func showSettings() {
        guard let view = self.view else { return }
        let settingsScene = SettingsScene(size: view.bounds.size)
        settingsScene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view.presentScene(settingsScene, transition: transition)
    }
    
    private func createEarthContinentsForMainMenu(on earth: SKShapeNode) {
        // Create ocean gradient effect
        let oceanGradient = SKShapeNode(circleOfRadius: 78)
        oceanGradient.fillColor = SKColor(red: 0.1, green: 0.25, blue: 0.5, alpha: 0.3)
        oceanGradient.strokeColor = .clear
        oceanGradient.blendMode = .add
        earth.addChild(oceanGradient)
        
        // North America - more detailed shape
        let northAmericaPath = CGMutablePath()
        northAmericaPath.move(to: CGPoint(x: -30, y: 40))
        northAmericaPath.addCurve(to: CGPoint(x: -15, y: 45), 
                                  control1: CGPoint(x: -25, y: 42),
                                  control2: CGPoint(x: -20, y: 44))
        northAmericaPath.addCurve(to: CGPoint(x: -5, y: 35),
                                  control1: CGPoint(x: -10, y: 43),
                                  control2: CGPoint(x: -7, y: 38))
        northAmericaPath.addCurve(to: CGPoint(x: -10, y: 15),
                                  control1: CGPoint(x: -3, y: 30),
                                  control2: CGPoint(x: -5, y: 20))
        northAmericaPath.addCurve(to: CGPoint(x: -25, y: 20),
                                  control1: CGPoint(x: -15, y: 10),
                                  control2: CGPoint(x: -20, y: 15))
        northAmericaPath.addCurve(to: CGPoint(x: -30, y: 40),
                                  control1: CGPoint(x: -30, y: 25),
                                  control2: CGPoint(x: -32, y: 35))
        northAmericaPath.closeSubpath()
        
        let northAmerica = SKShapeNode(path: northAmericaPath)
        northAmerica.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.2, alpha: 0.9)
        northAmerica.strokeColor = SKColor(red: 0.1, green: 0.35, blue: 0.15, alpha: 0.5)
        northAmerica.lineWidth = 1.5
        northAmerica.glowWidth = 1
        earth.addChild(northAmerica)
        
        // Add subtle texture to North America
        for _ in 0..<3 {
            let forest = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...5))
            forest.position = CGPoint(x: CGFloat.random(in: -25...(-10)),
                                     y: CGFloat.random(in: 20...35))
            forest.fillColor = SKColor(red: 0.1, green: 0.4, blue: 0.15, alpha: 0.3)
            forest.strokeColor = .clear
            northAmerica.addChild(forest)
        }
        
        // South America - tapered shape
        let southAmericaPath = CGMutablePath()
        southAmericaPath.move(to: CGPoint(x: -15, y: 10))
        southAmericaPath.addCurve(to: CGPoint(x: -8, y: -5),
                                  control1: CGPoint(x: -10, y: 5),
                                  control2: CGPoint(x: -8, y: 0))
        southAmericaPath.addCurve(to: CGPoint(x: -12, y: -30),
                                  control1: CGPoint(x: -8, y: -15),
                                  control2: CGPoint(x: -10, y: -25))
        southAmericaPath.addCurve(to: CGPoint(x: -20, y: -20),
                                  control1: CGPoint(x: -14, y: -28),
                                  control2: CGPoint(x: -17, y: -24))
        southAmericaPath.addCurve(to: CGPoint(x: -15, y: 10),
                                  control1: CGPoint(x: -23, y: -10),
                                  control2: CGPoint(x: -20, y: 5))
        southAmericaPath.closeSubpath()
        
        let southAmerica = SKShapeNode(path: southAmericaPath)
        southAmerica.fillColor = SKColor(red: 0.2, green: 0.55, blue: 0.25, alpha: 0.9)
        southAmerica.strokeColor = SKColor(red: 0.15, green: 0.4, blue: 0.2, alpha: 0.5)
        southAmerica.lineWidth = 1.5
        earth.addChild(southAmerica)
        
        // Amazon rainforest
        let amazon = SKShapeNode(circleOfRadius: 6)
        amazon.position = CGPoint(x: -14, y: -10)
        amazon.fillColor = SKColor(red: 0.05, green: 0.35, blue: 0.1, alpha: 0.5)
        amazon.strokeColor = .clear
        southAmerica.addChild(amazon)
        
        // Africa - distinctive shape with Sahara
        let africaPath = CGMutablePath()
        africaPath.move(to: CGPoint(x: 12, y: 30))
        africaPath.addCurve(to: CGPoint(x: 20, y: 20),
                           control1: CGPoint(x: 15, y: 28),
                           control2: CGPoint(x: 18, y: 24))
        africaPath.addCurve(to: CGPoint(x: 18, y: -5),
                           control1: CGPoint(x: 22, y: 10),
                           control2: CGPoint(x: 20, y: 0))
        africaPath.addCurve(to: CGPoint(x: 15, y: -25),
                           control1: CGPoint(x: 16, y: -15),
                           control2: CGPoint(x: 15, y: -20))
        africaPath.addCurve(to: CGPoint(x: 8, y: -20),
                           control1: CGPoint(x: 15, y: -28),
                           control2: CGPoint(x: 12, y: -25))
        africaPath.addCurve(to: CGPoint(x: 5, y: 10),
                           control1: CGPoint(x: 4, y: -10),
                           control2: CGPoint(x: 3, y: 0))
        africaPath.addCurve(to: CGPoint(x: 12, y: 30),
                           control1: CGPoint(x: 7, y: 20),
                           control2: CGPoint(x: 10, y: 28))
        africaPath.closeSubpath()
        
        let africa = SKShapeNode(path: africaPath)
        africa.fillColor = SKColor(red: 0.25, green: 0.45, blue: 0.2, alpha: 0.9)
        africa.strokeColor = SKColor(red: 0.2, green: 0.35, blue: 0.15, alpha: 0.5)
        africa.lineWidth = 1.5
        earth.addChild(africa)
        
        // Sahara Desert
        let sahara = SKShapeNode(ellipseOf: CGSize(width: 12, height: 8))
        sahara.position = CGPoint(x: 12, y: 15)
        sahara.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.4, alpha: 0.4)
        sahara.strokeColor = .clear
        africa.addChild(sahara)
        
        // Europe - small detailed region
        let europePath = CGMutablePath()
        europePath.move(to: CGPoint(x: 10, y: 40))
        europePath.addCurve(to: CGPoint(x: 20, y: 38),
                          control1: CGPoint(x: 13, y: 40),
                          control2: CGPoint(x: 17, y: 39))
        europePath.addCurve(to: CGPoint(x: 18, y: 32),
                          control1: CGPoint(x: 22, y: 36),
                          control2: CGPoint(x: 20, y: 34))
        europePath.addCurve(to: CGPoint(x: 8, y: 35),
                          control1: CGPoint(x: 15, y: 30),
                          control2: CGPoint(x: 10, y: 32))
        europePath.closeSubpath()
        
        let europe = SKShapeNode(path: europePath)
        europe.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 0.9)
        europe.strokeColor = SKColor(red: 0.15, green: 0.4, blue: 0.25, alpha: 0.5)
        europe.lineWidth = 1
        earth.addChild(europe)
        
        // Asia - large landmass with variety
        let asiaPath = CGMutablePath()
        asiaPath.move(to: CGPoint(x: 25, y: 35))
        asiaPath.addCurve(to: CGPoint(x: 55, y: 30),
                         control1: CGPoint(x: 35, y: 35),
                         control2: CGPoint(x: 45, y: 32))
        asiaPath.addCurve(to: CGPoint(x: 50, y: 10),
                         control1: CGPoint(x: 58, y: 25),
                         control2: CGPoint(x: 55, y: 15))
        asiaPath.addCurve(to: CGPoint(x: 30, y: 20),
                         control1: CGPoint(x: 45, y: 5),
                         control2: CGPoint(x: 35, y: 15))
        asiaPath.addCurve(to: CGPoint(x: 25, y: 35),
                         control1: CGPoint(x: 25, y: 25),
                         control2: CGPoint(x: 23, y: 32))
        asiaPath.closeSubpath()
        
        let asia = SKShapeNode(path: asiaPath)
        asia.fillColor = SKColor(red: 0.22, green: 0.48, blue: 0.22, alpha: 0.9)
        asia.strokeColor = SKColor(red: 0.18, green: 0.38, blue: 0.18, alpha: 0.5)
        asia.lineWidth = 1.5
        earth.addChild(asia)
        
        // Himalayan mountains
        let himalayas = SKShapeNode(ellipseOf: CGSize(width: 8, height: 4))
        himalayas.position = CGPoint(x: 38, y: 25)
        himalayas.fillColor = SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.6)
        himalayas.strokeColor = .clear
        asia.addChild(himalayas)
        
        // Australia
        let australiaPath = CGMutablePath()
        australiaPath.addEllipse(in: CGRect(x: 35, y: -30, width: 14, height: 10))
        let australia = SKShapeNode(path: australiaPath)
        australia.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.9)
        australia.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 0.5)
        australia.lineWidth = 1
        earth.addChild(australia)
        
        // Greenland and Arctic ice
        let greenland = SKShapeNode(ellipseOf: CGSize(width: 10, height: 14))
        greenland.position = CGPoint(x: -5, y: 50)
        greenland.fillColor = SKColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 0.9)
        greenland.strokeColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 0.5)
        greenland.lineWidth = 1
        greenland.glowWidth = 2
        earth.addChild(greenland)
        
        // Antarctica
        let antarctica = SKShapeNode(ellipseOf: CGSize(width: 40, height: 8))
        antarctica.position = CGPoint(x: 0, y: -45)
        antarctica.fillColor = SKColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 0.95)
        antarctica.strokeColor = SKColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 0.5)
        antarctica.lineWidth = 1
        antarctica.glowWidth = 3
        earth.addChild(antarctica)
        
        // Add city lights on night side
        if CGFloat.random(in: 0...1) > 0.3 {  // 70% chance to show city lights
            for _ in 0..<8 {
                let cityLight = SKShapeNode(circleOfRadius: 1)
                cityLight.position = CGPoint(
                    x: CGFloat.random(in: -20...20),
                    y: CGFloat.random(in: 20...40)
                )
                cityLight.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)
                cityLight.strokeColor = .clear
                cityLight.glowWidth = 2
                cityLight.blendMode = .add
                
                // Twinkle effect
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 0.5...1.0)),
                    SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 0.5...1.0))
                ])
                cityLight.run(SKAction.repeatForever(twinkle))
                earth.addChild(cityLight)
            }
        }
    }
}