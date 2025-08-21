import Foundation
import SpriteKit

// Simple text-based vector map loader
class SimpleVectorMapLoader {
    
    static let shared = SimpleVectorMapLoader()
    private var vectorMaps: [VectorMap] = []
    
    struct VectorPath {
        let points: [CGPoint]
        let curves: [Bool] // true if curve, false if line
    }
    
    struct VectorMap {
        let id: Int
        let name: String
        let difficulty: Int
        let waves: Int
        let color: (r: CGFloat, g: CGFloat, b: CGFloat)
        let glow: CGFloat
        let width: CGFloat
        let paths: [VectorPath]
        let towers: [(position: CGPoint, radius: CGFloat)]
        let spawns: [CGPoint]
        let cores: [CGPoint]
    }
    
    init() {
        print("🎨 SimpleVectorMapLoader initializing...")
        print("🎨 Current bundle: \(Bundle.main)")
        print("🎨 Bundle path: \(Bundle.main.bundlePath)")
        loadVectorMaps()
        print("🎨 SimpleVectorMapLoader initialized with \(vectorMaps.count) maps")
    }
    
    private func loadVectorMaps() {
        print("📂 Loading vector maps from text file...")
        
        // Try to load from bundle first
        if let bundlePath = Bundle.main.path(forResource: "vector_maps", ofType: "txt") {
            print("📦 Found vector_maps.txt in bundle")
            do {
                let content = try String(contentsOfFile: bundlePath, encoding: .utf8)
                parseVectorMaps(content)
                return
            } catch {
                print("❌ Error loading vector maps: \(error)")
            }
        }
        
        // Try development path
        let devPath = FileManager.default.currentDirectoryPath + "/Maps/vector_maps.txt"
        if FileManager.default.fileExists(atPath: devPath) {
            print("🔧 Found vector_maps.txt at development path")
            do {
                let content = try String(contentsOfFile: devPath, encoding: .utf8)
                parseVectorMaps(content)
                return
            } catch {
                print("❌ Error loading development vector maps: \(error)")
            }
        }
        
        print("⚠️ Using hardcoded fallback map")
        createFallbackMap()
    }
    
