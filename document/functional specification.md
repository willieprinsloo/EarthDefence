Perfect 👌 — since you’ll be leaning on AI-assisted development, the most useful thing is a detailed, structured TODO list that covers everything from game systems to launch tasks. You can then feed these step-by-step into your AI/dev pipeline.

Here’s a comprehensive TODO list for 🚀 Space Salvagers:

⸻

🧭 Game Overview
	•	Title: Space Salvagers (working title)
	•	Genre: Tower Defense with light meta-progression
	•	Setting: Derelict orbital stations overrun by alien swarms and rogue machines
	•	Core Pillars: Strategic placement, readable combat, meaningful upgrades, short sessions
	•	MVP Scope: One station map, four towers, four enemy types, 20 waves, meta repairs for simple buffs
	•	Victory: Survive all waves or complete station objective; Defeat: Station HP reaches 0 or enemies breach core

⸻

🎮 Core Game Loop (MVP)
	•	Plan: Review upcoming wave info (enemy types, count, modifiers). Place/upgrade towers using salvage
	•	Defend: Enemies spawn, path toward core; towers auto-fire per targeting rules
	•	Earn: Gain salvage from kills and wave-complete bonus
	•	Progress: Between waves, spend salvage on new towers/upgrades or on station repair (meta nodes)
	•	Repeat: Difficulty scales with each wave; boss or mini-boss every 5 waves

⸻

🕹 Controls
	•	iOS/Android Touch: Tap-hold to drag camera; pinch to zoom; tap node to place; tap tower to open radial menu
	•	Desktop (Editor/Debug): WASD/Right-drag to pan; scroll to zoom; left-click to place; right-click cancel
	•	Placement: Valid nodes highlight on hover; snap-to-node; red X if blocked/insufficient salvage
	•	Accessibility: Large touch targets (min 44pt); haptic feedback on place/upgrade/error (mobile)

⸻

📐 Camera & View
	•	Perspective: 2D/2.5D top-down with slight parallax
	•	Zoom: 3 steps (wide, mid, close). Persist choice per session
	•	Readability: Enemy health bars fade at distance; tower range ghost shows on select

⸻

🗺 Level & Pathing (MVP)
	•	Map: Single station with 2 spawn points and 1 core/exit
	•	Pathing: Predetermined spline/grid corridors; no dynamic walls for MVP
	•	Build Nodes: 20–30 predetermined sockets; some with adjacency buffs (later)
	•	Station HP: 20 core HP; each escaped enemy deals 1–3 HP based on size/tier

⸻

🔫 Towers — Detailed MVP
	•	Laser Turret
		•	Role: Single-target sustained DPS
		•	Base Stats: Cost 100, Range 5, Fire Rate 1.0 shots/s, Damage 15 energy, No splash
		•	Targeting: Nearest by default (switchable: strongest/first/last)
		•	Upgrades:
			•	Lv2 (+25% dmg, +10% range) cost 120
			•	Lv3 (+25% fire rate, +10% dmg) cost 180
		•	Path Mods (post-MVP): Beam splitter (chain to +1), Plasma burn (DoT 4s)
	•	Gravity Well
		•	Role: Area slow/control
		•	Base Stats: Cost 140, Radius 3, Slow 35%, Pulse every 0.75s, Damage 0
		•	Targeting: Passive aura; affects up to 20 enemies
		•	Upgrades:
			•	Lv2 (+10% slow, +0.5 radius) cost 150
			•	Lv3 (+5% slow, +0.5 radius, -0.1s pulse) cost 200
		•	Path Mods (post-MVP): Black hole burst (short stun), Field amplifier (+radius)
	•	EMP Shock Tower
		•	Role: AoE disable vs shields/robots
		•	Base Stats: Cost 160, Radius 2.5, Cooldown 4s, Damage 10 electric, Stun 0.6s to shielded/robotic
		•	Targeting: Prioritize shielded/robotic enemies in radius
		•	Upgrades:
			•	Lv2 (+0.2s stun, -0.5s CD) cost 170
			•	Lv3 (+0.2s stun, +10 dmg) cost 220
		•	Path Mods (post-MVP): Chain lightning (jumps 3), Pulse amplifier (+radius)
	•	Nanobot Swarm
		•	Role: Damage-over-time + utility
		•	Base Stats: Cost 120, Range 3.5, Fire Rate 0.8/s, DoT 8 dmg/s for 3s (stacks to 2)
		•	Targeting: Weakest HP first to finish runners
		•	Upgrades:
			•	Lv2 (+2 dmg/s, +0.5s duration) cost 130
			•	Lv3 (+2 dmg/s, +10% range) cost 180
		•	Path Mods (post-MVP): Infection spread (on death apply DoT), Repair aura (heal stations/towers)

