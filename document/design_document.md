# 🎨 Space Salvagers - Visual Design Document

## 🎯 Art Direction Overview

### Visual Theme
- **Style**: Cyberpunk meets derelict space station aesthetic
- **Color Palette**: 
  - Primary: Neon blues, purples, and cyans for technology
  - Secondary: Rust oranges, industrial grays for derelict areas
  - Accent: Bright greens for toxins, reds for danger/enemies
  - Glow Effects: Additive rendering for all energy weapons and shields
- **Mood**: Dark, atmospheric with strategic pops of neon light
- **Reference**: Think "Dead Space" meets "Tron Legacy" with tower defense clarity

---

## 🏚️ Environment & Background Design

### Station Interior (Main Playing Field)
- **Layout**: Industrial corridors with exposed pipes, broken panels, flickering lights
- **Floor Tiles**: 
  - Hexagonal metal grating with rust patterns
  - Build nodes: Glowing circular platforms with holographic grid
  - Path tiles: Darker metal with warning stripes on edges
- **Walls**: 
  - Layered metal panels with battle damage
  - Exposed wiring sparking occasionally
  - Emergency lighting strips (red pulsing)
- **Ambient Elements**:
  - Steam vents releasing periodic fog
  - Broken monitors flickering with static
  - Debris piles (non-blocking, decorative)
  - Emergency doors (locked, background detail)

### Background Layers (2.5D Parallax)
1. **Far Background**: Space vista visible through breached hull sections
   - Distant nebula with purple/blue gradients
   - Debris field floating slowly
   - Distant station wreckage
2. **Mid Background**: Station superstructure
   - Support beams and scaffolding
   - Inactive machinery silhouettes
   - Occasional sparks from damaged systems
3. **Near Background**: Immediate station details
   - Pipes running along walls
   - Control panels (some functional-looking)
   - Warning signs and station markings

### Core/Objective Area
- **Design**: Central reactor chamber with pulsing energy core
- **Visual**: Bright blue/white energy sphere with containment rings
- **Animation**: Gentle pulsing, damage causes red warning flashes
- **Details**: Control consoles, safety barriers, radiation warnings

---

## 🔫 Tower Designs

### 1. Laser Turret
- **Base Design**: 
  - Sleek cylindrical base with heat vents
  - Rotating top section with focusing lens
  - Glowing energy core visible through transparent panels
- **Color Scheme**: Gunmetal gray with blue energy accents
- **Firing Animation**: 
  - Charge-up: Lens brightens, energy particles gather
  - Fire: Continuous red beam with heat distortion
  - Cooldown: Vents release steam, lens dims
- **Upgrade Visual Changes**:
  - Level 2: Additional focusing rings, brighter core
  - Level 3: Dual barrels, larger heat sinks, plasma effects

### 2. Gravity Well Generator
- **Base Design**:
  - Spherical containment field on tripod base
  - Swirling dark matter effect inside sphere
  - Gravitational distortion rings emanating outward
- **Color Scheme**: Deep purple with black hole aesthetics
- **Active Effect**:
  - Constant swirling vortex animation
  - Rippling space distortion in radius
  - Pulled debris and particles
- **Upgrade Visual Changes**:
  - Level 2: Larger sphere, more intense distortion
  - Level 3: Multiple orbital rings, lightning arcs

### 3. EMP Shock Tower
- **Base Design**:
  - Tesla coil-inspired with multiple conductor rods
  - Central capacitor with visible charge buildup
  - Grounding cables and insulators
- **Color Scheme**: Industrial copper/brass with electric blue arcs
- **Firing Animation**:
  - Charge: Electric arcs between rods intensify
  - Discharge: Radial shockwave with lightning effects
  - Recovery: Smoke from overheated components
- **Upgrade Visual Changes**:
  - Level 2: Additional conductor rods, larger capacitor
  - Level 3: Rotating discharge array, constant mini-arcs

### 4. Nanobot Swarm Dispenser
- **Base Design**:
  - Hexagonal hive structure with deployment ports
  - Transparent chambers showing swarm movement
  - Bio-mechanical hybrid aesthetic
- **Color Scheme**: Organic greens with metallic accents
- **Active Effect**:
  - Constant particle stream of tiny bots
  - Swarm cloud effect around targets
  - Corrosion/dissolve effect on enemies
- **Upgrade Visual Changes**:
  - Level 2: More deployment ports, denser swarms
  - Level 3: Glowing enhancement modules, trail effects

---

## 👾 Enemy Designs

