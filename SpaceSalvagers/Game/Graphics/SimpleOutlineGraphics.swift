import SpriteKit

// Simplified outline graphics that can be used immediately without additional dependencies
class SimpleOutlineGraphics {
    
    static let shared = SimpleOutlineGraphics()
    
    struct Colors {
        static let neonPurple = SKColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0)
        static let neonCyan = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0)
        static let neonPink = SKColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0)
        static let neonGreen = SKColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 1.0)
        static let neonYellow = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        static let neonOrange = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    }
    
    // Create an improved path with purple neon outline
    func createNeonPath() -> SKNode {
        let path = SKNode()
        
        // Main path with purple outline as requested
        let pathShape = CGMutablePath()
        pathShape.move(to: CGPoint(x: 400, y: 0))
        pathShape.addCurve(to: CGPoint(x: 0, y: 150),
                          control1: CGPoint(x: 250, y: 0),
                          control2: CGPoint(x: 150, y: 150))
        pathShape.addCurve(to: CGPoint(x: -200, y: 0),
                          control1: CGPoint(x: -100, y: 150),
                          control2: CGPoint(x: -200, y: 100))
        pathShape.addCurve(to: CGPoint(x: 0, y: -150),
                          control1: CGPoint(x: -200, y: -100),
                          control2: CGPoint(x: -100, y: -150))
        pathShape.addCurve(to: CGPoint(x: 0, y: 0),
                          control1: CGPoint(x: 100, y: -150),
                          control2: CGPoint(x: 50, y: -75))
        
        // Purple outline for the path
        let outline = SKShapeNode(path: pathShape)
        outline.strokeColor = Colors.neonPurple
        outline.lineWidth = 4
        outline.glowWidth = 8
        outline.fillColor = .clear
        outline.alpha = 0.8
        path.addChild(outline)
        
        // Inner glow line
        let innerGlow = SKShapeNode(path: pathShape)
        innerGlow.strokeColor = Colors.neonPink
        innerGlow.lineWidth = 2
        innerGlow.glowWidth = 4
        innerGlow.fillColor = .clear
        innerGlow.alpha = 0.5
        path.addChild(innerGlow)
        
        // Add grid dots along the path
        for t in stride(from: 0.0, to: 1.0, by: 0.05) {
            let point = getPointOnPath(t: t)
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = Colors.neonPurple
            dot.strokeColor = .clear
            dot.position = point
            dot.glowWidth = 2
            dot.alpha = 0.6
            path.addChild(dot)
        }
        
        return path
    }
    
    // Create improved build nodes with outline style
    func createBuildNode(at position: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = position
        
        // Hexagonal outline base
        let hex = createHexagon(radius: 25)
        hex.strokeColor = Colors.neonCyan
        hex.lineWidth = 2
        hex.glowWidth = 4
        hex.fillColor = SKColor.black.withAlphaComponent(0.3)
        hex.alpha = 0.8
        node.addChild(hex)
        
        // Inner detail
        let innerHex = createHexagon(radius: 15)
        innerHex.strokeColor = Colors.neonCyan
        innerHex.lineWidth = 1
        innerHex.fillColor = .clear
        innerHex.alpha = 0.5
        node.addChild(innerHex)
        
        // Center dot
        let center = SKShapeNode(circleOfRadius: 3)
        center.fillColor = Colors.neonCyan
        center.strokeColor = .clear
        center.glowWidth = 4
        node.addChild(center)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        node.run(SKAction.repeatForever(pulse))
        
        return node
    }
    
    // Create improved tower with outline graphics
    func createOutlineTower(type: String) -> SKNode {
        let tower = SKNode()
        
        // Base with outline
        let base = createHexagon(radius: 20)
        base.strokeColor = getTowerColor(type: type)
        base.lineWidth = 2
        base.fillColor = SKColor.black.withAlphaComponent(0.5)
        base.glowWidth = 3
        tower.addChild(base)
        
        // Tower specific designs
        switch type {
        case "laser":
            // Laser cannon with clean lines
            let barrel = SKShapeNode(rect: CGRect(x: -3, y: 0, width: 6, height: 25))
            barrel.strokeColor = Colors.neonCyan
            barrel.lineWidth = 2
            barrel.fillColor = .clear
            barrel.glowWidth = 4
            barrel.name = "turret"
            tower.addChild(barrel)
            
            // Focusing rings
            for i in 1...3 {
                let ring = SKShapeNode(circleOfRadius: CGFloat(i * 4))
                ring.strokeColor = Colors.neonCyan.withAlphaComponent(0.3)
                ring.lineWidth = 1
                ring.position = CGPoint(x: 0, y: 20)
                tower.addChild(ring)
            }
            
        case "plasma":
            // Plasma orb with energy field
            let orb = SKShapeNode(circleOfRadius: 12)
            orb.strokeColor = Colors.neonPurple
            orb.lineWidth = 2
            orb.fillColor = Colors.neonPurple.withAlphaComponent(0.2)
            orb.glowWidth = 8
            orb.name = "turret"
            tower.addChild(orb)
            
            // Energy arcs
            for angle in stride(from: 0, to: 360, by: 60) {
                let arc = createEnergyArc(angle: angle)
                orb.addChild(arc)
            }
            
        case "missile":
            // Missile pods with clean design
            for angle in stride(from: 0, to: 360, by: 120) {
                let pod = SKShapeNode(rect: CGRect(x: -4, y: 5, width: 8, height: 15))
                pod.strokeColor = Colors.neonOrange
                pod.lineWidth = 2
                pod.fillColor = .clear
                pod.position = CGPoint(
                    x: cos(angle * .pi / 180) * 10,
                    y: sin(angle * .pi / 180) * 10
                )
                pod.zRotation = angle * .pi / 180
                pod.name = "turret"
                tower.addChild(pod)
            }
            
        default:
            // Generic tower
            let turret = SKShapeNode(circleOfRadius: 10)
            turret.strokeColor = .white
            turret.lineWidth = 2
            turret.fillColor = .clear
            turret.name = "turret"
            tower.addChild(turret)
        }
        
        return tower
    }
    
    // Create improved enemy with outline style
    func createOutlineEnemy(type: String) -> SKNode {
        let enemy = SKNode()
        
        let body: SKShapeNode
        let color: SKColor
        
        switch type {
        case "scout":
            // Triangle shape for fast enemies
            body = createTriangle(size: 12)
            color = Colors.neonPink
            
        case "fighter":
            // Diamond shape
            body = createDiamond(size: 15)
            color = Colors.neonOrange
            
        case "bomber":
            // Circle with spikes
            body = createSpikedCircle(radius: 12)
            color = Colors.neonPurple
            
        default:
            body = SKShapeNode(circleOfRadius: 10)
            color = SKColor.red
        }
        
        body.strokeColor = color
        body.lineWidth = 2
        body.fillColor = .clear
        body.glowWidth = 4
        enemy.addChild(body)
        
        // Add energy trail
        let trail = SKShapeNode(circleOfRadius: 4)
        trail.fillColor = color.withAlphaComponent(0.5)
        trail.strokeColor = .clear
        trail.position = CGPoint(x: -10, y: 0)
        trail.glowWidth = 6
        enemy.addChild(trail)
        
        // Pulse effect
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        body.run(SKAction.repeatForever(pulse))
        
        return enemy
    }
    
    // Helper functions
    private func createHexagon(radius: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return SKShapeNode(path: path)
    }
    
    private func createTriangle(size: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: -size * 0.866, y: -size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.866, y: -size * 0.5))
        path.closeSubpath()
        return SKShapeNode(path: path)
    }
    
    private func createDiamond(size: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: size, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size))
        path.addLine(to: CGPoint(x: -size, y: 0))
        path.closeSubpath()
        return SKShapeNode(path: path)
    }
    
    private func createSpikedCircle(radius: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let outerRadius = i % 2 == 0 ? radius * 1.3 : radius
            let x = cos(angle) * outerRadius
            let y = sin(angle) * outerRadius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return SKShapeNode(path: path)
    }
    
    private func createEnergyArc(angle: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: .zero)
        let endPoint = CGPoint(
            x: cos(angle * .pi / 180) * 20,
            y: sin(angle * .pi / 180) * 20
        )
        path.addLine(to: endPoint)
        
        let arc = SKShapeNode(path: path)
        arc.strokeColor = Colors.neonPurple.withAlphaComponent(0.5)
        arc.lineWidth = 1
        arc.glowWidth = 2
        
        // Flicker animation
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.1),
            SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        ])
        arc.run(SKAction.repeatForever(flicker))
        
        return arc
    }
    
    private func getTowerColor(type: String) -> SKColor {
        switch type {
        case "laser": return Colors.neonCyan
        case "plasma": return Colors.neonPurple
        case "missile": return Colors.neonOrange
        case "tesla": return Colors.neonYellow
        default: return .white
        }
    }
    
    private func getPointOnPath(t: CGFloat) -> CGPoint {
        // Approximate path calculation for dot placement
        if t < 0.25 {
            let localT = t * 4
            return CGPoint(
                x: 400 * (1 - localT),
                y: 150 * localT
            )
        } else if t < 0.5 {
            let localT = (t - 0.25) * 4
            return CGPoint(
                x: -200 * localT,
                y: 150 * (1 - localT)
            )
        } else if t < 0.75 {
            let localT = (t - 0.5) * 4
            return CGPoint(
                x: -200 * (1 - localT),
                y: -150 * localT
            )
        } else {
            let localT = (t - 0.75) * 4
            return CGPoint(
                x: 0,
                y: -150 * (1 - localT)
            )
        }
    }
}