⸻

👾 Enemies — Detailed MVP
	•	Alien Swarmers
		•	HP 40, Speed 2.0, Armor 0, Resist: none, Ability: pack bonus (+5% speed per 5 nearby)
		•	Salvage: 6, Core Damage: 1
	•	Rogue Robots
		•	HP 150, Speed 1.0, Armor 30% vs kinetic/energy, Weak to EMP (stun applies)
		•	Salvage: 12, Core Damage: 2
	•	AI Drones (Shielded)
		•	HP 80 + 60 shield, Speed 1.6, Shield reduces energy by 50% until broken
		•	Salvage: 10, Core Damage: 1
	•	Bio-Titan (Boss)
		•	HP 1200, Speed 0.8, Armor 20%, On death: splits into 6 Swarmers
		•	Salvage: 80, Core Damage: 3

⸻

📈 Waves & Difficulty Scaling (MVP)
	•	Waves: 20 total; boss on wave 10 and 20
	•	Spawn Budget: BaseBudget(w) = 60 + 10 × w; EnemyCost: Swarmers 6, Robots 12, Drones 10, Boss 80
	•	Scaling: Enemy HP × (1 + 0.05 × w), Speed × (1 + 0.01 × w)
	•	Mixing: Each wave has 2–3 enemy types max; preview panel lists composition and modifiers
	•	Modifiers (post-MVP): Fast, Heavily Armored, Shield Surge

⸻

🪙 Economy
	•	Starting Salvage: 200
	•	Income: On kill (see enemy salvage) + wave completion bonus (20 + 2 × wave)
	•	Refunds: Sell tower for 80% of invested cost (no cooldown)
	•	Costs: See tower base/upgrade costs above; meta repairs use a separate pool (earned between missions)

⸻

🏚 Station Repair & Tech Tree (Meta)
	•	Map: Node graph around the station; unlock lines to reach key modules
	•	Branches: Weapons (damage), Control (utility/targeting), Support (economy/defense)
	•	MVP Nodes: +10% laser damage, +1 starting tower slot, +5% salvage income, +1 station HP regen after wave
	•	Costs: 1–3 meta points per node; points earned by completing milestones (waves 5/10/15/20)
	•	Persistence: Cloud-synced; respec not in MVP

⸻

🖥 UI/UX (MVP)
	•	HUD: Salvage counter, wave counter/timer, station HP, fast-forward toggle (1×/2×)
	•	Build Menu: Contextual radial/menu on node tap; shows affordable towers first
	•	Tower Panel: Stats, DPS summary, range overlay toggle, upgrade/sell buttons
	•	Wave Preview: Enemy icons, counts, modifiers; next wave time; start wave button
	•	Feedback: Floating damage numbers (optional), hit effects, clear death pops
	•	Accessibility: Colorblind-friendly palettes; text scale 90–120%; tutorial tips can be re-opened

⸻

🎵 Audio (MVP)
	•	Music: Ambient build-up between waves; intensity layer during combat; boss cue layer
	•	SFX: Placement, upgrade, sell, laser, EMP, swarm chitter, robot stomp, boss roar
	•	Mix: Sidechain duck music slightly on heavy SFX bursts; sliders for SFX/Music/Master

⸻

✨ Visual Effects (MVP)
	•	Laser beam with additive glow; impact sparks
	•	EMP radial shockwave; brief screen chroma flash (reduced at low settings)
	•	Nanobot swarm particles with trail; enemy dissolve on death
	•	Performance mode: Simplified particles on low-end

⸻

🗄 Data & Balancing
	•	Config: ScriptableObjects per tower/enemy; JSON for wave tables
	•	Live Tuning: Debug sliders (dev only) to adjust damage/HP multipliers
	•	DPS Calculator: Internal tool to estimate tower DPS vs enemy types for balance passes

⸻

💾 Save & Cloud Sync
	•	Slots: 1 autosave per campaign + meta progression save
	•	Cloud: Firebase sync on app focus change and mission complete
	•	Conflict: Last-write-wins with manual restore option (post-MVP)

⸻

📊 Analytics (MVP)
	•	Core Events: session_start, session_end, level_start, level_end(reason, wave, hp_left),
		•	tower_place(type, cost), tower_upgrade(type, from, to, cost), tower_sell(type, refund)
		•	enemy_kill(type, wave), salvage_earned(amount, source), death(reason)
	•	Funnels: Tutorial completion, first-purchase (post-MVP), first-defeat, first-win

⸻