    private func parseVectorMaps(_ content: String) {
        let lines = content.components(separatedBy: "\n")
        var mapId = 0
        var mapName = ""
        var difficulty = 1
        var waves = 10
        var color = (r: CGFloat(0.0), g: CGFloat(0.8), b: CGFloat(1.0))
        var glow: CGFloat = 12
        var width: CGFloat = 40
        var paths: [VectorPath] = []
        var towers: [(CGPoint, CGFloat)] = []
        var spawns: [CGPoint] = []
        var cores: [CGPoint] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            // Parse map header
            if trimmed.hasPrefix("MAP ") {
                // Save previous map if exists
                if mapId > 0 {
                    let map = VectorMap(
                        id: mapId,
                        name: mapName,
                        difficulty: difficulty,
                        waves: waves,
                        color: color,
                        glow: glow,
                        width: width,
                        paths: paths,
                        towers: towers,
                        spawns: spawns,
                        cores: cores
                    )
                    vectorMaps.append(map)
                }
                
                // Reset for new map
                mapId = Int(trimmed.replacingOccurrences(of: "MAP ", with: "")) ?? 0
                mapName = ""
                difficulty = 1
                waves = 10
                color = (r: CGFloat(0.0), g: CGFloat(0.8), b: CGFloat(1.0))
                glow = 12
                width = 40
                paths = []
                towers = []
                spawns = []
                cores = []
                continue
            }
            
            // Parse properties
            if trimmed.hasPrefix("NAME:") {
                mapName = trimmed.replacingOccurrences(of: "NAME:", with: "").trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("DIFFICULTY:") {
                difficulty = Int(trimmed.replacingOccurrences(of: "DIFFICULTY:", with: "").trimmingCharacters(in: .whitespaces)) ?? 1
            } else if trimmed.hasPrefix("WAVES:") {
                waves = Int(trimmed.replacingOccurrences(of: "WAVES:", with: "").trimmingCharacters(in: .whitespaces)) ?? 10
            } else if trimmed.hasPrefix("COLOR:") {
                let colorStr = trimmed.replacingOccurrences(of: "COLOR:", with: "").trimmingCharacters(in: .whitespaces)
                let parts = colorStr.components(separatedBy: ",")
                if parts.count == 3 {
                    color = (
                        r: CGFloat(Float(parts[0]) ?? 0.0),
                        g: CGFloat(Float(parts[1]) ?? 0.8),
                        b: CGFloat(Float(parts[2]) ?? 1.0)
                    )
                }
            } else if trimmed.hasPrefix("GLOW:") {
                glow = CGFloat(Float(trimmed.replacingOccurrences(of: "GLOW:", with: "").trimmingCharacters(in: .whitespaces)) ?? 12)
            } else if trimmed.hasPrefix("WIDTH:") {
                width = CGFloat(Float(trimmed.replacingOccurrences(of: "WIDTH:", with: "").trimmingCharacters(in: .whitespaces)) ?? 40)
            } else if trimmed.hasPrefix("PATH:") {
                let pathStr = trimmed.replacingOccurrences(of: "PATH:", with: "").trimmingCharacters(in: .whitespaces)
                let vectorPath = parsePath(pathStr)
                paths.append(vectorPath)
            } else if trimmed.hasPrefix("TOWER:") {
                let towerStr = trimmed.replacingOccurrences(of: "TOWER:", with: "").trimmingCharacters(in: .whitespaces)
                let parts = towerStr.components(separatedBy: ",")
                if parts.count == 3 {
                    let x = CGFloat(Float(parts[0]) ?? 0)
                    let y = CGFloat(Float(parts[1]) ?? 0)
                    let radius = CGFloat(Float(parts[2]) ?? 40)
                    towers.append((CGPoint(x: x, y: y), radius))
                }
            } else if trimmed.hasPrefix("SPAWN:") {
                let spawnStr = trimmed.replacingOccurrences(of: "SPAWN:", with: "").trimmingCharacters(in: .whitespaces)
                let parts = spawnStr.components(separatedBy: ",")
                if parts.count == 2 {
                    let spawn = CGPoint(
                        x: CGFloat(Float(parts[0]) ?? 0),
                        y: CGFloat(Float(parts[1]) ?? 0)
                    )
                    spawns.append(spawn)
                }
            } else if trimmed.hasPrefix("CORE:") {
                let coreStr = trimmed.replacingOccurrences(of: "CORE:", with: "").trimmingCharacters(in: .whitespaces)
                let parts = coreStr.components(separatedBy: ",")
                if parts.count == 2 {
                    let core = CGPoint(
                        x: CGFloat(Float(parts[0]) ?? 0),
                        y: CGFloat(Float(parts[1]) ?? 0)
                    )
                    cores.append(core)
                }
            }
        }
        
        // Save last map
        if mapId > 0 {
            let map = VectorMap(
                id: mapId,
                name: mapName,
                difficulty: difficulty,
                waves: waves,
                color: color,
                glow: glow,
                width: width,
                paths: paths,
                towers: towers,
                spawns: spawns,
                cores: cores
            )
            vectorMaps.append(map)
        }
        
        print("✅ Loaded \(vectorMaps.count) vector maps")
    }
    
    private func parsePath(_ str: String) -> VectorPath {
        var points: [CGPoint] = []
        var curves: [Bool] = []
        
        // Split by both > (line) and ~ (curve) while preserving which separator was used
        let segments = str.components(separatedBy: CharacterSet(charactersIn: ">~"))
        let separators = extractSeparators(from: str)
        
        for (index, segment) in segments.enumerated() {
            let trimmed = segment.trimmingCharacters(in: .whitespaces)
            let parts = trimmed.components(separatedBy: ",")
            if parts.count == 2 {
                let x = CGFloat(Float(parts[0]) ?? 0)
                let y = CGFloat(Float(parts[1]) ?? 0)
                points.append(CGPoint(x: x, y: y))
                
                // Determine if this segment should be a curve (only for connections after first point)
                if index > 0 && index - 1 < separators.count {
                    curves.append(separators[index - 1] == "~")
                }
            }
        }
        
        return VectorPath(points: points, curves: curves)
    }
    
    private func extractSeparators(from str: String) -> [String] {
        var separators: [String] = []
        
        for char in str {
            if char == ">" {
                separators.append(">")
            } else if char == "~" {
                separators.append("~")
            }
        }
        
        return separators
    }
    
