# 🚀 Space Salvagers - Development TODO List

## 📋 Project Setup & Foundation

### Initial Setup
- [ ] Create new Unity project (2022 LTS with 2D URP)
- [ ] Set up folder structure (Scripts, Prefabs, Materials, Textures, Audio, UI, VFX)
- [ ] Configure project settings (2D, mobile build settings, quality presets)
- [ ] Set up version control (.gitignore for Unity)
- [ ] Import essential packages (TextMeshPro, 2D Sprite, URP)
- [ ] Configure URP asset for mobile optimization

### Core Architecture
- [ ] Create GameManager singleton
- [ ] Implement state machine (Menu, Playing, Paused, GameOver, Victory)
- [ ] Set up event system for decoupled communication
- [ ] Create object pooling system for projectiles/enemies/effects
- [ ] Implement save/load system with JSON serialization
- [ ] Set up debug console and cheats system

---

## 🎨 Art Assets Creation

### Environment Assets
- [ ] Create hexagonal floor tile sprites (clean, damaged, build node variants)
- [ ] Design metal wall panels with damage states
- [ ] Create pipe and wire decorative elements
- [ ] Design emergency lighting strips (animated)
- [ ] Create steam vent sprites with animation
- [ ] Design broken monitor props with static effect
- [ ] Create debris pile variations
- [ ] Design core reactor asset with pulsing animation
- [ ] Create warning signs and station markings

### Background Layers
- [ ] Paint space vista background (nebula, stars)
- [ ] Create debris field sprites for parallax
- [ ] Design distant station wreckage silhouettes
- [ ] Create support beam and scaffolding sprites
- [ ] Design inactive machinery silhouettes
- [ ] Add foreground pipe details

### Tower Sprites/Models
- [ ] **Laser Turret**
  - [ ] Base design with heat vents
  - [ ] Rotating turret top with lens
  - [ ] Level 2 upgrade visuals (additional rings)
  - [ ] Level 3 upgrade visuals (dual barrels)
  - [ ] Muzzle flash effect sprite
- [ ] **Gravity Well Generator**
  - [ ] Spherical containment field base
  - [ ] Dark matter swirl effect
  - [ ] Level 2 upgrade visuals (larger sphere)
  - [ ] Level 3 upgrade visuals (orbital rings)
  - [ ] Distortion shader effect
- [ ] **EMP Shock Tower**
  - [ ] Tesla coil base with conductors
  - [ ] Electric arc sprite sheet
  - [ ] Level 2 upgrade visuals (more rods)
  - [ ] Level 3 upgrade visuals (rotating array)
  - [ ] EMP pulse ring effect
- [ ] **Nanobot Swarm Dispenser**
  - [ ] Hexagonal hive structure
  - [ ] Transparent chamber overlay
  - [ ] Level 2 upgrade visuals (more ports)
  - [ ] Level 3 upgrade visuals (glow modules)
  - [ ] Swarm particle texture

### Enemy Sprites/Models
- [ ] **Alien Swarmers**
  - [ ] Base sprite with idle animation
  - [ ] Walk/scuttle animation (8 frames)
  - [ ] Death animation (explode to goo)
  - [ ] Glow map for bio-luminescent spots
- [ ] **Rogue Robots**
  - [ ] Heavy mech sprite
  - [ ] Walk cycle animation (mechanical)
  - [ ] Damage states (sparks, rust)
  - [ ] Death animation (collapse)
- [ ] **AI Drones**
  - [ ] Hovering drone sprite
  - [ ] Float animation (bobbing)
  - [ ] Shield bubble overlay
  - [ ] Shield break animation
  - [ ] Death spin animation
- [ ] **Bio-Titan Boss**
  - [ ] Large amalgamation sprite
  - [ ] Walk animation (earth-shaking)
  - [ ] Roar animation
  - [ ] Split death animation
  - [ ] Bio-sac pulsing animation

