# 🔧 Space Salvagers - Technical Specification (Swift/iOS)

## 📱 Platform & Technology Stack

### Core Requirements
- **Language**: Swift 5.9+
- **Minimum iOS**: iOS 15.0
- **Target Devices**: iPhone 8 and newer, iPad (7th gen+)
- **IDE**: Xcode 15.0+
- **Architecture**: MVVM-C (Model-View-ViewModel-Coordinator)
- **Rendering**: Metal 3 with fallback to Metal 2

### Primary Frameworks
```swift
// Core Frameworks
import SpriteKit       // 2D game engine
import GameplayKit     // AI, pathfinding, state machines
import Metal           // GPU rendering
import MetalKit        // Metal helpers
import simd            // Vector math

// Audio & Haptics
import AVFoundation    // Audio playback
import CoreHaptics     // Haptic feedback

// Platform Services  
import GameController  // Controller support
import CloudKit        // Cloud saves
import StoreKit        // IAP
import os.log          // Logging
```

---

## 🏗️ Architecture Overview

### Project Structure
```
SpaceSalvagers/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/
│   ├── Engine/
│   │   ├── GameEngine.swift
│   │   ├── RenderPipeline.swift
│   │   └── PhysicsEngine.swift
│   ├── Systems/
│   │   ├── EntityComponentSystem.swift
│   │   ├── InputSystem.swift
│   │   └── AudioSystem.swift
│   └── Utilities/
│       ├── Math/
│       ├── Extensions/
│       └── Helpers/
├── Game/
│   ├── Entities/
│   │   ├── Tower/
│   │   ├── Enemy/
│   │   └── Projectile/
│   ├── Components/
│   │   ├── HealthComponent.swift
│   │   ├── MovementComponent.swift
│   │   └── TargetingComponent.swift
│   ├── Systems/
│   │   ├── WaveSystem.swift
│   │   ├── EconomySystem.swift
│   │   └── CombatSystem.swift
│   └── Scenes/
│       ├── GameScene.swift
│       ├── MenuScene.swift
│       └── MetaProgressionScene.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Shaders/
│   ├── Particles/
│   └── Audio/
├── Data/
│   ├── Models/
│   ├── Persistence/
│   └── Configuration/
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── PerformanceTests/
```

---

## 🎮 Core Systems Implementation

### 1. Entity Component System (ECS)

```swift
// Base Entity Protocol
protocol Entity: AnyObject {
    var id: UUID { get }
    var components: [Component] { get set }
    func component<T: Component>(ofType type: T.Type) -> T?
}

// Base Component Protocol
protocol Component: AnyObject {
    var entity: Entity? { get set }
    func update(deltaTime: TimeInterval)
}

// Component Examples
class TransformComponent: Component {
    var position: SIMD2<Float>
    var rotation: Float
    var scale: SIMD2<Float>
}

class HealthComponent: Component {
    var currentHealth: Float
    var maxHealth: Float
    var armor: Float
    var shields: Float?
}

// System Protocol
protocol System {
    func update(deltaTime: TimeInterval, entities: [Entity])
}
```

### 2. Rendering Pipeline (SpriteKit + Metal)

```swift
class RenderingSystem {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState
    
    // Shader Configuration
    struct ShaderUniforms {
        var projectionMatrix: float4x4
        var viewMatrix: float4x4
        var time: Float
    }
    
    // Render Layers
    enum RenderLayer: Int {
        case background = 0
        case gameplayBack = 100
        case gameplay = 200
        case gameplayFront = 300
        case effects = 400
        case ui = 500
    }
    
    // Batch Rendering for Performance
    class SpriteBatcher {
        private var vertices: [Vertex] = []
        private var indices: [UInt16] = []
        private let maxSprites = 10000
        
        func addSprite(_ sprite: Sprite) {
            // Batch sprite vertices
        }
        
        func flush(encoder: MTLRenderCommandEncoder) {
            // Submit batched draw call
        }
    }
}
```

### 3. Game Scene Management

