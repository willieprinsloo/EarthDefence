# Space Salvagers - Game Design Document

## Game Overview

**Genre**: Tower Defense  
**Platform**: iOS/macOS  
**Target Audience**: Casual to mid-core strategy gamers  
**Art Style**: Neon outline sci-fi aesthetic  
**Theme**: Portal Defense - Stop alien invasion from outer planets  

## Story & Setting

### The Portal Invasion
Alien forces have established portals at the edge of our solar system and are invading planet by planet toward Earth. As humanity's last line of defense, players must fortify each planet's defensive outposts to prevent the aliens from opening portals closer to Earth.

### Progression Path
The invasion begins at the outer planets and moves inward:
- **Makemake & Eris**: First contact with alien portals
- **Pluto & Neptune**: Outer defense perimeter
- **Uranus & Saturn**: Research and mining stations under siege
- **Jupiter**: Major defensive stronghold
- **Asteroid Belt**: Mining operations crucial for resources
- **Mars**: Humanity's second home under threat
- **Earth**: Final stand for humanity
- **Venus & Mercury**: Last desperate defenses if Earth falls

## Core Game Loop

1. **Preparation Phase**
   - Player places/upgrades towers using salvage
   - Strategic positioning on limited build nodes
   - Resource management decisions

2. **Combat Phase**
   - Enemies spawn and follow predetermined paths
   - Towers automatically target and fire
   - Player earns salvage from destroyed enemies
   - Can still build/upgrade during combat

3. **Wave Completion**
   - No salvage bonus (only from enemy kills)
   - "Ready for next wave!" message appears
   - Brief respite to prepare for next wave
   - Health restored only between maps

4. **Map Progression**
   - Complete all waves to unlock next map
   - Auto-advance to next map after 3 seconds
   - Starting salvage provided: 120 + (mapNumber * 40)
   - Tower refunds between maps (80%)
   - Failure returns player to map selection

## Detailed Mechanics

### Tower Mechanics

#### Targeting Systems
- **Nearest**: Laser towers - focus closest threats
- **First**: Cannon towers - prevent leaks
- **Furthest**: Missile towers - maximum tracking time
- **Strongest**: Plasma towers - eliminate tanks
- **Weakest**: Tesla towers - clear swarms

#### Rotation and Aiming
- Smooth interpolated rotation (15% per frame)
- Aiming tolerance varies by tower type
- Predictive targeting for moving enemies
- Visual turret tracking

#### Upgrade System
- 3 levels per tower
- Cost: 150% of base price per upgrade
- Damage scales: Base + (level * multiplier)
- Range increases: 20% per level
- Fire rate improves: 20% per level
- Visual changes at each level

### Enemy Behavior

#### Path Following
- Bezier curve interpolation
- Variable speed based on enemy type
- No collision between enemies
- Waypoint system for complex paths

#### Special Behaviors
- **Swarm**: Zigzag movement pattern
- **Shield**: Regenerating shield bubble
- **Stealth**: Phases in/out (harder to target)
- **Destroyer**: Tank role, absorbs damage

#### Damage System
- Instant damage (laser, tesla)
- Projectile damage (cannon, plasma, missile)
- Area damage (plasma explosion, tesla chain)
- Damage types affect different enemies

### Economy System

#### Income Sources
- Enemy kills ONLY: 1-12 salvage based on type
  - Scout: 1 salvage
  - Swarm: 2 salvage
  - Fighter: 5 salvage
  - Bomber: 8 salvage
  - Shield: 10 salvage
  - Destroyer: 12 salvage
- Starting salvage per map: 120 + (mapNumber * 40)
- No wave or map completion bonuses
- No passive income

#### Spending
- Tower purchase:
  - Cannon: 80 salvage
  - Laser: 120 salvage
  - Plasma: 120 salvage
  - Missile: 400 salvage
  - Tesla/EMP: 500 salvage
- Tower upgrade: 150% of base cost
- Sell refund: 80% of total investment

#### Balance Philosophy
- Tight economy forces choices
- Can't afford all towers immediately
- Mistakes are costly but recoverable
- Risk/reward for greedy strategies

### Difficulty Progression

#### Wave Scaling
- Maps 1-2: 3 waves
- Maps 3-4: 4 waves  
- Maps 5+: 5 waves
- Enemy count: 15 + (waveNumber * 4)
- Enemy health increases per map

#### Enemy Introduction
- Wave 1: Scouts only
- Wave 2: Scouts + Swarms
- Waves 3-4: + Fighters
- Waves 5-6: + Stealth units
- Waves 7-8: + Shields, Bombers
- Waves 9+: + Destroyers
- Late game: All types mixed

#### Map Complexity & Themes
1. **Mercury Station**: Simple path - Close to sun with mining debris
2. **Venus Cloud City**: Dual paths - Toxic atmosphere and destroyed platforms
3. **Earth Defense**: Complex maze - Last stand with orbital stations
4. **Mars Colony**: Multiple entries - Red planet with abandoned colonies
5. **Asteroid Belt**: Scattered nodes - Dense asteroids and mining wrecks
6. **Jupiter Station**: Circular path - Gas giant with many moons
7. **Saturn Rings**: Ring formation - Research stations in rings
8. **Uranus Outpost**: Ice maze - Frozen defenses
9. **Neptune Base**: Deep space paths - Dark and mysterious
10. **Pluto Frontier**: Edge defense - First contact zone
11. **Eris Research**: Experimental layout - Alien artifacts
12. **Makemake Final**: Ultimate challenge - Portal nexus

