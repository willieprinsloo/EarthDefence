import SpriteKit

class BadgeViewerScene: SKScene {
    
    private var backgroundLayer: SKNode!
    private var uiLayer: SKNode!
    private var badgeContainer: SKNode!
    
    private struct Badge {
        let id: String
        let name: String
        let description: String
        let requirement: String
        let color: SKColor
        let glowColor: SKColor
        let icon: String
        let mapRequired: Int?
    }
    
    private let allBadges: [Badge] = [
        Badge(id: "badge_solar_defender",
              name: "Solar Defender",
              description: "Reached the Solar System perimeter at Pluto",
              requirement: "Complete Map 4 and enter Map 5",
              color: SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),
              glowColor: SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0),
              icon: "shield",
              mapRequired: 5),
        
        Badge(id: "badge_mars_guardian",
              name: "Mars Guardian",
              description: "Breached the Inner Solar System at Mars",
              requirement: "Complete Map 8 and enter Map 9",
              color: SKColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0),
              glowColor: SKColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0),
              icon: "sword",
              mapRequired: 9),
        
        Badge(id: "badge_earth_hero",
              name: "Earth's Hero",
              description: "Defended Earth in the final battle",
              requirement: "Complete Map 12 - Earth Final Stand",
              color: SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0),
              glowColor: SKColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0),
              icon: "earth",
              mapRequired: 12),
        
        Badge(id: "badge_perfect_defender",
              name: "Perfect Defender",
              description: "Completed a map without losing any lives",
              requirement: "Finish any map with full health",
              color: SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
              glowColor: SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0),
              icon: "star",
              mapRequired: nil),
        
        Badge(id: "badge_tower_master",
              name: "Tower Master",
              description: "Built 100 towers total",
              requirement: "Construct 100 towers across all games",
              color: SKColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0),
              glowColor: SKColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0),
              icon: "tower",
              mapRequired: nil),
        
        Badge(id: "badge_salvage_king",
              name: "Salvage King",
              description: "Earned 10,000 salvage in a single game",
              requirement: "Accumulate 10,000 salvage in one session",
              color: SKColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0),
              glowColor: SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0),
              icon: "coin",
              mapRequired: nil)
    ]
    
    override func didMove(to view: SKView) {
        setupScene()
        createBackground()
        createUI()
        displayBadges()
        animateEntrance()
    }
    
    private func setupScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = 0
        addChild(backgroundLayer)
        
        uiLayer = SKNode()
        uiLayer.zPosition = 10
        addChild(uiLayer)
        
        badgeContainer = SKNode()
        badgeContainer.zPosition = 20
        addChild(badgeContainer)
    }
    
    private func createBackground() {
        // Dark gradient background
        let background = SKShapeNode(rectOf: size)
        background.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        background.strokeColor = .clear
        backgroundLayer.addChild(background)
        
        // Add subtle stars
        for _ in 0..<100 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            star.fillColor = .white
            star.alpha = CGFloat.random(in: 0.2...0.6)
            backgroundLayer.addChild(star)
            
            // Twinkle animation
            let twinkle = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 2...4)),
                SKAction.fadeAlpha(to: star.alpha, duration: Double.random(in: 2...4))
            ]))
            star.run(twinkle)
        }
        
        // Add nebula effect
        let nebula = SKShapeNode(circleOfRadius: 200)
        nebula.position = CGPoint(x: -100, y: 100)
        nebula.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.1)
        nebula.strokeColor = .clear
        nebula.blendMode = .add
        backgroundLayer.addChild(nebula)
    }
    
    private func createUI() {
        // Title
        let titleContainer = SKNode()
        titleContainer.position = CGPoint(x: 0, y: size.height/2 - 80)
        uiLayer.addChild(titleContainer)
        
        // Title glow
        let titleGlow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleGlow.text = "BADGE COLLECTION"
        titleGlow.fontSize = 48
        titleGlow.fontColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.3)
        titleGlow.blendMode = .add
        titleGlow.setScale(1.1)
        titleContainer.addChild(titleGlow)
        
        // Main title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "BADGE COLLECTION"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1.0)
        titleContainer.addChild(titleLabel)
        
        // Subtitle
        let earnedCount = countEarnedBadges()
        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleLabel.text = "\(earnedCount) of \(allBadges.count) Badges Earned"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = SKColor(red: 0.6, green: 0.8, blue: 0.9, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: 0, y: -35)
        titleContainer.addChild(subtitleLabel)
        
        // Back button
        createBackButton()
    }
    
    private func displayBadges() {
        let columns = 3
        let rows = 2
        let spacing: CGFloat = 180
        let startX = -CGFloat(columns - 1) * spacing / 2
        let startY: CGFloat = 50
        
        for (index, badge) in allBadges.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let x = startX + CGFloat(col) * spacing
            let y = startY - CGFloat(row) * spacing
            
            let badgeNode = createBadgeDisplay(badge: badge, isEarned: isBadgeEarned(badge))
            badgeNode.position = CGPoint(x: x, y: y)
            badgeNode.alpha = 0
            badgeNode.setScale(0)
            badgeContainer.addChild(badgeNode)
            
            // Staggered entrance animation
            badgeNode.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.1),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
            ]))
        }
    }
    
    private func createBadgeDisplay(badge: Badge, isEarned: Bool) -> SKNode {
        let container = SKNode()
        container.name = badge.id
        
        // Badge frame
        let frame = SKShapeNode(circleOfRadius: 60)
        frame.fillColor = isEarned ? badge.color.withAlphaComponent(0.2) : SKColor.gray.withAlphaComponent(0.1)
        frame.strokeColor = isEarned ? badge.color : SKColor.gray.withAlphaComponent(0.3)
        frame.lineWidth = 3
        frame.glowWidth = isEarned ? 8 : 0
        container.addChild(frame)
        
        if isEarned {
            // Add glow effect for earned badges
            let glow = SKShapeNode(circleOfRadius: 65)
            glow.strokeColor = badge.glowColor
            glow.lineWidth = 2
            glow.fillColor = .clear
            glow.glowWidth = 15
            glow.alpha = 0.5
            glow.blendMode = .add
            container.addChild(glow)
            
            // Pulse animation
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 1.5),
                SKAction.fadeAlpha(to: 0.5, duration: 1.5)
            ]))
            glow.run(pulse)
        }
        
        // Badge icon
        let iconNode = createBadgeIcon(type: badge.icon, 
                                       color: isEarned ? badge.glowColor : SKColor.gray.withAlphaComponent(0.3),
                                       scale: 1.5)
        container.addChild(iconNode)
        
        // Badge name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = badge.name
        nameLabel.fontSize = 14
        nameLabel.fontColor = isEarned ? badge.glowColor : SKColor.gray.withAlphaComponent(0.5)
        nameLabel.position = CGPoint(x: 0, y: -85)
        container.addChild(nameLabel)
        
        // Status or requirement
        let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        if isEarned {
            statusLabel.text = "EARNED"
            statusLabel.fontColor = SKColor.green
        } else {
            statusLabel.text = badge.requirement
            statusLabel.fontColor = SKColor.gray.withAlphaComponent(0.5)
        }
        statusLabel.fontSize = 10
        statusLabel.position = CGPoint(x: 0, y: -100)
        container.addChild(statusLabel)
        
        // Lock overlay for unearned badges
        if !isEarned {
            let lock = SKLabelNode(text: "🔒")
            lock.fontSize = 30
            lock.position = CGPoint(x: 0, y: 0)
            lock.alpha = 0.5
            container.addChild(lock)
        }
        
        // Add tap detection
        container.userData = ["badge": badge, "earned": isEarned]
        
        return container
    }
    
    private func createBadgeIcon(type: String, color: SKColor, scale: CGFloat = 1.0) -> SKNode {
        let icon = SKNode()
        
        switch type {
        case "shield":
            let shieldPath = CGMutablePath()
            shieldPath.move(to: CGPoint(x: 0, y: 20))
            shieldPath.addCurve(to: CGPoint(x: -15, y: 10),
                               control1: CGPoint(x: -10, y: 20),
                               control2: CGPoint(x: -15, y: 15))
            shieldPath.addLine(to: CGPoint(x: -15, y: -5))
            shieldPath.addCurve(to: CGPoint(x: 0, y: -20),
                               control1: CGPoint(x: -15, y: -15),
                               control2: CGPoint(x: -8, y: -20))
            shieldPath.addCurve(to: CGPoint(x: 15, y: -5),
                               control1: CGPoint(x: 8, y: -20),
                               control2: CGPoint(x: 15, y: -15))
            shieldPath.addLine(to: CGPoint(x: 15, y: 10))
            shieldPath.addCurve(to: CGPoint(x: 0, y: 20),
                               control1: CGPoint(x: 15, y: 15),
                               control2: CGPoint(x: 10, y: 20))
            shieldPath.closeSubpath()
            
            let shield = SKShapeNode(path: shieldPath)
            shield.fillColor = color
            shield.strokeColor = .clear
            icon.addChild(shield)
            
        case "sword":
            let swordPath = CGMutablePath()
            swordPath.move(to: CGPoint(x: 0, y: 25))
            swordPath.addLine(to: CGPoint(x: -3, y: -15))
            swordPath.addLine(to: CGPoint(x: 0, y: -20))
            swordPath.addLine(to: CGPoint(x: 3, y: -15))
            swordPath.closeSubpath()
            
            let sword = SKShapeNode(path: swordPath)
            sword.fillColor = color
            sword.strokeColor = .clear
            icon.addChild(sword)
            
            let crossguard = SKShapeNode(rectOf: CGSize(width: 20, height: 4))
            crossguard.position = CGPoint(x: 0, y: -15)
            crossguard.fillColor = color
            crossguard.strokeColor = .clear
            icon.addChild(crossguard)
            
        case "earth":
            let earth = SKShapeNode(circleOfRadius: 18)
            earth.fillColor = color
            earth.strokeColor = .clear
            icon.addChild(earth)
            
            // Add continents
            for _ in 0..<3 {
                let continent = SKShapeNode(ellipseOf: CGSize(
                    width: CGFloat.random(in: 8...12),
                    height: CGFloat.random(in: 5...8)
                ))
                continent.position = CGPoint(
                    x: CGFloat.random(in: -8...8),
                    y: CGFloat.random(in: -8...8)
                )
                continent.fillColor = color.withAlphaComponent(0.3)
                continent.strokeColor = .clear
                earth.addChild(continent)
            }
            
        case "star":
            let starPath = CGMutablePath()
            for i in 0..<5 {
                let angle = CGFloat(i) * (2 * .pi / 5) - .pi / 2
                let outerRadius: CGFloat = 20
                let innerRadius: CGFloat = 10
                
                let outerPoint = CGPoint(x: cos(angle) * outerRadius, y: sin(angle) * outerRadius)
                let innerAngle = angle + .pi / 5
                let innerPoint = CGPoint(x: cos(innerAngle) * innerRadius, y: sin(innerAngle) * innerRadius)
                
                if i == 0 {
                    starPath.move(to: outerPoint)
                } else {
                    starPath.addLine(to: outerPoint)
                }
                starPath.addLine(to: innerPoint)
            }
            starPath.closeSubpath()
            
            let star = SKShapeNode(path: starPath)
            star.fillColor = color
            star.strokeColor = .clear
            icon.addChild(star)
            
        case "tower":
            let towerPath = CGMutablePath()
            towerPath.move(to: CGPoint(x: -8, y: -20))
            towerPath.addLine(to: CGPoint(x: -8, y: 15))
            towerPath.addLine(to: CGPoint(x: -12, y: 15))
            towerPath.addLine(to: CGPoint(x: -12, y: 20))
            towerPath.addLine(to: CGPoint(x: -4, y: 20))
            towerPath.addLine(to: CGPoint(x: -4, y: 15))
            towerPath.addLine(to: CGPoint(x: 4, y: 15))
            towerPath.addLine(to: CGPoint(x: 4, y: 20))
            towerPath.addLine(to: CGPoint(x: 12, y: 20))
            towerPath.addLine(to: CGPoint(x: 12, y: 15))
            towerPath.addLine(to: CGPoint(x: 8, y: 15))
            towerPath.addLine(to: CGPoint(x: 8, y: -20))
            towerPath.closeSubpath()
            
            let tower = SKShapeNode(path: towerPath)
            tower.fillColor = color
            tower.strokeColor = .clear
            icon.addChild(tower)
            
        case "coin":
            let coin = SKShapeNode(circleOfRadius: 18)
            coin.fillColor = color
            coin.strokeColor = color.withAlphaComponent(0.5)
            coin.lineWidth = 2
            icon.addChild(coin)
            
            let dollar = SKLabelNode(text: "$")
            dollar.fontSize = 24
            dollar.fontName = "AvenirNext-Bold"
            dollar.fontColor = color.withAlphaComponent(0.3)
            dollar.position = CGPoint(x: 0, y: -8)
            coin.addChild(dollar)
            
        default:
            let defaultIcon = SKShapeNode(circleOfRadius: 15)
            defaultIcon.fillColor = color
            defaultIcon.strokeColor = .clear
            icon.addChild(defaultIcon)
        }
        
        icon.setScale(scale)
        return icon
    }
    
    private func isBadgeEarned(_ badge: Badge) -> Bool {
        return UserDefaults.standard.bool(forKey: badge.id)
    }
    
    private func countEarnedBadges() -> Int {
        return allBadges.filter { isBadgeEarned($0) }.count
    }
    
    private func createBackButton() {
        let backButton = SKNode()
        backButton.name = "backButton"
        backButton.position = CGPoint(x: -size.width/2 + 80, y: size.height/2 - 60)
        
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 20)
        buttonBg.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.8)
        buttonBg.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)
        buttonBg.lineWidth = 2
        buttonBg.glowWidth = 3
        backButton.addChild(buttonBg)
        
        let backLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backLabel.text = "BACK"
        backLabel.fontSize = 18
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        uiLayer.addChild(backButton)
    }
    
    private func animateEntrance() {
        // Animate UI entrance
        uiLayer.alpha = 0
        uiLayer.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                // Return to main menu
                let transition = SKTransition.fade(withDuration: 0.5)
                let mainMenu = MainMenuScene(size: size)
                view?.presentScene(mainMenu, transition: transition)
                return
            }
            
            // Check if a badge was tapped
            if let badgeData = node.userData?["badge"] as? Badge,
               let isEarned = node.userData?["earned"] as? Bool {
                showBadgeDetails(badge: badgeData, isEarned: isEarned)
            } else if let badgeData = node.parent?.userData?["badge"] as? Badge,
                      let isEarned = node.parent?.userData?["earned"] as? Bool {
                showBadgeDetails(badge: badgeData, isEarned: isEarned)
            }
        }
    }
    
    private func showBadgeDetails(badge: Badge, isEarned: Bool) {
        // Create detail popup
        let detailContainer = SKNode()
        detailContainer.name = "badgeDetail"
        detailContainer.position = CGPoint.zero
        detailContainer.zPosition = 100
        
        // Darken background
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.7)
        overlay.strokeColor = .clear
        overlay.name = "detailOverlay"
        detailContainer.addChild(overlay)
        
        // Detail panel
        let panel = SKShapeNode(rectOf: CGSize(width: 500, height: 300), cornerRadius: 20)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95)
        panel.strokeColor = badge.color
        panel.lineWidth = 3
        panel.glowWidth = 10
        detailContainer.addChild(panel)
        
        // Badge icon
        let iconNode = createBadgeIcon(type: badge.icon, color: badge.glowColor, scale: 2.0)
        iconNode.position = CGPoint(x: -150, y: 50)
        panel.addChild(iconNode)
        
        // Badge name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        nameLabel.text = badge.name
        nameLabel.fontSize = 32
        nameLabel.fontColor = badge.glowColor
        nameLabel.position = CGPoint(x: 50, y: 80)
        panel.addChild(nameLabel)
        
        // Status
        let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statusLabel.text = isEarned ? "✓ EARNED" : "🔒 LOCKED"
        statusLabel.fontSize = 20
        statusLabel.fontColor = isEarned ? SKColor.green : SKColor.gray
        statusLabel.position = CGPoint(x: 50, y: 40)
        panel.addChild(statusLabel)
        
        // Description
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = badge.description
        descLabel.fontSize = 18
        descLabel.fontColor = .white
        descLabel.position = CGPoint(x: 0, y: -20)
        panel.addChild(descLabel)
        
        // Requirement
        let reqLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        reqLabel.text = "Requirement: \(badge.requirement)"
        reqLabel.fontSize = 14
        reqLabel.fontColor = SKColor.gray
        reqLabel.position = CGPoint(x: 0, y: -60)
        panel.addChild(reqLabel)
        
        // Close button
        let closeButton = SKLabelNode(text: "✕")
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        closeButton.position = CGPoint(x: 220, y: 120)
        closeButton.name = "closeDetail"
        panel.addChild(closeButton)
        
        // Animate in
        detailContainer.alpha = 0
        detailContainer.setScale(0.8)
        addChild(detailContainer)
        
        detailContainer.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "closeDetail" || node.name == "detailOverlay" {
                // Close detail view
                if let detailNode = childNode(withName: "badgeDetail") {
                    detailNode.run(SKAction.sequence([
                        SKAction.group([
                            SKAction.fadeOut(withDuration: 0.2),
                            SKAction.scale(to: 0.8, duration: 0.2)
                        ]),
                        SKAction.removeFromParent()
                    ]))
                }
                return
            }
        }
    }
}