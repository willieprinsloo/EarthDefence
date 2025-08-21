import Foundation
import SpriteKit

// MARK: - Tower Type Definitions
enum TowerType: String, CaseIterable, Codable {
    // Core Damage Towers
    case machineGun = "machine_gun"
    case laserTurret = "laser_turret"
    case railgunEmplacement = "railgun_emplacement"
    case plasmaArcNode = "plasma_arc_node"
    case missilePDBattery = "missile_pd_battery"
    case nanobotSwarmDispenser = "nanobot_swarm_dispenser"
    case cryoFoamProjector = "cryo_foam_projector"
    case gravityWellProjector = "gravity_well_projector"
    case empShockTower = "emp_shock_tower"
    case plasmaMortar = "plasma_mortar"
    case kineticCannon = "kinetic_cannon"
    
    // Support Towers
    case droneBay = "drone_bay"
    case shieldProjector = "shield_projector"
    case hackingUplink = "hacking_uplink"
    case resourceHarvester = "resource_harvester"
    case repairDroneSpire = "repair_drone_spire"
    
    // Ultimate Towers
    case solarLanceArray = "solar_lance_array"
    case singularityCannon = "singularity_cannon"
    
    var category: TowerCategory {
        switch self {
        case .machineGun, .laserTurret, .railgunEmplacement, .plasmaArcNode,
             .missilePDBattery, .nanobotSwarmDispenser, .cryoFoamProjector,
             .gravityWellProjector, .empShockTower, .plasmaMortar, .kineticCannon:
            return .damage
        case .droneBay, .shieldProjector, .hackingUplink,
             .resourceHarvester, .repairDroneSpire:
            return .support
        case .solarLanceArray, .singularityCannon:
            return .ultimate
        }
    }
    
    var buildLimit: Int? {
        switch self {
        case .solarLanceArray, .singularityCannon:
            return 1
        default:
            return nil
        }
    }
}

enum TowerCategory: String, Codable {
    case damage
    case support
    case ultimate
}

// MARK: - Damage Types
enum DamageType: String, Codable {
    case laser = "LZR"
    case kinetic = "KIN"
    case plasma = "PLS"
    case electric = "ELE"
    case nano = "NAN"
    case gravity = "GRV"
    case cryo = "CRY"
    case explosive = "EXP"
    case corrupt = "HCK"
    case trueDamage = "true"
    
    var color: SKColor {
        switch self {
        case .laser: return SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .kinetic: return SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        case .plasma: return SKColor(red: 0.58, green: 0.0, blue: 0.83, alpha: 1.0)
        case .electric: return SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        case .nano: return SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        case .gravity: return SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        case .cryo: return SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .explosive: return SKColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0)
        case .corrupt: return SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        case .trueDamage: return SKColor.white
        }
    }
}

// MARK: - Status Effects
enum StatusEffectType: String, Codable {
    case heat
    case shock
    case corrode
    case freeze
    case hack
    case gravity
    case infection
    case slow
    case stun
    case vulnerable
}

struct StatusEffect: Codable {
    let type: StatusEffectType
    let duration: TimeInterval
    let intensity: Float
    let stackable: Bool
    let maxStacks: Int
    
    // Effect-specific properties
    var vulnerabilityPercent: Float?
    var armorReduction: Float?
    var speedReduction: Float?
    var damageReduction: Float?
    var damagePerSecond: Float?
}

// MARK: - Tower Stats
struct TowerStats: Codable {
    var damage: Float
    var fireRate: Float  // Attacks per second
    var range: Float
    var powerConsumption: Float
    var critChance: Float = 0
    var critMultiplier: Float = 1.0
    var armorPierce: Float = 0
    
    // Special properties
    var chains: Int?
    var splashRadius: Float?
    var projectilePierce: Int?
    var auraRadius: Float?
    var healPerSecond: Float?
    var resourceGeneration: Float?
    var shieldHP: Float?
    var droneCount: Int?
}

// MARK: - Tower Upgrades
struct TowerUpgrade: Codable {
    let tier: Int
    let name: String
    let cost: Int
    let powerCost: Float
    let description: String
    
    // Stat modifications
    var statModifiers: TowerStatModifiers?
    var addsStatus: StatusEffect?
    var addsAbility: TowerAbility?
}

struct TowerStatModifiers: Codable {
    var damagePercent: Float?
    var damageFlat: Float?
    var fireRatePercent: Float?
    var fireRateFlat: Float?
    var rangePercent: Float?
    var rangeFlat: Float?
    var critChanceFlat: Float?
    var critMultiplierFlat: Float?
    var armorPierceFlat: Float?
    var chainsFlat: Int?
    var splashRadiusFlat: Float?
}

// MARK: - Tower Abilities
struct TowerAbility: Codable {
    let name: String
    let description: String
    let cooldown: TimeInterval
    let duration: TimeInterval?
    let manualActivation: Bool
    