    private func createFallbackMap() {
        // Hardcoded fallback map
        let fallback = VectorMap(
            id: 1,
            name: "Fallback Map",
            difficulty: 1,
            waves: 10,
            color: (r: CGFloat(0.0), g: CGFloat(0.8), b: CGFloat(1.0)),
            glow: 12,
            width: 40,
            paths: [
                VectorPath(
                    points: [
                        CGPoint(x: -350, y: -150),
                        CGPoint(x: 0, y: 0),
                        CGPoint(x: 350, y: 150)
                    ],
                    curves: [false, false] // All straight lines
                )
            ],
            towers: [
                (CGPoint(x: -150, y: -50), 40),
                (CGPoint(x: 150, y: 50), 40)
            ],
            spawns: [CGPoint(x: -350, y: -150)],
            cores: [CGPoint(x: 350, y: 150)]
        )
        vectorMaps.append(fallback)
    }
    
    func createVectorMapNodes(mapNumber: Int, in parent: SKNode) -> Bool {
        print("🎨 Creating vector map \(mapNumber) in parent: \(parent)")
        print("🎨 Parent node children count: \(parent.children.count)")
        
        guard mapNumber > 0 && mapNumber <= vectorMaps.count else {
            print("❌ Map \(mapNumber) not found")
            return false
        }
        
        let map = vectorMaps[mapNumber - 1]
        print("✅ Loading map: \(map.name)")
        
        // Create the cool neon paths with round borders
        for (index, path) in map.paths.enumerated() {
            createNeonPath(path: path, map: map, pathIndex: index, in: parent, mapNumber: mapNumber)
        }
        
        // Create tower zones with cool hexagonal design
        print("🏰 Creating \(map.towers.count) tower zones...")
        
        
        for tower in map.towers {
            print("🏰 Processing tower at: \(tower.position)")
            createCoolTowerZone(at: tower.position, radius: tower.radius, in: parent)
        }
        
        // Create spawn portals
        for (index, spawn) in map.spawns.enumerated() {
            createCoolSpawnPoint(at: spawn, index: index, in: parent)
        }
        
        // Create station cores
        for (index, core) in map.cores.enumerated() {
            createCoolStationCore(at: core, index: index, in: parent)
        }
        
        return true
    }
    
