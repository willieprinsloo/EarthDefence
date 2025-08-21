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
1. **Cannon** (100 salvage)
   - Basic starter tower
   - Fast fire rate (0.6s)
   - 1 damage per shot
   - Level 3 gets dual barrels (visual only)
   
2. **Laser** (140 salvage)
   - Powerful but slow charging (2.2s)
   - 5-11 damage based on level
   - Instant hit with visual beam
   - Charging effect before firing
   
3. **Plasma** (180 salvage)
   - Medium fire rate (1.2s)
   - Area damage on impact
   - Purple energy projectiles
   
4. **Missile** (200 salvage)
   - Homing projectiles
   - 2.0s fire rate
   - Targets furthest enemies
   
5. **Tesla/EMP** (240 salvage)
   - Chain lightning damage
   - Area effect
   - Targets weakest enemies

### Enemy Types
1. **Scout** - Pink triangle, 2 HP, fast (1.2x), 5 salvage
2. **Fighter** - Orange diamond, 4 HP, normal speed, 10 salvage
3. **Bomber** - Green hexagon, 10 HP, slow (0.8x), 15 salvage
4. **Destroyer** - Red star, 30 HP, very slow (0.6x), 25 salvage
5. **Swarm** - Cyan circle, 1 HP, very fast (1.8x), 3 salvage
6. **Shield** - Blue oval, 15 HP, slow (0.7x), 18 salvage
7. **Stealth** - Gray arrow, 3 HP, fast (1.4x), phases in/out, 10 salvage

### Visual Effects
- **Hit Reactions**: Enemies shake and flash when damaged
- **Damage Numbers**: Floating damage indicators
- **Particle Effects**: Impact sparks and debris
- **Death Animations**: Unique destruction effects per enemy type
- **Weapon Effects**: Color-coded projectiles and impacts
- **UI Animations**: Pulsing health bars, glowing buttons

### Game Balance
- **Starting Resources**: 120 salvage
- **Station Health**: 3 lives
- **Wave Bonuses**: 60-80+ salvage per wave
- **Map Completion**: 600 salvage for map 1, scaling for others
- **Enemy Progression**: Gradual introduction of tougher enemies

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

## 🆕 Recent Updates (v1.3.0)

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

### Previous Updates (v1.2.0)
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