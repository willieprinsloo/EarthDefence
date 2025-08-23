import SpriteKit

class MapSelectionScene: SKScene {
    
    // User progress tracking
    private var completedMaps: Set<Int> = []
    private var highestUnlockedMap: Int = 1
    
    // UI elements
    private var mapButtons: [SKNode] = []
    private var backButton: SKShapeNode!
    private var titleLabel: SKLabelNode!
    
    // Animation layers
    private var starLayer: SKNode!
    private var pathLayer: SKNode!
    private var planetLayer: SKNode!
    
    // Camera and scrolling
    private var cameraNode: SKCameraNode!
    private var scrollContainer: SKNode!
    private var lastTouchLocation: CGPoint?
    private var isDragging = false
    private var initialCameraScale: CGFloat = 1.0  // No zoom
    private var currentCameraScale: CGFloat = 1.0  // No zoom
    private var touchStartLocation: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var totalDragDistance: CGPoint = CGPoint.zero
    private var potentialMapSelection: Int?
    private var animationsPaused: Bool = false
    private var scrollEndTimer: Timer?
    
    // Velocity tracking for smooth scrolling
    private var scrollVelocity = CGPoint.zero
    private var lastTouchTime: TimeInterval = 0
    private var isDecelerating = false
    
    // FIT ON SCREEN: No scrolling needed
    private var contentMinX: CGFloat = -400  // Leftmost planet position
    private var contentMaxX: CGFloat = 400   // Rightmost planet position
    
    // Solar system constants
    private let totalMaps = 12
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        
        // Improve rendering quality to prevent double lines
        view.ignoresSiblingOrder = true
        view.shouldCullNonVisibleNodes = true
        
        // Set up camera with initial zoom
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint.zero
        cameraNode.setScale(currentCameraScale)
        camera = cameraNode
        addChild(cameraNode)
        
        // Disable multi-touch - no pinch zoom for simplicity
        view.isMultipleTouchEnabled = false
        
        // Create scrollable container
        scrollContainer = SKNode()
        scrollContainer.position = CGPoint.zero
        addChild(scrollContainer)
        
        // Create layers for proper z-ordering inside scroll container
        starLayer = SKNode()
        starLayer.zPosition = -10
        scrollContainer.addChild(starLayer)
        
        pathLayer = SKNode()
        pathLayer.zPosition = 0
        scrollContainer.addChild(pathLayer)
        
        planetLayer = SKNode()
        planetLayer.zPosition = 10
        scrollContainer.addChild(planetLayer)
        
        loadProgress()
        createSpaceBackground()
        addMovingBackgroundObjects()  // Add moving space objects
        createTitle()
        createGalaxyPath()
        createBackButton()
        createScrollIndicators()
        
