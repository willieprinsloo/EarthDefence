import UIKit
import CoreGraphics

class LaunchImageGenerator {
    
    static func generateLaunchBackground(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Dark space background
            UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0).setFill()
            context.fill(rect)
            
            // Add stars
            for _ in 0..<100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 0.5...2.0)
                let alpha = CGFloat.random(in: 0.3...1.0)
                
                UIColor.white.withAlphaComponent(alpha).setFill()
                context.cgContext.fillEllipse(in: CGRect(x: x - starSize/2, y: y - starSize/2, width: starSize, height: starSize))
            }
            
            // Add nebula gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.1, green: 0.0, blue: 0.3, alpha: 0.2).cgColor,
                    UIColor(red: 0.0, green: 0.1, blue: 0.4, alpha: 0.1).cgColor,
                    UIColor.clear.cgColor
                ] as CFArray,
                locations: [0, 0.5, 1]
            )!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                endRadius: size.width * 0.5,
                options: []
            )
        }
    }
    
    static func generateLaunchLogo(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Clear background
            UIColor.clear.setFill()
            context.fill(rect)
            
            // Draw hexagonal station core
            let centerX = size.width / 2
            let centerY = size.height / 2
            let radius = min(size.width, size.height) * 0.35
            
            // Outer glow
            for i in stride(from: 3, through: 0, by: -1) {
                let glowRadius = radius + CGFloat(i) * 10
                let alpha = 0.2 / CGFloat(i + 1)
                
                drawHexagon(
                    context: context.cgContext,
                    center: CGPoint(x: centerX, y: centerY),
                    radius: glowRadius,
                    fillColor: UIColor(red: 0, green: 0.8, blue: 1.0, alpha: alpha),
                    strokeColor: UIColor.clear
                )
            }
            
            // Main hexagon
            drawHexagon(
                context: context.cgContext,
                center: CGPoint(x: centerX, y: centerY),
                radius: radius,
                fillColor: UIColor(red: 0.05, green: 0.15, blue: 0.25, alpha: 1.0),
                strokeColor: UIColor(red: 0, green: 0.8, blue: 1.0, alpha: 1.0)
            )
            
            // Inner core
            let innerRadius = radius * 0.5
            drawHexagon(
                context: context.cgContext,
                center: CGPoint(x: centerX, y: centerY),
                radius: innerRadius,
                fillColor: UIColor(red: 0, green: 0.6, blue: 0.8, alpha: 0.8),
                strokeColor: UIColor(red: 0, green: 1.0, blue: 1.0, alpha: 1.0)
            )
            
            // Center glow
            let glowGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0, green: 1.0, blue: 1.0, alpha: 0.8).cgColor,
                    UIColor(red: 0, green: 0.8, blue: 1.0, alpha: 0.3).cgColor,
                    UIColor.clear.cgColor
                ] as CFArray,
                locations: [0, 0.5, 1]
            )!
            
            context.cgContext.drawRadialGradient(
                glowGradient,
                startCenter: CGPoint(x: centerX, y: centerY),
                startRadius: 0,
                endCenter: CGPoint(x: centerX, y: centerY),
                endRadius: innerRadius,
                options: []
            )
        }
    }
    
    private static func drawHexagon(context: CGContext, center: CGPoint, radius: CGFloat, fillColor: UIColor, strokeColor: UIColor) {
        let path = UIBezierPath()
        
        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3.0 - CGFloat.pi / 6.0
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.close()
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
    
    static func saveImages() {
        // Generate and save background images
        let bgSizes: [(CGSize, String)] = [
            (CGSize(width: 320, height: 568), "launch-bg@1x.png"),
            (CGSize(width: 750, height: 1334), "launch-bg@2x.png"),
            (CGSize(width: 1242, height: 2208), "launch-bg@3x.png")
        ]
        
        for (size, filename) in bgSizes {
            let image = generateLaunchBackground(size: size)
            if let data = image.pngData() {
                let path = "/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/LaunchBackground.imageset/\(filename)"
                try? data.write(to: URL(fileURLWithPath: path))
                print("Saved: \(path)")
            }
        }
        
        // Generate and save logo images
        let logoSizes: [(CGSize, String)] = [
            (CGSize(width: 200, height: 200), "launch-logo@1x.png"),
            (CGSize(width: 400, height: 400), "launch-logo@2x.png"),
            (CGSize(width: 600, height: 600), "launch-logo@3x.png")
        ]
        
        for (size, filename) in logoSizes {
            let image = generateLaunchLogo(size: size)
            if let data = image.pngData() {
                let path = "/Users/wlprinsloo/Documents/Projects/Tower-game/SpaceSalvagers/Resources/Assets.xcassets/LaunchLogo.imageset/\(filename)"
                try? data.write(to: URL(fileURLWithPath: path))
                print("Saved: \(path)")
            }
        }
    }
}

// Generate images when run
LaunchImageGenerator.saveImages()