    // Ability effects
    var damageMultiplier: Float?
    var rangeMultiplier: Float?
    var instantDamage: Float?
    var areaEffect: AreaEffect?
    var specialEffect: String?
}

struct AreaEffect: Codable {
    let radius: Float
    let damage: Float?
    let damageType: DamageType
    let statusEffect: StatusEffect?
}

// MARK: - Tower Configuration
class TowerConfiguration {
    static let shared = TowerConfiguration()
    
    private var configurations: [TowerType: TowerConfig] = [:]
    
    private init() {
        loadConfigurations()
    }
    
    func getConfig(for type: TowerType) -> TowerConfig? {
        return configurations[type]
    }
    
    private func loadConfigurations() {
        // Load from TowerConfiguration.json
        guard let url = Bundle.main.url(forResource: "TowerConfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load tower configurations")
            loadDefaultConfigurations()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let config = try decoder.decode(TowerConfigurationFile.self, from: data)
            
            for towerData in config.towers {
                if let type = TowerType(rawValue: towerData.id) {
                    configurations[type] = towerData
                }
            }
        } catch {
            print("Error parsing tower configuration: \(error)")
            loadDefaultConfigurations()
        }
    }
    
    private func loadDefaultConfigurations() {
        // Fallback configurations if JSON fails to load
        configurations[.laserTurret] = createLaserTurretConfig()
        configurations[.railgunEmplacement] = createRailgunConfig()
        configurations[.plasmaArcNode] = createPlasmaArcConfig()
        configurations[.gravityWellProjector] = createGravityWellConfig()
        // Add more default configs as needed
    }
    
    private func createLaserTurretConfig() -> TowerConfig {
        return TowerConfig(
            id: "laser_turret",
            name: "Laser Turret",
            description: "Baseline DPS tower with armor shred",
            tier: 1,
            costCr: 100,
            powerMw: 1.0,
            baseStats: TowerStats(
                damage: 20,
                fireRate: 1.2,
                range: 6,
                powerConsumption: 1.0
            ),
            damageType: .laser,
            upgrades: [
                TowerUpgrade(
                    tier: 2,
                    name: "Beam Focuser",
                    cost: 50,
                    powerCost: 0,
                    description: "+25% damage, +1 range",
                    statModifiers: TowerStatModifiers(
                        damagePercent: 25,
                        rangeFlat: 1
                    ),
                    addsStatus: nil,
                    addsAbility: nil
                )
            ]
        )
    }
    
    private func createRailgunConfig() -> TowerConfig {
        return TowerConfig(
            id: "railgun_emplacement",
            name: "Railgun Emplacement",
            description: "Long-range armor breaker",
            tier: 1,
            costCr: 220,
            powerMw: 1.5,
            baseStats: TowerStats(
                damage: 180,
                fireRate: 0.4,
                range: 9,
                powerConsumption: 1.5,
                armorPierce: 50
            ),
            damageType: .kinetic,
            upgrades: []
        )
    }
    
    private func createPlasmaArcConfig() -> TowerConfig {
        return TowerConfig(
            id: "plasma_arc_node",
            name: "Plasma Arc Node",
            description: "Chain lightning for swarms",
            tier: 1,
            costCr: 180,
            powerMw: 1.2,
            baseStats: TowerStats(
                damage: 24,
                fireRate: 1.8,
                range: 5,
                powerConsumption: 1.2,
                chains: 3
            ),
            damageType: .plasma,
            upgrades: []
        )
    }
    
    private func createGravityWellConfig() -> TowerConfig {
        return TowerConfig(
            id: "gravity_well_projector",
            name: "Gravity Well Projector",
            description: "Pulls and clusters enemies",
            tier: 1,
            costCr: 260,
            powerMw: 1.8,
            baseStats: TowerStats(
                damage: 0,
                fireRate: 0.5,
                range: 6,
                powerConsumption: 1.8,
                auraRadius: 6
            ),
            damageType: .gravity,
            upgrades: []
        )
    }
}

// MARK: - Tower Config Data Structures
struct TowerConfigurationFile: Codable {
    let towers: [TowerConfig]
    let damageTypes: [String: DamageTypeInfo]
    let statusEffects: [String: StatusEffectInfo]
    let synergies: [TowerSynergy]
}

struct TowerConfig: Codable {
    let id: String
    let name: String
    let description: String
    let tier: Int
    let costCr: Int
    let powerMw: Float
    let baseStats: TowerStats
    let damageType: DamageType
    let upgrades: [TowerUpgrade]
}

struct DamageTypeInfo: Codable {
    let name: String
    let color: String
}

struct StatusEffectInfo: Codable {
    let name: String
    let description: String
    let stackable: Bool
    let maxStacks: Int?
}

struct TowerSynergy: Codable {
    let source: String
    let target: String
    let effect: String
}