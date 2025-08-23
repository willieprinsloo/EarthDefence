# Space Salvagers - Tower Defense Game

A fast-paced sci-fi tower defense game built with SpriteKit for iOS/macOS. Defend your space station against waves of alien invaders using an arsenal of futuristic towers!

## 🚀 Quick Start

### Building the Game

```bash
# Clone the repository
git clone https://github.com/yourusername/space-salvagers.git
cd Tower-game

# Build using Xcode command line tools
xcodebuild -project SpaceSalvagers.xcodeproj -scheme SpaceSalvagers -sdk iphonesimulator build

# Or open in Xcode
open SpaceSalvagers.xcodeproj
# Then press Cmd+B to build and Cmd+R to run
```

### Requirements
- Xcode 14.0 or later
- iOS 15.0+ / macOS 12.0+
- Swift 5.0+

## 🎮 Game Features

### Core Gameplay
- **10 Unique Maps**: Each with different paths and challenges
- **Dynamic Wave System**: 3-5 waves per map based on difficulty
- **Strategic Tower Placement**: Limited build nodes require careful planning
- **Economy Management**: Tight salvage economy forces strategic decisions
- **Difficulty Progression**: Game gets progressively harder with each map

### Tower Types
1. **Machine Gun** (75 salvage)
   - Rapid-fire starter tower
   - Extremely fast fire rate (5 shots/sec)
   - 0.85 damage per shot (reduced 15%)
   - Best against swarms

2. **Cannon** (80 salvage)
   - Balanced damage tower
   - Moderate fire rate
   - Good all-around choice
   
3. **Laser** (120 salvage)
   - Powerful but slow charging (2.2s)
   - 5-11 damage based on level
   - Instant hit with visual beam
   - Charging effect before firing
   
4. **Plasma** (150 salvage)
   - Medium fire rate (1.2s)
   - Area damage on impact
   - Purple energy projectiles
   
5. **Missile** (200 salvage)
   - Homing projectiles
   - 2.0s fire rate
   - Targets furthest enemies
   
6. **Tesla** (160 salvage)
   - Chain lightning damage
   - Area effect
   - Targets weakest enemies

7. **EMP** (160 salvage)
   - Disables enemy shields
   - Slows enemies
   - Area of effect

8. **Gravity** (140 salvage)
   - Slows all enemies in range
   - No damage
   - Essential for late game

9. **Nanobot** (120 salvage)
   - Healing support tower
   - Repairs nearby towers
   - Boosts tower efficiency
   - Chain lightning damage
   - Area effect
   - Targets weakest enemies

### Enemy Types

#### Basic Enemies
1. **Scout** - Pink triangle, 2 HP, fast (1.2x), 4 salvage
2. **Fighter** - Orange diamond, 4 HP, normal speed, 9 salvage
3. **Bomber** - Purple hexagon, 10 HP, slow (0.8x), 11 salvage
4. **Swarm** - Cyan circle, 1 HP, very fast (2.5x), 5 salvage
5. **Shield** - Blue oval, 15 HP, slow (0.7x), 8 salvage
6. **Stealth** - Gray arrow, 3 HP, fast (1.4x), phases in/out, 7 salvage
7. **Armored** - Metal gray square, 20 HP, very slow (0.5x), 15 salvage
8. **Fast** - Yellow arrow, 2 HP, extremely fast (2.0x), 6 salvage

#### Heavy Enemies (New)
9. **Juggernaut** - Molten orange fortress, 80 HP, extremely slow (0.3x), 34 salvage
   - 50% damage reduction, heavy armor plating
10. **Goliath** - Crystalline cyan octagon, 100 HP, very slow (0.35x), 41 salvage
    - Multi-layered shields (30 HP shield)
11. **Behemoth** - Bio-mechanical purple horror, 90 HP, slow (0.4x), 38 salvage
    - Regenerates 3 HP/second

#### Boss Enemies
12. **Destroyer** - Massive red hexagon, 126 HP, slow (0.7x), 45 salvage
    - 48 HP regenerating shield, 50% damage reduction
13. **Titan** - Alien purple tentacle beast, 360 HP, very slow (0.4x), 90 salvage
    - Regenerates 5 HP/second, 30% damage reduction