### 1. Alien Swarmers
- **Appearance**: 
  - Small, insectoid creatures with bio-luminescent spots
  - Multiple legs for scuttling movement
  - Translucent wing membranes (non-functional)
- **Color**: Dark green/black with acid-green glowing sacs
- **Animation**:
  - Rapid scuttling with occasional jumps
  - Pack behavior - move in coordinated groups
  - Death: Explode in green goo splash
- **Size**: 0.5x standard unit

### 2. Rogue Robots
- **Appearance**:
  - Bulky, industrial design with exposed hydraulics
  - Tank treads or heavy mechanical legs
  - Sparking damage and rust patches
- **Color**: Gunmetal gray with orange rust, red sensor eyes
- **Animation**:
  - Heavy, deliberate movement with mechanical sounds
  - Occasional steam venting from joints
  - Death: Collapse into scrap pile with electric sparks
- **Size**: 1.5x standard unit

### 3. AI Drones (Shielded)
- **Appearance**:
  - Sleek, hovering design with anti-gravity engines
  - Hexagonal shield bubble (semi-transparent blue)
  - Central eye-like sensor array
- **Color**: White/silver with blue shield, red when shield breaks
- **Animation**:
  - Smooth floating movement with slight bobbing
  - Shield flickers when hit, shatters dramatically
  - Death: Spin out of control, crash and explode
- **Size**: 1x standard unit

### 4. Bio-Titan (Boss)
- **Appearance**:
  - Massive amalgamation of organic and mechanical parts
  - Multiple eyes and weapon appendages
  - Pulsating bio-sacs that spawn swarmers
- **Color**: Dark purple/black with green bio-lights
- **Animation**:
  - Slow, earth-shaking steps
  - Periodic roar animation with screen shake
  - Death: Violent explosion spawning 6 swarmers
- **Size**: 3x standard unit

---

## 💥 Projectile & Effect Designs

### Projectiles
1. **Laser Beam**: Continuous red/orange beam with heat shimmer
2. **EMP Pulse**: Expanding blue ring with lightning tendrils
3. **Nanobots**: Green particle cloud that clings to targets
4. **Enemy Projectiles**: 
   - Swarmer acid spit (green globs)
   - Robot missiles (if added later)

### Impact Effects
- **Energy Impact**: Bright flash with sparks
- **Kinetic Impact**: Metal denting, debris particles
- **DoT Effect**: Corrosion spreading, dissolve animation
- **Shield Impact**: Ripple effect on shield surface

### Environmental Effects
- **Explosions**: Multi-layered with shockwave, debris, smoke
- **Death Particles**: Enemy-specific (goo, scrap, energy)
- **Tower Construction**: Holographic blueprint materializing
- **Upgrade Effect**: Energy surge with temporary glow

---

## 🎮 UI/HUD Design

### Main HUD Layout
- **Top Bar**:
  - Salvage counter (holographic credit display)
  - Wave indicator (current/total with timer)
  - Fast-forward button (sleek play/FF icons)
- **Bottom Bar**:
  - Tower selection (radial menu or card-based)
  - Selected tower info panel
- **Side Panel**:
  - Station HP (visual damage indicators)
  - Incoming wave preview
  - Objective tracker

### Visual Style
- **Frame Design**: Holographic panels with subtle glow
- **Typography**: Futuristic mono-spaced font (like Orbitron)
- **Colors**: 
  - UI Primary: Cyan-blue holographic
  - Success: Green glow
  - Warning: Orange pulse
  - Danger: Red flash
- **Animations**:
  - Panel slide-ins from edges
  - Pulse effects on important updates
  - Subtle parallax on menu layers

### Build Menu
- **Node Interaction**: 
  - Hover: Soft blue glow
  - Valid placement: Green hologram preview
  - Invalid: Red X with reason tooltip
- **Tower Cards**: 
  - 3D rotating tower preview
  - Cost in salvage credits
  - Quick stats (DPS, range)
  - Upgrade path preview

### Wave Preview Panel
- **Design**: Terminal-style interface
- **Elements**:
  - Enemy portraits with count badges
  - Wave modifiers as warning icons
  - Countdown timer or "Start Wave" button
  - Threat level indicator (color-coded)

---

## 🎨 Visual Polish & Effects

### Particle Systems
1. **Ambient Particles**: Dust motes, steam, sparks
2. **Combat Particles**: Projectile trails, impact bursts
3. **Environmental**: Fog layers, debris floating