```swift
class GameScene: SKScene {
    // Core Systems
    private var waveManager: WaveManager!
    private var towerManager: TowerManager!
    private var enemyManager: EnemyManager!
    private var economySystem: EconomySystem!
    private var particleSystem: ParticleSystem!
    
    // Game State
    private var gameState: GameState = .preparing
    private var currentWave: Int = 0
    private var stationHealth: Float = 20.0
    
    // Node Hierarchy
    private var worldNode: SKNode!
    private var enemyLayer: SKNode!
    private var towerLayer: SKNode!
    private var projectileLayer: SKNode!
    private var effectsLayer: SKNode!
    private var uiLayer: SKNode!
    
    override func didMove(to view: SKView) {
        setupLayers()
        setupSystems()
        setupGestures()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        
        // Update all systems
        waveManager.update(deltaTime)
        towerManager.update(deltaTime)
        enemyManager.update(deltaTime)
        particleSystem.update(deltaTime)
        
        // Check win/lose conditions
        checkGameState()
    }
}
```

---

## 🗼 Tower System

```swift
// Tower Base Class
class Tower: SKSpriteNode {
    // Properties
    var level: Int = 1
    var targetingMode: TargetingMode = .nearest
    var range: Float
    var damage: Float
    var fireRate: Float
    var lastFireTime: TimeInterval = 0
    
    // Components
    private var targetingComponent: TargetingComponent!
    private var weaponComponent: WeaponComponent!
    
    // Targeting System
    enum TargetingMode {
        case nearest
        case strongest
        case weakest
        case first
        case last
    }
    
    func update(deltaTime: TimeInterval, enemies: [Enemy]) {
        // Find target
        guard let target = targetingComponent.selectTarget(
            from: enemies,
            mode: targetingMode,
            range: range
        ) else { return }
        
        // Fire if ready
        if canFire(currentTime: CACurrentMediaTime()) {
            weaponComponent.fire(at: target)
            lastFireTime = CACurrentMediaTime()
        }
    }
    
    func upgrade() {
        guard level < 3 else { return }
        level += 1
        applyUpgradeStats()
    }
}

// Specific Tower Implementations
class LaserTower: Tower {
    private var beamEffect: SKShapeNode?
    
    override init() {
        super.init()
        setupLaserProperties()
    }
    
    private func createBeamEffect(to target: Enemy) {
        // Create continuous beam visual
        let beam = SKShapeNode()
        beam.path = CGPath.line(from: position, to: target.position)
        beam.strokeColor = .red
        beam.glowWidth = 2.0
        beam.zPosition = RenderLayer.effects.rawValue
        parent?.addChild(beam)
        
        // Apply damage over time
        target.takeDamage(damage * fireRate)
    }
}

class GravityWellTower: Tower {
    private var fieldNode: SKFieldNode?
    private var affectedEnemies: Set<Enemy> = []
    
    override func update(deltaTime: TimeInterval, enemies: [Enemy]) {
        // Apply slow effect to enemies in range
        for enemy in enemies {
            let distance = simd_distance(position.simd, enemy.position.simd)
            if distance <= range {
                enemy.applySlowEffect(0.35, duration: 0.75)
            }
        }
    }
}
```

---

## 👾 Enemy System

```swift
class Enemy: SKSpriteNode {
    // Properties
    var health: Float
    var maxHealth: Float
    var speed: Float
    var armor: Float = 0
    var salvageValue: Int
    var coreDamage: Int
    
    // Components
    private var pathFollower: PathFollowComponent!
    private var healthBar: HealthBarNode!
    
    // Status Effects
    private var statusEffects: [StatusEffect] = []
    
    func update(deltaTime: TimeInterval) {
        // Move along path
        pathFollower.update(deltaTime)
        
        // Update status effects
        statusEffects.forEach { $0.update(deltaTime) }
        statusEffects.removeAll { $0.isExpired }
        
        // Update health bar
        healthBar.setProgress(health / maxHealth)
    }
    
    func takeDamage(_ damage: Float) {
        let actualDamage = damage * (1.0 - armor)
        health -= actualDamage
        
        // Show damage number
        showDamageNumber(actualDamage)
        
        if health <= 0 {
            die()
        }
    }
    
    func applyStatusEffect(_ effect: StatusEffect) {
        statusEffects.append(effect)
    }
}

// Enemy Variants
class AlienSwarmer: Enemy {
    override init() {
        super.init()
        health = 40
        speed = 2.0
        salvageValue = 6
        
        // Pack bonus implementation
        updatePackBonus()
    }
    
    private func updatePackBonus() {
        let nearbySwarmers = parent?.children.compactMap { $0 as? AlienSwarmer }
            .filter { simd_distance(position.simd, $0.position.simd) < 100 }
        
        let bonus = Float(nearbySwarmers?.count ?? 0) / 5.0 * 0.05
        speed = 2.0 * (1.0 + bonus)
    }
}

class BioTitan: Enemy {
    override func die() {
        // Spawn swarmers on death
        for i in 0..<6 {
            let swarmer = AlienSwarmer()
            let angle = Float(i) * .pi / 3.0
            let offset = SIMD2<Float>(cos(angle), sin(angle)) * 50
            swarmer.position = CGPoint(x: position.x + CGFloat(offset.x),
                                      y: position.y + CGFloat(offset.y))
            parent?.addChild(swarmer)
        }
        super.die()
    }
}
```

