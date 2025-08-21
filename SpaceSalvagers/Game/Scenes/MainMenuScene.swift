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
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "SPACE SALVAGERS"
        titleLabel.fontSize = 56
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height * 0.25)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 100
        
        // Add multiple glow layers for epic effect
        for i in 1...3 {
            let glow = SKLabelNode(fontNamed: "Helvetica-Bold")
            glow.text = "SPACE SALVAGERS"
            glow.fontSize = 56
            glow.fontColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4 / CGFloat(i))
            glow.position = .zero
            glow.alpha = 1.0 / CGFloat(i)
            glow.blendMode = .add
            glow.setScale(1.0 + (CGFloat(i) * 0.02))
            titleLabel.addChild(glow)
        }
        
        // Add subtitle
        let subtitle = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "DEFEND THE SOLAR SYSTEM"
        subtitle.fontSize = 18
        subtitle.fontColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.9)
        subtitle.position = CGPoint(x: 0, y: -40)
        titleLabel.addChild(subtitle)
        
        // Animate title
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 3.0),
            SKAction.scale(to: 1.0, duration: 3.0)
        ])
        titleLabel.run(SKAction.repeatForever(pulse))
        
        addChild(titleLabel)
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
        // Create stunning Earth with enhanced effects
        let earthContainer = SKNode()
        earthContainer.position = CGPoint(x: -size.width * 0.35, y: size.height * 0.1)
        
        // Earth planet with gradient-like effect
        let earth = SKShapeNode(circleOfRadius: 80)
        earth.fillColor = SKColor(red: 0.15, green: 0.35, blue: 0.65, alpha: 1.0)
        earth.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
        earth.lineWidth = 2
        earth.glowWidth = 12
        earthContainer.addChild(earth)
        
        // Add realistic Earth continents
        createEarthContinentsForMainMenu(on: earth)
        
        // Add cloud layer
        let cloudLayer = SKNode()
        for _ in 0..<8 {
            let cloud = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...15))
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: 50...75)
            cloud.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            cloud.fillColor = SKColor.white.withAlphaComponent(0.2)
            cloud.strokeColor = .clear
            cloud.blendMode = .add
            cloudLayer.addChild(cloud)
        }
        earth.addChild(cloudLayer)
        
        // Animate cloud layer rotation (faster than planet)
        let rotateClouds = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 40)
        cloudLayer.run(SKAction.repeatForever(rotateClouds))
        
        // Add shimmering atmosphere
        let atmosphere = SKShapeNode(circleOfRadius: 90)
        atmosphere.fillColor = .clear
        atmosphere.strokeColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.4)
        atmosphere.lineWidth = 6
        atmosphere.glowWidth = 20
        earth.addChild(atmosphere)
        
        // Animate atmosphere pulsing
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 2.0),
            SKAction.fadeAlpha(to: 0.3, duration: 2.0)
        ])
        atmosphere.run(SKAction.repeatForever(pulse))
        
        // Add Moon orbiting Earth
        let moonOrbit = SKNode()
        earthContainer.addChild(moonOrbit)
        
        let moon = SKShapeNode(circleOfRadius: 12)
        moon.position = CGPoint(x: 120, y: 0)
        moon.fillColor = SKColor(red: 0.8, green: 0.8, blue: 0.75, alpha: 0.9)
        moon.strokeColor = SKColor(red: 0.9, green: 0.9, blue: 0.85, alpha: 1.0)
        moon.lineWidth = 1
        moon.glowWidth = 3
        
        // Add craters to moon
        for _ in 0..<3 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            crater.position = CGPoint(
                x: CGFloat.random(in: -8...8),
                y: CGFloat.random(in: -8...8)
            )
            crater.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
            crater.strokeColor = .clear
            moon.addChild(crater)
        }
        
        moonOrbit.addChild(moon)
        
        // Animate moon orbit
        let orbitMoon = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        moonOrbit.run(SKAction.repeatForever(orbitMoon))
        
        // Add space station orbiting Earth
        let stationOrbit = SKNode()
        earthContainer.addChild(stationOrbit)
        
        let station = SKShapeNode(rectOf: CGSize(width: 8, height: 4))
        station.position = CGPoint(x: 0, y: 100)
        station.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.8)
        station.strokeColor = .cyan
        station.lineWidth = 0.5
        station.glowWidth = 2
        
        // Add blinking light to station
        let light = SKShapeNode(circleOfRadius: 1)
        light.fillColor = .red
        light.strokeColor = .clear
        light.glowWidth = 3
        station.addChild(light)
        
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])
        light.run(SKAction.repeatForever(blink))
        
        stationOrbit.addChild(station)
        
        // Animate station orbit (faster than moon)
        let orbitStation = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 12)
        stationOrbit.run(SKAction.repeatForever(orbitStation))
        
        planetLayer.addChild(earthContainer)
        
        // Slow rotation of Earth itself with wobble
        let rotateEarth = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
        let wobble = SKAction.sequence([
            SKAction.rotate(toAngle: 0.05, duration: 15),
            SKAction.rotate(toAngle: -0.05, duration: 15)
        ])
        earth.run(SKAction.repeatForever(SKAction.group([rotateEarth, wobble])))
        
        // Mars in the distance with dust storms
        let marsContainer = SKNode()
        marsContainer.position = CGPoint(x: size.width * 0.4, y: -size.height * 0.3)
        
        let mars = SKShapeNode(circleOfRadius: 35)
        mars.fillColor = SKColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 0.8)
        mars.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.3, alpha: 1.0)
        mars.lineWidth = 1
        mars.glowWidth = 5
        marsContainer.addChild(mars)
        
        // Add dust storm effect
        for _ in 0..<3 {
            let storm = SKShapeNode(circleOfRadius: CGFloat.random(in: 10...15))
            storm.position = CGPoint(
                x: CGFloat.random(in: -20...20),
                y: CGFloat.random(in: -20...20)
            )
            storm.fillColor = SKColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 0.3)
            storm.strokeColor = .clear
            storm.blendMode = .alpha
            
            let swirl = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -10...10),
                               y: CGFloat.random(in: -10...10),
                               duration: Double.random(in: 3...5)),
                SKAction.moveBy(x: CGFloat.random(in: -10...10),
                               y: CGFloat.random(in: -10...10),
                               duration: Double.random(in: 3...5))
            ])
            storm.run(SKAction.repeatForever(swirl))
            mars.addChild(storm)
        }
        
        // Rotate Mars
        let rotateMars = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 45)
        mars.run(SKAction.repeatForever(rotateMars))
        
        planetLayer.addChild(marsContainer)
        
        // Add warning beacon on Mars
        let beacon = SKShapeNode(circleOfRadius: 3)
        beacon.fillColor = .red
        beacon.glowWidth = 5
        beacon.position = CGPoint(x: 0, y: 30)
        mars.addChild(beacon)
        
        // Blinking beacon with pulse
        let beaconBlink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])
        let beaconPulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        beacon.run(SKAction.repeatForever(SKAction.group([beaconBlink, beaconPulse])))
        
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