### UI Assets
- [ ] HUD frame designs (holographic style)
- [ ] Tower selection cards
- [ ] Resource icons (salvage, energy)
- [ ] Wave preview enemy portraits
- [ ] Health bars (player, enemy, station)
- [ ] Button designs (play, pause, fast-forward, upgrade, sell)
- [ ] Damage indicators and numbers
- [ ] Victory/defeat screen layouts
- [ ] Font selection (Orbitron or similar)

---

## 🎮 Core Gameplay Systems

### Map & Grid System
- [ ] Implement grid-based map system
- [ ] Create path node system for enemy movement
- [ ] Implement build node placement system
- [ ] Add node validation (occupied, affordable)
- [ ] Create range indicator system
- [ ] Implement map boundaries and collision

### Wave Management
- [ ] Create Wave class with enemy composition data
- [ ] Implement WaveManager with spawn timing
- [ ] Add wave scaling formulas (HP, speed, count)
- [ ] Create wave preview system
- [ ] Implement wave completion detection
- [ ] Add between-wave pause state
- [ ] Create boss wave special logic
- [ ] Implement wave modifiers system (post-MVP)

### Enemy System
- [ ] Create base Enemy class with health/speed/armor
- [ ] Implement enemy movement along paths
- [ ] Add enemy state machine (spawning, moving, attacking, dying)
- [ ] Create damage and death systems
- [ ] Implement armor and resistance calculations
- [ ] Add special abilities:
  - [ ] Swarmers pack bonus
  - [ ] Robot EMP resistance
  - [ ] Drone shields
  - [ ] Boss splitting
- [ ] Create enemy spawn animation
- [ ] Implement enemy health bars

### Tower System
- [ ] Create base Tower class
- [ ] Implement tower placement system
- [ ] Add tower targeting systems:
  - [ ] Nearest enemy
  - [ ] Strongest enemy
  - [ ] Weakest enemy
  - [ ] First in line
  - [ ] Last in line
- [ ] Create tower upgrade system (3 levels)
- [ ] Implement tower selling with refund
- [ ] Add tower range visualization
- [ ] Create specific tower behaviors:
  - [ ] Laser continuous beam
  - [ ] Gravity Well area slow
  - [ ] EMP area stun
  - [ ] Nanobot DoT application

### Projectile System
- [ ] Create projectile pooling manager
- [ ] Implement projectile movement and collision
- [ ] Add different projectile types:
  - [ ] Instant hit (laser)
  - [ ] Area effect (EMP)
  - [ ] Persistent effect (gravity)
  - [ ] DoT application (nanobots)
- [ ] Create projectile visual effects
- [ ] Implement damage calculation on hit

### Economy System
- [ ] Create salvage currency manager
- [ ] Implement kill rewards
- [ ] Add wave completion bonuses
- [ ] Create tower cost calculations
- [ ] Implement upgrade pricing
- [ ] Add sell/refund system (80% return)
- [ ] Display floating salvage numbers

### Combat System
- [ ] Implement damage calculation with armor
- [ ] Create status effect system:
  - [ ] Slow (gravity well)
  - [ ] Stun (EMP)
  - [ ] DoT (nanobots)
- [ ] Add damage number display
- [ ] Implement combo system (if applicable)
- [ ] Create critical hit system (if applicable)

---

## 🎨 Visual Effects Implementation

### Particle Systems
- [ ] Create laser beam effect with heat distortion
- [ ] Implement EMP shockwave ring
- [ ] Design nanobot swarm particles
- [ ] Add enemy death particles:
  - [ ] Green goo splash (swarmers)
  - [ ] Metal debris (robots)
  - [ ] Energy dissipation (drones)
  - [ ] Multiple spawns (boss)
- [ ] Create ambient particles (dust, steam, sparks)
- [ ] Implement tower construction effect
- [ ] Add upgrade enhancement glow

### Shaders & Materials
- [ ] Create hologram shader for UI
- [ ] Implement shield shader for drones
- [ ] Design distortion shader for gravity well
- [ ] Create glow/emission shader for energy
- [ ] Implement damage flash shader
- [ ] Add dissolve shader for deaths