---

## 🌊 Wave Management

```swift
class WaveManager {
    // Wave Configuration
    struct WaveConfig: Codable {
        let waveNumber: Int
        let enemyComposition: [EnemySpawn]
        let spawnInterval: TimeInterval
        let waveDuration: TimeInterval
    }
    
    struct EnemySpawn: Codable {
        let enemyType: EnemyType
        let count: Int
        let spawnPoint: Int
    }
    
    // Deterministic RNG
    private var rng: SeededRandomNumberGenerator
    
    // Wave State
    private var currentWave: Int = 0
    private var spawnQueue: [EnemySpawn] = []
    private var waveTimer: TimeInterval = 0
    
    func startWave(_ waveNumber: Int) {
        currentWave = waveNumber
        let budget = calculateBudget(for: waveNumber)
        let composition = generateComposition(budget: budget)
        spawnQueue = composition
    }
    
    private func calculateBudget(for wave: Int) -> Int {
        return 60 + 10 * wave
    }
    
    func update(deltaTime: TimeInterval) {
        waveTimer += deltaTime
        
        // Process spawn queue
        if !spawnQueue.isEmpty && waveTimer >= nextSpawnTime {
            spawnNextEnemy()
        }
    }
}
```

---

## 💾 Data & Persistence

```swift
// Data Models
struct TowerData: Codable {
    let id: String
    let baseCost: Int
    let baseStats: TowerStats
    let upgrades: [UpgradeData]
}

struct EnemyData: Codable {
    let id: String
    let health: Float
    let speed: Float
    let armor: Float
    let salvageValue: Int
}

// Persistence Manager
class PersistenceManager {
    private let userDefaults = UserDefaults.standard
    private let cloudKit = CKContainer.default()
    
    // Save Game State
    func saveGameState(_ state: GameState) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        
        // Local save
        userDefaults.set(data, forKey: "gameState")
        
        // Cloud save
        let record = CKRecord(recordType: "GameState")
        record["data"] = data
        try await cloudKit.privateCloudDatabase.save(record)
    }
    
    // Configuration Loading
    func loadTowerConfigs() -> [TowerData] {
        guard let url = Bundle.main.url(forResource: "towers", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        
        return (try? JSONDecoder().decode([TowerData].self, from: data)) ?? []
    }
}
```

---

## 🎨 Particle & Effects System

```swift
class ParticleSystem {
    private var emitters: [ParticleEmitter] = []
    private let particlePool: ObjectPool<Particle>
    
    // Particle Effects
    enum EffectType {
        case explosion(size: CGSize, color: UIColor)
        case beam(start: CGPoint, end: CGPoint)
        case impact(position: CGPoint)
        case death(enemyType: EnemyType)
    }
    
    func createEffect(_ type: EffectType, at position: CGPoint) {
        switch type {
        case .explosion(let size, let color):
            createExplosion(at: position, size: size, color: color)
        case .beam(let start, let end):
            createBeam(from: start, to: end)
        case .impact:
            createImpact(at: position)
        case .death(let enemyType):
            createDeathEffect(for: enemyType, at: position)
        }
    }
    
    private func createExplosion(at position: CGPoint, size: CGSize, color: UIColor) {
        guard let emitter = SKEmitterNode(fileNamed: "Explosion") else { return }
        emitter.position = position
        emitter.particleColor = color
        emitter.particleScale = size.width / 100
        scene?.addChild(emitter)
        
        // Auto-remove after duration
        emitter.run(.sequence([
            .wait(forDuration: emitter.particleLifetime),
            .removeFromParent()
        ]))
    }
}
```