        // Focus camera on first unlocked planet or current planet
        focusOnCurrentPlanet()
    }
    
    private func loadProgress() {
        // TESTING MODE - Unlock all levels for easy testing
        completedMaps = Set<Int>()  // Keep track of actually completed maps
        highestUnlockedMap = 10  // Unlock all 10 maps for testing
        
        // Original code (commented out for testing):
        // if let saved = UserDefaults.standard.array(forKey: "completedMaps") as? [Int] {
        //     completedMaps = Set(saved)
        // }
        // highestUnlockedMap = UserDefaults.standard.integer(forKey: "highestUnlockedMap")
        // if highestUnlockedMap == 0 {
        //     highestUnlockedMap = 1  // First map is always unlocked
        // }
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(Array(completedMaps), forKey: "completedMaps")
        UserDefaults.standard.set(highestUnlockedMap, forKey: "highestUnlockedMap")
    }
    
    private func createTitle() {
        // Create a cosmic title
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "GALACTIC SECTORS"
        titleLabel.fontSize = 42
        titleLabel.fontColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: size.height * 0.42 - 20)
        titleLabel.zPosition = 100
        
        // Add single glow layer behind the main title
        let glowTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        glowTitle.text = "GALACTIC SECTORS"
        glowTitle.fontSize = 44
        glowTitle.fontColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.2)
        glowTitle.position = .zero
        glowTitle.setScale(1.02)
        glowTitle.blendMode = .add
        glowTitle.zPosition = -1
        titleLabel.addChild(glowTitle)
        
        cameraNode.addChild(titleLabel)
        
        // Subtle floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 2.0),
            SKAction.moveBy(x: 0, y: -5, duration: 2.0)
        ])
        titleLabel.run(SKAction.repeatForever(float))
    }
    
    private func createGalaxyPath() {
        // Create solar system with orbital paths
        createSolarSystemLayout()
    }
    
    private func createSolarSystemLayout() {
        let deviceType = UIDevice.current.userInterfaceIdiom
        // Sun removed - using linear progression layout instead
        // let sunPosition = deviceType == .pad ? 
        //     CGPoint(x: -1200, y: -150) :  // iPad: 3x larger space (was -400, -50)
        //     CGPoint(x: -540, y: -60)      // iPhone: 3x larger (was -180, -20)
        // createSun(at: sunPosition)
        
        // Only show start indicator if player hasn't started yet
        if highestUnlockedMap == 1 && completedMaps.isEmpty {
            let horizontalSpread: CGFloat = deviceType == .pad ? 120 : 90  // Match the minimal planet spacing
            let startIndicator = SKLabelNode(text: "START HERE ↓")
            startIndicator.fontSize = 14
            startIndicator.fontName = "AvenirNext-Bold"
            startIndicator.fontColor = SKColor.yellow
            startIndicator.position = CGPoint(x: -horizontalSpread * 1.5, y: 180)
            startIndicator.zPosition = 15
            
            // Pulsing animation for visibility
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ])
            startIndicator.run(SKAction.repeatForever(pulse))
            scrollContainer.addChild(startIndicator)
        }
        
        // Adjust layout based on device - MUCH SMALLER for full screen view
        let radiusMultiplier: CGFloat = deviceType == .pad ? 0.4 : 0.3  // Much smaller orbits
        let sizeMultiplier: CGFloat = deviceType == .pad ? 0.4 : 0.3      // Much smaller planets
        
        // Planet data: EXACTLY 12 MAPS - Game completes after Map 12 (EARTH)
        let planets: [(name: String, radius: CGFloat, size: CGFloat, color: SKColor, mapNumber: Int)] = [
            // OUTER DEFENSE - Far from Earth (defending incoming invasion)
            ("Alpha Centauri", 600 * radiusMultiplier, 45 * sizeMultiplier, SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0), 1),
            ("Proxima B", 550 * radiusMultiplier, 40 * sizeMultiplier, SKColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1.0), 2),
            ("Kepler Station", 500 * radiusMultiplier, 38 * sizeMultiplier, SKColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0), 3),
            ("Tau Ceti", 450 * radiusMultiplier, 42 * sizeMultiplier, SKColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0), 4),
            ("Pluto", 400 * radiusMultiplier, 45 * sizeMultiplier, SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0), 5),
            
            // MID DEFENSE - Outer solar system
            ("Neptune", 350 * radiusMultiplier, 50 * sizeMultiplier, SKColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1.0), 6),
            ("Saturn", 300 * radiusMultiplier, 55 * sizeMultiplier, SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0), 7),
            ("Jupiter", 250 * radiusMultiplier, 60 * sizeMultiplier, SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0), 8),
            ("Io", 220 * radiusMultiplier, 25 * sizeMultiplier, SKColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0), 9),
            
            // INNER DEFENSE - Close to Earth
            ("Mars", 180 * radiusMultiplier, 35 * sizeMultiplier, SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0), 10),
            ("Moon Base", 120 * radiusMultiplier, 30 * sizeMultiplier, SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), 11),
            ("EARTH", 60 * radiusMultiplier, 45 * sizeMultiplier, SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0), 12)
        ]
        
        // Orbital paths removed - using linear progression layout instead
        
        // Store planet positions for connecting paths
        var planetPositions: [CGPoint] = []
        
        // Track min and max X positions for proper scrolling bounds
        var minPlanetX: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxPlanetX: CGFloat = -CGFloat.greatestFiniteMagnitude
        
        // Create planets using full screen width and height, avoiding UI elements
        for (index, planet) in planets.enumerated() {
            let position: CGPoint
            
            // Calculate usable screen area (avoid title and buttons)
            let topBoundary = size.height * 0.35   // Below title and back button
            let bottomBoundary = -size.height * 0.35  // Above hint label
            let leftBoundary = -size.width * 0.45   // Full width minus margins
            let rightBoundary = size.width * 0.45   // Full width minus margins
            
            let usableWidth = rightBoundary - leftBoundary
            let usableHeight = topBoundary - bottomBoundary
            
            // Distribute planets across full available space
            switch planet.mapNumber {
            case 1: // Alpha Centauri - Top left
                position = CGPoint(x: leftBoundary + usableWidth * 0.1, y: topBoundary - usableHeight * 0.1)
            case 2: // Proxima B - Top center-left
                position = CGPoint(x: leftBoundary + usableWidth * 0.25, y: topBoundary - usableHeight * 0.15)
            case 3: // Kepler Station - Top center
                position = CGPoint(x: leftBoundary + usableWidth * 0.4, y: topBoundary - usableHeight * 0.1)
            case 4: // Tau Ceti - Top center-right
                position = CGPoint(x: leftBoundary + usableWidth * 0.55, y: topBoundary - usableHeight * 0.15)
            case 5: // Pluto - Far right side (moved to right and made bigger)
                position = CGPoint(x: leftBoundary + usableWidth * 0.9, y: topBoundary - usableHeight * 0.1)
            case 6: // Neptune - Upper middle left
                position = CGPoint(x: leftBoundary + usableWidth * 0.15, y: topBoundary - usableHeight * 0.35)
            case 7: // Saturn - Upper middle center
                position = CGPoint(x: leftBoundary + usableWidth * 0.35, y: topBoundary - usableHeight * 0.4)
            case 8: // Jupiter - Upper middle right
                position = CGPoint(x: leftBoundary + usableWidth * 0.55, y: topBoundary - usableHeight * 0.35)
            case 9: // Io - Middle right
                position = CGPoint(x: leftBoundary + usableWidth * 0.75, y: topBoundary - usableHeight * 0.4)
            case 10: // Mars - Lower middle left
                position = CGPoint(x: leftBoundary + usableWidth * 0.25, y: topBoundary - usableHeight * 0.65)
            case 11: // Moon Base - Lower middle right
                position = CGPoint(x: leftBoundary + usableWidth * 0.65, y: topBoundary - usableHeight * 0.65)
            case 12: // EARTH - Bottom center, prominent final destination
                position = CGPoint(x: leftBoundary + usableWidth * 0.5, y: bottomBoundary + usableHeight * 0.15)
            default:
                // Fallback grid layout using available space
                let row = (index / 5)
                let col = (index % 5) - 2
                position = CGPoint(x: leftBoundary + usableWidth * (0.1 + CGFloat(col) * 0.2), 
                                  y: topBoundary - usableHeight * (0.2 + CGFloat(row) * 0.3))
            }
            planetPositions.append(position)
            
            // Track bounds (include planet size)
            minPlanetX = min(minPlanetX, position.x - 100)
            maxPlanetX = max(maxPlanetX, position.x + 100)
            
            let planetNode = createSolarPlanetNode(
                mapNumber: planet.mapNumber,
                position: position,
                planetName: planet.name,
                planetSize: planet.size,
                planetColor: planet.color
            )
            
            mapButtons.append(planetNode)
            planetLayer.addChild(planetNode)
            
            // Add animated arrow pointing to the next planet to play
            if planet.mapNumber == highestUnlockedMap && !completedMaps.contains(planet.mapNumber) {
                createNextPlanetIndicator(at: position, planetName: planet.name)
            }
        }
        
        // Create dotted connection paths between planets in order
        // Sort positions by map number to ensure correct path order
        let sortedPlanets = planets.sorted { $0.mapNumber < $1.mapNumber }
        for i in 0..<(sortedPlanets.count - 1) {
            let fromIndex = sortedPlanets[i].mapNumber - 1
            let toIndex = sortedPlanets[i + 1].mapNumber - 1
            if fromIndex < planetPositions.count && toIndex < planetPositions.count {
                createDottedPath(from: planetPositions[fromIndex], to: planetPositions[toIndex], mapNumber: sortedPlanets[i].mapNumber)
            }
        }
        
        // Set content bounds after all planets are created
        if minPlanetX != CGFloat.greatestFiniteMagnitude {
            contentMinX = minPlanetX - 50
            contentMaxX = maxPlanetX + 50
        }
    }
    
    private func createNextPlanetIndicator(at position: CGPoint, planetName: String) {
        // Create arrow pointing to next planet
        let arrowContainer = SKNode()
        arrowContainer.position = CGPoint(x: position.x, y: position.y + 60)
        arrowContainer.zPosition = 20
        
        // Create downward pointing arrow
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -15, y: 15))
        arrowPath.addLine(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: 15, y: 15))
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: 20))
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = SKColor.yellow
        arrow.lineWidth = 3
        arrow.lineCap = .round
        arrow.glowWidth = 2
        arrowContainer.addChild(arrow)
        
        // Add "PLAY NEXT" label
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "PLAY NEXT"
        label.fontSize = 14
        label.fontColor = SKColor.yellow
        label.position = CGPoint(x: 0, y: 30)
        arrowContainer.addChild(label)
        
        // Add bouncing animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -10, duration: 0.8),
            SKAction.moveBy(x: 0, y: 10, duration: 0.8)
        ])
        arrowContainer.run(SKAction.repeatForever(bounce))
        
        // Add pulsing glow
        let pulse = SKAction.sequence([
            SKAction.run { arrow.glowWidth = 4 },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { arrow.glowWidth = 2 },
            SKAction.wait(forDuration: 0.5)
        ])
        arrowContainer.run(SKAction.repeatForever(pulse))
        
        planetLayer.addChild(arrowContainer)
    }
    
    private func createSun(at position: CGPoint) {
        // Create the sun as a glowing central star
        let sun = SKNode()
        sun.position = position
        
        // Sun core
        let core = SKShapeNode(circleOfRadius: 25)
        core.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        core.strokeColor = .clear
        core.glowWidth = 30
        core.blendMode = .add
        sun.addChild(core)
        
        // Sun corona layers
        for i in 1...3 {
            let corona = SKShapeNode(circleOfRadius: 25 + CGFloat(i * 8))
            corona.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.15 / CGFloat(i))
            corona.strokeColor = .clear
            corona.blendMode = .add
            sun.addChild(corona)
        }
        
        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        core.run(SKAction.repeatForever(pulse))
        
        // Sun label
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "SOL"
        label.fontSize = 12
        label.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        label.position = CGPoint(x: 0, y: -40)
        sun.addChild(label)
        
        pathLayer.addChild(sun)
    }
    
    private func createOrbit(radius: CGFloat, center: CGPoint) {
        let orbit = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius))
        orbit.position = center
        orbit.strokeColor = SKColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 0.3)
        orbit.lineWidth = 1
        orbit.fillColor = .clear
        orbit.zPosition = -1
        pathLayer.addChild(orbit)
    }
    
    private func createDottedPath(from: CGPoint, to: CGPoint, mapNumber: Int) {
        // Calculate distance and angle between points
        let dx = to.x - from.x
        let dy = to.y - from.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Create dots along the path
        let dotSpacing: CGFloat = 20  // Good spacing for visibility
        let dotCount = Int(distance / dotSpacing)
        
        for i in 1..<dotCount {
            let progress = CGFloat(i) / CGFloat(dotCount)
            let dotX = from.x + dx * progress
            let dotY = from.y + dy * progress
            
            let dot = SKShapeNode(circleOfRadius: 3)  // Visible dot size
            dot.position = CGPoint(x: dotX, y: dotY)
            
            // Color based on completion status
            if mapNumber <= highestUnlockedMap {
                if completedMaps.contains(mapNumber) {
                    // Completed path - green
                    dot.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.8)
                    dot.strokeColor = .clear
                    dot.glowWidth = 2
                } else {
                    // Unlocked but not completed - yellow/orange
                    dot.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 0.8)
                    dot.strokeColor = .clear
                    dot.glowWidth = 3
                    
                    // Pulsing animation for current path
                    let pulse = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.4, duration: 1.0),
                        SKAction.fadeAlpha(to: 1.0, duration: 1.0)
                    ])
                    dot.run(SKAction.repeatForever(pulse))
                }
            } else {
                // Locked path - more visible gray
                dot.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)
                dot.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
                dot.lineWidth = 0.5
            }
            
            dot.zPosition = -0.5  // Above orbits but below planets
            pathLayer.addChild(dot)
        }
    }
    
    private func createSolarPlanetNode(mapNumber: Int, position: CGPoint, planetName: String, planetSize: CGFloat, planetColor: SKColor) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = "map\(mapNumber)"
        
        // Determine button state
        let isCompleted = completedMaps.contains(mapNumber)
        let isUnlocked = mapNumber <= highestUnlockedMap
        let isCurrent = mapNumber == highestUnlockedMap && !isCompleted
        
        // Create planet with enhanced visual effects based on planet type
        let planetNode = createEnhancedPlanet(
            name: planetName,
            size: planetSize,
            baseColor: planetColor,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            isCurrent: isCurrent
        )
        
        container.addChild(planetNode)
        
        // Planet name
        let nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        nameLabel.text = planetName.uppercased()
        nameLabel.fontSize = 16  // Reduced text size
        nameLabel.fontColor = isUnlocked ? .white : .gray
        nameLabel.position = CGPoint(x: 0, y: -planetSize - 20)
        container.addChild(nameLabel)
        
        // Map number removed per user request
        
        // Wave info
        if isUnlocked || isCompleted {
            let waveLabel = SKLabelNode(fontNamed: "Helvetica")
            waveLabel.text = getWaveInfo(mapNumber)
            waveLabel.fontSize = 10
            waveLabel.fontColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.7)
            waveLabel.position = CGPoint(x: 0, y: -planetSize - 35)
            container.addChild(waveLabel)
        }
        
        // Status icons
        // Removed green checkmark for completed planets
        if !isUnlocked {
            let lockIcon = SKLabelNode(text: "🔒")
            lockIcon.fontSize = 30  // Smaller lock icon
            lockIcon.position = CGPoint(x: 0, y: 0)
            lockIcon.zPosition = 2
            container.addChild(lockIcon)
        }
        
        return container
    }
    
    private func createEnhancedPlanet(name: String, size: CGFloat, baseColor: SKColor, isCompleted: Bool, isUnlocked: Bool, isCurrent: Bool) -> SKNode {
        let planetContainer = SKNode()
        
        // Base planet body
        let planet = SKShapeNode(circleOfRadius: size)
        
        // Apply state-based styling
        if isCompleted {
            planet.fillColor = baseColor
            planet.strokeColor = SKColor.green
            planet.lineWidth = 2
            planet.glowWidth = 2
        } else if isCurrent {
            planet.fillColor = baseColor.withAlphaComponent(0.9)
            planet.strokeColor = SKColor.cyan
            planet.lineWidth = 2
            planet.glowWidth = 3
            
            // Pulsing effect for current planet
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            planet.run(SKAction.repeatForever(pulse))
        } else if isUnlocked {
            planet.fillColor = baseColor.withAlphaComponent(0.8)
            planet.strokeColor = baseColor.withAlphaComponent(0.5)
            planet.lineWidth = 1
            planet.glowWidth = 0
        } else {
            planet.fillColor = baseColor.withAlphaComponent(0.2)
            planet.strokeColor = SKColor.darkGray
            planet.lineWidth = 1
            planet.alpha = 0.4
        }
        
        planetContainer.addChild(planet)
        
        // Add planet-specific enhanced visual effects
        if isUnlocked || isCompleted {
            switch name {
            case "Alpha Centauri A":
                addAlphaCentauriEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Proxima B":
                addProximaBEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Kepler Station":
                addKeplerStationEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Tau Ceti":
                addTauCetiEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Pluto":
                addPlutoEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Neptune":
                addNeptuneEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Uranus":
                addUranusEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Saturn":
                addSaturnEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Jupiter":
                addJupiterEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Mars":
                addMarsEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Io":
                addIoEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Moon", "Moon Base":
                addMoonEffects(to: planetContainer, planetSize: size, planet: planet)
            case "EARTH":
                addEarthFinalEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Eris":
                addErisEffects(to: planetContainer, planetSize: size, planet: planet)
            case "Makemake":
                addMakemakeEffects(to: planetContainer, planetSize: size, planet: planet)
            default:
                break
            }
        }
        
        // Add atmospheric glow for gas giants and special planets
        if isUnlocked || isCompleted {
            addAtmosphericGlow(to: planetContainer, planetName: name, planetSize: size)
        }
        
        // Planet rotation animation
        if isUnlocked && !isCurrent {
            let rotationSpeed = getRotationSpeed(for: name)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotationSpeed)
            planet.run(SKAction.repeatForever(rotate))
        }
        
        return planetContainer
    }
    
    // MARK: - Planet-Specific Visual Effects
    
    private func addAlphaCentauriEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Alpha Centauri A - A yellow star with alien structures
        
        // Add solar flare effect
        let flareLayer = SKNode()
        for i in 0..<6 {
            let flare = SKShapeNode(circleOfRadius: planetSize * 0.3)
            let angle = CGFloat(i) * (CGFloat.pi * 2.0 / 6.0)
            flare.position = CGPoint(x: cos(angle) * planetSize * 0.8, y: sin(angle) * planetSize * 0.8)
            flare.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 0.3)
            flare.strokeColor = .clear
            flare.blendMode = .add
            flareLayer.addChild(flare)
        }
        planet.addChild(flareLayer)
        
        // Animate solar flares
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2.0),
            SKAction.scale(to: 0.8, duration: 2.0)
        ])
        flareLayer.run(SKAction.repeatForever(pulse))
        
        // Add alien structures (geometric shapes)
        for _ in 0..<4 {
            let structure = SKShapeNode(rectOf: CGSize(width: planetSize * 0.15, height: planetSize * 0.15))
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = planetSize * CGFloat.random(in: 0.5...0.7)
            structure.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            structure.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.9, alpha: 0.6)
            structure.strokeColor = SKColor.purple
            structure.lineWidth = 1
            structure.zRotation = CGFloat.random(in: 0...(CGFloat.pi/4))
            planet.addChild(structure)
        }
        
        // Add star corona
        let corona = SKShapeNode(circleOfRadius: planetSize + 8)
        corona.fillColor = .clear
        corona.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.4)
        corona.lineWidth = 6
        corona.glowWidth = 15
        container.addChild(corona)
        
        // Animate corona
        let coronaPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 1.5),
            SKAction.fadeAlpha(to: 0.3, duration: 1.5)
        ])
        corona.run(SKAction.repeatForever(coronaPulse))
        
        // Add targeting reticle if Mercury is the current unplayed map
        let userDefaults = UserDefaults.standard
        let completedMaps = userDefaults.array(forKey: "completedMaps") as? [Int] ?? []
        
        if !completedMaps.contains(1) {
            // Add animated targeting reticle to help users find the first map
            let targetOuter = SKShapeNode(circleOfRadius: planetSize + 30)
            targetOuter.strokeColor = SKColor.red.withAlphaComponent(0.6)
            targetOuter.lineWidth = 2
            targetOuter.fillColor = .clear
            targetOuter.zPosition = 10
            container.addChild(targetOuter)
            
            let targetInner = SKShapeNode(circleOfRadius: planetSize + 20)
            targetInner.strokeColor = SKColor.orange.withAlphaComponent(0.5)
            targetInner.lineWidth = 1.5
            targetInner.fillColor = .clear
            targetInner.zPosition = 10
            container.addChild(targetInner)
            
            // Add crosshairs
            let crosshairPath = CGMutablePath()
            crosshairPath.move(to: CGPoint(x: -(planetSize + 35), y: 0))
            crosshairPath.addLine(to: CGPoint(x: -(planetSize + 10), y: 0))
            crosshairPath.move(to: CGPoint(x: planetSize + 10, y: 0))
            crosshairPath.addLine(to: CGPoint(x: planetSize + 35, y: 0))
            crosshairPath.move(to: CGPoint(x: 0, y: -(planetSize + 35)))
            crosshairPath.addLine(to: CGPoint(x: 0, y: -(planetSize + 10)))
            crosshairPath.move(to: CGPoint(x: 0, y: planetSize + 10))
            crosshairPath.addLine(to: CGPoint(x: 0, y: planetSize + 35))
            
            let crosshair = SKShapeNode(path: crosshairPath)
            crosshair.strokeColor = SKColor.red.withAlphaComponent(0.4)
            crosshair.lineWidth = 1.5
            crosshair.zPosition = 10
            container.addChild(crosshair)
            
            // Animate the target
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0)
            targetOuter.run(SKAction.repeatForever(rotate))
            
            let rotateReverse = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 6.0)
            targetInner.run(SKAction.repeatForever(rotateReverse))
            
            // Pulse the crosshairs
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 1.0),
                SKAction.fadeAlpha(to: 0.6, duration: 1.0)
            ])
            crosshair.run(SKAction.repeatForever(pulse))
            
            // Add "FIRST TARGET" label
            let targetLabel = SKLabelNode(text: "FIRST TARGET")
            targetLabel.fontSize = 10
            targetLabel.fontName = "AvenirNext-Bold"
            targetLabel.fontColor = SKColor.red
            targetLabel.position = CGPoint(x: 0, y: planetSize + 45)
            targetLabel.zPosition = 10
            container.addChild(targetLabel)
            
            // Flash the label
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.6),
                SKAction.fadeAlpha(to: 1.0, duration: 0.6)
            ])
            targetLabel.run(SKAction.repeatForever(flash))
        }
        
        // Cratered surface texture
        for _ in 0..<8 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            crater.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 0.6)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.7...planetSize * 0.7),
                y: CGFloat.random(in: -planetSize * 0.7...planetSize * 0.7)
            )
            // Only add if within planet bounds
            if crater.position.x * crater.position.x + crater.position.y * crater.position.y <= planetSize * planetSize * 0.8 {
                planet.addChild(crater)
            }
        }
        
        // Hot side glow
        let hotGlow = SKShapeNode(circleOfRadius: planetSize * 0.4)
        hotGlow.position = CGPoint(x: planetSize * 0.3, y: 0)
        hotGlow.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 0.3)
        hotGlow.strokeColor = .clear
        hotGlow.blendMode = .add
        planet.addChild(hotGlow)
    }
    
    private func addVenusEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Thick atmosphere with swirling clouds
        let cloudLayer1 = SKShapeNode(circleOfRadius: planetSize * 1.05)
        cloudLayer1.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.3, alpha: 0.4)
        cloudLayer1.strokeColor = .clear
        cloudLayer1.blendMode = .add
        container.addChild(cloudLayer1)
        
        // Cloud patterns
        for i in 0..<6 {
            let cloudBand = SKShapeNode(ellipseOf: CGSize(width: planetSize * 1.8, height: planetSize * 0.3))
            cloudBand.fillColor = SKColor(red: 0.95, green: 0.85, blue: 0.4, alpha: 0.2)
            cloudBand.strokeColor = .clear
            cloudBand.zRotation = CGFloat(i) * CGFloat.pi / 6
            cloudBand.blendMode = .add
            planet.addChild(cloudBand)
            
            // Animated cloud rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 15...25))
            cloudBand.run(SKAction.repeatForever(rotate))
        }
        
        // Sulfuric acid cloud shimmer
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 2.0),
            SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        ])
        cloudLayer1.run(SKAction.repeatForever(shimmer))
    }
    
    private func addEarthEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Continents
        let continents = [
            (CGPoint(x: -planetSize * 0.3, y: planetSize * 0.2), planetSize * 0.35),
            (CGPoint(x: planetSize * 0.2, y: -planetSize * 0.3), planetSize * 0.25),
            (CGPoint(x: 0, y: planetSize * 0.4), planetSize * 0.2)
        ]
        
        for (position, size) in continents {
            let continent = SKShapeNode(circleOfRadius: size)
            continent.position = position
            continent.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 0.7)
            continent.strokeColor = .clear
            planet.addChild(continent)
        }
        
        // Ice caps
        let northCap = SKShapeNode(circleOfRadius: planetSize * 0.2)
        northCap.position = CGPoint(x: 0, y: planetSize * 0.7)
        northCap.fillColor = SKColor.white.withAlphaComponent(0.8)
        northCap.strokeColor = .clear
        planet.addChild(northCap)
        
        let southCap = SKShapeNode(circleOfRadius: planetSize * 0.15)
        southCap.position = CGPoint(x: 0, y: -planetSize * 0.75)
        southCap.fillColor = SKColor.white.withAlphaComponent(0.8)
        southCap.strokeColor = .clear
        planet.addChild(southCap)
        
        // Atmospheric glow
        let atmosphere = SKShapeNode(circleOfRadius: planetSize * 1.08)
        atmosphere.fillColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.2)
        atmosphere.strokeColor = .clear
        atmosphere.blendMode = .add
        container.addChild(atmosphere)
        
        // Moving clouds
        let cloudLayer = SKShapeNode(circleOfRadius: planetSize * 1.02)
        cloudLayer.fillColor = SKColor.white.withAlphaComponent(0.15)
        cloudLayer.strokeColor = .clear
        cloudLayer.blendMode = .add
        container.addChild(cloudLayer)
        
        let cloudRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30)
        cloudLayer.run(SKAction.repeatForever(cloudRotate))
    }
    
    private func addMarsEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Polar ice caps
        let northCap = SKShapeNode(circleOfRadius: planetSize * 0.15)
        northCap.position = CGPoint(x: 0, y: planetSize * 0.8)
        northCap.fillColor = SKColor.white.withAlphaComponent(0.9)
        northCap.strokeColor = .clear
        planet.addChild(northCap)
        
        // Dust storms
        for _ in 0..<4 {
            let storm = SKShapeNode(ellipseOf: CGSize(width: planetSize * 0.6, height: planetSize * 0.3))
            storm.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.5...planetSize * 0.5),
                y: CGFloat.random(in: -planetSize * 0.5...planetSize * 0.5)
            )
            storm.fillColor = SKColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 0.3)
            storm.strokeColor = .clear
            storm.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            storm.blendMode = .add
            planet.addChild(storm)
            
            // Animated dust movement
            let swirl = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 8...15))
            storm.run(SKAction.repeatForever(swirl))
        }
        
        // Valles Marineris (canyon system)
        let canyon = SKShapeNode(ellipseOf: CGSize(width: planetSize * 1.2, height: planetSize * 0.1))
        canyon.fillColor = SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 0.8)
        canyon.strokeColor = .clear
        canyon.zRotation = CGFloat.pi / 6
        planet.addChild(canyon)
    }
    
    private func addCeresEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Asteroid field around Ceres
        for _ in 0..<12 {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            let distance = planetSize + CGFloat.random(in: 15...30)
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            
            asteroid.position = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            asteroid.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8)
            asteroid.strokeColor = .clear
            container.addChild(asteroid)
            
            // Orbital motion
            let orbit = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 20...40))
            asteroid.run(SKAction.repeatForever(orbit))
        }
        
        // Surface craters
        for _ in 0..<5 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            crater.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6),
                y: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6)
            )
            crater.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7)
            crater.strokeColor = .clear
            planet.addChild(crater)
        }
    }
    
    private func addJupiterEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Cloud bands
        for i in 0..<8 {
            let band = SKShapeNode(ellipseOf: CGSize(width: planetSize * 2.1, height: planetSize * 0.2))
            band.position = CGPoint(x: 0, y: CGFloat(i - 4) * planetSize * 0.2)
            
            let hue = (i % 2 == 0) ? 
                SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 0.4) :
                SKColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 0.4)
            band.fillColor = hue
            band.strokeColor = .clear
            band.blendMode = .add
            planet.addChild(band)
            
            // All bands rotate at exactly the same speed for perfect synchronization
            let rotateSpeed = 15.0  // All bands use the same speed
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotateSpeed)
            band.run(SKAction.repeatForever(rotate))
        }
        
        // Great Red Spot
        let redSpot = SKShapeNode(ellipseOf: CGSize(width: planetSize * 0.4, height: planetSize * 0.25))
        redSpot.position = CGPoint(x: planetSize * 0.3, y: -planetSize * 0.2)
        redSpot.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.8)
        redSpot.strokeColor = .clear
        planet.addChild(redSpot)
        
        // Storm rotation
        let stormRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 25)
        redSpot.run(SKAction.repeatForever(stormRotate))
        
        // Lightning flashes
        createLightningEffects(on: planet, planetSize: planetSize)
    }
    
    private func addSaturnEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Multiple ring systems
        let ringDistances: [CGFloat] = [1.4, 1.7, 2.0, 2.2, 2.5]
        let ringColors = [
            SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.8),
            SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.6),
            SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.7),
            SKColor(red: 0.75, green: 0.65, blue: 0.45, alpha: 0.5),
            SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.4)
        ]
        
        for (i, distance) in ringDistances.enumerated() {
            let ring = SKShapeNode(ellipseOf: CGSize(width: planetSize * distance, height: planetSize * distance * 0.15))
            ring.strokeColor = ringColors[i]
            ring.lineWidth = CGFloat.random(in: 2...5)
            ring.fillColor = .clear
            container.addChild(ring)
            
            // Ring particle sparkles
            for _ in 0..<20 {
                let particle = SKShapeNode(circleOfRadius: 0.5)
                let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
                let radius = planetSize * distance * 0.5
                particle.position = CGPoint(
                    x: cos(angle) * radius,
                    y: sin(angle) * radius * 0.15
                )
                particle.fillColor = ringColors[i]
                particle.strokeColor = .clear
                particle.alpha = CGFloat.random(in: 0.3...0.8)
                container.addChild(particle)
                
                // Synchronized twinkling effect
                let baseDuration = 2.0
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: baseDuration),
                    SKAction.fadeAlpha(to: 0.8, duration: baseDuration)
                ])
                particle.run(SKAction.repeatForever(twinkle))
            }
        }
        
        // Hexagonal storm at north pole
        let hexagon = createHexagon(radius: planetSize * 0.2)
        hexagon.position = CGPoint(x: 0, y: planetSize * 0.7)
        hexagon.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.3, alpha: 0.6)
        hexagon.strokeColor = .clear
        planet.addChild(hexagon)
        
        let hexRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 15)
        hexagon.run(SKAction.repeatForever(hexRotate))
    }
    
    private func addUranusEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Horizontal rings (same direction as other planets)
        for i in 0..<5 {
            let ring = SKShapeNode(ellipseOf: CGSize(width: planetSize * (1.3 + CGFloat(i) * 0.1), height: planetSize * 0.05))
            ring.strokeColor = SKColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.4)
            ring.lineWidth = 1
            ring.fillColor = .clear
            container.addChild(ring)
        }
        
        // Methane atmosphere bands
        for i in 0..<4 {
            let band = SKShapeNode(ellipseOf: CGSize(width: planetSize * 2, height: planetSize * 0.3))
            band.position = CGPoint(x: 0, y: CGFloat(i - 2) * planetSize * 0.3)
            band.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 0.2)
            band.strokeColor = .clear
            band.blendMode = .add
            planet.addChild(band)
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 25...35))
            band.run(SKAction.repeatForever(rotate))
        }
        
        // Cold blue glow
        let coldGlow = SKShapeNode(circleOfRadius: planetSize * 1.1)
        coldGlow.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.1)
        coldGlow.strokeColor = .clear
        coldGlow.blendMode = .add
        container.addChild(coldGlow)
    }
    
    private func addNeptuneEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Dynamic storm systems
        for _ in 0..<3 {
            let storm = SKShapeNode(ellipseOf: CGSize(width: planetSize * 0.4, height: planetSize * 0.3))
            storm.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.4...planetSize * 0.4),
                y: CGFloat.random(in: -planetSize * 0.4...planetSize * 0.4)
            )
            storm.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.7, alpha: 0.6)
            storm.strokeColor = .clear
            storm.blendMode = .add
            planet.addChild(storm)
            
            // Storm movement
            let move = SKAction.sequence([
                SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 8...15)),
                SKAction.moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -10...10), duration: 5)
            ])
            storm.run(SKAction.repeatForever(move))
        }
        
        // High-speed winds visualization
        for i in 0..<6 {
            let windBand = SKShapeNode(ellipseOf: CGSize(width: planetSize * 2.1, height: planetSize * 0.15))
            windBand.position = CGPoint(x: 0, y: CGFloat(i - 3) * planetSize * 0.25)
            windBand.fillColor = SKColor(red: 0.0, green: 0.1, blue: 0.8, alpha: 0.3)
            windBand.strokeColor = .clear
            windBand.blendMode = .add
            planet.addChild(windBand)
            
            let fastRotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 5...10))
            windBand.run(SKAction.repeatForever(fastRotate))
        }
        
        // Deep blue atmospheric glow
        let deepGlow = SKShapeNode(circleOfRadius: planetSize * 1.08)
        deepGlow.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.9, alpha: 0.2)
        deepGlow.strokeColor = .clear
        deepGlow.blendMode = .add
        container.addChild(deepGlow)
    }
    
    private func addPlutoEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Binary system with Charon
        let charon = SKShapeNode(circleOfRadius: planetSize * 0.4)
        charon.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 0.8)
        charon.strokeColor = .clear
        charon.position = CGPoint(x: planetSize * 1.8, y: 0)
        container.addChild(charon)
        
        // Nitrogen ice patches
        for _ in 0..<4 {
            let icePatch = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            icePatch.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6),
                y: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6)
            )
            icePatch.fillColor = SKColor.white.withAlphaComponent(0.7)
            icePatch.strokeColor = .clear
            planet.addChild(icePatch)
        }
        
        // Heart-shaped feature (Tombaugh Regio)
        let heart = createHeartShape(size: planetSize * 0.3)
        heart.position = CGPoint(x: planetSize * 0.2, y: 0)
        heart.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.8, alpha: 0.6)
        heart.strokeColor = .clear
        planet.addChild(heart)
        
        // Binary orbital motion
        let binaryOrbit = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 40)
        container.run(SKAction.repeatForever(binaryOrbit))
    }
    
    private func addErisEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Highly reflective icy surface
        let iceLayer = SKShapeNode(circleOfRadius: planetSize * 1.02)
        iceLayer.fillColor = SKColor.white.withAlphaComponent(0.3)
        iceLayer.strokeColor = .clear
        iceLayer.blendMode = .add
        container.addChild(iceLayer)
        
        // Crystalline surface patterns
        for _ in 0..<8 {
            let crystal = SKShapeNode(ellipseOf: CGSize(width: 3, height: 1))
            crystal.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.7...planetSize * 0.7),
                y: CGFloat.random(in: -planetSize * 0.7...planetSize * 0.7)
            )
            crystal.fillColor = SKColor.white.withAlphaComponent(0.8)
            crystal.strokeColor = .clear
            crystal.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            planet.addChild(crystal)
        }
        
        // Distant shimmer effect
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 3.0),
            SKAction.fadeAlpha(to: 1.0, duration: 3.0)
        ])
        iceLayer.run(SKAction.repeatForever(shimmer))
    }
    
    private func addMakemakeEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Reddish surface composition
        let surfaceLayer = SKShapeNode(circleOfRadius: planetSize * 1.01)
        surfaceLayer.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.3, alpha: 0.3)
        surfaceLayer.strokeColor = .clear
        surfaceLayer.blendMode = .add
        container.addChild(surfaceLayer)
        
        // Methane frost patches
        for _ in 0..<6 {
            let frost = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            frost.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6),
                y: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6)
            )
            frost.fillColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.6)
            frost.strokeColor = .clear
            planet.addChild(frost)
        }
        
        // Irregular shape hint (elongated)
        let elongation = SKShapeNode(ellipseOf: CGSize(width: planetSize * 0.3, height: planetSize * 1.8))
        elongation.fillColor = SKColor(red: 0.7, green: 0.5, blue: 0.4, alpha: 0.2)
        elongation.strokeColor = .clear
        elongation.blendMode = .add
        planet.addChild(elongation)
    }
    
    // MARK: - Helper Methods for Visual Effects
    
    private func addAtmosphericGlow(to container: SKNode, planetName: String, planetSize: CGFloat) {
        let glowColors: [String: SKColor] = [
            "Venus": SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.15),
            "Earth": SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.12),
            "Mars": SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.08),
            "Jupiter": SKColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 0.15),
            "Saturn": SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.12),
            "Uranus": SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.1),
            "Neptune": SKColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 0.12)
        ]
        
        if let glowColor = glowColors[planetName] {
            let atmosphereGlow = SKShapeNode(circleOfRadius: planetSize * 1.15)
            atmosphereGlow.fillColor = glowColor
            atmosphereGlow.strokeColor = .clear
            atmosphereGlow.blendMode = .add
            container.insertChild(atmosphereGlow, at: 0)
        }
    }
    
    private func createLightningEffects(on planet: SKShapeNode, planetSize: CGFloat) {
        // Create occasional lightning flashes
        let lightning = SKShapeNode(rectOf: CGSize(width: 2, height: planetSize * 0.3))
        lightning.fillColor = SKColor.white
        lightning.strokeColor = .clear
        lightning.alpha = 0
        lightning.position = CGPoint(
            x: CGFloat.random(in: -planetSize * 0.5...planetSize * 0.5),
            y: CGFloat.random(in: -planetSize * 0.5...planetSize * 0.5)
        )
        lightning.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
        planet.addChild(lightning)
        
        let flash = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 5...15)),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        ])
        lightning.run(SKAction.repeatForever(flash))
    }
    
    private func createHexagon(radius: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        return SKShapeNode(path: path)
    }
    
    private func createHeartShape(size: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        
        // Create a simplified heart shape
        path.move(to: CGPoint(x: 0, y: -size * 0.5))
        path.addQuadCurve(to: CGPoint(x: size * 0.5, y: 0), control: CGPoint(x: size * 0.5, y: -size * 0.3))
        path.addQuadCurve(to: CGPoint(x: 0, y: size * 0.5), control: CGPoint(x: size * 0.3, y: size * 0.3))
        path.addQuadCurve(to: CGPoint(x: -size * 0.5, y: 0), control: CGPoint(x: -size * 0.3, y: size * 0.3))
        path.addQuadCurve(to: CGPoint(x: 0, y: -size * 0.5), control: CGPoint(x: -size * 0.5, y: -size * 0.3))
        
        return SKShapeNode(path: path)
    }
    
    private func getRotationSpeed(for planetName: String) -> Double {
        switch planetName {
        case "Mercury": return 58.6  // Very slow
        case "Venus": return 243.0   // Extremely slow, retrograde
        case "Earth": return 24.0    // 24 hours
        case "Mars": return 24.6     // Similar to Earth
        case "Ceres": return 9.1     // Fast rotation
        case "Jupiter": return 9.9   // Very fast
        case "Saturn": return 10.7   // Fast
        case "Uranus": return 17.2   // Tilted rotation
        case "Neptune": return 16.1  // Fast rotation
        case "Pluto": return 153.3   // Very slow
        case "Eris": return 25.9     // Earth-like
        case "Makemake": return 22.5 // Earth-like
        default: return 30.0
        }
    }
    
    private func drawConstellationPaths(_ points: [CGPoint]) {
        for i in 0..<points.count - 1 {
            let start = points[i]
            let end = points[i + 1]
            
            // Determine if this path segment is unlocked
            let isUnlocked = i + 1 < highestUnlockedMap
            
            if isUnlocked {
                // Create energy beam path
                createEnergyBeam(from: start, to: end)
            } else {
                // Create dotted path for locked sections
                createDottedPath(from: start, to: end)
            }
        }
    }
    
    private func createEnergyBeam(from start: CGPoint, to end: CGPoint) {
        // Main beam
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let beam = SKShapeNode(path: path)
        beam.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        beam.lineWidth = 2
        beam.glowWidth = 4
        pathLayer.addChild(beam)
        
        // Animated energy particles along the beam
        for i in 0..<3 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = .cyan
            particle.strokeColor = .clear
            particle.glowWidth = 3
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.5)
            let move = SKAction.move(to: end, duration: 2.0)
            let reset = SKAction.move(to: start, duration: 0)
            let sequence = SKAction.sequence([delay, move, reset])
            
            particle.position = start
            particle.run(SKAction.repeatForever(sequence))
            pathLayer.addChild(particle)
        }
    }
    
    private func createDottedPath(from start: CGPoint, to end: CGPoint) {
        let distance = hypot(end.x - start.x, end.y - start.y)
        let dotCount = Int(distance / 20)
        
        for i in 0...dotCount {
            let progress = CGFloat(i) / CGFloat(dotCount)
            let x = start.x + (end.x - start.x) * progress
            let y = start.y + (end.y - start.y) * progress
            
            let dot = SKShapeNode(circleOfRadius: 1.5)
            dot.fillColor = SKColor.gray
            dot.strokeColor = .clear
            dot.alpha = 0.3
            dot.position = CGPoint(x: x, y: y)
            pathLayer.addChild(dot)
        }
    }
    
    private func createPlanetNode(mapNumber: Int, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = "map\(mapNumber)"
        
        // Determine button state
        let isCompleted = completedMaps.contains(mapNumber)
        let isUnlocked = mapNumber <= highestUnlockedMap
        let isCurrent = mapNumber == highestUnlockedMap && !isCompleted
        
        // Create planet/station visual
        let planetRadius: CGFloat = 30
        
        // Outer ring (orbit)
        let orbit = SKShapeNode(circleOfRadius: planetRadius + 15)
        orbit.strokeColor = isUnlocked ? SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.3) : SKColor.gray.withAlphaComponent(0.2)
        orbit.lineWidth = 1
        orbit.fillColor = .clear
        container.addChild(orbit)
        
        // Planet body
        let planet = SKShapeNode(circleOfRadius: planetRadius)
        
        // Planet colors based on state
        if isCompleted {
            // Conquered planet - green/teal
            planet.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.4, alpha: 0.9)
            planet.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 0.7, alpha: 1.0)
            planet.lineWidth = 3
            planet.glowWidth = 5
            
            // Add spinning rings for completed planets
            let ring = createPlanetRing(radius: planetRadius + 8, color: .green)
            container.addChild(ring)
        } else if isCurrent {
            // Target planet - pulsing blue/purple
            planet.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.9)
            planet.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
            planet.lineWidth = 4
            planet.glowWidth = 8
            
            // Pulsing effect
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            planet.run(SKAction.repeatForever(pulse))
            
            // Add targeting reticle
            createTargetingReticle(for: container, radius: planetRadius + 20)
        } else if isUnlocked {
            // Accessible planet - dim blue
            planet.fillColor = SKColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 0.8)
            planet.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.6, alpha: 0.8)
            planet.lineWidth = 2
        } else {
            // Locked planet - dark gray
            planet.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
            planet.strokeColor = SKColor.darkGray
            planet.lineWidth = 1
            planet.alpha = 0.4
        }
        
        container.addChild(planet)
        
        // Add planet texture details
        if isUnlocked || isCompleted {
            addPlanetDetails(to: planet, mapNumber: mapNumber)
        }
        
        // Map number
        let numberLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        numberLabel.text = "\(mapNumber)"
        numberLabel.fontSize = 20
        numberLabel.fontColor = isUnlocked ? .white : .gray
        numberLabel.verticalAlignmentMode = .center
        numberLabel.position = CGPoint(x: 0, y: 0)
        numberLabel.zPosition = 1
        container.addChild(numberLabel)
        
        // Status icons
        // Removed green checkmark for completed planets
        if !isUnlocked {
            let lockIcon = SKLabelNode(text: "🔒")
            lockIcon.fontSize = 35  // Smaller lock icon
            lockIcon.position = CGPoint(x: 0, y: -20)
            lockIcon.zPosition = 2
            container.addChild(lockIcon)
        }
        
        // Sector name (floating below)
        if isUnlocked || isCompleted {
            let nameLabel = SKLabelNode(fontNamed: "Helvetica")
            nameLabel.text = getMapName(mapNumber)
            nameLabel.fontSize = 16  // Reduced text size
            nameLabel.fontColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.8)
            nameLabel.position = CGPoint(x: 0, y: -55)
            container.addChild(nameLabel)
            
            // Wave info
            let waveLabel = SKLabelNode(fontNamed: "Helvetica")
            waveLabel.text = getWaveInfo(mapNumber)
            waveLabel.fontSize = 9
            waveLabel.fontColor = .cyan
            waveLabel.alpha = 0.7
            waveLabel.position = CGPoint(x: 0, y: -68)
            container.addChild(waveLabel)
        }
        
        // Slow rotation for unlocked planets
        if isUnlocked && !isCurrent {
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 30.0)
            planet.run(SKAction.repeatForever(rotate))
        }
        
        return container
    }
    
    private func createPlanetRing(radius: CGFloat, color: SKColor) -> SKNode {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.strokeColor = color
        ring.lineWidth = 2
        ring.fillColor = .clear
        ring.alpha = 0.6
        
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 4.0)
        ring.run(SKAction.repeatForever(rotate))
        
        return ring
    }
    
    private func createTargetingReticle(for node: SKNode, radius: CGFloat) {
        // Create animated targeting brackets
        for angle in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 2) {
            let bracket = createBracket()
            bracket.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            bracket.zRotation = angle
            node.addChild(bracket)
            
            // Rotating animation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0)
            bracket.run(SKAction.repeatForever(rotate))
        }
    }
    
    private func createBracket() -> SKNode {
        let bracket = SKNode()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -10, y: 0))
        path.addLine(to: CGPoint(x: -5, y: 0))
        path.move(to: CGPoint(x: 5, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 0))
        
        let shape = SKShapeNode(path: path)
        shape.strokeColor = .cyan
        shape.lineWidth = 2
        shape.glowWidth = 1
        bracket.addChild(shape)
        
        return bracket
    }
    
    private func addPlanetDetails(to planet: SKShapeNode, mapNumber: Int) {
        // Add some visual variety to planets
        let detail = SKShapeNode(circleOfRadius: 8)
        detail.fillColor = planet.fillColor.withAlphaComponent(0.5)
        detail.strokeColor = .clear
        detail.position = CGPoint(x: -8, y: 8)
        planet.addChild(detail)
        
        let detail2 = SKShapeNode(circleOfRadius: 5)
        detail2.fillColor = planet.fillColor.withAlphaComponent(0.3)
        detail2.strokeColor = .clear
        detail2.position = CGPoint(x: 10, y: -5)
        planet.addChild(detail2)
    }
    
    private func getMapName(_ mapNumber: Int) -> String {
        switch mapNumber {
        case 1: return "Alpha Centauri A"
        case 2: return "Proxima B Outpost"
        case 3: return "Kepler Station"
        case 4: return "Tau Ceti Colony"
        case 5: return "Pluto Frontier"
        case 6: return "Neptune Base"
        case 7: return "Uranus Outpost"
        case 8: return "Saturn Rings"
        case 9: return "Jupiter Station"
        case 10: return "Mars Colony"
        case 11: return "Moon Base"
        case 12: return "Earth Defense"
        default: return "Unknown Sector"
        }
    }
    
    private func getWaveInfo(_ mapNumber: Int) -> String {
        switch mapNumber {
        case 1...2: return "◆ 3 Waves ◆"
        case 3...4: return "◆ 4 Waves ◆"
        default: return "◆ 5 Waves ◆"
        }
    }
    
    private func pauseAnimations() {
        guard !animationsPaused else { return }
        animationsPaused = true
        
        // Pause all node animations
        starLayer.isPaused = true
        pathLayer.isPaused = true
        planetLayer.isPaused = true
        scrollContainer.isPaused = true
        
        // Cancel the resume timer if it exists
        scrollEndTimer?.invalidate()
        scrollEndTimer = nil
    }
    
    private func resumeAnimationsAfterDelay() {
        // Cancel any existing timer
        scrollEndTimer?.invalidate()
        
        // Set a timer to resume animations after scrolling stops
        scrollEndTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.resumeAnimations()
        }
    }
    
    private func resumeAnimations() {
        guard animationsPaused else { return }
        animationsPaused = false
        
        // Resume all node animations
        starLayer.isPaused = false
        pathLayer.isPaused = false
        planetLayer.isPaused = false
        scrollContainer.isPaused = false
        
        scrollEndTimer?.invalidate()
        scrollEndTimer = nil
    }
    
    private func createBackButton() {
        // Create sleek space-themed back button
        backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 20)
        backButton.position = CGPoint(x: -size.width * 0.38, y: size.height * 0.38)  // Moved up
        
        // Dark glass-like background with blue accent
        backButton.fillColor = SKColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 0.85)
        backButton.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.9)
        backButton.lineWidth = 1.5
        backButton.glowWidth = 4
        backButton.name = "backButton"
        backButton.zPosition = 100
        
        // Create arrow icon
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -25, y: 0))
        arrowPath.addLine(to: CGPoint(x: -15, y: -8))
        arrowPath.move(to: CGPoint(x: -25, y: 0))
        arrowPath.addLine(to: CGPoint(x: -15, y: 8))
        arrowPath.move(to: CGPoint(x: -25, y: 0))
        arrowPath.addLine(to: CGPoint(x: -5, y: 0))
        
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0)
        arrow.lineWidth = 2.5
        arrow.lineCap = .round
        arrow.position = CGPoint(x: -15, y: 0)
        backButton.addChild(arrow)
        
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = "BACK"
        label.fontSize = 16
        label.fontColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 15, y: 0)
        backButton.addChild(label)
        
        // Add subtle animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        backButton.run(SKAction.repeatForever(pulse))
        
        cameraNode.addChild(backButton)
    }
    
    private func createScrollIndicators() {
        // Create left scroll indicator
        let leftIndicator = SKNode()
        leftIndicator.position = CGPoint(x: -size.width * 0.45, y: 0)
        leftIndicator.zPosition = 100
        leftIndicator.name = "leftScrollIndicator"
        
        // Left arrow shape
        let leftArrowPath = CGMutablePath()
        leftArrowPath.move(to: CGPoint(x: 10, y: -20))
        leftArrowPath.addLine(to: CGPoint(x: -10, y: 0))
        leftArrowPath.addLine(to: CGPoint(x: 10, y: 20))
        
        let leftArrow = SKShapeNode(path: leftArrowPath)
        leftArrow.strokeColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.8)
        leftArrow.lineWidth = 3
        leftArrow.lineCap = .round
        leftArrow.lineJoin = .round
        leftArrow.fillColor = .clear
        leftIndicator.addChild(leftArrow)
        
        // Pulsing animation for left arrow
        let leftPulse = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.8),
            SKAction.moveBy(x: 5, y: 0, duration: 0.8)
        ])
        leftArrow.run(SKAction.repeatForever(leftPulse))
        
        cameraNode.addChild(leftIndicator)
        
        // Create right scroll indicator
        let rightIndicator = SKNode()
        rightIndicator.position = CGPoint(x: size.width * 0.45, y: 0)
        rightIndicator.zPosition = 100
        rightIndicator.name = "rightScrollIndicator"
        
        // Right arrow shape
        let rightArrowPath = CGMutablePath()
        rightArrowPath.move(to: CGPoint(x: -10, y: -20))
        rightArrowPath.addLine(to: CGPoint(x: 10, y: 0))
        rightArrowPath.addLine(to: CGPoint(x: -10, y: 20))
        
        let rightArrow = SKShapeNode(path: rightArrowPath)
        rightArrow.strokeColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.8)
        rightArrow.lineWidth = 3
        rightArrow.lineCap = .round
        rightArrow.lineJoin = .round
        rightArrow.fillColor = .clear
        rightIndicator.addChild(rightArrow)
        
        // Pulsing animation for right arrow
        let rightPulse = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.8),
            SKAction.moveBy(x: -5, y: 0, duration: 0.8)
        ])
        rightArrow.run(SKAction.repeatForever(rightPulse))
        
        cameraNode.addChild(rightIndicator)
        
        // Add "Swipe to scroll" hint text
        let hintLabel = SKLabelNode(fontNamed: "Helvetica")
        hintLabel.text = "← Swipe to explore →"
        hintLabel.fontSize = 14
        hintLabel.fontColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.6)
        hintLabel.position = CGPoint(x: 0, y: -size.height * 0.42)
        hintLabel.zPosition = 100
        
        // Fade in/out animation for hint
        let fadeSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.5),
            SKAction.fadeAlpha(to: 0.6, duration: 1.5)
        ])
        hintLabel.run(SKAction.repeatForever(fadeSequence))
        
        cameraNode.addChild(hintLabel)
    }
    
    private func updateScrollIndicators() {
        // Update visibility based on scroll position
        let leftIndicator = cameraNode.childNode(withName: "leftScrollIndicator")
        let rightIndicator = cameraNode.childNode(withName: "rightScrollIndicator")
        
        // Show/hide indicators based on camera position
        let scrollLimit: CGFloat = 2000
        leftIndicator?.alpha = cameraNode.position.x < scrollLimit ? 1.0 : 0.3
        rightIndicator?.alpha = cameraNode.position.x > -scrollLimit ? 1.0 : 0.3
    }
    
    private func createSpaceBackground() {
        // Create COLORFUL nebula clouds with various hues
        let nebulaColors = [
            (r: 0.6, g: 0.2, b: 0.8),  // Purple nebula
            (r: 0.2, g: 0.5, b: 0.9),  // Blue nebula
            (r: 0.9, g: 0.3, b: 0.4),  // Pink/Red nebula
            (r: 0.3, g: 0.8, b: 0.7),  // Cyan nebula
            (r: 0.8, g: 0.6, b: 0.2),  // Orange nebula
            (r: 0.4, g: 0.7, b: 0.3),  // Green nebula
            (r: 0.9, g: 0.9, b: 0.3)   // Yellow nebula
        ]
        
        for i in 0..<12 {
            let color = nebulaColors[i % nebulaColors.count]
            let nebula = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...250))
            nebula.fillColor = SKColor(
                red: CGFloat(color.r),
                green: CGFloat(color.g),
                blue: CGFloat(color.b),
                alpha: CGFloat.random(in: 0.08...0.15)
            )
            nebula.strokeColor = .clear
            nebula.position = CGPoint(
                x: CGFloat.random(in: -size.width*1.5...size.width*1.5),
                y: CGFloat.random(in: -size.height*1.5...size.height*1.5)
            )
            nebula.zPosition = -25
            nebula.blendMode = .add
            starLayer.addChild(nebula)
            
            // Slow drift animation
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: Double.random(in: 40...80)),
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: Double.random(in: 40...80))
            ])
            nebula.run(SKAction.repeatForever(drift))
        }
        
        // Create DENSE star field with various colors and sizes
        let deviceType = UIDevice.current.userInterfaceIdiom
        let starCount = deviceType == .pad ? 5000 : 1000  // Even more stars to fill screen
        for _ in 0..<starCount {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.2...2.5))
            
            // Vary star colors for realism
            let starType = Int.random(in: 0...10)
            switch starType {
            case 0...5:  // White stars (most common)
                star.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
            case 6...7:  // Blue giants
                star.fillColor = SKColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 1.0)
            case 8:  // Red giants
                star.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.6, alpha: 1.0)
            case 9:  // Yellow stars
                star.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
            default:  // Orange stars
                star.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)
            }
            
            star.strokeColor = .clear
            
            let baseAlpha = CGFloat.random(in: 0.3...0.9)
            star.alpha = baseAlpha
            
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width*2...size.width*2),
                y: CGFloat.random(in: -size.height*2...size.height*2)
            )
            
            starLayer.addChild(star)
            
            // Varied flicker animations
            if Int.random(in: 0...2) == 0 {  // Only some stars flicker
                let flickerDuration = Double.random(in: 2...6)
                let fadeOut = SKAction.fadeAlpha(to: baseAlpha * 0.3, duration: flickerDuration)
                let fadeIn = SKAction.fadeAlpha(to: baseAlpha, duration: flickerDuration)
                let flicker = SKAction.sequence([fadeOut, fadeIn])
                let delay = SKAction.wait(forDuration: Double.random(in: 0...3))
                star.run(SKAction.sequence([delay, SKAction.repeatForever(flicker)]))
            }
        }
        
        // Add bright star clusters
        for _ in 0..<8 {
            let clusterCenter = CGPoint(
                x: CGFloat.random(in: -size.width...size.width),
                y: CGFloat.random(in: -size.height...size.height)
            )
            
            // Create a cluster of stars
            for _ in 0..<15 {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
                star.fillColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
                star.strokeColor = .clear
                star.alpha = CGFloat.random(in: 0.5...0.9)
                star.position = CGPoint(
                    x: clusterCenter.x + CGFloat.random(in: -40...40),
                    y: clusterCenter.y + CGFloat.random(in: -40...40)
                )
                star.glowWidth = 1
                starLayer.addChild(star)
            }
        }
        
        // Add some colorful distant galaxies
        for _ in 0..<5 {
            let galaxy = createDistantGalaxy()
            galaxy.position = CGPoint(
                x: CGFloat.random(in: -size.width/3...size.width/3),
                y: CGFloat.random(in: -size.height/3...size.height/3)
            )
            starLayer.addChild(galaxy)
        }
        
        // REDUCED: Only 4 very small moving objects
        createMinimalMovingObjects()
    }
    
    private func createDistantGalaxy() -> SKNode {
        let galaxy = SKNode()
        
        // Random galaxy colors
        let galaxyColors = [
            (r: 0.9, g: 0.6, b: 1.0),  // Purple galaxy
            (r: 0.6, g: 0.9, b: 1.0),  // Cyan galaxy
            (r: 1.0, g: 0.7, b: 0.5),  // Orange galaxy
            (r: 0.5, g: 1.0, b: 0.7),  // Green galaxy
            (r: 1.0, g: 0.5, b: 0.7),  // Pink galaxy
            (r: 0.7, g: 0.7, b: 1.0)   // Blue galaxy
        ]
        
        let color = galaxyColors.randomElement()!
        
        // Central bright core with color
        let core = SKShapeNode(circleOfRadius: 5)
        core.fillColor = SKColor(red: CGFloat(color.r), green: CGFloat(color.g), blue: CGFloat(color.b), alpha: 0.6)
        core.strokeColor = .clear
        core.blendMode = .add
        core.glowWidth = 8
        galaxy.addChild(core)
        
        // Inner bright core
        let innerCore = SKShapeNode(circleOfRadius: 2)
        innerCore.fillColor = SKColor.white.withAlphaComponent(0.8)
        innerCore.strokeColor = .clear
        innerCore.blendMode = .add
        galaxy.addChild(innerCore)
        
        // Create spiral arms with gradient
        for arm in 0..<3 {
            let armOffset = CGFloat(arm) * (CGFloat.pi * 2 / 3)
            
            for i in 0..<30 {
                let angle = CGFloat(i) * 0.2 + armOffset
                let radius = CGFloat(i) * 1.5
                let alpha = 0.4 * (1.0 - CGFloat(i) / 30.0)  // Fade out at edges
                
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.3...1.0))
                star.fillColor = SKColor(
                    red: CGFloat(color.r) * CGFloat.random(in: 0.8...1.0),
                    green: CGFloat(color.g) * CGFloat.random(in: 0.8...1.0),
                    blue: CGFloat(color.b) * CGFloat.random(in: 0.8...1.0),
                    alpha: alpha
                )
                star.strokeColor = .clear
                star.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius * 0.4)
                star.blendMode = .add
                galaxy.addChild(star)
            }
        }
        
        // Add some bright spots
        for _ in 0..<5 {
            let brightSpot = SKShapeNode(circleOfRadius: 1)
            brightSpot.fillColor = SKColor.white.withAlphaComponent(0.6)
            brightSpot.strokeColor = .clear
            brightSpot.position = CGPoint(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -4...4)
            )
            brightSpot.blendMode = .add
            galaxy.addChild(brightSpot)
        }
        
        // Slow rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 100...150))
        galaxy.run(SKAction.repeatForever(rotate))
        
        // Scale for distance
        galaxy.setScale(CGFloat.random(in: 0.5...1.2))
        
        return galaxy
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for UI elements first (back button)
        let cameraLocation = touch.location(in: cameraNode)
        let cameraNodes = cameraNode.nodes(at: cameraLocation)
        
        for node in cameraNodes {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                returnToMainMenu()
                return
            }
        }
        
        // Check for celebration return button (not in camera node)
        let sceneLocation = touch.location(in: self)
        let sceneNodes = nodes(at: sceneLocation)
        
        for node in sceneNodes {
            if node.name == "celebrationReturn" || node.parent?.name == "celebrationReturn" {
                returnToMainMenu()
                return
            }
        }
        
        // Start tracking for potential scrolling or map selection
        lastTouchLocation = touch.location(in: self)
        touchStartLocation = lastTouchLocation
        touchStartTime = touch.timestamp
        lastTouchTime = touch.timestamp
        isDragging = false
        totalDragDistance = CGPoint.zero
        scrollVelocity = CGPoint.zero
        isDecelerating = false
        potentialMapSelection = nil
        
        // Stop any ongoing momentum scrolling
        cameraNode.removeAllActions()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Handle pinch zoom if multiple touches
        if touches.count == 2 {
            handlePinchZoom(touches)
            return
        }
        
        let currentLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let deltaX = currentLocation.x - previousLocation.x
        let deltaY = currentLocation.y - previousLocation.y
        let currentTime = touch.timestamp
        
        // Update velocity for momentum scrolling
        let timeDelta = currentTime - lastTouchTime
        if timeDelta > 0 {
            scrollVelocity = CGPoint(
                x: deltaX / CGFloat(timeDelta),
                y: deltaY / CGFloat(timeDelta)
            )
        }
        lastTouchTime = currentTime
        
        // Track total drag distance for determining if this is a scroll vs tap
        totalDragDistance.x += abs(deltaX)
        totalDragDistance.y += abs(deltaY)
        
        // If we've moved enough in either direction, consider this a drag
        if totalDragDistance.x > 5 || totalDragDistance.y > 5 {
            isDragging = true
            potentialMapSelection = nil  // Cancel any potential selection
        }
        
        // Apply scrolling with limited range
        let maxVerticalScroll: CGFloat = 35  // ~1cm vertical
        let maxHorizontalScroll: CGFloat = 70 // ~2cm horizontal
        
        let newX = cameraNode.position.x - deltaX
        let newY = cameraNode.position.y - deltaY
        
        // Clamp to bounds
        cameraNode.position.x = max(-maxHorizontalScroll, min(maxHorizontalScroll, newX))
        cameraNode.position.y = max(-maxVerticalScroll, min(maxVerticalScroll, newY))
    }
    
    private func handlePinchZoom(_ touches: Set<UITouch>) {
        let touchArray = Array(touches)
        guard touchArray.count == 2 else { return }
        
        let touch1 = touchArray[0]
        let touch2 = touchArray[1]
        
        // Calculate current and previous distances
        let currentDistance = hypot(
            touch1.location(in: self).x - touch2.location(in: self).x,
            touch1.location(in: self).y - touch2.location(in: self).y
        )
        
        let previousDistance = hypot(
            touch1.previousLocation(in: self).x - touch2.previousLocation(in: self).x,
            touch1.previousLocation(in: self).y - touch2.previousLocation(in: self).y
        )
        
        // Calculate scale change
        let scale = currentDistance / previousDistance
        
        // Apply zoom with limits (inverted scale calculation for natural feel)
        let newScale = currentCameraScale / scale  // Inverted for natural pinch behavior
        let minZoom: CGFloat = 0.5  // Zoomed out (see everything)
        let maxZoom: CGFloat = 3.0  // Zoomed in (closer view)
        
        currentCameraScale = max(minZoom, min(maxZoom, newScale))
        cameraNode.setScale(currentCameraScale)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        defer {
            // Clean up tracking variables
            isDragging = false
            lastTouchLocation = nil
            potentialMapSelection = nil
            resumeAnimationsAfterDelay()  // Resume animations after short delay
        }
        
        // If we were dragging vertically, apply momentum scrolling
        if isDragging {
            // Apply momentum if there's any vertical velocity
            if abs(scrollVelocity.y) > 10 {
                applyVerticalScrollMomentum()
            }
            return
        }
        
        // If not dragging, check for map selection (tap)
        let scrollLocation = touch.location(in: scrollContainer)
        let scrollNodes = scrollContainer.nodes(at: scrollLocation)
        
        for node in scrollNodes {
            if let nodeName = node.name ?? node.parent?.name ?? node.parent?.parent?.name,
               nodeName.hasPrefix("map") {
                if let mapNumber = Int(nodeName.replacingOccurrences(of: "map", with: "")) {
                    selectMap(mapNumber)
                    return
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        lastTouchLocation = nil
        potentialMapSelection = nil
        scrollVelocity = CGPoint.zero
        resumeAnimationsAfterDelay()  // Resume animations after short delay
    }
    
    private func applyVerticalScrollMomentum() {
        isDecelerating = true
        
        // Combined horizontal and vertical momentum scrolling
        let decelerate = SKAction.customAction(withDuration: 1.5) { [weak self] _, elapsedTime in
            guard let self = self, self.isDecelerating else { return }
            
            // Simple deceleration
            let decelerationRate: CGFloat = 0.92
            let timeScale = CGFloat(1.0 / 60.0)
            
            // Apply velocity
            self.cameraNode.position.x -= self.scrollVelocity.x * timeScale
            self.cameraNode.position.y -= self.scrollVelocity.y * timeScale
            
            // Use defined bounds
            let maxVerticalScroll: CGFloat = 35  // ~1cm vertical
            let maxHorizontalScroll: CGFloat = 70 // ~2cm horizontal
            
            self.cameraNode.position.x = max(-maxHorizontalScroll, min(maxHorizontalScroll, self.cameraNode.position.x))
            self.cameraNode.position.y = max(-maxVerticalScroll, min(maxVerticalScroll, self.cameraNode.position.y))
            
            // Reduce velocity
            self.scrollVelocity.x *= decelerationRate
            self.scrollVelocity.y *= decelerationRate
            
            // Stop if velocity is too low
            if abs(self.scrollVelocity.x) < 1 && abs(self.scrollVelocity.y) < 1 {
                self.isDecelerating = false
            }
        }
        
        self.run(decelerate)
    }
    
    private func applyScrollMomentum() {
        isDecelerating = true
        
        // SIMPLE momentum scrolling
        let decelerate = SKAction.customAction(withDuration: 2.0) { [weak self] _, elapsedTime in
            guard let self = self, self.isDecelerating else { return }
            
            // Simple deceleration
            let decelerationRate: CGFloat = 0.95
            let timeScale = CGFloat(1.0 / 60.0)
            
            // Apply velocity
            self.cameraNode.position.x -= self.scrollVelocity.x * timeScale
            
            // Use the dynamically calculated bounds
            let minX = self.contentMinX
            let maxX = self.contentMaxX
            
            self.cameraNode.position.x = max(minX, min(maxX, self.cameraNode.position.x))
            self.cameraNode.position.y = 0
            
            // Update scroll indicators during momentum
            self.updateScrollIndicators()
            
            // Decelerate velocity
            self.scrollVelocity.x *= decelerationRate
            
            // Stop if velocity is too small
            if abs(self.scrollVelocity.x) < 5 {
                self.scrollVelocity = CGPoint.zero
                self.isDecelerating = false
                self.resumeAnimationsAfterDelay()
            }
        }
        
        self.run(decelerate)
    }
    
    private func selectMap(_ mapNumber: Int) {
        // Check if map is unlocked
        guard mapNumber <= highestUnlockedMap else {
            // Show locked message
            showMessage("Complete Sector \(mapNumber - 1) first!", at: CGPoint(x: 0, y: 0))
            return
        }
        
        // Check if this is the final map and already completed - show celebration
        if mapNumber == 12 && completedMaps.contains(12) {
            showFinalCelebration()
            return
        }
        
        // Start the selected map with warp effect
        startGame(atMap: mapNumber)
    }
    
    private func showMessage(_ text: String, at position: CGPoint) {
        let messageBox = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 10)
        messageBox.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9)
        messageBox.strokeColor = .red
        messageBox.lineWidth = 2
        messageBox.position = position
        messageBox.zPosition = 200
        
        let message = SKLabelNode(fontNamed: "Helvetica-Bold")
        message.text = text
        message.fontSize = 18
        message.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        message.verticalAlignmentMode = .center
        messageBox.addChild(message)
        
        addChild(messageBox)
        
        // Shake and fade
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        
        messageBox.run(SKAction.sequence([
            shake,
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func startGame(atMap mapNumber: Int) {
        // Create warp effect before transitioning
        let warpEffect = SKShapeNode(circleOfRadius: 5)
        warpEffect.fillColor = .white
        warpEffect.strokeColor = .cyan
        warpEffect.lineWidth = 2
        warpEffect.position = mapButtons[mapNumber - 1].position
        warpEffect.zPosition = 300
        addChild(warpEffect)
        
        // FASTER: Reduced warp effect time
        let expand = SKAction.scale(to: 100, duration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([expand, fade])
        
        warpEffect.run(SKAction.sequence([
            group,
            SKAction.run { [weak self] in
                self?.transitionToGame(mapNumber: mapNumber)
            }
        ]))
    }
    
    private func transitionToGame(mapNumber: Int) {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        gameScene.userData = NSMutableDictionary()
        gameScene.userData?["startingMap"] = mapNumber
        
        // FASTER: Quicker transition to game
        let transition = SKTransition.fade(with: .white, duration: 0.15)
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func showFinalCelebration() {
        // Create celebration overlay
        let celebrationBg = SKShapeNode(rectOf: CGSize(width: size.width * 0.9, height: size.height * 0.7), cornerRadius: 20)
        celebrationBg.position = CGPoint(x: 0, y: 0)
        celebrationBg.fillColor = SKColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 0.95)
        celebrationBg.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold color
        celebrationBg.lineWidth = 3
        celebrationBg.glowWidth = 5
        celebrationBg.zPosition = 200
        addChild(celebrationBg)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "🌟 GALAXY LIBERATED! 🌟"
        titleLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 36 : 28
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold color
        titleLabel.position = CGPoint(x: 0, y: size.height * 0.25)
        titleLabel.zPosition = 201
        addChild(titleLabel)
        
        // Congratulations text
        let congratsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        congratsLabel.text = "Congratulations, Commander!"
        congratsLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20
        congratsLabel.fontColor = .cyan
        congratsLabel.position = CGPoint(x: 0, y: size.height * 0.15)
        congratsLabel.zPosition = 201
        addChild(congratsLabel)
        
        // Story text
        let storyText = """
        You have successfully liberated all sectors
        of the galaxy from the alien menace.
        
        The space salvagers can now operate freely,
        and peace has been restored to the cosmos.
        
        Thank you for playing SpaceSalvagers!
        """
        
        let storyLabel = SKLabelNode(fontNamed: "Helvetica")
        storyLabel.text = storyText
        storyLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14
        storyLabel.fontColor = .white
        storyLabel.numberOfLines = 0
        storyLabel.preferredMaxLayoutWidth = size.width * 0.8
        storyLabel.position = CGPoint(x: 0, y: 0)
        storyLabel.zPosition = 201
        addChild(storyLabel)
        
        // Return button
        let returnButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        returnButton.position = CGPoint(x: 0, y: -size.height * 0.2)
        returnButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.8)
        returnButton.strokeColor = .cyan
        returnButton.lineWidth = 2
        returnButton.name = "celebrationReturn"
        returnButton.zPosition = 201
        addChild(returnButton)
        
        let returnLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        returnLabel.text = "Return to Main Menu"
        returnLabel.fontSize = 18
        returnLabel.fontColor = .white
        returnLabel.verticalAlignmentMode = .center
        returnButton.addChild(returnLabel)
        
        // Add celebration particles
        createCelebrationEffects()
        
        // Animate appearance
        celebrationBg.alpha = 0
        titleLabel.alpha = 0
        congratsLabel.alpha = 0
        storyLabel.alpha = 0
        returnButton.alpha = 0
        
        celebrationBg.run(SKAction.fadeIn(withDuration: 0.5))
        titleLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.fadeIn(withDuration: 0.5)]))
        congratsLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.fadeIn(withDuration: 0.5)]))
        storyLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeIn(withDuration: 0.5)]))
        returnButton.run(SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.fadeIn(withDuration: 0.5)]))
        
        // Play celebration sound
        SoundManager.shared.playSound(.mapComplete)
    }
    
    private func createCelebrationEffects() {
        // Create golden particles falling from top
        for i in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold color
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: size.height/2 + 50
            )
            particle.zPosition = 250
            addChild(particle)
            
            // Animate falling with sparkle
            let fall = SKAction.moveTo(y: -size.height/2 - 50, duration: Double.random(in: 3...6))
            let sparkle = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2)
            
            particle.run(SKAction.group([
                fall,
                SKAction.repeatForever(sparkle),
                SKAction.repeatForever(rotate)
            ])) {
                particle.removeFromParent()
            }
            
            // Stagger the start times
            particle.run(SKAction.sequence([SKAction.wait(forDuration: Double(i) * 0.1), SKAction.run {}]))
        }
    }
    
    private func returnToMainMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }
    
    private func focusOnCurrentPlanet() {
        // Find the current or first unlocked planet position
        let targetMap = highestUnlockedMap
        
        // Calculate approximate position based on map number
        // We need to find the actual planet node position
        if targetMap <= mapButtons.count && targetMap > 0 {
            let planetNode = mapButtons[targetMap - 1]
            
            // Animate camera to focus on this planet
            let moveAction = SKAction.move(to: planetNode.position, duration: 0.5)
            cameraNode.run(moveAction)
        }
    }
    
    // Called when a map is completed
    func markMapCompleted(_ mapNumber: Int) {
        completedMaps.insert(mapNumber)
        
        // Unlock next map
        if mapNumber == highestUnlockedMap && mapNumber < totalMaps {
            highestUnlockedMap = mapNumber + 1
        }
        
        saveProgress()
    }
    
    // MARK: - New Alien World Effects
    
    private func addProximaBEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // PROXIMA B - Red dwarf star with orbiting planets
        print("🌟 Creating Proxima B star system effects with size: \(planetSize)")
        
        // Make the main body glow like a BRIGHT RED star
        planet.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 1.0)  // Brighter red
        planet.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)  // Orange glow
        planet.lineWidth = 3  // Thicker line
        planet.glowWidth = 25  // Much bigger glow
        
        // Add multiple corona layers for stronger effect
        let corona1 = SKShapeNode(circleOfRadius: planetSize * 1.5)
        corona1.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.4)
        corona1.strokeColor = .clear
        corona1.blendMode = .add
        corona1.zPosition = -1
        container.insertChild(corona1, at: 0)
        
        let corona2 = SKShapeNode(circleOfRadius: planetSize * 2.0)
        corona2.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 0.2)
        corona2.strokeColor = .clear
        corona2.blendMode = .add
        corona2.zPosition = -2
        container.insertChild(corona2, at: 0)
        
        // Pulsing star glow animation - MORE DRAMATIC
        let pulseStar = SKAction.sequence([
            SKAction.run { [weak planet, weak corona1, weak corona2] in
                planet?.glowWidth = 35  // Much bigger pulse
                corona1?.alpha = 0.6
                corona2?.alpha = 0.4
                planet?.setScale(1.1)  // Scale up slightly
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak planet, weak corona1, weak corona2] in
                planet?.glowWidth = 20
                corona1?.alpha = 0.3
                corona2?.alpha = 0.2
                planet?.setScale(1.0)  // Scale back down
            },
            SKAction.wait(forDuration: 1.0)
        ])
        container.run(SKAction.repeatForever(pulseStar))
        
        // Add orbiting planets
        let orbitingPlanets = SKNode()
        container.addChild(orbitingPlanets)
        
        // Create 3 visible planets orbiting Proxima B
        let planetColors = [
            SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),  // Blue planet
            SKColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 1.0),  // Brown planet
            SKColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)   // Green planet
        ]
        
        // Larger orbit radii for better visibility
        let orbitRadii: [CGFloat] = [
            planetSize * 2.5,  // Increased from 2.0
            planetSize * 3.5,  // Increased from 2.8
            planetSize * 4.5   // Increased from 3.6
        ]
        
        let orbitSpeeds: [TimeInterval] = [4.0, 7.0, 11.0]
        
        for i in 0..<3 {
            // Create orbit path (more visible)
            let orbitPath = SKShapeNode(circleOfRadius: orbitRadii[i])
            orbitPath.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.3)  // More visible
            orbitPath.lineWidth = 1
            orbitPath.fillColor = .clear
            orbitingPlanets.addChild(orbitPath)
            
            // Create planet - BIGGER for visibility
            let smallPlanet = SKShapeNode(circleOfRadius: planetSize * 0.3)  // Doubled from 0.15
            smallPlanet.fillColor = planetColors[i]
            smallPlanet.strokeColor = planetColors[i].withAlphaComponent(0.8)  // More visible stroke
            smallPlanet.lineWidth = 2  // Thicker line
            smallPlanet.glowWidth = 4  // Bigger glow
            
            // Position planet on orbit
            let startAngle = CGFloat.random(in: 0...(2 * .pi))
            smallPlanet.position = CGPoint(
                x: cos(startAngle) * orbitRadii[i],
                y: sin(startAngle) * orbitRadii[i]
            )
            
            orbitingPlanets.addChild(smallPlanet)
            
            // Create circular orbit animation
            let orbitAction = SKAction.customAction(withDuration: orbitSpeeds[i]) { node, elapsedTime in
                let angle = startAngle + (elapsedTime / orbitSpeeds[i]) * CGFloat.pi * 2
                node.position = CGPoint(
                    x: cos(angle) * orbitRadii[i],
                    y: sin(angle) * orbitRadii[i]
                )
            }
            smallPlanet.run(SKAction.repeatForever(orbitAction))
            
            // Add tiny moon to first planet
            if i == 0 {
                let moon = SKShapeNode(circleOfRadius: planetSize * 0.05)
                moon.fillColor = .lightGray
                moon.strokeColor = .clear
                moon.position = CGPoint(x: planetSize * 0.25, y: 0)
                smallPlanet.addChild(moon)
            }
        }
        
        // Add solar flare effects
        for _ in 0..<3 {
            let flare = SKShapeNode(circleOfRadius: planetSize * 0.1)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = planetSize * CGFloat.random(in: 0.8...1.0)
            flare.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            flare.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.6)
            flare.strokeColor = .clear
            flare.blendMode = .add
            planet.addChild(flare)
            
            // Flare animation
            let flareAnimation = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 1.0, duration: 0),
                SKAction.fadeIn(withDuration: 0),
                SKAction.wait(forDuration: CGFloat.random(in: 2...5))
            ])
            flare.run(SKAction.repeatForever(flareAnimation))
        }
    }
    
    private func addKeplerStationEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Advanced space station with multiple rotating rings and energy effects
        let ring1 = SKShapeNode(circleOfRadius: planetSize + 8)
        ring1.strokeColor = SKColor(red: 0.9, green: 0.4, blue: 1.0, alpha: 0.9)
        ring1.lineWidth = 3
        ring1.fillColor = .clear
        ring1.glowWidth = 6
        container.addChild(ring1)
        
        let ring2 = SKShapeNode(circleOfRadius: planetSize + 15)
        ring2.strokeColor = SKColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 0.7)
        ring2.lineWidth = 2
        ring2.fillColor = .clear
        ring2.glowWidth = 4
        container.addChild(ring2)
        
        let ring3 = SKShapeNode(circleOfRadius: planetSize + 22)
        ring3.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.5)
        ring3.lineWidth = 1
        ring3.fillColor = .clear
        ring3.glowWidth = 2
        container.addChild(ring3)
        
        // Counter-rotating rings for dynamic effect
        let rotate1 = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8)
        let rotate2 = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 12)
        let rotate3 = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        ring1.run(SKAction.repeatForever(rotate1))
        ring2.run(SKAction.repeatForever(rotate2))
        ring3.run(SKAction.repeatForever(rotate3))
        
        // Add energy core pulses
        let coreGlow = SKShapeNode(circleOfRadius: planetSize * 0.6)
        coreGlow.fillColor = SKColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 0.3)
        coreGlow.strokeColor = .clear
        coreGlow.blendMode = .add
        planet.addChild(coreGlow)
        
        // Pulsing energy effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 1.5),
            SKAction.scale(to: 0.8, duration: 1.5)
        ])
        coreGlow.run(SKAction.repeatForever(pulse))
        
        // Add station lights
        for i in 0..<8 {
            let angle = CGFloat.pi * 2 * CGFloat(i) / 8
            let light = SKShapeNode(circleOfRadius: 2)
            light.position = CGPoint(
                x: cos(angle) * planetSize * 0.7,
                y: sin(angle) * planetSize * 0.7
            )
            light.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
            light.strokeColor = .clear
            light.glowWidth = 4
            planet.addChild(light)
            
            // Blinking lights with staggered timing
            let blink = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.fadeIn(withDuration: 0.5)
            ])
            let delay = SKAction.wait(forDuration: Double(i) * 0.2)
            light.run(SKAction.sequence([delay, SKAction.repeatForever(blink)]))
        }
    }
    
    private func addTauCetiEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Teal outpost with energy shields
        let shield = SKShapeNode(circleOfRadius: planetSize + 6)
        shield.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 0.7, alpha: 0.5)
        shield.lineWidth = 3
        shield.fillColor = .clear
        shield.glowWidth = 8
        container.addChild(shield)
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 2),
            SKAction.scale(to: 1.0, duration: 2)
        ])
        shield.run(SKAction.repeatForever(pulse))
    }
    
    private func addIoEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Io - Jupiter's volcanic moon
        
        // Volcanic eruptions
        for _ in 0..<5 {
            let volcano = SKShapeNode(circleOfRadius: planetSize * 0.15)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = planetSize * CGFloat.random(in: 0.3...0.7)
            volcano.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            volcano.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 0.8)
            volcano.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
            volcano.lineWidth = 1
            volcano.glowWidth = 3
            planet.addChild(volcano)
            
            // Lava glow animation
            let glow = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.5...1.5))
            ])
            volcano.run(SKAction.repeatForever(glow))
        }
        
        // Sulfur deposits
        for _ in 0..<8 {
            let sulfur = SKShapeNode(ellipseOf: CGSize(
                width: planetSize * CGFloat.random(in: 0.1...0.3),
                height: planetSize * CGFloat.random(in: 0.1...0.2)
            ))
            sulfur.position = CGPoint(
                x: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6),
                y: CGFloat.random(in: -planetSize * 0.6...planetSize * 0.6)
            )
            sulfur.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.3, alpha: 0.6)
            sulfur.strokeColor = .clear
            sulfur.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            sulfur.blendMode = .add
            planet.addChild(sulfur)
        }
        
        // Volcanic plume effect
        let plume = SKShapeNode(circleOfRadius: planetSize * 1.2)
        plume.fillColor = .clear
        plume.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.2)
        plume.lineWidth = 2
        plume.glowWidth = 8
        plume.blendMode = .add
        container.addChild(plume)
        
        // Animate plume
        let plumeAnimation = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        plume.run(SKAction.repeatForever(plumeAnimation))
    }
    
    private func addMoonEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // Lunar base with craters and domes
        for _ in 0..<4 {
            let crater = SKShapeNode(circleOfRadius: planetSize * CGFloat.random(in: 0.1...0.2))
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = planetSize * CGFloat.random(in: 0.3...0.7)
            crater.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            crater.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
            crater.strokeColor = .clear
            planet.addChild(crater)
        }
        
        // Add lunar domes
        for _ in 0..<2 {
            let dome = SKShapeNode(circleOfRadius: planetSize * 0.15)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = planetSize * 0.5
            dome.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            dome.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 0.7)
            dome.strokeColor = SKColor.cyan
            dome.lineWidth = 1
            planet.addChild(dome)
        }
    }
    
    private func addEarthFinalEffects(to container: SKNode, planetSize: CGFloat, planet: SKShapeNode) {
        // EARTH - THE FINAL STAND - Make it absolutely STUNNING
        
        // Enhanced planet gradient with beautiful blue-green colors
        planet.fillColor = SKColor(red: 0.15, green: 0.4, blue: 0.7, alpha: 1.0)
        
        // Create realistic continents with proper shapes
        let continents = [
            // Africa/Europe
            (position: CGPoint(x: planetSize * 0.2, y: planetSize * 0.1), 
             size: planetSize * 0.4,
             color: SKColor(red: 0.3, green: 0.65, blue: 0.35, alpha: 0.8)),
            // Americas
            (position: CGPoint(x: -planetSize * 0.3, y: 0), 
             size: planetSize * 0.35,
             color: SKColor(red: 0.35, green: 0.7, blue: 0.4, alpha: 0.8)),
            // Asia
            (position: CGPoint(x: planetSize * 0.25, y: planetSize * 0.35), 
             size: planetSize * 0.45,
             color: SKColor(red: 0.32, green: 0.68, blue: 0.38, alpha: 0.8)),
            // Australia
            (position: CGPoint(x: planetSize * 0.15, y: -planetSize * 0.4), 
             size: planetSize * 0.2,
             color: SKColor(red: 0.38, green: 0.72, blue: 0.42, alpha: 0.8))
        ]
        
        for continent in continents {
            let landmass = SKShapeNode(ellipseOf: CGSize(width: continent.size, height: continent.size * 0.7))
            landmass.position = continent.position
            landmass.fillColor = continent.color
            landmass.strokeColor = .clear
            landmass.blendMode = .alpha
            landmass.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            planet.addChild(landmass)
        }
        
        // Add stunning cloud layers
        for i in 0..<3 {
            let cloudLayer = SKShapeNode(circleOfRadius: planetSize * 1.02)
            cloudLayer.fillColor = .clear
            cloudLayer.strokeColor = SKColor.white.withAlphaComponent(0.15 - CGFloat(i) * 0.03)
            cloudLayer.lineWidth = CGFloat(8 - i * 2)
            cloudLayer.blendMode = .add
            container.addChild(cloudLayer)
            
            // Slowly rotating clouds
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double(60 + i * 20))
            cloudLayer.run(SKAction.repeatForever(rotate))
        }
        
        // Beautiful glowing atmosphere with multiple layers
        let atmosphereLayers = [
            (radius: planetSize * 1.25, color: SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.08), glow: 25),
            (radius: planetSize * 1.18, color: SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.12), glow: 20),
            (radius: planetSize * 1.12, color: SKColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 0.15), glow: 15),
            (radius: planetSize * 1.08, color: SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.2), glow: 10)
        ]
        
        for layer in atmosphereLayers {
            let atmosphere = SKShapeNode(circleOfRadius: layer.radius)
            atmosphere.fillColor = layer.color
            atmosphere.strokeColor = SKColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 0.3)
            atmosphere.lineWidth = 2
            atmosphere.glowWidth = CGFloat(layer.glow)
            atmosphere.blendMode = .add
            container.insertChild(atmosphere, at: 0)
        }
        
        // Epic orbital defense grid with animated shields
        for ringNum in 0..<3 {
            let radius = planetSize * (1.4 + CGFloat(ringNum) * 0.15)
            
            // Create hexagonal shield segments
            for i in 0..<12 {
                let angle = CGFloat(i) * CGFloat.pi * 2 / 12
                let shieldSegment = SKShapeNode(circleOfRadius: 8)
                shieldSegment.position = CGPoint(
                    x: cos(angle) * radius,
                    y: sin(angle) * radius
                )
                shieldSegment.fillColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 0.6)
                shieldSegment.strokeColor = SKColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 0.8)
                shieldSegment.lineWidth = 1
                shieldSegment.glowWidth = 5
                container.addChild(shieldSegment)
                
                // Shield pulsing
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.5),
                    SKAction.scale(to: 0.8, duration: 0.5),
                    SKAction.wait(forDuration: Double(i) * 0.1)
                ])
                shieldSegment.run(SKAction.repeatForever(pulse))
            }
            
            // Connecting energy beams
            let defenseRing = SKShapeNode(circleOfRadius: radius)
            defenseRing.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.2)
            defenseRing.lineWidth = 1
            defenseRing.fillColor = .clear
            defenseRing.glowWidth = 3
            container.addChild(defenseRing)
            
            // Rotate defense rings
            let rotateSpeed = Double(8 + ringNum * 2)
            let direction = ringNum % 2 == 0 ? 1.0 : -1.0
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2 * direction, duration: rotateSpeed)
            defenseRing.run(SKAction.repeatForever(rotate))
        }
        
        // Add city lights on the dark side
        for _ in 0..<8 {
            let cityLight = SKShapeNode(circleOfRadius: 1)
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = planetSize * CGFloat.random(in: 0.2...0.7)
            cityLight.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            cityLight.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)
            cityLight.strokeColor = .clear
            cityLight.glowWidth = 2
            cityLight.blendMode = .add
            planet.addChild(cityLight)
            
            // City lights twinkling
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 0.5...1.5))
            ])
            cityLight.run(SKAction.repeatForever(twinkle))
        }
        
        // Epic aurora borealis effect at poles
        for poleY in [planetSize * 0.8, -planetSize * 0.8] {
            let aurora = SKShapeNode(ellipseOf: CGSize(width: planetSize * 0.6, height: planetSize * 0.2))
            aurora.position = CGPoint(x: 0, y: poleY)
            aurora.fillColor = SKColor(red: 0.2, green: 1.0, blue: 0.8, alpha: 0.2)
            aurora.strokeColor = SKColor(red: 0.4, green: 1.0, blue: 0.9, alpha: 0.3)
            aurora.lineWidth = 2
            aurora.glowWidth = 8
            aurora.blendMode = .add
            container.addChild(aurora)
            
            // Aurora dancing animation
            let dance = SKAction.sequence([
                SKAction.scaleX(to: 1.3, y: 0.8, duration: 3),
                SKAction.scaleX(to: 0.7, y: 1.2, duration: 3)
            ])
            aurora.run(SKAction.repeatForever(dance))
        }
        
        // Space station orbiting Earth
        let spaceStation = SKShapeNode(rectOf: CGSize(width: 6, height: 3))
        spaceStation.fillColor = SKColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
        spaceStation.strokeColor = SKColor.white
        spaceStation.lineWidth = 0.5
        spaceStation.position = CGPoint(x: planetSize * 1.3, y: 0)
        container.addChild(spaceStation)
        
        // Station orbit
        let orbitPath = CGMutablePath()
        orbitPath.addEllipse(in: CGRect(x: -planetSize * 1.3, y: -planetSize * 0.8,
                                        width: planetSize * 2.6, height: planetSize * 1.6))
        let orbit = SKAction.follow(orbitPath, asOffset: false, orientToPath: true, duration: 20)
        spaceStation.run(SKAction.repeatForever(orbit))
        
        // Epic "FINAL STAND" holographic display
        if completedMaps.count < 10 {  // Only show if not yet completed
            let holoContainer = SKNode()
            holoContainer.position = CGPoint(x: 0, y: planetSize + 35)
            container.addChild(holoContainer)
            
            // Holographic background
            let holoBack = SKShapeNode(rectOf: CGSize(width: 100, height: 20))
            holoBack.fillColor = SKColor(red: 0, green: 0, blue: 0.2, alpha: 0.4)
            holoBack.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.8)
            holoBack.lineWidth = 1
            holoBack.glowWidth = 5
            holoContainer.addChild(holoBack)
            
            // Main text with epic styling
            let finalLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            finalLabel.text = "EARTH - FINAL STAND"
            finalLabel.fontSize = 10
            finalLabel.fontColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
            finalLabel.verticalAlignmentMode = .center
            holoContainer.addChild(finalLabel)
            
            // Glowing effect behind text
            let glowLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            glowLabel.text = "EARTH - FINAL STAND"
            glowLabel.fontSize = 10
            glowLabel.fontColor = SKColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 0.6)
            glowLabel.verticalAlignmentMode = .center
            glowLabel.zPosition = -1
            glowLabel.xScale = 1.1
            glowLabel.yScale = 1.1
            holoContainer.addChild(glowLabel)
            
            // Epic pulsing animation
            let pulse = SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.1, duration: 0.6),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.6)
                ]),
                SKAction.group([
                    SKAction.scale(to: 0.95, duration: 0.6),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.6)
                ])
            ])
            holoContainer.run(SKAction.repeatForever(pulse))
            
            // Scanning line effect
            let scanLine = SKShapeNode(rectOf: CGSize(width: 100, height: 1))
            scanLine.fillColor = SKColor(red: 0.2, green: 1.0, blue: 1.0, alpha: 0.8)
            scanLine.strokeColor = .clear
            scanLine.position = CGPoint(x: 0, y: -10)
            holoContainer.addChild(scanLine)
            
            let scan = SKAction.sequence([
                SKAction.moveTo(y: 10, duration: 2),
                SKAction.moveTo(y: -10, duration: 0)
            ])
            scanLine.run(SKAction.repeatForever(scan))
        }
        
        // Add dramatic lens flare from the sun
        let sunFlare = SKShapeNode(circleOfRadius: planetSize * 0.3)
        sunFlare.position = CGPoint(x: -planetSize * 0.6, y: planetSize * 0.6)
        sunFlare.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.3)
        sunFlare.strokeColor = .clear
        sunFlare.blendMode = .add
        container.addChild(sunFlare)
    }
    
    // MARK: - Moving Background Objects
    
    private func addMovingBackgroundObjects() {
        // Add same galaxy plasma effects as game screen
        addGalaxyPlasmaEffects()
    }
    
    private func addGalaxyPlasmaEffects() {
        // Use same plasma effect for consistency with game
        createSlowPlasmaBackground()
    }
    
    private func createSlowPlasmaBackground() {
        let plasmaContainer = SKNode()
        plasmaContainer.name = "plasmaBackground"
        plasmaContainer.zPosition = -100  // Behind everything
        addChild(plasmaContainer)
        
        // Create multiple plasma layers
        for i in 0..<3 {
            let plasma = createPlasmaLayer(index: i)
            plasmaContainer.addChild(plasma)
        }
    }
    
    private func createPlasmaLayer(index: Int) -> SKNode {
        let layer = SKNode()
        
        // Create plasma blobs
        let blobCount = 5 + index * 2
        for _ in 0..<blobCount {
            let blob = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...200))
            
            // Set plasma colors
            let colors: [SKColor] = [
                SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.15),  // Purple
                SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.15),  // Cyan
                SKColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 0.15),  // Pink
                SKColor(red: 0.4, green: 1.0, blue: 0.8, alpha: 0.15)   // Turquoise
            ]
            
            blob.fillColor = colors.randomElement()!
            blob.strokeColor = .clear
            blob.blendMode = .add
            blob.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            
            // Add slow movement
            let moveX = CGFloat.random(in: -30...30)
            let moveY = CGFloat.random(in: -30...30)
            let duration = Double.random(in: 20...40)
            
            let moveAction = SKAction.sequence([
                SKAction.moveBy(x: moveX, y: moveY, duration: duration),
                SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            ])
            
            // Add scale pulsing
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: duration * 0.5),
                SKAction.scale(to: 0.8, duration: duration * 0.5)
            ])
            
            // Add rotation
            let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: duration * 2)
            
            blob.run(SKAction.repeatForever(SKAction.group([moveAction, scaleAction, rotateAction])))
            layer.addChild(blob)
        }
        
        // Offset each layer slightly
        layer.alpha = 0.3 - CGFloat(index) * 0.1
        layer.speed = 1.0 - CGFloat(index) * 0.2
        
        return layer
    }
    
    private func createSimplePlasmaBackground() {
        // Create slow-moving plasma blobs
        for _ in 0..<5 {
            let plasma = SKShapeNode(circleOfRadius: CGFloat.random(in: 100...200))
            plasma.fillColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.08)  // Very subtle purple
            plasma.strokeColor = .clear
            plasma.blendMode = .add
            plasma.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            plasma.zPosition = -80  // Far background
            
            addChild(plasma)
            
            // Slow drift
            let moveX = CGFloat.random(in: -20...20)
            let moveY = CGFloat.random(in: -20...20)
            let duration = Double.random(in: 30...50)
            
            let moveAction = SKAction.sequence([
                SKAction.moveBy(x: moveX, y: moveY, duration: duration),
                SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            ])
            
            // Gentle pulsing
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: duration * 0.5),
                SKAction.scale(to: 0.9, duration: duration * 0.5)
            ])
            
            plasma.run(SKAction.repeatForever(SKAction.group([moveAction, scaleAction])))
        }
    }
    
    private func createMinimalSpaceObjects() {
        // Just 2-3 small asteroids drifting slowly
        for _ in 0..<3 {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...8))
            asteroid.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 0.5)
            asteroid.strokeColor = SKColor(red: 0.3, green: 0.2, blue: 0.2, alpha: 0.7)
            asteroid.lineWidth = 1
            
            // Start from edge
            let startX = size.width/2 + 30
            let startY = CGFloat.random(in: -size.height/3...size.height/3)
            asteroid.position = CGPoint(x: startX, y: startY)
            asteroid.zPosition = -60
            
            addChild(asteroid)
            
            // Very slow drift
            let moveAction = SKAction.moveBy(
                x: -(size.width + 60),
                y: CGFloat.random(in: -20...20),
                duration: Double.random(in: 40...60)
            )
            
            // Slow rotation
            let rotateAction = SKAction.rotate(
                byAngle: CGFloat.pi * 2,
                duration: Double.random(in: 10...20)
            )
            
            // Reset when off screen
            let resetAction = SKAction.run {
                asteroid.position = CGPoint(
                    x: self.size.width/2 + 30,
                    y: CGFloat.random(in: -self.size.height/3...self.size.height/3)
                )
            }
            
            let sequence = SKAction.sequence([moveAction, resetAction])
            asteroid.run(SKAction.repeatForever(sequence))
            asteroid.run(SKAction.repeatForever(rotateAction))
        }
        
        // One small comet
        let comet = createSimpleCometSprite()
        comet.position = CGPoint(x: -size.width/2 - 30, y: size.height/4)
        comet.zPosition = -50
        addChild(comet)
        
        // Diagonal movement
        let moveAction = SKAction.move(
            to: CGPoint(x: size.width/2 + 30, y: -size.height/4),
            duration: 25
        )
        let resetAction = SKAction.run {
            comet.position = CGPoint(x: -self.size.width/2 - 30, y: self.size.height/4)
        }
        
        let sequence = SKAction.sequence([moveAction, resetAction])
        comet.run(SKAction.repeatForever(sequence))
    }
    
    private func createSimpleCometSprite() -> SKNode {
        let comet = SKNode()
        
        // Small comet head
        let head = SKShapeNode(circleOfRadius: 3)
        head.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 0.6)
        head.strokeColor = .clear
        head.glowWidth = 2
        comet.addChild(head)
        
        // Simple tail
        for i in 1...3 {
            let tailPart = SKShapeNode(circleOfRadius: CGFloat(3 - i) * 0.7)
            tailPart.fillColor = SKColor(red: 0.5, green: 0.6, blue: 0.8, alpha: 0.3 - CGFloat(i) * 0.08)
            tailPart.strokeColor = .clear
            tailPart.position = CGPoint(x: -CGFloat(i) * 2, y: 0)
            tailPart.blendMode = .add
            comet.addChild(tailPart)
        }
        
        return comet
    }
    
    private func createMinimalMovingObjects() {
        // Only 4 very small objects floating slowly
        
        // 2 tiny asteroids
        for i in 0..<2 {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))  // Very small
            asteroid.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 0.4)
            asteroid.strokeColor = SKColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 0.5)
            asteroid.lineWidth = 0.5
            
            // Start from different edges
            let startX = i == 0 ? size.width/2 + 20 : -size.width/2 - 20
            let startY = CGFloat.random(in: -size.height/4...size.height/4)
            asteroid.position = CGPoint(x: startX, y: startY)
            asteroid.zPosition = -80  // Far behind
            
            addChild(asteroid)
            
            // Very slow movement
            let moveX = i == 0 ? -(size.width + 40) : (size.width + 40)
            let moveAction = SKAction.moveBy(
                x: moveX,
                y: CGFloat.random(in: -10...10),
                duration: Double.random(in: 60...80)  // Much slower
            )
            
            // Slow rotation
            let rotateAction = SKAction.rotate(
                byAngle: CGFloat.pi * 2,
                duration: Double.random(in: 20...30)
            )
            
            // Reset position
            let resetAction = SKAction.run {
                asteroid.position = CGPoint(
                    x: i == 0 ? self.size.width/2 + 20 : -self.size.width/2 - 20,
                    y: CGFloat.random(in: -self.size.height/4...self.size.height/4)
                )
            }
            
            let sequence = SKAction.sequence([moveAction, resetAction])
            asteroid.run(SKAction.repeatForever(sequence))
            asteroid.run(SKAction.repeatForever(rotateAction))
        }
        
        // 1 tiny comet
        let comet = SKNode()
        let cometHead = SKShapeNode(circleOfRadius: 2)  // Very small
        cometHead.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.8, alpha: 0.5)
        cometHead.strokeColor = .clear
        cometHead.glowWidth = 1
        comet.addChild(cometHead)
        
        // Tiny tail
        for i in 1...2 {
            let tailPart = SKShapeNode(circleOfRadius: CGFloat(2 - i) * 0.8)
            tailPart.fillColor = SKColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 0.2)
            tailPart.strokeColor = .clear
            tailPart.position = CGPoint(x: -CGFloat(i) * 1.5, y: 0)
            tailPart.blendMode = .add
            comet.addChild(tailPart)
        }
        
        comet.position = CGPoint(x: -size.width/2 - 20, y: size.height/3)
        comet.zPosition = -75
        addChild(comet)
        
        // Slow diagonal movement
        let moveAction = SKAction.move(
            to: CGPoint(x: size.width/2 + 20, y: -size.height/3),
            duration: 45
        )
        let resetAction = SKAction.run {
            comet.position = CGPoint(x: -self.size.width/2 - 20, y: self.size.height/3)
        }
        
        let sequence = SKAction.sequence([moveAction, resetAction])
        comet.run(SKAction.repeatForever(sequence))
        
        // 1 tiny space debris
        let debris = SKShapeNode(rect: CGRect(x: -2, y: -1, width: 4, height: 2))  // Very small
        debris.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.3)
        debris.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.4)
        debris.lineWidth = 0.5
        
        debris.position = CGPoint(x: size.width/4, y: size.height/2 + 20)
        debris.zPosition = -70
        addChild(debris)
        
        // Tumbling motion
        let tumbleAction = SKAction.sequence([
            SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8),
            SKAction.moveBy(x: -50, y: -100, duration: 8)
        ])
        let resetDebris = SKAction.run {
            debris.position = CGPoint(x: self.size.width/4, y: self.size.height/2 + 20)
        }
        
        let debrisSequence = SKAction.sequence([tumbleAction, resetDebris])
        debris.run(SKAction.repeatForever(debrisSequence))
    }
    
    private func createMovingAsteroids() {
        for _ in 0..<8 {
            let asteroid = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...12))
            asteroid.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 0.8)
            asteroid.strokeColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
            asteroid.lineWidth = 1
            
            // Random starting position off-screen
            let startX = size.width/2 + 50
            let startY = CGFloat.random(in: -size.height/2...size.height/2)
            asteroid.position = CGPoint(x: startX, y: startY)
            asteroid.zPosition = -50  // Behind everything
            
            addChild(asteroid)  // Add to main scene, not scroll container
            
            // Movement across screen
            let moveAction = SKAction.moveBy(
                x: -(size.width + 100),
                y: CGFloat.random(in: -50...50),
                duration: Double.random(in: 15...30)
            )
            
            // Rotation
            let rotateAction = SKAction.rotate(
                byAngle: CGFloat.pi * 2,
                duration: Double.random(in: 3...8)
            )
            
            // Reset position when off-screen
            let resetAction = SKAction.run {
                asteroid.position = CGPoint(
                    x: self.size.width/2 + 50,
                    y: CGFloat.random(in: -self.size.height/2...self.size.height/2)
                )
            }
            
            let sequence = SKAction.sequence([moveAction, resetAction])
            asteroid.run(SKAction.repeatForever(sequence))
            asteroid.run(SKAction.repeatForever(rotateAction))
        }
    }
    
    private func createAlienShips() {
        for _ in 0..<3 {
            let ship = createAlienShipSprite()
            
            // Random starting position
            let startX = CGFloat.random(in: -size.width/2...size.width/2)
            let startY = size.height/2 + 50
            ship.position = CGPoint(x: startX, y: startY)
            ship.zPosition = -45  // Behind planets
            
            addChild(ship)
            
            // Complex flight path
            let path = CGMutablePath()
            path.move(to: ship.position)
            path.addCurve(
                to: CGPoint(x: -startX, y: -size.height/2 - 50),
                control1: CGPoint(x: startX + 100, y: 0),
                control2: CGPoint(x: -startX - 100, y: -100)
            )
            
            let followPath = SKAction.follow(
                path,
                asOffset: false,
                orientToPath: true,
                duration: Double.random(in: 20...35)
            )
            
            let resetAction = SKAction.run {
                ship.position = CGPoint(
                    x: CGFloat.random(in: -self.size.width/2...self.size.width/2),
                    y: self.size.height/2 + 50
                )
            }
            
            let sequence = SKAction.sequence([followPath, resetAction])
            ship.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func createAlienShipSprite() -> SKNode {
        let ship = SKNode()
        
        // Ship body
        let body = SKShapeNode(ellipseOf: CGSize(width: 20, height: 8))
        body.fillColor = SKColor(red: 0.4, green: 0.1, blue: 0.5, alpha: 0.9)
        body.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
        body.lineWidth = 1
        body.glowWidth = 2
        ship.addChild(body)
        
        // Cockpit
        let cockpit = SKShapeNode(circleOfRadius: 3)
        cockpit.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 0.9)
        cockpit.strokeColor = .clear
        cockpit.glowWidth = 3
        cockpit.position = CGPoint(x: 0, y: 0)
        ship.addChild(cockpit)
        
        // Engine glow
        let engine = SKShapeNode(circleOfRadius: 2)
        engine.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.8)
        engine.strokeColor = .clear
        engine.glowWidth = 4
        engine.position = CGPoint(x: -8, y: 0)
        engine.blendMode = .add
        ship.addChild(engine)
        
        // Pulsing engine
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        engine.run(SKAction.repeatForever(pulse))
        
        return ship
    }
    
    private func createSpaceDebris() {
        for _ in 0..<12 {
            let debris = SKShapeNode(rectOf: CGSize(
                width: CGFloat.random(in: 2...6),
                height: CGFloat.random(in: 2...6)
            ))
            debris.fillColor = SKColor(white: 0.4, alpha: 0.6)
            debris.strokeColor = .clear
            
            // Random position
            debris.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            debris.zPosition = -60  // Far background
            
            addChild(debris)
            
            // Slow drift
            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -30...30),
                y: CGFloat.random(in: -30...30),
                duration: Double.random(in: 10...20)
            )
            
            let reverseDrift = drift.reversed()
            let sequence = SKAction.sequence([drift, reverseDrift])
            
            // Tumble
            let tumble = SKAction.rotate(
                byAngle: CGFloat.pi * 2,
                duration: Double.random(in: 5...15)
            )
            
            debris.run(SKAction.repeatForever(sequence))
            debris.run(SKAction.repeatForever(tumble))
        }
    }
    
    private func createComets() {
        for _ in 0..<2 {
            let comet = createCometSprite()
            
            // Start from random edge
            let edge = Int.random(in: 0...3)
            var startPos: CGPoint
            var endPos: CGPoint
            
            switch edge {
            case 0: // Top
                startPos = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2), y: size.height/2 + 50)
                endPos = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2), y: -size.height/2 - 50)
            case 1: // Right
                startPos = CGPoint(x: size.width/2 + 50, y: CGFloat.random(in: -size.height/2...size.height/2))
                endPos = CGPoint(x: -size.width/2 - 50, y: CGFloat.random(in: -size.height/2...size.height/2))
            case 2: // Bottom
                startPos = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2), y: -size.height/2 - 50)
                endPos = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2), y: size.height/2 + 50)
            default: // Left
                startPos = CGPoint(x: -size.width/2 - 50, y: CGFloat.random(in: -size.height/2...size.height/2))
                endPos = CGPoint(x: size.width/2 + 50, y: CGFloat.random(in: -size.height/2...size.height/2))
            }
            
            comet.position = startPos
            comet.zPosition = -40  // In front of far background
            addChild(comet)
            
            // Fast movement
            let moveAction = SKAction.move(to: endPos, duration: Double.random(in: 8...15))
            let resetAction = SKAction.run {
                comet.position = startPos
                // Randomize new end position
                switch edge {
                case 0, 2:
                    endPos.x = CGFloat.random(in: -self.size.width/2...self.size.width/2)
                default:
                    endPos.y = CGFloat.random(in: -self.size.height/2...self.size.height/2)
                }
            }
            
            let sequence = SKAction.sequence([moveAction, resetAction])
            comet.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func createCometSprite() -> SKNode {
        let comet = SKNode()
        
        // Comet head
        let head = SKShapeNode(circleOfRadius: 4)
        head.fillColor = SKColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 0.9)
        head.strokeColor = .white
        head.lineWidth = 1
        head.glowWidth = 3
        comet.addChild(head)
        
        // Comet tail
        for i in 1...5 {
            let tailPart = SKShapeNode(circleOfRadius: CGFloat(4 - i) * 0.6)
            tailPart.fillColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.6 - CGFloat(i) * 0.1)
            tailPart.strokeColor = .clear
            tailPart.position = CGPoint(x: -CGFloat(i) * 3, y: 0)
            tailPart.blendMode = .add
            comet.addChild(tailPart)
        }
        
        return comet
    }
    
    deinit {
        scrollEndTimer?.invalidate()
        scrollEndTimer = nil
    }
}