### Lighting
- [ ] Set up global 2D lighting
- [ ] Add point lights for towers
- [ ] Implement emergency lighting system
- [ ] Create muzzle flash lights
- [ ] Add explosion lighting
- [ ] Implement boss encounter lighting change

### Post-Processing
- [ ] Configure bloom for energy effects
- [ ] Add chromatic aberration for EMP
- [ ] Implement screen shake for impacts
- [ ] Set up vignette for atmosphere
- [ ] Create color grading LUT
- [ ] Add motion blur for fast enemies

---

## 🎵 Audio Implementation

### Sound Effects
- [ ] Tower placement sound
- [ ] Tower upgrade sound
- [ ] Tower sell sound
- [ ] Laser firing sound
- [ ] EMP discharge sound
- [ ] Gravity well hum
- [ ] Nanobot swarm buzz
- [ ] Enemy spawn sounds (per type)
- [ ] Enemy movement sounds (per type)
- [ ] Enemy death sounds (per type)
- [ ] Damage impact sounds
- [ ] UI click sounds
- [ ] Wave start/complete sounds
- [ ] Victory/defeat stingers
- [ ] Ambient station sounds

### Music
- [ ] Main menu theme
- [ ] Build phase ambient track
- [ ] Combat music (scalable intensity)
- [ ] Boss battle theme
- [ ] Victory fanfare
- [ ] Defeat theme

### Audio System
- [ ] Implement audio manager
- [ ] Create sound pooling system
- [ ] Add volume controls (Master, SFX, Music)
- [ ] Implement dynamic music system
- [ ] Add audio ducking for important sounds

---

## 🖥️ UI Implementation

### Main Menu
- [ ] Create main menu layout
- [ ] Implement play button
- [ ] Add settings menu
- [ ] Create credits screen
- [ ] Add quit functionality

### HUD
- [ ] Create salvage counter display
- [ ] Implement wave counter/timer
- [ ] Add station health bar
- [ ] Create fast-forward toggle
- [ ] Implement pause button
- [ ] Add settings access button

### Tower UI
- [ ] Create tower selection menu
- [ ] Implement radial/card selection
- [ ] Add tower info panel
- [ ] Create upgrade buttons
- [ ] Implement sell button
- [ ] Add range indicator toggle
- [ ] Show DPS and stats

### Wave UI
- [ ] Create wave preview panel
- [ ] Display enemy composition
- [ ] Show wave modifiers
- [ ] Add countdown timer
- [ ] Implement "Start Wave" button

### Game Over/Victory
- [ ] Create victory screen
- [ ] Implement defeat screen
- [ ] Add statistics display
- [ ] Create restart button
- [ ] Implement return to menu

### Mobile UI Adaptations
- [ ] Add touch input handling
- [ ] Implement pinch-to-zoom
- [ ] Create drag-to-pan
- [ ] Add haptic feedback
- [ ] Ensure minimum touch target sizes

---

## 🔧 Meta Progression

### Station Repair System
- [ ] Create tech tree data structure
- [ ] Implement node unlock system
- [ ] Design visual tech tree UI
- [ ] Add three branches (Weapons, Control, Support)
- [ ] Implement specific upgrades:
  - [ ] +10% laser damage
  - [ ] +1 starting tower slot
  - [ ] +5% salvage income
  - [ ] +1 station HP regen
- [ ] Create unlock animations
- [ ] Add progress persistence

### Progression Tracking
- [ ] Implement milestone system
- [ ] Track player statistics
- [ ] Create achievement system (post-MVP)
- [ ] Add player level/rank (post-MVP)

---

## 🎯 Balancing & Testing

### Balance Testing
- [ ] Create DPS calculator tool
- [ ] Test tower effectiveness vs each enemy
- [ ] Balance enemy HP scaling
- [ ] Tune wave difficulty curve
- [ ] Adjust salvage economy
- [ ] Test upgrade cost/benefit ratios
- [ ] Verify boss difficulty

### Playtesting Systems
- [ ] Create debug menu
- [ ] Implement instant wave spawn
- [ ] Add infinite salvage mode
- [ ] Create god mode
- [ ] Implement time scale controls
- [ ] Add enemy spawn commands
- [ ] Create stat display overlay