---

## 🔊 Audio System

```swift
class AudioSystem {
    private var audioEngine: AVAudioEngine
    private var musicPlayer: AVAudioPlayerNode
    private var sfxPlayers: [AVAudioPlayerNode] = []
    
    // Audio Layers
    private var ambientMusicNode: AVAudioPlayerNode
    private var combatMusicNode: AVAudioPlayerNode
    private var bossMusicNode: AVAudioPlayerNode
    
    // Sound Bank
    private var soundBuffers: [String: AVAudioPCMBuffer] = [:]
    
    // Dynamic Music System
    func updateMusicIntensity(combatIntensity: Float) {
        // Crossfade between music layers
        ambientMusicNode.volume = 1.0 - combatIntensity
        combatMusicNode.volume = combatIntensity
    }
    
    func playSFX(_ soundName: String, at position: CGPoint? = nil) {
        guard let buffer = soundBuffers[soundName] else { return }
        
        let player = getAvailableSFXPlayer()
        
        // 3D positioning if position provided
        if let position = position {
            apply3DPosition(to: player, position: position)
        }
        
        player.scheduleBuffer(buffer, completionHandler: nil)
        player.play()
    }
    
    private func apply3DPosition(to player: AVAudioPlayerNode, position: CGPoint) {
        // Calculate pan and volume based on position
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width / 2,
                                  y: UIScreen.main.bounds.height / 2)
        let pan = Float((position.x - screenCenter.x) / screenCenter.x)
        player.pan = max(-1, min(1, pan))
    }
}
```

---

## 📱 Input Handling

```swift
class InputSystem {
    // Gesture Recognizers
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    
    // Touch Handling
    func handleTouches(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: scene)
        
        // Check for UI elements first
        if let node = scene.nodes(at: location).first(where: { $0 is UINode }) {
            handleUITouch(node, at: location)
            return
        }
        
        // Check for tower placement nodes
        if let buildNode = scene.nodes(at: location).first(where: { $0 is BuildNode }) {
            handleBuildNodeTouch(buildNode as! BuildNode)
            return
        }
        
        // Check for tower selection
        if let tower = scene.nodes(at: location).first(where: { $0 is Tower }) {
            handleTowerSelection(tower as! Tower)
        }
    }
    
    // Haptic Feedback
    private let hapticEngine = CHHapticEngine()
    
    func triggerHaptic(_ type: HapticType) {
        switch type {
        case .selection:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .success:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        case .error:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
        }
    }
}
```

---

## 🧪 Testing Strategy

```swift
// Unit Test Example
class TowerSystemTests: XCTestCase {
    func testLaserTowerTargeting() {
        // Arrange
        let tower = LaserTower()
        tower.targetingMode = .nearest
        let enemies = createTestEnemies()
        
        // Act
        let target = tower.selectTarget(from: enemies)
        
        // Assert
        XCTAssertEqual(target, enemies[0])
    }
    
    func testDeterministicWaveGeneration() {
        // Arrange
        let seed: UInt64 = 12345
        let manager1 = WaveManager(seed: seed)
        let manager2 = WaveManager(seed: seed)
        
        // Act
        let wave1 = manager1.generateWave(1)
        let wave2 = manager2.generateWave(1)
        
        // Assert
        XCTAssertEqual(wave1, wave2)
    }
}

// Performance Test
class PerformanceTests: XCTestCase {
    func testEnemySystemWith200Enemies() {
        measure {
            let enemies = (0..<200).map { _ in AlienSwarmer() }
            let deltaTime: TimeInterval = 1.0/60.0
            
            for _ in 0..<60 {
                enemies.forEach { $0.update(deltaTime) }
            }
        }
    }
}
```

---