    private func createNeonPath(path: VectorPath, map: VectorMap, pathIndex: Int, in parent: SKNode, mapNumber: Int = 0) {
        guard path.points.count > 1 else { return }
        
        // Create smooth bezier path with rounded corners and curves
        let smoothPath = createSmoothPath(from: path.points, curves: path.curves)
        
        // Create two neon edge lines with nice rounded borders
        let _ = createOffsetPath(from: smoothPath, offset: map.width/2)
        let _ = createOffsetPath(from: smoothPath, offset: -map.width/2)
        
        // Original style road rendering with outer border, inner clear, and glow
        
        // Outer border (creates the road width visual)
        let outerBorder = SKShapeNode(path: smoothPath)
        
        // Special handling for Earth map - more transparent to show planet
        if mapNumber == 10 {
            outerBorder.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.5) // Transparent purple
            outerBorder.blendMode = .add  // Additive blending for glow effect
        } else {
            outerBorder.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 0.9) // Normal purple
        }
        
        outerBorder.lineWidth = 44 // Slightly wider for border effect
        outerBorder.lineCap = .round
        outerBorder.fillColor = .clear
        outerBorder.zPosition = 2  // Bottom layer
        parent.addChild(outerBorder)
        
        // Inner clear space - REMOVED: This was blocking planet backgrounds
        // The hollow road effect is achieved with just the outer border
        
        // Glowing border lines like original with pulsing effect
        let glow = SKShapeNode(path: smoothPath)
        glow.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 1.0, alpha: 0.6) // Bright purple
        glow.lineWidth = 42
        glow.lineCap = .round
        glow.fillColor = .clear
        glow.glowWidth = 8
        glow.zPosition = 1.5  // Below main track
        
        // Add funky pulsing glow effect
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.2),
            SKAction.fadeAlpha(to: 0.8, duration: 1.2)
        ])
        glow.run(SKAction.repeatForever(glowPulse))
        
        // Add slight glow width pulsing too
        let glowWidthPulse = SKAction.sequence([
            SKAction.customAction(withDuration: 1.2) { node, elapsedTime in
                if let shapeNode = node as? SKShapeNode {
                    let normalizedTime = elapsedTime / 1.2
                    let glowWidth = 6 + sin(normalizedTime * .pi) * 4
                    shapeNode.glowWidth = glowWidth
                }
            },
            SKAction.customAction(withDuration: 1.2) { node, elapsedTime in
                if let shapeNode = node as? SKShapeNode {
                    let normalizedTime = elapsedTime / 1.2
                    let glowWidth = 10 - sin(normalizedTime * .pi) * 4
                    shapeNode.glowWidth = glowWidth
                }
            }
        ])
        glow.run(SKAction.repeatForever(glowWidthPulse))
        
        parent.addChild(glow)
        
        // Create cool plasma wave effect running through the path
        createPlasmaWaveEffect(path: smoothPath, pathIndex: pathIndex, in: parent, mapNumber: mapNumber)
        
        // Invisible center path for enemy movement
        let enemyPath = SKShapeNode(path: smoothPath)
        enemyPath.strokeColor = .clear
        enemyPath.name = "enemyPath_\(pathIndex)"
        enemyPath.zPosition = 0
        parent.addChild(enemyPath)
    }
    
    private func createSmoothPath(from points: [CGPoint], curves: [Bool] = []) -> CGPath {
        let path = CGMutablePath()
        
        if points.count < 2 { return path }
        
        path.move(to: points[0])
        
        for i in 0..<points.count - 1 {
            let current = points[i]
            let next = points[i + 1]
            let shouldCurve = i < curves.count ? curves[i] : false
            
            // CRITICAL FIX: Detect 90-degree bends and handle them properly
            let is90DegreeBend = detect90DegreeBend(at: i, in: points)
            
            if shouldCurve && !is90DegreeBend && i > 0 && i < points.count - 2 {
                // Create smooth curve using control point (only for gentle curves)
                let prev = points[i - 1]
                let nextNext = points[i + 2]
                
                // Calculate control point for smooth curve
                let cp1 = CGPoint(
                    x: current.x + (next.x - prev.x) * 0.2,
                    y: current.y + (next.y - prev.y) * 0.2
                )
                let cp2 = CGPoint(
                    x: next.x - (nextNext.x - current.x) * 0.2,
                    y: next.y - (nextNext.y - current.y) * 0.2
                )
                path.addCurve(to: next, control1: cp1, control2: cp2)
            } else if is90DegreeBend {
                // FIXED: Handle 90-degree bends with slight rounding to match original hardcoded style
                path.addLine(to: CGPoint(
                    x: current.x + (next.x - current.x) * 0.9,
                    y: current.y + (next.y - current.y) * 0.9
                ))
                path.addLine(to: next)
            } else {
                // Straight line - original hardcoded behavior
                path.addLine(to: next)
            }
        }
        
        return path
    }
    
    private func createPlasmaWaveEffect(path: CGPath, pathIndex: Int, in parent: SKNode, mapNumber: Int = 0) {
        // Create dark track center with visible borders
        let blackTrack = SKShapeNode(path: path)
        
        // Special handling for Earth map (map 10) - make track transparent to show Earth
        if mapNumber == 10 {
            // For Earth map, use very transparent black to allow planet to show through
            blackTrack.strokeColor = SKColor.black.withAlphaComponent(0.3)
            blackTrack.blendMode = .multiply
        } else {
            // Normal maps get solid black track with visible borders
            blackTrack.strokeColor = SKColor.black.withAlphaComponent(0.85)
        }
        
        blackTrack.lineWidth = 38  // Narrower than outer border to show purple edges
        blackTrack.lineCap = .round
        blackTrack.fillColor = .clear
        blackTrack.glowWidth = 0
        blackTrack.zPosition = 3  // Above borders
        blackTrack.name = "blackTrack_\(pathIndex)"
        parent.addChild(blackTrack)
        
        // Create thin neon border lines (two thin lines on the edges)
        // Left edge line
        let leftBorder = SKShapeNode(path: path)
        leftBorder.strokeColor = SKColor(red: 0.1, green: 0.8, blue: 1.0, alpha: 0.5)
        leftBorder.lineWidth = 2  // Very thin
        leftBorder.lineCap = .round
        leftBorder.fillColor = .clear
        leftBorder.glowWidth = 4  // Small glow
        leftBorder.zPosition = 4  // Above black track for edge visibility
        leftBorder.name = "leftBorder_\(pathIndex)"
        parent.addChild(leftBorder)
        
        // For visual separation, we'll rely on the path width setting
        // The black track creates the dark middle, borders show the edges
        
        // Create flowing energy particles along the entire path
        createFlowingParticles(path: path, pathIndex: pathIndex, in: parent)
        
        // Add plasma crackling effects at random intervals
        createPlasmaArcs(path: path, pathIndex: pathIndex, in: parent)
    }
    
    private func createFlowingParticles(path: CGPath, pathIndex: Int, in parent: SKNode) {
        // Create many small energy particles that flow along the entire track
        let particleCount = 25
        
        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 3)  // Slightly bigger
            particle.strokeColor = .clear
            particle.fillColor = SKColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 0.3)  // More visible on black
            particle.glowWidth = 2  // Small glow
            particle.zPosition = 5  // Above everything for particle visibility
            particle.name = "plasmaParticle_\(pathIndex)_\(i)"
            
            // Individual particle pulsing
            let particlePulse = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.4),
                SKAction.scale(to: 0.8, duration: 0.6)
            ])
            particle.run(SKAction.repeatForever(particlePulse))
            
            parent.addChild(particle)
            
            // Each particle follows the path with different timing and speed
            let duration = TimeInterval(6.0 + Double(i) * 0.3)
            let delay = Double(i) * 0.2
            
            let followAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: duration)
            let particleSequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                followAction
            ])
            
            particle.run(SKAction.repeatForever(particleSequence))
        }
    }
    
    private func createPlasmaArcs(path: CGPath, pathIndex: Int, in parent: SKNode) {
        // Create crackling plasma arcs that appear randomly along the track
        let arcCount = 8
        
        // Get path points for positioning arcs
        var pathPoints: [CGPoint] = []
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                pathPoints.append(element.pointee.points[0])
            case .addQuadCurveToPoint:
                pathPoints.append(element.pointee.points[1]) // End point
            case .addCurveToPoint:
                pathPoints.append(element.pointee.points[2]) // End point
            default:
                break
            }
        }
        
        guard pathPoints.count > 1 else { return }
        
        for i in 0..<arcCount {
            // Position arcs along the path
            let pointIndex = (i * pathPoints.count) / arcCount
            let basePosition = pathPoints[min(pointIndex, pathPoints.count - 1)]
            
            let arc = SKShapeNode()
            let arcPath = CGMutablePath()
            
            // Create small crackling arc
            let startPoint = CGPoint(x: basePosition.x - 8, y: basePosition.y - 4)
            let endPoint = CGPoint(x: basePosition.x + 8, y: basePosition.y + 4)
            let controlPoint = CGPoint(x: basePosition.x + CGFloat.random(in: -6...6), 
                                     y: basePosition.y + CGFloat.random(in: -10...10))
            
            arcPath.move(to: startPoint)
            arcPath.addQuadCurve(to: endPoint, control: controlPoint)
            
            arc.path = arcPath
            arc.strokeColor = SKColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.3)
            arc.lineWidth = 1
            arc.lineCap = .round
            arc.fillColor = .clear
            arc.glowWidth = 0
            arc.zPosition = 4.5  // Above track for arc visibility
            arc.name = "plasmaArc_\(pathIndex)_\(i)"
            
            // Crackling animation - appear and disappear randomly
            let crackle = SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval.random(in: 0.5...2.0)),
                SKAction.fadeIn(withDuration: 0.1),
                SKAction.wait(forDuration: TimeInterval.random(in: 0.1...0.3)),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.wait(forDuration: TimeInterval.random(in: 1.0...4.0))
            ])
            
            arc.run(SKAction.repeatForever(crackle))
            parent.addChild(arc)
        }
    }
    
    // CRITICAL FIX: Detect 90-degree bends to render them like original hardcoded style
    private func detect90DegreeBend(at index: Int, in points: [CGPoint]) -> Bool {
        guard index > 0 && index < points.count - 1 else { return false }
        
        let prev = points[index - 1]
        let current = points[index]
        let next = points[index + 1]
        
        // Calculate vectors
        let vector1 = CGPoint(x: current.x - prev.x, y: current.y - prev.y)
        let vector2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
        
        // Calculate dot product to determine angle
        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
        
        guard magnitude1 > 0 && magnitude2 > 0 else { return false }
        
        let cosAngle = dotProduct / (magnitude1 * magnitude2)
        let angle = acos(max(-1, min(1, cosAngle))) // Clamp to avoid floating point errors
        let degrees = angle * 180 / .pi
        
        // Consider it a 90-degree bend if angle is between 75-105 degrees (allowing for some tolerance)
        return degrees >= 75 && degrees <= 105
    }
    
    private func createOffsetPath(from originalPath: CGPath, offset: CGFloat) -> CGPath {
        // Simple offset - just add offset to Y coordinate for cleaner 90-degree corners
        let offsetPath = CGMutablePath()
        
        originalPath.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint:
                let point = element.pointee.points[0]
                offsetPath.move(to: CGPoint(x: point.x, y: point.y + offset))
            case .addLineToPoint:
                let point = element.pointee.points[0]
                offsetPath.addLine(to: CGPoint(x: point.x, y: point.y + offset))
            case .addQuadCurveToPoint:
                let points = element.pointee.points
                let control = CGPoint(x: points[0].x, y: points[0].y + offset)
                let end = CGPoint(x: points[1].x, y: points[1].y + offset)
                offsetPath.addQuadCurve(to: end, control: control)
            case .addCurveToPoint:
                let points = element.pointee.points
                let control1 = CGPoint(x: points[0].x, y: points[0].y + offset)
                let control2 = CGPoint(x: points[1].x, y: points[1].y + offset)
                let end = CGPoint(x: points[2].x, y: points[2].y + offset)
                offsetPath.addCurve(to: end, control1: control1, control2: control2)
            default:
                break
            }
        }
        
        return offsetPath
    }
    
    private func createCoolTowerZone(at position: CGPoint, radius: CGFloat, in parent: SKNode) {
        print("🏗️ Creating tower zone at position: \(position) with radius: \(radius)")
        
        
        // Create cool hexagonal tower zone with rounded corners - FIXED FOR VISIBILITY
        let _ = createRoundedHexagonPath(radius: radius)
        
        // Simple circle buildNode like original system
        let buildNode = SKShapeNode(circleOfRadius: 20)
        buildNode.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.8)
        buildNode.lineWidth = 3
        buildNode.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.4)
        buildNode.position = position
        buildNode.zPosition = 100
        buildNode.name = "buildNode"
        buildNode.isUserInteractionEnabled = false
        
        // Inner circle like original
        let innerCircle = SKShapeNode(circleOfRadius: 15)
        innerCircle.strokeColor = SKColor.cyan
        innerCircle.lineWidth = 1
        innerCircle.fillColor = .clear
        innerCircle.name = "buildNode"
        buildNode.addChild(innerCircle)
        
        buildNode.userData = NSMutableDictionary()
        buildNode.userData?["isOccupied"] = false
        
        parent.addChild(buildNode)
    }
    
    private func createRoundedHexagonPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let angleStep = CGFloat.pi * 2 / 6
        let cornerRadius: CGFloat = radius * 0.15  // Rounded corners
        
        var points: [CGPoint] = []
        for i in 0..<6 {
            let angle = angleStep * CGFloat(i) - CGFloat.pi / 2
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            points.append(CGPoint(x: x, y: y))
        }
        
        // Create path with rounded corners
        for i in 0..<6 {
            let current = points[i]
            let next = points[(i + 1) % 6]
            let prev = points[(i + 5) % 6]
            
            // Calculate corner points
            let toPrev = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let toNext = CGPoint(x: next.x - current.x, y: next.y - current.y)
            let toPrevLength = sqrt(toPrev.x * toPrev.x + toPrev.y * toPrev.y)
            let toNextLength = sqrt(toNext.x * toNext.x + toNext.y * toNext.y)
            
            let cornerStart = CGPoint(
                x: current.x + (toPrev.x / toPrevLength) * cornerRadius,
                y: current.y + (toPrev.y / toPrevLength) * cornerRadius
            )
            let cornerEnd = CGPoint(
                x: current.x + (toNext.x / toNextLength) * cornerRadius,
                y: current.y + (toNext.y / toNextLength) * cornerRadius
            )
            
            if i == 0 {
                path.move(to: cornerEnd)
            } else {
                path.addLine(to: cornerStart)
                path.addQuadCurve(to: cornerEnd, control: current)
            }
        }
        path.closeSubpath()
        
        return path
    }
    
    private func createCoolSpawnPoint(at position: CGPoint, index: Int, in parent: SKNode) {
        // Cool portal effect with rounded design
        let portal = SKShapeNode(circleOfRadius: 30)
        portal.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)
        portal.lineWidth = 2
        portal.fillColor = SKColor(red: 0.0, green: 0.3, blue: 0.2, alpha: 0.3)
        // No excessive glow
        portal.position = position
        portal.zPosition = 120
        
        // Inner swirl
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: CGFloat(20 - i * 5))
            ring.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 0.7, alpha: CGFloat(0.8 - Float(i) * 0.2))
            ring.lineWidth = 1
            ring.fillColor = .clear
            // Clean rings
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double(2 + i))
            ring.run(SKAction.repeatForever(rotate))
            portal.addChild(ring)
        }
        
        // Center glow
        let center = SKShapeNode(circleOfRadius: 5)
        center.fillColor = SKColor(red: 0.5, green: 1.0, blue: 0.8, alpha: 1.0)
        center.strokeColor = .clear
        // Clean center
        portal.addChild(center)
        
        // Label with spawn index
        let label = SKLabelNode(text: index == 0 ? "S" : "S\(index+1)")
        label.fontSize = 18
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        portal.addChild(label)
        
        parent.addChild(portal)
    }
    
    private func createCoolStationCore(at position: CGPoint, index: Int, in parent: SKNode) {
        // Cool energy core with rounded design
        let core = SKShapeNode(circleOfRadius: 35)
        core.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        core.lineWidth = 3
        core.fillColor = SKColor(red: 0.3, green: 0.05, blue: 0.05, alpha: 0.3)
        // Clean core
        core.position = position
        core.zPosition = 120
        core.name = "stationCore"
        
        // Energy rings
        for i in 0..<2 {
            let ring = SKShapeNode(circleOfRadius: CGFloat(25 - i * 10))
            ring.strokeColor = SKColor(red: 1.0, green: CGFloat(0.3 + Float(i) * 0.2), blue: 0.3, alpha: 0.8)
            ring.lineWidth = 2
            ring.fillColor = .clear
            // Clean ring
            
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * CGFloat(2 - i * 2), duration: Double(3 + i))
            ring.run(SKAction.repeatForever(rotate))
            core.addChild(ring)
        }
        
        // Core center
        let center = SKShapeNode(circleOfRadius: 10)
        center.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        center.strokeColor = .clear
        // Clean core center
        core.addChild(center)
        
        // Lightning symbol
        let symbol = SKLabelNode(text: "⚡")
        symbol.fontSize = 20
        symbol.verticalAlignmentMode = .center
        core.addChild(symbol)
        
        // Pulse
        let scaleUp = SKAction.scale(to: 1.15, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.9, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        core.run(SKAction.repeatForever(pulse))
        
        parent.addChild(core)
    }
    
    // Get path for enemy movement (returns first path)
    func getVectorPath(mapNumber: Int) -> CGPath? {
        guard mapNumber > 0 && mapNumber <= vectorMaps.count else {
            return nil
        }
        
        let map = vectorMaps[mapNumber - 1]
        guard !map.paths.isEmpty else { return nil }
        
        let firstPath = map.paths[0]
        return createSmoothPath(from: firstPath.points, curves: firstPath.curves)
    }
    
    // Get all paths for complex enemy routing
    func getAllVectorPaths(mapNumber: Int) -> [CGPath] {
        guard mapNumber > 0 && mapNumber <= vectorMaps.count else {
            return []
        }
        
        let map = vectorMaps[mapNumber - 1]
        return map.paths.map { path in
            createSmoothPath(from: path.points, curves: path.curves)
        }
    }
    
    // Get spawn points for enemy spawning
    func getSpawnPoints(mapNumber: Int) -> [CGPoint] {
        guard mapNumber > 0 && mapNumber <= vectorMaps.count else {
            return []
        }
        
        let map = vectorMaps[mapNumber - 1]
        return map.spawns
    }
}