## Visual Design

### Art Direction
- **Neon Outline Style**: All sprites use glowing strokes
- **Dynamic Backgrounds**: Each map has unique space environments
  - Planets in various states (intact, damaged, invaded)
  - Destroyed ships and stations floating in space
  - Asteroid fields and space debris
  - Alien portals on outer planets
  - Nebulas and galaxy formations
- **Color Language**:
  - Red: Damage/danger/portal breach
  - Blue: Shields/defense
  - Green: Health/salvage
  - Purple: Alien technology/portals
  - Yellow: Warning/kinetic
  - Cyan: Energy/laser
  - Orange: Critical warnings

### Effects System

#### Projectile Effects
- Laser: Instant beam with core + glow layers
- Cannon: Physical shell with trail
- Plasma: Glowing orb with particles
- Missile: Homing with exhaust trail
- Tesla: Branching lightning

#### Impact Effects
- Screen shake (high damage)
- Particle bursts
- Damage numbers
- Enemy shake/flash
- Color-coded by damage type

#### UI Effects
- Pulsing low health warning
- Button glow on hover
- Smooth transitions
- Progress bars
- Floating text

### Audio Design (Planned)

#### Sound Effects
- Unique firing sound per tower
- Impact sounds by damage type
- Enemy destruction
- UI interactions
- Warning alarms

#### Music
- Ambient space theme
- Combat intensity layers
- Victory/defeat stingers

## User Interface

### Main Menu
- Galaxy spiral background with Earth and Mars
- "SPACE SALVAGERS" title with glow effects
- "DEFEND THE SOLAR SYSTEM" subtitle
- Play and Settings buttons

### Map Selection (Solar System View)
- Interactive solar system with orbital paths
- Planets as selectable maps with visual states:
  - Locked: Dark with lock icon
  - Available: Normal color with glow
  - Current: Pulsing with targeting reticle
  - Completed: Green checkmark
- Scrollable view with smooth camera movement
- Shows waves and map names

### HUD Layout
- Top: Score, salvage (with icon), wave counter (X/Y)
- Bottom Right: Start/Next wave button (circular)
- Top Right: Station health with icon
- Left: Speed control (1x/2x/3x)
- Center: Gameplay area

### Tower Menu
- Radial menu on build node tap
- Shows available towers
- Cost displayed clearly
- Grayed out if can't afford
- Range preview on hover

### Feedback Systems
- Damage numbers (floating text)
- Salvage gain notifications (+X with glow)
- Wave announcements ("Ready for next wave!")
- Low health warnings (red pulse)
- Tower ready indicators
- Critical messages with background panels:
  - "Not enough salvage!" with shake effect
  - "Portal breached!" on game over
  - Starting salvage amount on new map

## Monetization Strategy (Future)

### Premium Version
- No ads
- Bonus starting salvage
- Exclusive tower skins
- Additional maps

### In-App Purchases
- Map packs
- Tower packs
- Salvage doublers
- Cosmetic themes

### Progression Systems
- Tower unlock system
- Achievement rewards
- Daily challenges
- Leaderboards

## Technical Architecture

### Entity Component System
- Flexible tower/enemy creation
- Efficient update loops
- Easy to extend
- Performance optimized

### Scene Management
- Main menu scene (with galaxy background)
- Map selection scene (solar system view)
- Game scene (with dynamic backgrounds)
- Settings scene
- Game over returns to map selection

### Save System
- High scores
- Unlocked content
- Settings preferences
- Progress tracking

## Balance Formulas

### Tower Damage
```
Damage = BaseDamage + (Level * ScalingFactor)
Laser: 5 + (level * 2)
Cannon: 1 (flat)
Plasma: 3 + (level * 2)
Missile: 3 * level
Tesla: 2 + level
```

### Enemy Health
```
Health = BaseHealth * (1 + MapNumber * 0.2)
```

### Salvage Rewards
```
Reward = BaseReward * DifficultyMultiplier
```

### Wave Timing
```
SpawnDelay = max(0.8, 1.5 - (MapNumber * 0.2))
```

## Future Features

### Planned Updates
- Boss enemies (Portal Guardians)
- Special abilities (Emergency shields, orbital strikes)
- Tower synergies
- Endless mode (Defend Earth indefinitely)
- Co-op multiplayer (Defend multiple planets)
- Map editor
- Cloud saves
- Achievements
- Story mode cutscenes

### Experimental Ideas
- Tower fusion mechanics
- Enemy mutations
- Environmental hazards
- Power-up drops
- Hero units
- Research tree
- Base building

## Performance Targets

- 60 FPS on iPhone 12+
- 30 FPS minimum on iPhone 8
- Load time < 3 seconds
- Memory usage < 200MB
- Battery efficient

## Success Metrics

- Session length: 10-15 minutes
- Retention D1: 40%
- Retention D7: 20%
- Completion rate Map 1: 80%
- Completion rate Map 5: 30%
- Upgrade rate: 60% of towers

---

*Last Updated: Current Version*