## 📊 Performance Optimization

### Memory Management
```swift
// Object Pooling
class ObjectPool<T: AnyObject> {
    private var available: [T] = []
    private var inUse: Set<T> = []
    private let createObject: () -> T
    
    func acquire() -> T {
        if let obj = available.popLast() {
            inUse.insert(obj)
            return obj
        } else {
            let obj = createObject()
            inUse.insert(obj)
            return obj
        }
    }
    
    func release(_ obj: T) {
        inUse.remove(obj)
        available.append(obj)
    }
}

// Texture Atlas Management
class TextureManager {
    private var atlases: [String: SKTextureAtlas] = [:]
    
    func preloadTextures() async {
        let atlasNames = ["towers", "enemies", "effects", "ui"]
        
        await withTaskGroup(of: Void.self) { group in
            for name in atlasNames {
                group.addTask {
                    let atlas = SKTextureAtlas(named: name)
                    atlas.preload {}
                    self.atlases[name] = atlas
                }
            }
        }
    }
}
```

### Rendering Optimization
```swift
// Batch Rendering
extension SKScene {
    func enableBatchRendering() {
        view?.ignoresSiblingOrder = true
        view?.showsNodeCount = true // Debug only
        view?.showsFPS = true // Debug only
    }
}

// LOD System
enum DetailLevel: Int {
    case high = 0
    case medium = 1
    case low = 2
    
    static var current: DetailLevel {
        // Determine based on device capabilities
        if ProcessInfo.processInfo.processorCount >= 6 {
            return .high
        } else if ProcessInfo.processInfo.processorCount >= 4 {
            return .medium
        } else {
            return .low
        }
    }
}
```

---

## 🔐 Security & Privacy

```swift
// Data Protection
extension PersistenceManager {
    func encryptSaveData(_ data: Data) -> Data {
        // Use CryptoKit for encryption
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try! AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
}

// Privacy
class AnalyticsManager {
    func trackEvent(_ event: String, parameters: [String: Any]? = nil) {
        // Only track if user consented
        guard UserDefaults.standard.bool(forKey: "analyticsConsent") else { return }
        
        // Sanitize data before sending
        let sanitized = parameters?.filter { !$0.key.contains("personal") }
        
        // Send to analytics service
    }
}
```

---

## 📦 Build Configuration

### Build Settings
```yaml
# Development
DEBUG_INFORMATION_FORMAT: dwarf-with-dsym
SWIFT_OPTIMIZATION_LEVEL: -Onone
ENABLE_TESTABILITY: YES

# Release
SWIFT_OPTIMIZATION_LEVEL: -O
ENABLE_BITCODE: YES
STRIP_SWIFT_SYMBOLS: YES

# Performance
METAL_ENABLE_DEBUG_INFO: NO
ASSETCATALOG_COMPILER_OPTIMIZATION: space
```

### Dependencies (Swift Package Manager)
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0")
]
```

---

## 🚀 Deployment Pipeline

### CI/CD Configuration
```yaml
# .github/workflows/ios.yml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build
      run: xcodebuild build -scheme SpaceSalvagers
    - name: Test
      run: xcodebuild test -scheme SpaceSalvagers
    - name: Performance Tests
      run: xcodebuild test -scheme PerformanceTests
```

---

## 📋 Technical Milestones

### Phase 1: Foundation (Weeks 1-2)
- [ ] Project setup with all frameworks
- [ ] ECS architecture implementation
- [ ] Basic rendering pipeline
- [ ] Input system

### Phase 2: Core Gameplay (Weeks 3-6)
- [ ] Tower system with all 4 types
- [ ] Enemy system with all 4 types
- [ ] Wave management
- [ ] Combat calculations

### Phase 3: Polish (Weeks 7-9)
- [ ] Particle effects
- [ ] Audio implementation
- [ ] UI/HUD complete
- [ ] Performance optimization

### Phase 4: Platform Features (Weeks 10-12)
- [ ] CloudKit integration
- [ ] StoreKit implementation
- [ ] Analytics
- [ ] TestFlight deployment

---

*This technical specification provides a complete Swift/iOS native implementation blueprint for Space Salvagers, optimized for performance and following Apple's best practices.*