💰 Monetization (Non-intrusive)
	•	IAP SKUs (post-MVP): Cosmetic tower skins, station themes; no gameplay advantages
	•	Store: Preview in 3D/animated; purchases restore via StoreKit; parental gate when needed

⸻

⚙️ Technical Constraints & Targets
	•	Engine: Unity 2022 LTS; 2D URP
	•	iOS: iOS 15+, iPhone 8+; Target 60 FPS; Memory budget 600 MB total
	•	Android (post-MVP): Android 10+, mid-tier devices; 60 FPS target with scalable VFX
	•	Build Sizes: <200 MB install; use Addressables for content
	•	QA: Automated smoke tests for load, basic wave run, placement, upgrade, save/load

⸻

✅ Acceptance Criteria (MVP)
	•	Player can complete 20 waves on the station map at normal difficulty
	•	All four towers place/upgrade/sell correctly and meaningfully contribute
	•	All four enemy types spawn with intended behaviors and counters
	•	Economy supports at least 12–16 placements by wave 10 with room for upgrades
	•	Wave preview, HUD, tower panel, and end-of-level screens function without blocking issues
	•	Average session length 8–15 minutes; stable 55–60 FPS on target devices
	•	No progression blockers; save/load works across app restarts

⸻

🚫 Out of Scope (MVP)
	•	PvP or synchronous multiplayer
	•	Procedural map generation
	•	User-generated content/map editor
	•	Ads and reward videos
	•	Complex status effects beyond listed (e.g., freeze, poison variants)

⸻

🤖 AI Testing Strategy (Towers, Enemies, Waves)
	•	Goals
		•	Ensure enemy pathing, tower targeting, and wave orchestration are correct, deterministic, and performant
		•	Catch regressions in balance, behavior, and performance via automated headless runs
	•	Determinism & Replayability
		•	Single RNG service seeded per test; no use of UnityEngine.Random directly in gameplay code
		•	Fixed timestep for PlayMode tests; physics settings locked; disable vsync
		•	Record and replay: persist wave seed, spawn timestamps, and decisions to verify identical outcomes (hash of event stream)
	•	EditMode Unit Tests (pure logic)
		•	Target Selection: Given N mock enemies with distances/HP, verify selection for modes (nearest/strongest/weakest/first/last)
		•	Damage & Status: Verify DPS, DoT stacking caps, stun application rules (EMP vs shielded/robotic)
		•	Scaling: Enemy HP/speed and wave budget formulas produce expected values across waves 1–20
		•	Wave Budget Solver: Composition never exceeds budget; no negative counts; boss waves allocate correctly
		•	Economy: Refund = 80% of invested; wave-completion bonus calculation
	•	PlayMode/Integration Tests (headless scene)
		•	Pathing: Spawn batches along defined corridors; assert 100% reach core or die; zero “stuck > 3s” occurrences
		•	Placement/Range: Place towers on known nodes; verify range overlays and actual hit registration align within 0.1 units
		•	Tower vs Enemy Counters: EMP stuns shielded/robots; Gravity Well slow stacks capped; Laser deals full vs unarmored
		•	Wave Flow: Run waves 1–5 with scripted placements; assert station HP >= threshold and kill counts match expectations
		•	Save/Load: Mid-wave save disallowed; between-wave save/load restores state and deterministic next-wave outcome
	•	Property-Based & Fuzz
		•	Generate random enemy sets (within constraints) and verify invariants: no NaNs, no negative HP, no frame without progress for >2s
		•	Randomize tower placements within valid nodes; assert no performance spikes and no unreachable states
	•	Performance & Stability Gates
		•	Enemy Systems: With 200 active enemies, AI and pathing combined < 2.0 ms/frame on target device profile (Editor proxy < 1.0 ms)
		•	Tower Systems: With 50 towers, targeting + firing + VFX spawn < 2.5 ms/frame (Editor proxy < 1.5 ms)
		•	Memory: No growth after 5 consecutive waves (>2 minutes) beyond 10 MB; pooled projectiles/enemies reclaim on death
		•	Stuck Detector: Any unit not moving > 2s triggers reposition or kill-and-respawn in tests; zero occurrences allowed in CI
	•	Automation & CI
		•	Directories: Tests/EditMode for pure C#; Tests/PlayMode for scene-driven tests
		•	CLI: Run with Unity Test Runner in batchmode (editmode + playmode), XML results archived; coverage via Unity Code Coverage package
		•	Smoke Suite (fast): ~2 minutes, runs on every push; Full Suite (long): nightly includes 100-seed simulations
	•	Simulation Bot (rule-based)
		•	Script: Spend starting salvage on a prioritized build order; upgrade rules by ROI; sell low-ROI for boss prep
		•	Metrics: Median wave reached across 50 seeds; expected >= 10 on “Normal” with scripted placements
	•	Pass/Fail Thresholds (CI blockers)
		•	Determinism hash mismatch across two runs with same seed → fail
		•	Any stuck unit or NaN/Infinity in transforms/HP/damage → fail
		•	Performance budgets exceeded in standardized test scenes → fail
		•	Wave budget or economy invariant violations → fail