### Lighting
- **Global Illumination**: Dark ambient with strategic light sources
- **Dynamic Lights**: 
  - Tower firing creates brief illumination
  - Explosions cast shadows
  - Emergency lights pulse during boss waves
- **Emissive Materials**: All UI, energy weapons, enemy weak spots

### Post-Processing Stack
- **Bloom**: For all energy weapons and neon elements
- **Chromatic Aberration**: During EMP blasts
- **Screen Shake**: Boss footsteps, large explosions
- **Vignette**: Darkens edges for focus
- **Color Grading**: Cyberpunk LUT with high contrast

### Performance Modes
- **High Quality**: All effects enabled
- **Medium**: Reduced particles, simplified shadows
- **Low/Mobile**: Essential effects only, optimized shaders

---

## 📱 Mobile-Specific Considerations

### Touch Feedback
- **Visual**: Ripple effect at touch point
- **Haptic**: Light tap for UI, medium for placement
- **Audio**: Subtle UI clicks

### Screen Adaptation
- **Safe Zones**: UI elements avoid notches/corners
- **Scaling**: Dynamic UI scaling based on screen size
- **Orientation**: Landscape only for gameplay

### Readability
- **Minimum Sizes**: 
  - Touch targets: 44pt minimum
  - Text: 12pt minimum
  - Health bars: Scale with zoom
- **Contrast**: High contrast mode option
- **Colorblind**: Alternate palettes available

---

## 🎬 Animation Guidelines

### Frame Rates
- **UI Animations**: 60 FPS
- **Gameplay**: 30-60 FPS adaptive
- **Background Elements**: 15-30 FPS

### Animation Principles
- **Anticipation**: Charge-up before attacks
- **Follow-through**: Recoil after firing
- **Squash & Stretch**: For organic enemies
- **Mechanical**: Rigid, precise for robots/towers

### Priority System
1. **Critical**: Player actions, enemy deaths
2. **Important**: Tower firing, enemy movement
3. **Nice-to-have**: Ambient animations, particles
4. **Optional**: Deep background elements

---

## 🔧 Technical Specifications

### Texture Resolutions
- **Towers**: 512x512 base, 1024x1024 for hero assets
- **Enemies**: 256x256 for swarmers, 512x512 for bosses
- **Environment**: 1024x1024 tileable textures
- **UI**: Vector where possible, 2048x2048 atlas

### Polygon Budgets (if 3D elements)
- **Towers**: 500-1000 triangles
- **Enemies**: 300-800 triangles
- **Environment**: 5000 total on screen

### Shader Requirements
- **Standard**: Lit/unlit with emission
- **Special**: Hologram, shield, distortion
- **Mobile**: Simplified versions of all shaders

---

## 📋 Asset Production Checklist

### Priority 1 (MVP)
- [ ] 4 tower models with 3 upgrade states each
- [ ] 4 enemy types with animations
- [ ] 1 complete station environment
- [ ] Basic UI elements and HUD
- [ ] Essential particle effects
- [ ] Core audio (10-15 SFX)

### Priority 2 (Polish)
- [ ] Advanced particle effects
- [ ] Environmental animations
- [ ] Additional UI polish
- [ ] Music tracks (3-5)
- [ ] Victory/defeat sequences

### Priority 3 (Post-Launch)
- [ ] New tower variants
- [ ] Seasonal themes
- [ ] Cosmetic skins
- [ ] Additional environments

---

## 🎯 Visual Success Metrics

- **Readability**: Players can instantly identify towers, enemies, and threats
- **Consistency**: Cohesive art style throughout
- **Performance**: Maintains 60 FPS on target devices
- **Polish**: Feels premium despite being free-to-play
- **Accessibility**: Playable by users with various visual needs

---

*This design document serves as the visual blueprint for Space Salvagers. All art assets should align with these specifications while maintaining flexibility for creative interpretation and technical constraints.*

---

## 🤖 AI-Driven Backlog & Task Graph (MVP)

Use this backlog to feed tasks directly to AI/dev tools. Tasks are atomic, parallelizable where possible, and include dependencies and acceptance criteria.

### Principles
- Deterministic systems (seeded RNG), test-first, small PRs, CI green before merge
- Data-driven configs (ScriptableObjects/JSON) for towers, enemies, waves
- Headless test scenes for simulation; performance budgets enforced in CI

### Dependency Graph (high level)
- Core Systems → (Towers, Enemies) → Economy/Win-Lose → UI/HUD → Meta → Analytics/Cloud → Store/Build

