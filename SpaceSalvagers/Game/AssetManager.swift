import SpriteKit
import CoreGraphics

class AssetManager {
    static let shared = AssetManager()
    
    // MARK: - Asset Caches
    private var textureCache: [String: SKTexture] = [:]
    private var spriteFrameCache: [String: [SKTexture]] = [:]
    
    // MARK: - Color Palette
    struct Colors {
        // Space/Background Colors
        static let spaceBlack = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        static let nebulaPurple = SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 0.8)
        static let nebulaBlue = SKColor(red: 0.05, green: 0.15, blue: 0.35, alpha: 0.6)
        
        // Neon/Cyberpunk Colors
        static let neonCyan = SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        static let neonPurple = SKColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1.0)
        static let neonOrange = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        static let neonYellow = SKColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        static let neonGreen = SKColor(red: 0.0, green: 1.0, blue: 0.3, alpha: 1.0)
        static let neonRed = SKColor(red: 1.0, green: 0.1, blue: 0.3, alpha: 1.0)
        
        // UI Colors
        static let hologramBlue = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.7)
        static let hologramGreen = SKColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 0.7)
        static let warningRed = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)
        
        // Grid Colors
        static let gridPrimary = SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.4)
        static let gridSecondary = SKColor(red: 0.05, green: 0.15, blue: 0.25, alpha: 0.2)
    }
    
    private init() {
        preloadAssets()
    }
    
    // MARK: - Asset Loading
    
    private func preloadAssets() {
        // Generate and cache all textures
        generateBackgroundTextures()
        generateTowerTextures()
        generateEnemyTextures()
        generateProjectileTextures()
        generateEffectTextures()
        generateUITextures()
    }
    
    func getTexture(named name: String) -> SKTexture? {
        return textureCache[name]
    }
    
    func getAnimationFrames(named name: String) -> [SKTexture]? {
        return spriteFrameCache[name]
    }
    
    func getTowerColor(type: String) -> SKColor {
        switch type.lowercased() {
        case "laser":
            return Colors.neonCyan
        case "plasma":
            return Colors.neonPurple
        case "missile":
            return Colors.neonOrange
        case "tesla":
            return Colors.neonYellow
        default:
            return SKColor.gray
        }
    }
    
    // MARK: - Background Generation
    
    private func generateBackgroundTextures() {
        // Main space background with nebula
        textureCache["background_space"] = generateSpaceBackground()
        textureCache["background_nebula"] = generateNebulaOverlay()
        textureCache["background_stars"] = generateStarField()
        textureCache["grid_holographic"] = generateHolographicGrid()
        textureCache["grid_overlay"] = generateGridOverlay()
    }
    
    private func generateSpaceBackground() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Deep space gradient
            let gradient = CGGradient(colorsSpace: nil, colors: [
                Colors.spaceBlack.cgColor,
                SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0).cgColor,
                Colors.spaceBlack.cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.7),
                startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.7),
                endRadius: size.width * 0.8,
                options: []
            )
            
            // Add distant nebula clouds
            for _ in 0..<5 {
                let cloudSize = CGFloat.random(in: 100...300)
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                
                let nebulaGradient = CGGradient(colorsSpace: nil, colors: [
                    Colors.nebulaPurple.cgColor,
                    Colors.nebulaBlue.cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.5, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    nebulaGradient,
                    startCenter: CGPoint(x: x, y: y),
                    startRadius: 0,
                    endCenter: CGPoint(x: x, y: y),
                    endRadius: cloudSize,
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func generateStarField() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(SKColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            // Generate stars of various sizes and brightness
            for _ in 0..<200 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 1...3)
                let brightness = CGFloat.random(in: 0.3...1.0)
                
                context.cgContext.setFillColor(SKColor.white.withAlphaComponent(brightness).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: x, y: y, width: starSize, height: starSize))
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func generateHolographicGrid() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(SKColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            // Create holographic grid lines
            context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(0.3).cgColor)
            context.cgContext.setLineWidth(1.0)
            
            let gridSize: CGFloat = 50
            
            // Vertical lines
            for x in stride(from: 0, through: size.width, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: x, y: 0))
                context.cgContext.addLine(to: CGPoint(x: x, y: size.height))
            }
            
            // Horizontal lines
            for y in stride(from: 0, through: size.height, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: 0, y: y))
                context.cgContext.addLine(to: CGPoint(x: size.width, y: y))
            }
            
            context.cgContext.strokePath()
            
            // Add grid intersection points with glow
            context.cgContext.setFillColor(Colors.neonCyan.withAlphaComponent(0.5).cgColor)
            for x in stride(from: 0, through: size.width, by: gridSize) {
                for y in stride(from: 0, through: size.height, by: gridSize) {
                    context.cgContext.fillEllipse(in: CGRect(x: x-1, y: y-1, width: 2, height: 2))
                }
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func generateGridOverlay() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(SKColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            // Subtle grid for gameplay reference
            context.cgContext.setStrokeColor(Colors.gridSecondary.cgColor)
            context.cgContext.setLineWidth(0.5)
            
            let gridSize: CGFloat = 25
            
            for x in stride(from: 0, through: size.width, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: x, y: 0))
                context.cgContext.addLine(to: CGPoint(x: x, y: size.height))
            }
            
            for y in stride(from: 0, through: size.height, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: 0, y: y))
                context.cgContext.addLine(to: CGPoint(x: size.width, y: y))
            }
            
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateNebulaOverlay() -> SKTexture {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(SKColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            // Animated nebula clouds that will be animated via code
            let cloudPositions = [
                CGPoint(x: size.width * 0.2, y: size.height * 0.8),
                CGPoint(x: size.width * 0.7, y: size.height * 0.3),
                CGPoint(x: size.width * 0.9, y: size.height * 0.6)
            ]
            
            for position in cloudPositions {
                let cloudGradient = CGGradient(colorsSpace: nil, colors: [
                    Colors.nebulaPurple.withAlphaComponent(0.3).cgColor,
                    Colors.nebulaBlue.withAlphaComponent(0.2).cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.6, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    cloudGradient,
                    startCenter: position,
                    startRadius: 0,
                    endCenter: position,
                    endRadius: 150,
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Tower Generation
    
    private func generateTowerTextures() {
        // Generate base texture (shared by all towers)
        textureCache["tower_base"] = generateTowerBase()
        
        // Generate individual tower turrets
        textureCache["tower_laser_turret"] = generateLaserTurret()
        textureCache["tower_plasma_turret"] = generatePlasmaTurret()
        textureCache["tower_missile_turret"] = generateMissileTurret()
        textureCache["tower_tesla_turret"] = generateTeslaTurret()
        
        // Generate tower effects
        textureCache["tower_laser_crystal"] = generateLaserCrystal()
        textureCache["tower_plasma_orb"] = generatePlasmaOrb()
        textureCache["tower_missile_pod"] = generateMissilePod()
        textureCache["tower_tesla_coil"] = generateTeslaCoil()
    }
    
    private func generateTowerBase() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius: CGFloat = 28
            
            // Outer ring with metallic gradient
            let outerGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0).cgColor,
                SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0).cgColor,
                SKColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                outerGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
            
            // Inner platform
            context.cgContext.setFillColor(SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 20, y: center.y - 20, width: 40, height: 40))
            
            // Holographic connection points
            for angle in stride(from: 0, to: 360, by: 90) {
                let x = center.x + 22 * cos(CGFloat(angle) * .pi / 180)
                let y = center.y + 22 * sin(CGFloat(angle) * .pi / 180)
                
                context.cgContext.setFillColor(Colors.neonCyan.cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: x-2, y: y-2, width: 4, height: 4))
            }
            
            // Central mount point
            context.cgContext.setFillColor(SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0).cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16))
        }
        
        return SKTexture(image: image)
    }
    
    private func generateLaserTurret() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Main turret body
            let turretGradient = CGGradient(colorsSpace: nil, colors: [
                Colors.neonCyan.withAlphaComponent(0.8).cgColor,
                SKColor(red: 0.0, green: 0.4, blue: 0.6, alpha: 1.0).cgColor,
                Colors.neonCyan.cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                turretGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 18,
                options: []
            )
            
            // Laser focusing lens
            context.cgContext.setFillColor(SKColor.white.withAlphaComponent(0.8).cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16))
            
            // Crystal core
            context.cgContext.setFillColor(Colors.neonCyan.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
            
            // Targeting reticle
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(1.0)
            for angle in stride(from: 0, to: 360, by: 30) {
                let startRadius: CGFloat = 12
                let endRadius: CGFloat = 16
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
    
    private func generatePlasmaTurret() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Main turret body with purple energy
            let turretGradient = CGGradient(colorsSpace: nil, colors: [
                Colors.neonPurple.withAlphaComponent(0.8).cgColor,
                SKColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 1.0).cgColor,
                Colors.neonPurple.cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                turretGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 18,
                options: []
            )
            
            // Plasma containment rings
            for radius in [10, 14, 18] {
                context.cgContext.setStrokeColor(Colors.neonPurple.withAlphaComponent(0.6).cgColor)
                context.cgContext.setLineWidth(1.0)
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius), 
                                                         width: CGFloat(radius * 2), height: CGFloat(radius * 2)))
            }
            
            // Central plasma orb
            let orbGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                Colors.neonPurple.cgColor,
                SKColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 1.0).cgColor
            ] as CFArray, locations: [0.0, 0.3, 1.0])!
            
            context.cgContext.drawRadialGradient(
                orbGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 8,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func generateMissileTurret() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Main turret body
            let turretGradient = CGGradient(colorsSpace: nil, colors: [
                Colors.neonOrange.withAlphaComponent(0.8).cgColor,
                SKColor(red: 0.5, green: 0.2, blue: 0.0, alpha: 1.0).cgColor,
                Colors.neonOrange.cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                turretGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 18,
                options: []
            )
            
            // Missile launch tubes
            let tubePositions = [
                CGPoint(x: center.x - 8, y: center.y - 8),
                CGPoint(x: center.x + 8, y: center.y - 8),
                CGPoint(x: center.x - 8, y: center.y + 8),
                CGPoint(x: center.x + 8, y: center.y + 8)
            ]
            
            for position in tubePositions {
                // Tube body
                context.cgContext.setFillColor(SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: position.x - 3, y: position.y - 3, width: 6, height: 6))
                
                // Tube opening
                context.cgContext.setFillColor(SKColor.black.cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: position.x - 2, y: position.y - 2, width: 4, height: 4))
                
                // Ready indicator
                context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(0.8).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: position.x - 1, y: position.y - 1, width: 2, height: 2))
            }
            
            // Central targeting system
            context.cgContext.setStrokeColor(Colors.neonOrange.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.strokeEllipse(in: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10))
        }
        
        return SKTexture(image: image)
    }
    
    private func generateTeslaTurret() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Main turret body
            let turretGradient = CGGradient(colorsSpace: nil, colors: [
                Colors.neonYellow.withAlphaComponent(0.8).cgColor,
                SKColor(red: 0.5, green: 0.4, blue: 0.0, alpha: 1.0).cgColor,
                Colors.neonYellow.cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                turretGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 18,
                options: []
            )
            
            // Tesla coil rings
            for (radius, alpha) in [(8, 1.0), (12, 0.7), (16, 0.4)] {
                context.cgContext.setStrokeColor(Colors.neonYellow.withAlphaComponent(alpha).cgColor)
                context.cgContext.setLineWidth(2.0)
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius),
                                                         width: CGFloat(radius * 2), height: CGFloat(radius * 2)))
            }
            
            // Central conductor
            context.cgContext.setFillColor(SKColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
            
            // Electric arcs (simplified representation)
            context.cgContext.setStrokeColor(Colors.neonYellow.cgColor)
            context.cgContext.setLineWidth(1.0)
            for angle in stride(from: 0, to: 360, by: 45) {
                let arcLength: CGFloat = 12
                let startX = center.x + 6 * cos(CGFloat(angle) * .pi / 180)
                let startY = center.y + 6 * sin(CGFloat(angle) * .pi / 180)
                let endX = center.x + arcLength * cos(CGFloat(angle) * .pi / 180)
                let endY = center.y + arcLength * sin(CGFloat(angle) * .pi / 180)
                
                context.cgContext.move(to: CGPoint(x: startX, y: startY))
                context.cgContext.addLine(to: CGPoint(x: endX, y: endY))
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Helper Methods for Tower Components
    
    private func generateLaserCrystal() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Crystal with inner glow
            let crystalGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                Colors.neonCyan.cgColor,
                Colors.neonCyan.withAlphaComponent(0.6).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                crystalGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 8,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func generatePlasmaOrb() -> SKTexture {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Plasma orb with energy swirls
            let orbGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                Colors.neonPurple.cgColor,
                SKColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 0.8).cgColor
            ] as CFArray, locations: [0.0, 0.4, 1.0])!
            
            context.cgContext.drawRadialGradient(
                orbGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 10,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func generateMissilePod() -> SKTexture {
        let size = CGSize(width: 12, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Missile body
            context.cgContext.setFillColor(SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor)
            context.cgContext.fill(CGRect(x: 2, y: 4, width: 8, height: 12))
            
            // Missile tip
            context.cgContext.setFillColor(Colors.neonOrange.cgColor)
            let tipPath = CGMutablePath()
            tipPath.move(to: CGPoint(x: 6, y: 2))
            tipPath.addLine(to: CGPoint(x: 2, y: 4))
            tipPath.addLine(to: CGPoint(x: 10, y: 4))
            tipPath.closeSubpath()
            context.cgContext.addPath(tipPath)
            context.cgContext.fillPath()
            
            // Fins
            context.cgContext.setFillColor(SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
            let finPath = CGMutablePath()
            finPath.move(to: CGPoint(x: 0, y: 16))
            finPath.addLine(to: CGPoint(x: 2, y: 12))
            finPath.addLine(to: CGPoint(x: 2, y: 16))
            finPath.closeSubpath()
            finPath.move(to: CGPoint(x: 12, y: 16))
            finPath.addLine(to: CGPoint(x: 10, y: 12))
            finPath.addLine(to: CGPoint(x: 10, y: 16))
            finPath.closeSubpath()
            context.cgContext.addPath(finPath)
            context.cgContext.fillPath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateTeslaCoil() -> SKTexture {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Coil body
            context.cgContext.setStrokeColor(SKColor(red: 0.6, green: 0.5, blue: 0.0, alpha: 1.0).cgColor)
            context.cgContext.setLineWidth(2.0)
            
            // Spiral coil pattern
            for radius in stride(from: 4, through: 10, by: 2) {
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius),
                                                         width: CGFloat(radius * 2), height: CGFloat(radius * 2)))
            }
            
            // Central conductor
            context.cgContext.setFillColor(Colors.neonYellow.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: center.x - 2, y: center.y - 2, width: 4, height: 4))
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Enemy Generation
    
    private func generateEnemyTextures() {
        // Scrap Drone
        spriteFrameCache["enemy_scrap_drone_idle"] = generateScrapDroneFrames(state: "idle")
        spriteFrameCache["enemy_scrap_drone_move"] = generateScrapDroneFrames(state: "move")
        
        // Heavy Hauler
        spriteFrameCache["enemy_heavy_hauler_idle"] = generateHeavyHaulerFrames(state: "idle")
        spriteFrameCache["enemy_heavy_hauler_move"] = generateHeavyHaulerFrames(state: "move")
        
        // Swarm Units
        spriteFrameCache["enemy_swarm_unit_idle"] = generateSwarmUnitFrames(state: "idle")
        spriteFrameCache["enemy_swarm_unit_move"] = generateSwarmUnitFrames(state: "move")
        
        // Boss Ship
        spriteFrameCache["enemy_boss_ship_idle"] = generateBossShipFrames(state: "idle")
        spriteFrameCache["enemy_boss_ship_move"] = generateBossShipFrames(state: "move")
    }
    
    private func generateScrapDroneFrames(state: String) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameCount = state == "idle" ? 4 : 6
        
        for frame in 0..<frameCount {
            let size = CGSize(width: 32, height: 32)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                
                // Drone body with rusty metallic appearance
                let bodyGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0).cgColor,
                    SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor,
                    SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
                ] as CFArray, locations: [0.0, 0.5, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    bodyGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: 12,
                    options: []
                )
                
                // Propulsion engines (animated based on frame)
                let engineBrightness = state == "move" ? 
                    CGFloat(0.5 + 0.5 * sin(Double(frame) * 0.5)) : 0.3
                
                for angle in [45, 135, 225, 315] {
                    let x = center.x + 8 * cos(CGFloat(angle) * .pi / 180)
                    let y = center.y + 8 * sin(CGFloat(angle) * .pi / 180)
                    
                    context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(engineBrightness).cgColor)
                    context.cgContext.fillEllipse(in: CGRect(x: x-2, y: y-2, width: 4, height: 4))
                }
                
                // Central sensor/eye
                context.cgContext.setFillColor(Colors.neonRed.withAlphaComponent(0.8).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x-3, y: center.y-3, width: 6, height: 6))
                
                // Salvage collector arms
                context.cgContext.setStrokeColor(SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor)
                context.cgContext.setLineWidth(1.0)
                for angle in [0, 90, 180, 270] {
                    let armLength: CGFloat = 10
                    let startX = center.x + 5 * cos(CGFloat(angle) * .pi / 180)
                    let startY = center.y + 5 * sin(CGFloat(angle) * .pi / 180)
                    let endX = center.x + armLength * cos(CGFloat(angle) * .pi / 180)
                    let endY = center.y + armLength * sin(CGFloat(angle) * .pi / 180)
                    
                    context.cgContext.move(to: CGPoint(x: startX, y: startY))
                    context.cgContext.addLine(to: CGPoint(x: endX, y: endY))
                }
                context.cgContext.strokePath()
            }
            
            frames.append(SKTexture(image: image))
        }
        
        return frames
    }
    
    private func generateHeavyHaulerFrames(state: String) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameCount = state == "idle" ? 3 : 5
        
        for frame in 0..<frameCount {
            let size = CGSize(width: 64, height: 48)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                
                // Main hull
                let hullPath = CGMutablePath()
                hullPath.move(to: CGPoint(x: 10, y: center.y))
                hullPath.addLine(to: CGPoint(x: size.width - 10, y: center.y - 15))
                hullPath.addLine(to: CGPoint(x: size.width - 5, y: center.y + 15))
                hullPath.addLine(to: CGPoint(x: 15, y: center.y + 10))
                hullPath.closeSubpath()
                
                context.cgContext.addPath(hullPath)
                context.cgContext.setFillColor(SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor)
                context.cgContext.fillPath()
                
                // Armor plating
                context.cgContext.setStrokeColor(SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0).cgColor)
                context.cgContext.setLineWidth(2.0)
                context.cgContext.addPath(hullPath)
                context.cgContext.strokePath()
                
                // Cargo bays
                for x in stride(from: 20, to: size.width - 10, by: 15) {
                    context.cgContext.setFillColor(SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0).cgColor)
                    context.cgContext.fill(CGRect(x: x, y: center.y - 8, width: 10, height: 16))
                    
                    context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(0.5).cgColor)
                    context.cgContext.setLineWidth(1.0)
                    context.cgContext.stroke(CGRect(x: x, y: center.y - 8, width: 10, height: 16))
                }
                
                // Engine exhaust (animated)
                let exhaustIntensity = state == "move" ? 
                    CGFloat(0.6 + 0.4 * sin(Double(frame) * 0.8)) : 0.2
                
                context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(exhaustIntensity).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: 2, y: center.y - 5, width: 12, height: 10))
                
                // Shield generators
                context.cgContext.setFillColor(Colors.neonCyan.withAlphaComponent(0.3).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16))
            }
            
            frames.append(SKTexture(image: image))
        }
        
        return frames
    }
    
    private func generateSwarmUnitFrames(state: String) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameCount = state == "idle" ? 6 : 8
        
        for frame in 0..<frameCount {
            let size = CGSize(width: 16, height: 16)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                
                // Tiny triangular body
                let bodyPath = CGMutablePath()
                bodyPath.move(to: CGPoint(x: center.x, y: center.y - 6))
                bodyPath.addLine(to: CGPoint(x: center.x - 4, y: center.y + 3))
                bodyPath.addLine(to: CGPoint(x: center.x + 4, y: center.y + 3))
                bodyPath.closeSubpath()
                
                context.cgContext.addPath(bodyPath)
                context.cgContext.setFillColor(SKColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
                context.cgContext.fillPath()
                
                // Wing blur effect when moving
                if state == "move" {
                    let wingBlur = CGFloat(0.3 + 0.7 * abs(sin(Double(frame) * 1.2)))
                    context.cgContext.setFillColor(Colors.neonRed.withAlphaComponent(wingBlur).cgColor)
                    
                    // Wing trails
                    context.cgContext.fillEllipse(in: CGRect(x: center.x - 6, y: center.y - 2, width: 4, height: 2))
                    context.cgContext.fillEllipse(in: CGRect(x: center.x + 2, y: center.y - 2, width: 4, height: 2))
                }
                
                // Targeting laser
                context.cgContext.setFillColor(Colors.neonRed.cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2))
            }
            
            frames.append(SKTexture(image: image))
        }
        
        return frames
    }
    
    private func generateBossShipFrames(state: String) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameCount = state == "idle" ? 4 : 6
        
        for frame in 0..<frameCount {
            let size = CGSize(width: 128, height: 96)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { context in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                
                // Main command ship body
                let bodyPath = CGMutablePath()
                bodyPath.move(to: CGPoint(x: 20, y: center.y))
                bodyPath.addQuadCurve(to: CGPoint(x: size.width - 15, y: center.y - 25), 
                                    control: CGPoint(x: center.x, y: center.y - 30))
                bodyPath.addLine(to: CGPoint(x: size.width - 10, y: center.y + 25))
                bodyPath.addQuadCurve(to: CGPoint(x: 20, y: center.y), 
                                    control: CGPoint(x: center.x, y: center.y + 30))
                bodyPath.closeSubpath()
                
                // Hull gradient
                let hullGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0).cgColor,
                    SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0).cgColor,
                    SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor
                ] as CFArray, locations: [0.0, 0.5, 1.0])!
                
                context.cgContext.saveGState()
                context.cgContext.addPath(bodyPath)
                context.cgContext.clip()
                context.cgContext.drawLinearGradient(
                    hullGradient,
                    start: CGPoint(x: 0, y: center.y - 30),
                    end: CGPoint(x: 0, y: center.y + 30),
                    options: []
                )
                context.cgContext.restoreGState()
                
                // Command bridge
                context.cgContext.setFillColor(SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1.0).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: center.x - 15, y: center.y - 10, width: 30, height: 20))
                
                // Weapon hardpoints
                let weaponPositions = [
                    CGPoint(x: center.x - 30, y: center.y - 15),
                    CGPoint(x: center.x - 30, y: center.y + 15),
                    CGPoint(x: center.x + 20, y: center.y - 20),
                    CGPoint(x: center.x + 20, y: center.y + 20)
                ]
                
                for position in weaponPositions {
                    context.cgContext.setFillColor(SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)
                    context.cgContext.fillEllipse(in: CGRect(x: position.x - 4, y: position.y - 4, width: 8, height: 8))
                    
                    // Weapon charging effect
                    let chargeIntensity = CGFloat(0.3 + 0.7 * sin(Double(frame) * 0.6 + Double(position.x)))
                    context.cgContext.setFillColor(Colors.neonRed.withAlphaComponent(chargeIntensity).cgColor)
                    context.cgContext.fillEllipse(in: CGRect(x: position.x - 2, y: position.y - 2, width: 4, height: 4))
                }
                
                // Engine array
                for i in 0..<5 {
                    let engineY = center.y - 20 + CGFloat(i * 10)
                    let enginePower = state == "move" ? 
                        CGFloat(0.7 + 0.3 * sin(Double(frame) * 0.8 + Double(i))) : 0.3
                    
                    context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(enginePower).cgColor)
                    context.cgContext.fillEllipse(in: CGRect(x: 5, y: engineY - 2, width: 15, height: 4))
                }
                
                // Shield effect
                if frame % 2 == 0 {
                    context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(0.3).cgColor)
                    context.cgContext.setLineWidth(2.0)
                    context.cgContext.strokeEllipse(in: CGRect(x: center.x - 50, y: center.y - 35, width: 100, height: 70))
                }
            }
            
            frames.append(SKTexture(image: image))
        }
        
        return frames
    }
    
    // MARK: - Projectile Generation
    
    private func generateProjectileTextures() {
        textureCache["projectile_laser_beam"] = generateLaserBeam()
        textureCache["projectile_plasma_orb"] = generatePlasmaProjectile()
        textureCache["projectile_missile"] = generateMissileProjectile()
        textureCache["projectile_lightning"] = generateLightningBolt()
    }
    
    private func generateLaserBeam() -> SKTexture {
        let size = CGSize(width: 32, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Laser beam with core and glow
            let beamGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.clear.cgColor,
                Colors.neonCyan.withAlphaComponent(0.3).cgColor,
                Colors.neonCyan.cgColor,
                SKColor.white.cgColor,
                Colors.neonCyan.cgColor,
                Colors.neonCyan.withAlphaComponent(0.3).cgColor,
                SKColor.clear.cgColor
            ] as CFArray, locations: [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0])!
            
            context.cgContext.drawLinearGradient(
                beamGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func generatePlasmaProjectile() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Plasma orb with energy trails
            let plasmaGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                Colors.neonPurple.cgColor,
                Colors.neonPurple.withAlphaComponent(0.5).cgColor,
                SKColor.clear.cgColor
            ] as CFArray, locations: [0.0, 0.3, 0.7, 1.0])!
            
            context.cgContext.drawRadialGradient(
                plasmaGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 8,
                options: []
            )
            
            // Energy sparkles
            for _ in 0..<8 {
                let sparkleX = center.x + CGFloat.random(in: -6...6)
                let sparkleY = center.y + CGFloat.random(in: -6...6)
                context.cgContext.setFillColor(Colors.neonPurple.withAlphaComponent(0.8).cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: sparkleX, y: sparkleY, width: 1, height: 1))
            }
        }
        
        return SKTexture(image: image)
    }
    
    private func generateMissileProjectile() -> SKTexture {
        let size = CGSize(width: 20, height: 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Missile body
            context.cgContext.setFillColor(SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor)
            context.cgContext.fill(CGRect(x: 4, y: 1, width: 12, height: 4))
            
            // Missile tip
            let tipPath = CGMutablePath()
            tipPath.move(to: CGPoint(x: 16, y: 3))
            tipPath.addLine(to: CGPoint(x: 20, y: 3))
            tipPath.addLine(to: CGPoint(x: 16, y: 1))
            tipPath.addLine(to: CGPoint(x: 16, y: 5))
            tipPath.closeSubpath()
            context.cgContext.addPath(tipPath)
            context.cgContext.setFillColor(Colors.neonOrange.cgColor)
            context.cgContext.fillPath()
            
            // Engine exhaust
            context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(0.8).cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 2, width: 6, height: 2))
        }
        
        return SKTexture(image: image)
    }
    
    private func generateLightningBolt() -> SKTexture {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Lightning bolt path
            let boltPath = CGMutablePath()
            boltPath.move(to: CGPoint(x: 12, y: 2))
            boltPath.addLine(to: CGPoint(x: 8, y: 10))
            boltPath.addLine(to: CGPoint(x: 14, y: 12))
            boltPath.addLine(to: CGPoint(x: 6, y: 22))
            boltPath.addLine(to: CGPoint(x: 10, y: 14))
            boltPath.addLine(to: CGPoint(x: 4, y: 12))
            boltPath.closeSubpath()
            
            context.cgContext.addPath(boltPath)
            context.cgContext.setFillColor(Colors.neonYellow.cgColor)
            context.cgContext.fillPath()
            
            // Glow effect
            context.cgContext.setStrokeColor(Colors.neonYellow.withAlphaComponent(0.6).cgColor)
            context.cgContext.setLineWidth(3.0)
            context.cgContext.addPath(boltPath)
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - Effect Generation
    
    private func generateEffectTextures() {
        // Explosion effects
        spriteFrameCache["effect_explosion_small"] = generateExplosionFrames(size: "small")
        spriteFrameCache["effect_explosion_large"] = generateExplosionFrames(size: "large")
        
        // Shield effects
        textureCache["effect_shield_bubble"] = generateShieldBubble()
        textureCache["effect_shield_impact"] = generateShieldImpact()
        
        // Build effects
        textureCache["effect_hologram_build"] = generateHologramBuild()
        textureCache["effect_energy_pulse"] = generateEnergyPulse()
    }
    
    private func generateExplosionFrames(size: String) -> [SKTexture] {
        var frames: [SKTexture] = []
        let frameCount = 8
        let explosionSize: CGFloat = size == "small" ? 32 : 64
        
        for frame in 0..<frameCount {
            let textureSize = CGSize(width: explosionSize, height: explosionSize)
            let renderer = UIGraphicsImageRenderer(size: textureSize)
            
            let image = renderer.image { context in
                let center = CGPoint(x: textureSize.width/2, y: textureSize.height/2)
                let progress = CGFloat(frame) / CGFloat(frameCount - 1)
                let radius = explosionSize * 0.5 * progress
                
                // Explosion core
                let coreGradient = CGGradient(colorsSpace: nil, colors: [
                    SKColor.white.cgColor,
                    Colors.neonOrange.cgColor,
                    Colors.neonRed.cgColor,
                    SKColor.clear.cgColor
                ] as CFArray, locations: [0.0, 0.3, 0.7, 1.0])!
                
                context.cgContext.drawRadialGradient(
                    coreGradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: []
                )
                
                // Debris particles
                if frame > 2 {
                    for _ in 0..<Int(10 * progress) {
                        let debrisAngle = CGFloat.random(in: 0...(2 * .pi))
                        let debrisDistance = CGFloat.random(in: radius * 0.5...radius * 1.2)
                        let debrisX = center.x + debrisDistance * cos(debrisAngle)
                        let debrisY = center.y + debrisDistance * sin(debrisAngle)
                        
                        context.cgContext.setFillColor(Colors.neonOrange.withAlphaComponent(1.0 - progress).cgColor)
                        context.cgContext.fillEllipse(in: CGRect(x: debrisX - 1, y: debrisY - 1, width: 2, height: 2))
                    }
                }
            }
            
            frames.append(SKTexture(image: image))
        }
        
        return frames
    }
    
    private func generateShieldBubble() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Shield dome effect
            let shieldGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.clear.cgColor,
                Colors.neonCyan.withAlphaComponent(0.2).cgColor,
                Colors.neonCyan.withAlphaComponent(0.4).cgColor,
                Colors.neonCyan.withAlphaComponent(0.2).cgColor,
                SKColor.clear.cgColor
            ] as CFArray, locations: [0.0, 0.3, 0.5, 0.7, 1.0])!
            
            context.cgContext.drawRadialGradient(
                shieldGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 30,
                options: []
            )
            
            // Hexagonal shield pattern
            context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(0.6).cgColor)
            context.cgContext.setLineWidth(1.0)
            
            for radius in [15, 20, 25] {
                let hexPath = CGMutablePath()
                for i in 0..<6 {
                    let angle = CGFloat(i) * .pi / 3
                    let x = center.x + CGFloat(radius) * cos(angle)
                    let y = center.y + CGFloat(radius) * sin(angle)
                    
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
        }
        
        return SKTexture(image: image)
    }
    
    private func generateShieldImpact() -> SKTexture {
        let size = CGSize(width: 48, height: 48)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Impact ripple effect
            for radius in [8, 12, 16, 20] {
                let alpha = CGFloat(20 - radius) / 20.0
                context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(alpha).cgColor)
                context.cgContext.setLineWidth(2.0)
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius),
                                                          width: CGFloat(radius * 2), height: CGFloat(radius * 2)))
            }
            
            // Electric discharge
            context.cgContext.setStrokeColor(Colors.neonYellow.cgColor)
            context.cgContext.setLineWidth(1.0)
            for angle in stride(from: 0, to: 360, by: 30) {
                let startRadius: CGFloat = 8
                let endRadius: CGFloat = 18
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
    
    private func generateHologramBuild() -> SKTexture {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Holographic construction grid
            context.cgContext.setStrokeColor(Colors.hologramBlue.cgColor)
            context.cgContext.setLineWidth(1.0)
            
            // Vertical grid lines
            for x in stride(from: 16, through: 48, by: 8) {
                context.cgContext.move(to: CGPoint(x: x, y: 16))
                context.cgContext.addLine(to: CGPoint(x: x, y: 48))
            }
            
            // Horizontal grid lines
            for y in stride(from: 16, through: 48, by: 8) {
                context.cgContext.move(to: CGPoint(x: 16, y: y))
                context.cgContext.addLine(to: CGPoint(x: 48, y: y))
            }
            context.cgContext.strokePath()
            
            // Corner markers
            let cornerPositions = [
                CGPoint(x: 16, y: 16), CGPoint(x: 48, y: 16),
                CGPoint(x: 16, y: 48), CGPoint(x: 48, y: 48)
            ]
            
            for corner in cornerPositions {
                context.cgContext.setFillColor(Colors.hologramBlue.cgColor)
                context.cgContext.fillEllipse(in: CGRect(x: corner.x - 2, y: corner.y - 2, width: 4, height: 4))
            }
            
            // Central build indicator
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(2.0)
            context.cgContext.strokeEllipse(in: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16))
        }
        
        return SKTexture(image: image)
    }
    
    private func generateEnergyPulse() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            
            // Energy pulse rings
            for (radius, alpha) in [(8, 1.0), (12, 0.6), (16, 0.3)] {
                context.cgContext.setStrokeColor(Colors.neonCyan.withAlphaComponent(alpha).cgColor)
                context.cgContext.setLineWidth(2.0)
                context.cgContext.strokeEllipse(in: CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius),
                                                          width: CGFloat(radius * 2), height: CGFloat(radius * 2)))
            }
            
            // Central energy core
            let coreGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor.white.cgColor,
                Colors.neonCyan.cgColor,
                Colors.neonCyan.withAlphaComponent(0.5).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(
                coreGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: 6,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: - UI Generation
    
    private func generateUITextures() {
        // Button backgrounds
        textureCache["ui_button_normal"] = generateUIButton(state: "normal")
        textureCache["ui_button_pressed"] = generateUIButton(state: "pressed")
        textureCache["ui_button_disabled"] = generateUIButton(state: "disabled")
        
        // Progress bars
        textureCache["ui_progress_background"] = generateProgressBackground()
        textureCache["ui_progress_fill"] = generateProgressFill()
        
        // Health bars
        textureCache["ui_health_background"] = generateHealthBackground()
        textureCache["ui_health_fill_green"] = generateHealthFill(color: Colors.neonGreen)
        textureCache["ui_health_fill_yellow"] = generateHealthFill(color: Colors.neonYellow)
        textureCache["ui_health_fill_red"] = generateHealthFill(color: Colors.neonRed)
        
        // Panel backgrounds
        textureCache["ui_panel_background"] = generateUIPanel()
        textureCache["ui_modal_background"] = generateModalBackground()
    }
    
    private func generateUIButton(state: String) -> SKTexture {
        let size = CGSize(width: 120, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let buttonRect = CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4)
            
            var fillColor: SKColor
            var strokeColor: SKColor
            
            switch state {
            case "pressed":
                fillColor = Colors.hologramBlue.withAlphaComponent(0.8)
                strokeColor = Colors.neonCyan
            case "disabled":
                fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
                strokeColor = SKColor.gray
            default: // normal
                fillColor = Colors.hologramBlue.withAlphaComponent(0.6)
                strokeColor = Colors.neonCyan.withAlphaComponent(0.8)
            }
            
            // Button background with holographic effect
            let buttonGradient = CGGradient(colorsSpace: nil, colors: [
                fillColor.withAlphaComponent(0.3).cgColor,
                fillColor.cgColor,
                fillColor.withAlphaComponent(0.3).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawLinearGradient(
                buttonGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
            
            // Button border
            context.cgContext.setStrokeColor(strokeColor.cgColor)
            context.cgContext.setLineWidth(2.0)
            context.cgContext.stroke(buttonRect)
            
            // Corner highlights
            let cornerSize: CGFloat = 8
            let corners = [
                CGPoint(x: 2, y: 2),
                CGPoint(x: size.width - 2, y: 2),
                CGPoint(x: 2, y: size.height - 2),
                CGPoint(x: size.width - 2, y: size.height - 2)
            ]
            
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(1.0)
            for corner in corners {
                context.cgContext.move(to: CGPoint(x: corner.x - cornerSize/2, y: corner.y))
                context.cgContext.addLine(to: CGPoint(x: corner.x + cornerSize/2, y: corner.y))
                context.cgContext.move(to: CGPoint(x: corner.x, y: corner.y - cornerSize/2))
                context.cgContext.addLine(to: CGPoint(x: corner.x, y: corner.y + cornerSize/2))
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateProgressBackground() -> SKTexture {
        let size = CGSize(width: 200, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let progressRect = CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2)
            
            // Background
            context.cgContext.setFillColor(SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.8).cgColor)
            context.cgContext.fill(progressRect)
            
            // Border
            context.cgContext.setStrokeColor(Colors.hologramBlue.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.stroke(progressRect)
            
            // Inner grid pattern
            context.cgContext.setStrokeColor(Colors.hologramBlue.withAlphaComponent(0.3).cgColor)
            context.cgContext.setLineWidth(0.5)
            for x in stride(from: 10, through: size.width - 10, by: 10) {
                context.cgContext.move(to: CGPoint(x: x, y: 1))
                context.cgContext.addLine(to: CGPoint(x: x, y: size.height - 1))
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateProgressFill() -> SKTexture {
        let size = CGSize(width: 196, height: 18)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Progress fill with energy effect
            let fillGradient = CGGradient(colorsSpace: nil, colors: [
                Colors.neonCyan.withAlphaComponent(0.6).cgColor,
                Colors.neonCyan.cgColor,
                Colors.neonCyan.withAlphaComponent(0.6).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawLinearGradient(
                fillGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
            
            // Animated scan line effect
            context.cgContext.setStrokeColor(SKColor.white.withAlphaComponent(0.8).cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: size.width - 2, y: 0))
            context.cgContext.addLine(to: CGPoint(x: size.width - 2, y: size.height))
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateHealthBackground() -> SKTexture {
        let size = CGSize(width: 60, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let healthRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // Background
            context.cgContext.setFillColor(SKColor.black.withAlphaComponent(0.6).cgColor)
            context.cgContext.fill(healthRect)
            
            // Border
            context.cgContext.setStrokeColor(SKColor.white.withAlphaComponent(0.8).cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.stroke(healthRect)
        }
        
        return SKTexture(image: image)
    }
    
    private func generateHealthFill(color: SKColor) -> SKTexture {
        let size = CGSize(width: 58, height: 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Health fill with gradient
            let healthGradient = CGGradient(colorsSpace: nil, colors: [
                color.withAlphaComponent(0.8).cgColor,
                color.cgColor,
                color.withAlphaComponent(0.8).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawLinearGradient(
                healthGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func generateUIPanel() -> SKTexture {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let panelRect = CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4)
            
            // Panel background with transparency
            let panelGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9).cgColor,
                SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.9).cgColor,
                SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.9).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawLinearGradient(
                panelGradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
            
            // Panel border with corner details
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(2.0)
            context.cgContext.stroke(panelRect)
            
            // Corner decorations
            let cornerSize: CGFloat = 16
            let corners = [
                CGPoint(x: 2, y: 2),
                CGPoint(x: size.width - 2, y: 2),
                CGPoint(x: 2, y: size.height - 2),
                CGPoint(x: size.width - 2, y: size.height - 2)
            ]
            
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(1.0)
            for corner in corners {
                // Draw corner brackets
                context.cgContext.move(to: CGPoint(x: corner.x - cornerSize, y: corner.y))
                context.cgContext.addLine(to: CGPoint(x: corner.x, y: corner.y))
                context.cgContext.addLine(to: CGPoint(x: corner.x, y: corner.y - cornerSize))
            }
            context.cgContext.strokePath()
        }
        
        return SKTexture(image: image)
    }
    
    private func generateModalBackground() -> SKTexture {
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Semi-transparent dark background
            context.cgContext.setFillColor(SKColor.black.withAlphaComponent(0.7).cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Central panel area
            let panelRect = CGRect(x: 50, y: 50, width: size.width - 100, height: size.height - 100)
            
            let modalGradient = CGGradient(colorsSpace: nil, colors: [
                SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.95).cgColor,
                SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95).cgColor,
                SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.95).cgColor
            ] as CFArray, locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawLinearGradient(
                modalGradient,
                start: CGPoint(x: 0, y: panelRect.minY),
                end: CGPoint(x: 0, y: panelRect.maxY),
                options: []
            )
            
            // Modal border
            context.cgContext.setStrokeColor(Colors.neonCyan.cgColor)
            context.cgContext.setLineWidth(2.0)
            context.cgContext.stroke(panelRect)
        }
        
        return SKTexture(image: image)
    }
}