14. **Mega Boss** - Fortress with rotating parts, 480 HP, slow (0.5x), 150 salvage
    - 60 HP shield, 40% damage reduction

### Visual Effects
- **Hit Reactions**: Enemies shake and flash when damaged
- **Damage Numbers**: Floating damage indicators
- **Particle Effects**: Impact sparks and debris
- **Death Animations**: Unique destruction effects per enemy type
- **Weapon Effects**: Color-coded projectiles and impacts
- **UI Animations**: Pulsing health bars, glowing buttons

### Game Balance
- **Starting Resources**: 120 salvage + (map-1) × 40
- **Station Health**: 3 lives
- **Salvage Rewards**: Reduced by 25-30% for harder progression
- **Map Difficulty**:
  - Map 1 (Mars): 45% harder from wave 2 onwards
  - Map 2 (Venus): 100% harder (doubled difficulty)
  - Map 3 (Earth): 150% harder with elite enemies
  - Map 4 (Mars Outpost): 200% harder with heavy units
  - Maps 5-12: Progressive difficulty with boss variations
- **Spawn Rates**:
  - Map 1: 1.8s (wave 1), 1.1s (wave 2+)
  - Map 2: 1.0s base delay
  - Map 3: 0.8s base delay
  - Map 4: 0.65s base delay

## 🕹️ Controls

### Tower Placement
1. Tap a build node (highlighted spots)
2. Select tower type from menu
3. Confirm placement if you have enough salvage

### Tower Management
- **Tap tower**: Show upgrade menu
- **Upgrade**: Costs 150% of base price
- **Sell**: Get 80% refund

### Game Controls
- **Start Wave**: Purple button when ready
- **Fast Forward**: Toggle 1x/2x speed (bottom left)
- **Secret Skip**: Tap top-left 3 times to skip level (testing)
- **Restart**: Tap anywhere after game over

## 🚀 Quick Start

### Requirements
- Xcode 14.0+
- iOS 15.0+ / macOS 12.0+
- Swift 5.5+

### Installation
```bash
# Clone the repository
git clone [repository-url]

# Navigate to project
cd Tower-game

# Open in Xcode
open SpaceSalvagers.xcodeproj

# Build and run (Cmd+R)
```

### Testing
```bash
# Run the test script
./test_game.sh
```

## 📁 Project Structure

```
SpaceSalvagers/
├── Game/
│   ├── Scenes/         # Game scenes (Menu, Game, etc.)
│   ├── Components/      # Tower and enemy components
│   └── UI/             # UI elements and HUD
├── Core/
│   ├── Engine/         # ECS and game engine
│   └── Systems/        # Game systems (wave, combat, etc.)
├── Data/
│   └── Configuration/  # Map and enemy configs
└── Resources/
    └── Assets/         # Sprites and sounds
```

## 🎯 Strategy Tips

### Early Game
- Start with 1 cannon at a choke point
- Save for laser tower ASAP
- Focus on high-traffic areas
- Don't spread towers too thin

### Mid Game
- Upgrade existing towers before buying new ones
- Mix tower types for different enemy types
- Use plasma for groups, laser for tough enemies
- Position missiles at back for maximum coverage

### Late Game
- Level 3 towers are significantly more powerful
- Tesla towers for swarm control
- Keep some salvage for emergency towers
- Sell and reposition if needed

## 🐛 Known Issues
- Restart button occasionally needs double-tap
- Missile orientation updates may lag
- Some particle effects may impact performance on older devices

## 🔧 Development

### Adding New Towers
1. Add tower type to `createSimpleTowerSprite()`
2. Define stats in `getTowerFireRate()` and `getTowerRange()`
3. Create projectile in `fireProjectile()`
4. Add visual in tower creation switch

### Adding New Enemies
1. Define enemy in `createEnemy()` switch
2. Add to spawn logic in `getEnemyTypeForWave()`
3. Create unique animations
4. Set health, speed, and salvage values

### Modifying Maps
1. Edit `createMapXLayout()` functions
2. Adjust path waypoints
3. Position build nodes
4. Set visual theme

