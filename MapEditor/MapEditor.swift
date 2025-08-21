import Foundation

// ASCII Map Editor for Space Salvagers
// Characters:
// S = Start (enemy spawn)
// E = End (station core)
// # = Path
// + = Path corner/junction
// O = Build node (tower placement)
// . = Empty space
// * = Special build node (power node)
// ~ = Decoration/obstacle

struct MapDefinition {
    let name: String
    let difficulty: Int
    let waves: Int
    let grid: [[Character]]
    let theme: String
    
    func toGameMap() -> GameMapData {
        var pathPoints: [CGPoint] = []
        var buildNodes: [CGPoint] = []
        var specialNodes: [CGPoint] = []
        var startPoint = CGPoint.zero
        var endPoint = CGPoint.zero
        
        let rows = grid.count
        let cols = grid.first?.count ?? 0
        let cellSize: CGFloat = 40 // Size of each grid cell
        
        // Parse the ASCII grid
        for (y, row) in grid.enumerated() {
            for (x, char) in row.enumerated() {
                // Convert grid coordinates to game coordinates
                // Center the map around (0,0)
                let gameX = CGFloat(x - cols/2) * cellSize
                let gameY = CGFloat(rows/2 - y) * cellSize // Flip Y axis
                let point = CGPoint(x: gameX, y: gameY)
                
                switch char {
                case "S":
                    startPoint = point
                    pathPoints.append(point)
                case "E":
                    endPoint = point
                    pathPoints.append(point)
                case "#", "+":
                    pathPoints.append(point)
                case "O":
                    buildNodes.append(point)
                case "*":
                    specialNodes.append(point)
                default:
                    break
                }
            }
        }
        
        // Sort path points to create a continuous path
        let sortedPath = sortPathPoints(pathPoints, start: startPoint, end: endPoint)
        
        return GameMapData(
            name: name,
            difficulty: difficulty,
            waves: waves,
            theme: theme,
            pathPoints: sortedPath,
            buildNodes: buildNodes,
            specialNodes: specialNodes,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    private func sortPathPoints(_ points: [CGPoint], start: CGPoint, end: CGPoint) -> [CGPoint] {
        // Simple path sorting algorithm
        var sorted: [CGPoint] = [start]
        var remaining = points.filter { $0 != start && $0 != end }
        
        while !remaining.isEmpty {
            let current = sorted.last!
            
            // Find nearest point
            var nearestIndex = 0
            var nearestDistance = CGFloat.greatestFiniteMagnitude
            
            for (index, point) in remaining.enumerated() {
                let dist = hypot(point.x - current.x, point.y - current.y)
                if dist < nearestDistance {
                    nearestDistance = dist
                    nearestIndex = index
                }
            }
            
            // Add nearest point to sorted path
            sorted.append(remaining[nearestIndex])
            remaining.remove(at: nearestIndex)
        }
        
        sorted.append(end)
        return sorted
    }
}

struct GameMapData {
    let name: String
    let difficulty: Int
    let waves: Int
    let theme: String
    let pathPoints: [CGPoint]
    let buildNodes: [CGPoint]
    let specialNodes: [CGPoint]
    let startPoint: CGPoint
    let endPoint: CGPoint
}

// Map Editor Class
class ASCIIMapEditor {
    
    // Predefined map templates
    static let maps: [MapDefinition] = [
        
        // Map 1: Simple S-Curve
        MapDefinition(
            name: "Training Station",
            difficulty: 1,
            waves: 3,
            theme: "training",
            grid: [
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "S", "#", "#", "#", "."],
                [".", ".", ".", "O", ".", ".", ".", ".", ".", ".", "#", "#", ".", ".", "#", "."],
                [".", ".", "O", ".", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", "#", "."],
                [".", ".", ".", ".", ".", "O", ".", ".", "#", "#", ".", ".", "O", ".", "#", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", ".", ".", "#", "."],
                [".", ".", ".", "O", ".", ".", "#", "#", ".", ".", ".", ".", ".", ".", "#", "."],
                [".", ".", ".", ".", ".", "#", "#", ".", ".", ".", "O", ".", ".", "#", "#", "."],
                [".", ".", ".", ".", "#", "#", ".", ".", ".", ".", ".", ".", "#", "#", ".", "."],
                [".", ".", ".", "#", "#", ".", ".", ".", "O", ".", ".", "#", "#", ".", ".", "."],
                [".", ".", "#", "#", ".", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", "."],
                [".", "#", "#", ".", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", ".", "."],
                [".", "#", "E", ".", ".", "O", ".", ".", "#", "#", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."]
            ]
        ),
        
        // Map 2: Figure-8
        MapDefinition(
            name: "Industrial Complex",
            difficulty: 2,
            waves: 3,
            theme: "industrial",
            grid: [
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", "#", "#", "#", "#", ".", ".", "#", "#", "#", "#", ".", ".", "."],
                [".", ".", "#", "#", ".", ".", "#", "#", "#", "#", ".", ".", "#", "#", ".", "."],
                [".", "#", "#", ".", ".", "O", ".", "#", "#", ".", "O", ".", ".", "#", "#", "."],
                [".", "#", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", ".", ".", "#", "."],
                ["S", "#", ".", ".", "*", ".", ".", "#", "#", ".", ".", "*", ".", ".", "#", "#"],
                [".", "#", ".", ".", ".", ".", ".", "#", "#", ".", ".", ".", ".", ".", "#", "."],
                [".", "#", "#", ".", ".", "O", ".", "#", "#", ".", "O", ".", ".", "#", "#", "."],
                [".", ".", "#", "#", ".", ".", "#", "#", "#", "#", ".", ".", "#", "#", ".", "."],
                [".", ".", ".", "#", "#", "#", "#", "E", ".", "#", "#", "#", "#", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."]
            ]
        ),
        
        // Map 3: Spiral
        MapDefinition(
            name: "Vortex Station",
            difficulty: 3,
            waves: 4,
            theme: "vortex",
            grid: [
                ["S", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "#", "."],
                [".", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", ".", "#", "."],
                [".", "#", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", "#", "#", "#", "#", "#", "#", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", ".", ".", ".", ".", ".", ".", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", ".", "#", "#", "#", "#", ".", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", ".", "#", "E", ".", "#", ".", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", ".", "#", "#", "#", "#", ".", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", ".", ".", ".", ".", ".", ".", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", "#", "#", "#", "#", "#", "#", "#", "#", ".", "#", ".", "#", "."],
                [".", "#", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "#", ".", "#", "."],
                [".", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#", ".", "#", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "#", "."],
                [".", "O", ".", "O", ".", "O", ".", "O", ".", "O", ".", "O", ".", ".", "#", "."],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."]
            ]
        ),
        
        // Map 4: Cross Assault
        MapDefinition(
            name: "Crossfire Base",
            difficulty: 4,
            waves: 4,
            theme: "military",
            grid: [
                [".", ".", ".", ".", ".", ".", "S", "#", "S", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", "O", ".", ".", ".", ".", "#", ".", ".", ".", ".", "O", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                ["S", "#", "#", "#", "#", "#", "#", "E", "#", "#", "#", "#", "#", "#", "#", "S"],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", "O", ".", ".", ".", ".", "#", ".", ".", ".", ".", "O", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", "S", "#", "S", ".", ".", ".", ".", ".", ".", "."]
            ]
        ),
        
        // Map 5: Maze
        MapDefinition(
            name: "Labyrinth Core",
            difficulty: 5,
            waves: 5,
            theme: "labyrinth",
            grid: [
                ["S", "#", "#", "#", "#", "#", "#", ".", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", ".", ".", ".", ".", ".", "#", ".", "#", "#", "#", "#", "#", "#", "#", "."],
                [".", "#", "#", "#", "#", ".", "#", ".", "#", ".", ".", ".", ".", ".", "#", "."],
                [".", "#", ".", ".", "#", ".", "#", ".", "#", ".", "#", "#", "#", ".", "#", "."],
                [".", "#", ".", ".", "#", ".", "#", ".", "#", ".", "#", "E", "#", ".", "#", "."],
                [".", "#", ".", ".", "#", ".", "#", ".", "#", ".", "#", "#", "#", ".", "#", "."],
                [".", "#", ".", ".", "#", ".", "#", ".", "#", ".", ".", ".", ".", ".", "#", "."],
                [".", "#", "#", "#", "#", ".", "#", ".", "#", "#", "#", "#", "#", "#", "#", "."],
                [".", ".", ".", ".", ".", ".", "#", ".", ".", ".", ".", ".", ".", ".", ".", "."],
                [".", "O", ".", "O", ".", ".", "#", "#", "#", "#", "#", "#", "#", "#", "#", "#"],
                [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."]
            ]
        )
    ]
    
    // Convert ASCII map to game code
    static func generateSwiftCode(for mapIndex: Int) -> String {
        guard mapIndex < maps.count else { return "" }
        
        let map = maps[mapIndex]
        let gameData = map.toGameMap()
        
        var code = """
        private func createMap\(mapIndex + 1)Layout() {
            // Map: \(map.name)
            // Difficulty: \(map.difficulty)
            // Waves: \(map.waves)
            
            // Clear any existing paths
            gameplayLayer.enumerateChildNodes(withName: "enemyPath") { node, _ in
                node.removeFromParent()
            }
            
            // Create path
            let path = CGMutablePath()
        """
        
        // Generate path code
        for (index, point) in gameData.pathPoints.enumerated() {
            if index == 0 {
                code += "\n    path.move(to: CGPoint(x: \(point.x), y: \(point.y)))"
            } else {
                code += "\n    path.addLine(to: CGPoint(x: \(point.x), y: \(point.y)))"
            }
        }
        
        code += """
        
            
            // Create visual path
            let pathNode = SKNode()
            pathNode.name = "enemyPath"
            
            let pathShape = SKShapeNode(path: path)
            pathShape.strokeColor = AssetManager.Colors.neonPurple
            pathShape.lineWidth = 4
            pathShape.glowWidth = 8
            pathShape.fillColor = .clear
            pathShape.alpha = 0.8
            pathNode.addChild(pathShape)
            
            gameplayLayer.addChild(pathNode)
            
            // Create build nodes
            let buildPositions = [
        """
        
        // Add build nodes
        for node in gameData.buildNodes {
            code += "\n        CGPoint(x: \(node.x), y: \(node.y)),"
        }
        
        code += """
        
            ]
            
            for (index, position) in buildPositions.enumerated() {
                let buildNode = createBuildNode(at: position, index: index)
                gameplayLayer.addChild(buildNode)
            }
        """
        
        // Add special nodes if any
        if !gameData.specialNodes.isEmpty {
            code += """
            
            
            // Special power nodes
            let specialNodes = [
            """
            
            for node in gameData.specialNodes {
                code += "\n        CGPoint(x: \(node.x), y: \(node.y)),"
            }
            
            code += """
            
            ]
            
            for position in specialNodes {
                let powerNode = createPowerNode(at: position)
                gameplayLayer.addChild(powerNode)
            }
            """
        }
        
        code += """
        
            
            // Set theme
            setMapVisualTheme(.\(map.theme))
        }
        """
        
        return code
    }
    
    // Visual preview of map
    static func previewMap(_ mapIndex: Int) -> String {
        guard mapIndex < maps.count else { return "Invalid map index" }
        
        let map = maps[mapIndex]
        var preview = """
        =====================================
        Map \(mapIndex + 1): \(map.name)
        Difficulty: \(map.difficulty) | Waves: \(map.waves)
        =====================================
        
        """
        
        for row in map.grid {
            preview += String(row) + "\n"
        }
        
        preview += """
        
        Legend:
        S = Start (Enemy Spawn)
        E = End (Station Core)
        # = Path
        O = Build Node (Tower)
        * = Power Node (Special)
        . = Empty Space
        =====================================
        """
        
        return preview
    }
    
    // Interactive map creator
    static func createCustomMap(width: Int = 16, height: Int = 12) -> [[Character]] {
        var grid = Array(repeating: Array(repeating: Character("."), count: width), count: height)
        return grid
    }
    
    // Save map to file
    static func saveMapToFile(_ map: MapDefinition, filename: String) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        // Convert to JSON-compatible format
        let gridStrings = map.grid.map { String($0) }
        let jsonData = [
            "name": map.name,
            "difficulty": map.difficulty,
            "waves": map.waves,
            "theme": map.theme,
            "grid": gridStrings
        ] as [String : Any]
        
        if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted) {
            let url = URL(fileURLWithPath: filename)
            try? data.write(to: url)
            print("Map saved to: \(filename)")
        }
    }
}

// Helper function to create build nodes
extension ASCIIMapEditor {
    static func createBuildNodeCode() -> String {
        return """
        private func createBuildNode(at position: CGPoint, index: Int) -> SKNode {
            let node = SKShapeNode(circleOfRadius: 25)
            node.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.5)
            node.lineWidth = 2
            node.glowWidth = 2
            node.fillColor = .clear
            node.position = position
            node.name = "buildNode_\\(index)"
            node.zPosition = 100
            return node
        }
        
        private func createPowerNode(at position: CGPoint) -> SKNode {
            let node = SKShapeNode(circleOfRadius: 30)
            node.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)
            node.lineWidth = 3
            node.glowWidth = 5
            node.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.1)
            node.position = position
            node.name = "powerNode"
            node.zPosition = 100
            
            // Add pulsing animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            node.run(SKAction.repeatForever(pulse))
            
            return node
        }
        """
    }
}