⸻

✅ Space Salvagers – Development TODO List

⸻

🎮 Core Game Systems
	•	Set up Unity project with 2D/2.5D pipeline.
	•	Implement wave manager (enemy spawner, scaling difficulty).
	•	Implement pathfinding system (enemy movement along corridors).
	•	Implement tower placement system (snap-to-node).
	•	Implement tower targeting system (nearest, strongest, weakest).
	•	Implement tower upgrade system (3 levels per tower).
	•	Implement enemy health/damage system.
	•	Implement salvage currency system (earned from kills).
	•	Implement game win/lose conditions (station HP or wave completion).

⸻

🔫 Towers (Base MVP)
	•	Laser Turret → single-target DPS + upgrades (beam splitter, plasma burn).
	•	Gravity Well → slow AoE + upgrades (wider field, black hole burst).
	•	EMP Shock Tower → AoE disable + upgrades (chain lightning, pulse amp).
	•	Nanobot Swarm → DoT + upgrades (infection spread, repair aura).

⸻

👾 Enemies
	•	Alien Swarms (fast, weak).
	•	Rogue Robots (armored, laser-resistant).
	•	AI Drones (shielded, fast, weak to EMP).
	•	Boss Enemy (bio-titan splitting into smaller units).

⸻

🏚 Station Repair & Progression
	•	Implement station repair map (modules locked at start).
	•	Add repair system → spend salvage to unlock nodes, paths, buffs.
	•	Implement tech tree UI (3 branches: Weapons, Control, Support).
	•	Add passive buffs (e.g., faster recharge, tower HP).
	•	Add campaign map with 5 stations (but MVP = 1).

⸻

🎨 Art & Visuals
	•	Create placeholder art for towers, enemies, and station.
	•	Replace with final neon cyberpunk designs (glow effects).
	•	Implement particle effects:
	•	Laser beams.
	•	EMP surges.
	•	Nanobot swarm particles.
	•	Enemy death explosions.
	•	Build sci-fi HUD UI (salvage counter, wave counter, tower menu).

⸻

🎵 Audio
	•	Import synthwave music pack (ambient + combat + boss).
	•	Add SFX: laser shots, EMP bursts, alien screeches, robot stomps.
	•	Add dynamic music system (intensity increases with waves).

⸻

💰 Monetization (No Ads)
	•	Implement IAP system (StoreKit + Firebase).
	•	Add cosmetic tower skins (retro pixel, neon, alien biotech).
	•	Add station themes (derelict, cyberpunk, alien infestation).
	•	Implement premium towers (Railgun, Plasma Shield, Orbital Strike).
	•	Add unlock flow for IAP items (persistent across sessions).

⸻

⚙️ Technical & Backend
	•	Integrate Firebase (analytics, crash reporting, cloud save).
	•	Implement cloud save (player progress sync).
	•	Add difficulty scaling algorithm (enemy HP, speed, spawn size).
	•	Add data-driven configs (JSON/ScriptableObjects for towers/enemies).

⸻

🧪 Testing
	•	Build debug tools (wave skip, spawn enemy, give salvage).
	•	Create internal playtest builds.
	•	Conduct balancing passes on tower DPS vs enemy HP.
	•	Test performance on low-end iPhones (optimize particles, pathfinding).

⸻

📱 App Store Prep
	•	Create App Store listing (title, subtitle, description).
	•	Generate app icon (glowing neon station silhouette).
	•	Capture screenshots with captions:
	•	Build towers.
	•	Defend against aliens.
	•	Repair your station.
	•	Unlock super modules.
	•	Cut 30-second gameplay trailer (synthwave track, quick cuts).
	•	Prepare keywords for ASO (tower defense, sci-fi, alien, space).

⸻

🚀 Launch & Post-Launch
	•	Release to TestFlight beta testers.
	•	Soft launch in Canada/Australia.
	•	Gather metrics → retention, monetization, difficulty.
	•	Global launch with PR push.
	•	Post-launch roadmap:
	•	+2 new towers.
	•	+2 new enemy types.
	•	New campaign station.
	•	Seasonal Battle Pass.

⸻