## 📊 Performance

- Optimized for 60 FPS on modern devices
- Efficient particle pooling
- Smart enemy culling
- Minimal texture atlas usage
- SKAction-based animations

## 🎨 Art Style

- **Neon Outline Aesthetic**: All sprites use glowing outlines
- **Color Coding**: Consistent color language for damage types
- **Minimalist Design**: Clean, readable battlefield
- **Particle Effects**: Used sparingly for impact

## 📈 Version History

### Current Version
- Enhanced visual effects and hit feedback
- Balanced economy (50% salvage reduction)
- 7 enemy types with unique behaviors
- 10 unique maps with themes
- Improved tower targeting and rotation
- Fast forward feature
- Multiple difficulty adjustments

## 🆕 Recent Updates (v1.4.0)

### Major Difficulty Overhaul
- **Map Difficulty Scaling**
  - Map 1: 45% harder from wave 2 (tutorial only wave 1)
  - Map 2: 100% harder with immediate tough enemies
  - Map 3: 150% harder with elite units from start
  - Map 4: 200% harder with heavy tanks and fast spawns
  
- **New Heavy Tank Enemies**
  - Juggernaut: Industrial war machine with pulsing armor
  - Goliath: Crystalline fortress with triple shield layers
  - Behemoth: Bio-mechanical horror with regeneration
  
- **Visual Enhancements**
  - All new enemies have stunning particle effects
  - Multiple animation layers per enemy
  - Vibrant neon colors with high glow values
  - Iridescent and color-shifting effects
  
- **Balance Changes**
  - All salvage rewards reduced by 25-30%
  - Machine gun damage reduced by 15%
  - Boss health increased by 20%
  - Boss shields increased by 20%
  
## Previous Updates (v1.3.0)

### Background Animations & Map Navigation
- **Stunning Background Effects**
  - 200+ animated stars with varied effects (twinkle, pulse, shimmer)
  - Periodic shooting stars streaking across the sky
  - Floating space debris and asteroids with realistic rotation
  - Animated nebula clouds with drift and morphing
  - Alien ships periodically flying across background
  - Mars now features animated dust storms
  - Earth has wobble effect and enhanced atmosphere
  
- **Improved Map Navigation**
  - Smoother camera panning with 1.5x sensitivity
  - Better zoom levels for all maps (15-35% zoom out)
  - Camera constraints to keep map visible
  - Touch-based scrolling without UI interference

- **Bug Fixes**
  - Fixed starting salvage calculation (now correctly 120 + (map-1) × 40)
  - Removed automatic salvage increase bug
  - Fixed salvage only increases from destroying enemies

### v1.2.0
- **Enhanced Visual Effects**
  - Massive explosion effects when losing lives with screen shake
  - Improved planet animations in main menu with orbiting moon and space station
  - Added animated clouds, atmosphere pulsing, and orbital mechanics
  
- **UI/UX Improvements**
  - Fixed "PORTAL BREACHED" screen properly hiding game UI
  - Fixed restart button functionality (now creates fresh game instance)
  - Added abort game button (red X) with confirmation dialog
  - Removed non-functional settings button
  - Fixed red screen getting stuck after taking damage
  
- **Gameplay Balance**
  - Comprehensive difficulty progression for all 12 planets
  - Each planet has unique enemy compositions and themes
  - Cannon tower nerfed by 30% (damage and fire rate)
  - Proper 1:1 life loss for each enemy that reaches the station
  
- **Bug Fixes**
  - Fixed lives display not updating properly
  - Fixed duplicate damage when enemies reach station
  - Fixed game continuing to run in background on game over
  - Improved planet spacing in solar system map selection

### Compilation Instructions
The project now includes proper build verification. Always compile after making changes:

```bash
# Command line build
xcodebuild -project SpaceSalvagers.xcodeproj -scheme SpaceSalvagers -sdk iphonesimulator build

# Or in Xcode
# Press Cmd+B to build
# Press Cmd+R to run in simulator
```

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This project is proprietary. All rights reserved.

## 👨‍💻 Author

Willie Prinsloo

---

*Space Salvagers - Defend the station. Salvage the future.*