### Automated Testing
- [ ] Write unit tests for core systems
- [ ] Create integration tests for gameplay
- [ ] Implement performance benchmarks
- [ ] Add memory leak detection
- [ ] Create deterministic replay system

---

## 📱 Platform-Specific Features

### Mobile Optimization
- [ ] Implement LOD system for sprites
- [ ] Add quality settings presets
- [ ] Optimize particle counts
- [ ] Implement texture atlasing
- [ ] Add battery saver mode
- [ ] Optimize shader complexity

### iOS Specific
- [ ] Configure iOS build settings
- [ ] Implement iOS-specific UI adjustments
- [ ] Add Game Center integration (post-MVP)
- [ ] Configure haptic feedback
- [ ] Handle iOS interruptions

### Android Specific
- [ ] Configure Android build settings
- [ ] Implement back button handling
- [ ] Add Google Play Games integration (post-MVP)
- [ ] Handle Android interruptions
- [ ] Test on various screen ratios

---

## 🚀 Polish & Launch Preparation

### Visual Polish
- [ ] Add juice to all interactions
- [ ] Implement smooth transitions
- [ ] Polish particle effects
- [ ] Fine-tune animations
- [ ] Add screen effects
- [ ] Implement camera shake

### Performance Optimization
- [ ] Profile and optimize scripts
- [ ] Reduce draw calls
- [ ] Optimize texture sizes
- [ ] Implement object pooling
- [ ] Reduce garbage collection
- [ ] Optimize physics calculations

### Analytics Integration
- [ ] Implement analytics SDK
- [ ] Track key events:
  - [ ] Session start/end
  - [ ] Level completion
  - [ ] Tower usage
  - [ ] Economy flow
  - [ ] Player progression
- [ ] Create custom funnels
- [ ] Set up crash reporting

### Store Preparation
- [ ] Create app icon
- [ ] Design store screenshots
- [ ] Write store description
- [ ] Create promotional video
- [ ] Prepare keywords for ASO
- [ ] Set up beta testing

---

## 🐛 Bug Fixing & QA

### Known Issues to Address
- [ ] Fix enemy pathfinding edge cases
- [ ] Resolve tower targeting bugs
- [ ] Fix UI scaling issues
- [ ] Address memory leaks
- [ ] Fix save/load corruption
- [ ] Resolve audio playback issues

### QA Checklist
- [ ] Complete functional testing
- [ ] Perform device compatibility testing
- [ ] Execute performance testing
- [ ] Complete localization testing (if applicable)
- [ ] Test IAP functionality (post-MVP)
- [ ] Verify analytics tracking

---

## 📈 Post-Launch Features (Future)

### Content Updates
- [ ] Additional towers (Railgun, Plasma Shield)
- [ ] New enemy types
- [ ] More station maps
- [ ] Endless mode
- [ ] Daily challenges

### Monetization
- [ ] Cosmetic tower skins
- [ ] Station themes
- [ ] Premium currency (non-P2W)
- [ ] Battle pass system
- [ ] Ad integration (optional)

### Social Features
- [ ] Leaderboards
- [ ] Replay sharing
- [ ] Friend challenges
- [ ] Clan system
- [ ] Tournaments

---

## 🎯 Development Milestones

### Milestone 1: Core Systems (Week 1-2)
- Project setup
- Basic enemy spawning and movement
- Tower placement and shooting
- Simple UI

### Milestone 2: Full Gameplay Loop (Week 3-4)
- All 4 towers functional
- All 4 enemy types
- Wave system
- Economy working

### Milestone 3: Art Integration (Week 5-6)
- All sprites implemented
- Particle effects
- UI skinned
- Audio integrated

### Milestone 4: Polish & Balance (Week 7-8)
- Balance testing
- Bug fixes
- Performance optimization
- Meta progression

### Milestone 5: Launch Prep (Week 9-10)
- Store assets
- Final testing
- Analytics integration
- Release build

---

*This TODO list should be tracked in a project management tool with assignments, deadlines, and dependencies clearly marked.*