import SpriteKit

class SettingsScene: SKScene {
    
    // UI Elements
    private var backButton: SKShapeNode!
    private var titleLabel: SKLabelNode!
    
    // Sound Controls
    private var soundEffectsToggle: SKShapeNode!
    private var soundEffectsLabel: SKLabelNode!
    private var soundVolumeSlider: SKNode!
    private var soundVolumeLabel: SKLabelNode!
    
    // Music Controls
    private var musicToggle: SKShapeNode!
    private var musicLabel: SKLabelNode!
    private var musicVolumeSlider: SKNode!
    private var musicVolumeLabel: SKLabelNode!
    
    // Background layers
    private var backgroundLayer: SKNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        
        setupBackground()
        createTitle()
        createSoundControls()
        // Music controls removed - only effect sounds
        createBackButton()
    }
    
    private func setupBackground() {
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -10
        addChild(backgroundLayer)
        
        // Add stars
        for _ in 0..<100 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.8)
            star.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            star.zPosition = -20
            
            // Twinkle animation
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
            star.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
            
            backgroundLayer.addChild(star)
        }
    }
    
    private func createTitle() {
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "SETTINGS"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height * 0.35)
        titleLabel.zPosition = 100
        
        // Add glow effect
        let glow = SKLabelNode(fontNamed: "Helvetica-Bold")
        glow.text = "SETTINGS"
        glow.fontSize = 48
        glow.fontColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4)
        glow.position = .zero
        glow.blendMode = .add
        glow.setScale(1.02)
        titleLabel.addChild(glow)
        
        addChild(titleLabel)
    }
    
    private func createSoundControls() {
        // Sound Effects Label
        soundEffectsLabel = SKLabelNode(fontNamed: "Helvetica")
        soundEffectsLabel.text = "Sound Effects"
        soundEffectsLabel.fontSize = 24
        soundEffectsLabel.fontColor = .white
        soundEffectsLabel.position = CGPoint(x: -size.width * 0.25, y: size.height * 0.15)
        soundEffectsLabel.horizontalAlignmentMode = .left
        addChild(soundEffectsLabel)
        
        // Sound Effects Toggle
        soundEffectsToggle = createToggleButton(
            isOn: SoundManager.shared.soundEnabled,
            position: CGPoint(x: size.width * 0.25, y: size.height * 0.15)
        )
        soundEffectsToggle.name = "soundToggle"
        addChild(soundEffectsToggle)
        
        // Sound Volume Label
        soundVolumeLabel = SKLabelNode(fontNamed: "Helvetica")
        soundVolumeLabel.text = "Sound Volume"
        soundVolumeLabel.fontSize = 20
        soundVolumeLabel.fontColor = SKColor.lightGray
        soundVolumeLabel.position = CGPoint(x: -size.width * 0.25, y: size.height * 0.05)
        soundVolumeLabel.horizontalAlignmentMode = .left
        addChild(soundVolumeLabel)
        
        // Sound Volume Slider
        soundVolumeSlider = createSlider(
            value: CGFloat(SoundManager.shared.soundVolume),
            position: CGPoint(x: 0, y: size.height * 0.05)
        )
        soundVolumeSlider.name = "soundVolumeSlider"
        addChild(soundVolumeSlider)
        
        // Volume percentage
        let soundVolumePercent = SKLabelNode(fontNamed: "Helvetica")
        soundVolumePercent.name = "soundVolumePercent"
        soundVolumePercent.text = "\(Int(SoundManager.shared.soundVolume * 100))%"
        soundVolumePercent.fontSize = 20
        soundVolumePercent.fontColor = .cyan
        soundVolumePercent.position = CGPoint(x: size.width * 0.3, y: size.height * 0.05)
        soundVolumePercent.horizontalAlignmentMode = .left
        addChild(soundVolumePercent)
    }
    
    // Music controls removed - only effect sounds
    
    private func createToggleButton(isOn: Bool, position: CGPoint) -> SKShapeNode {
        let toggle = SKShapeNode(rectOf: CGSize(width: 80, height: 40), cornerRadius: 20)
        toggle.position = position
        toggle.fillColor = isOn ? SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0) : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        toggle.strokeColor = isOn ? .green : .darkGray
        toggle.lineWidth = 2
        
        // Toggle knob
        let knob = SKShapeNode(circleOfRadius: 15)
        knob.name = "knob"
        knob.fillColor = .white
        knob.strokeColor = .clear
        knob.position = CGPoint(x: isOn ? 20 : -20, y: 0)
        toggle.addChild(knob)
        
        // ON/OFF label
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.name = "label"
        label.text = isOn ? "ON" : "OFF"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: isOn ? -20 : 20, y: 0)
        toggle.addChild(label)
        
        return toggle
    }
    
    private func createSlider(value: CGFloat, position: CGPoint) -> SKNode {
        let slider = SKNode()
        slider.position = position
        
        // Slider track
        let track = SKShapeNode(rectOf: CGSize(width: 200, height: 4), cornerRadius: 2)
        track.fillColor = SKColor.darkGray
        track.strokeColor = .clear
        slider.addChild(track)
        
        // Filled track
        let filledWidth = 200 * value
        let filledTrack = SKShapeNode(rectOf: CGSize(width: filledWidth, height: 4), cornerRadius: 2)
        filledTrack.name = "filled"
        filledTrack.fillColor = .cyan
        filledTrack.strokeColor = .clear
        filledTrack.position = CGPoint(x: -100 + filledWidth/2, y: 0)
        slider.addChild(filledTrack)
        
        // Slider handle
        let handle = SKShapeNode(circleOfRadius: 12)
        handle.name = "handle"
        handle.fillColor = .white
        handle.strokeColor = .cyan
        handle.lineWidth = 2
        handle.position = CGPoint(x: -100 + (200 * value), y: 0)
        slider.addChild(handle)
        
        return slider
    }
    
    private func createBackButton() {
        backButton = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 10)
        backButton.position = CGPoint(x: 0, y: -size.height * 0.35)
        backButton.strokeColor = .cyan
        backButton.lineWidth = 2
        backButton.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.3)
        backButton.name = "backButton"
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "BACK"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        backButton.addChild(label)
        
        addChild(backButton)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                SoundManager.shared.playSound(.buttonTap)
                animateButtonPress(backButton) {
                    self.goBack()
                }
            } else if node.name == "soundToggle" || node.parent?.name == "soundToggle" {
                toggleSound()
            } else if node.name == "musicToggle" || node.parent?.name == "musicToggle" {
                toggleMusic()
            } else if let slider = findSliderParent(node: node) {
                startDraggingSlider(slider, at: location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let slider = currentDraggingSlider {
            updateSliderPosition(slider, at: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentDraggingSlider = nil
    }
    
    private var currentDraggingSlider: SKNode?
    
    private func findSliderParent(node: SKNode) -> SKNode? {
        if node.name == "soundVolumeSlider" {
            return node
        }
        if let parent = node.parent {
            if parent.name == "soundVolumeSlider" {
                return parent
            }
        }
        return nil
    }
    
    private func startDraggingSlider(_ slider: SKNode, at location: CGPoint) {
        currentDraggingSlider = slider
        updateSliderPosition(slider, at: location)
    }
    
    private func updateSliderPosition(_ slider: SKNode, at location: CGPoint) {
        let sliderLocation = slider.convert(location, from: self)
        
        // Clamp x position between -100 and 100
        let clampedX = max(-100, min(100, sliderLocation.x))
        
        // Update handle position
        if let handle = slider.childNode(withName: "handle") {
            handle.position = CGPoint(x: clampedX, y: 0)
        }
        
        // Update filled track
        let value = (clampedX + 100) / 200
        if let filled = slider.childNode(withName: "filled") as? SKShapeNode {
            let filledWidth = 200 * value
            filled.removeFromParent()
            let newFilled = SKShapeNode(rectOf: CGSize(width: filledWidth, height: 4), cornerRadius: 2)
            newFilled.name = "filled"
            newFilled.fillColor = .cyan
            newFilled.strokeColor = .clear
            newFilled.position = CGPoint(x: -100 + filledWidth/2, y: 0)
            slider.addChild(newFilled)
        }
        
        // Update volume
        if slider.name == "soundVolumeSlider" {
            SoundManager.shared.soundVolume = Float(value)
            if let label = childNode(withName: "soundVolumePercent") as? SKLabelNode {
                label.text = "\(Int(value * 100))%"
            }
            // Play a test sound
            SoundManager.shared.playSound(.buttonTap)
        }
        // Music volume slider removed
    }
    
    private func toggleSound() {
        SoundManager.shared.soundEnabled = !SoundManager.shared.soundEnabled
        updateToggleButton(soundEffectsToggle, isOn: SoundManager.shared.soundEnabled)
        
        if SoundManager.shared.soundEnabled {
            SoundManager.shared.playSound(.buttonTap)
        }
    }
    
    private func toggleMusic() {
        SoundManager.shared.musicEnabled = !SoundManager.shared.musicEnabled
        updateToggleButton(musicToggle, isOn: SoundManager.shared.musicEnabled)
        
        SoundManager.shared.playSound(.buttonTap)
    }
    
    private func updateToggleButton(_ toggle: SKShapeNode, isOn: Bool) {
        // Update colors
        toggle.fillColor = isOn ? SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0) : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        toggle.strokeColor = isOn ? .green : .darkGray
        
        // Animate knob position
        if let knob = toggle.childNode(withName: "knob") {
            let moveAction = SKAction.moveTo(x: isOn ? 20 : -20, duration: 0.2)
            knob.run(moveAction)
        }
        
        // Update label
        if let label = toggle.childNode(withName: "label") as? SKLabelNode {
            label.text = isOn ? "ON" : "OFF"
            let moveAction = SKAction.moveTo(x: isOn ? -20 : 20, duration: 0.2)
            label.run(moveAction)
        }
    }
    
    private func animateButtonPress(_ button: SKShapeNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        button.run(sequence) {
            completion()
        }
    }
    
    private func goBack() {
        guard let view = self.view else { return }
        let menuScene = MainMenuScene(size: view.bounds.size)
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view.presentScene(menuScene, transition: transition)
    }
}