### Epic: Core Systems
- Task: Create deterministic RNG service
  - Dependency: none
  - Output: `RngService` class with seed control, unit tests
  - Accept: Same seed ⇒ identical sequences across runs
- Task: Implement pathing on fixed corridors
  - Dependency: none
  - Output: `PathController` with spline/grid support, gizmo debug
  - Accept: 100% of agents reach core or die; no stalls >2s
- Task: Wave manager skeleton
  - Dependency: RNG service
  - Output: `WaveManager` with budget, spawn scheduling, seed
  - Accept: Given seed + table, emits exact spawn events

### Epic: Enemies
- Task: Enemy framework (HP, armor/shield, movement)
  - Dependency: Pathing
  - Output: `EnemyController` base + 3 derived types
  - Accept: Stats match config; events on death/escape
- Task: Boss split behavior
  - Dependency: Enemy framework
  - Output: `BossController` spawns 6 swarmers on death
  - Accept: Deterministic spawn positions/counts

### Epic: Towers
- Task: Placement and validation
  - Dependency: Core Systems
  - Output: Build nodes, placement rules, sell/refund
  - Accept: Invalid placements blocked with reason
- Task: Targeting modes
  - Dependency: Enemies present
  - Output: Strategy selectors (nearest/first/last/strongest)
  - Accept: Unit tests cover tie-breakers and ranges
- Task: Implement Laser, Gravity, EMP, Nanobot
  - Dependency: Targeting, placement
  - Output: 4 tower prefabs + behaviors + upgrades
  - Accept: DPS/DoT/slow/stun match spec within 1%

### Epic: Economy & Win/Lose
- Task: Salvage earnings and wave bonus
  - Dependency: Enemies, Wave manager
  - Output: Economy service; HUD hooks
  - Accept: Refund = 80%; earnings match tables
- Task: Station HP, end states
  - Dependency: Enemies reaching core
  - Output: Loss/win screens, state transitions
  - Accept: No mid-wave save; between-wave save works

### Epic: UI/HUD
- Task: HUD (salvage, wave, HP, speed toggle)
  - Dependency: Economy, Wave manager
  - Output: HUD canvas + bindings; 1×/2× speed
  - Accept: All values update within 1 frame
- Task: Wave preview panel
  - Dependency: Wave manager
  - Output: Enemy icons/counts/modifiers; start button
  - Accept: Matches upcoming composition exactly
- Task: Tower panel
  - Dependency: Towers
  - Output: Stats, DPS summary, upgrade/sell
  - Accept: ROI numbers reflect current buffs

### Epic: Meta Progression (Station Repair MVP)
- Task: Tech graph and unlocks
  - Dependency: Core gameplay functional
  - Output: 6–8 nodes; apply passive buffs
  - Accept: Buffs persist; toggleable in debug

### Epic: Data & Balancing
- Task: Config schemas
  - Dependency: Core Systems
  - Output: SO/JSON for towers, enemies, waves
  - Accept: Hot-reloadable in editor; validation tests
- Task: Difficulty curves
  - Dependency: Waves
  - Output: HP/speed/budget formulas, documented
  - Accept: Target TTKs met in simulation seeds

### Epic: Testing & CI
- Task: EditMode tests (logic)
  - Dependency: Systems under test
  - Output: Targeting, economy, scaling tests
  - Accept: >85% line coverage in Core assemblies
- Task: PlayMode sims (headless)
  - Dependency: Core gameplay
  - Output: 50-seed runs; determinism hash
  - Accept: Zero stalls/NaNs; perf budgets met

### Epic: Audio/VFX (MVP)
- Task: Hook SFX/music layers
  - Dependency: Events from gameplay
  - Output: Mixer, sliders, basic cues
  - Accept: No clipping; levels within targets

### Epic: Analytics & Cloud Save
- Task: Event schema + dispatch
  - Dependency: Gameplay events
  - Output: level_start/end, tower_place, etc.
  - Accept: Events visible in debug sink
- Task: Cloud save integration
  - Dependency: Local save
  - Output: Firebase sync; last-write-wins
  - Accept: Cross-restart persistence verified

### Parallelization Guidance
- Start in parallel: RNG, Pathing, Enemy base, Placement, Test scaffold
- Next: Wave manager + HUD + Targeting (parallel)
- Then: 4 towers (parallel per tower), economy hooks
- Finally: Meta, analytics, audio/vfx (parallel)

### Definition of Done (per task)
- Unit/PlayMode tests added and passing; coverage updated
- CI build green; no performance regressions
- Docs: short README in component folder; public APIs XML-docced

