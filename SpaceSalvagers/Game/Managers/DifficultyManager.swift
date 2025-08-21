import Foundation
import SpriteKit

// MARK: - Difficulty Manager
class DifficultyManager {
    
    static let shared = DifficultyManager()
    
    // Current difficulty settings
    private(set) var currentDifficulty: DifficultyLevel = .normal
    private var difficultyConfig: DifficultyConfiguration?
    private var currentWave: Int = 1
    
    // Difficulty modifiers
    private(set) var enemyHealthMultiplier: Float = 1.0
    private(set) var enemySpeedMultiplier: Float = 1.0
    private(set) var enemyCountMultiplier: Float = 1.0
    private(set) var enemySpawnRate: Float = 1.5
    private(set) var startingResources: Int = 300
    private(set) var startingLives: Int = 5
    private(set) var resourcePerKillMultiplier: Float = 1.0
    private(set) var waveBonusMultiplier: Float = 1.0
    
    // Special modifiers
    private(set) var armorBonus: Int = 0
    private(set) var shieldEnemies: Bool = false
    private(set) var eliteSpawnChance: Float = 0.0
    private(set) var bossHealthMultiplier: Float = 1.0
    private(set) var towerCostMultiplier: Float = 1.0
    private(set) var powerConsumptionMultiplier: Float = 1.0
    private(set) var enemyRegen: Float = 0.0
    private(set) var disableSelling: Bool = false
    private(set) var randomPathSwitching: Bool = false
    
    // Challenge modifiers
    private var activeChallenges: Set<ChallengeModifier> = []
    
    // MARK: - Initialization
    
    private init() {
        loadDifficultyConfiguration()
    }
    
    private func loadDifficultyConfiguration() {
        guard let url = Bundle.main.url(forResource: "DifficultyConfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load difficulty configuration")
            return
        }
        
        do {
            difficultyConfig = try JSONDecoder().decode(DifficultyConfiguration.self, from: data)
            print("Difficulty configuration loaded successfully")
        } catch {
            print("Failed to decode difficulty configuration: \(error)")
        }
    }
    
    // MARK: - Difficulty Management
    
    func setDifficulty(_ level: DifficultyLevel) {
        currentDifficulty = level
        applyDifficultySettings()
    }
    
    private func applyDifficultySettings() {
        guard let config = difficultyConfig,
              let settings = config.difficultyLevels[currentDifficulty.rawValue] else {
            print("No settings found for difficulty: \(currentDifficulty)")
            return
        }
        
        // Apply base multipliers
        enemyHealthMultiplier = settings.enemyHealthMultiplier
        enemySpeedMultiplier = settings.enemySpeedMultiplier
        enemyCountMultiplier = settings.enemyCountMultiplier
        enemySpawnRate = settings.enemySpawnRate
        startingResources = settings.startingResources
        startingLives = settings.startingLives
        resourcePerKillMultiplier = settings.resourcePerKillMultiplier
        waveBonusMultiplier = settings.waveBonusMultiplier
        
        // Apply special modifiers
        if let special = settings.specialModifiers {
            armorBonus = special.armorBonus ?? 0
            shieldEnemies = special.shieldEnemies ?? false
            eliteSpawnChance = special.eliteSpawnChance ?? 0.0
            bossHealthMultiplier = special.bossHealthMultiplier ?? 1.0
            towerCostMultiplier = special.towerCostMultiplier ?? 1.0
            powerConsumptionMultiplier = special.powerConsumptionMultiplier ?? 1.0
            enemyRegen = special.enemyRegen ?? 0.0
            disableSelling = special.disableSelling ?? false
            randomPathSwitching = special.randomPathSwitching ?? false
        }
        
        // Apply balance changes for harder game (if on hard or above)
        if currentDifficulty.rawValue >= DifficultyLevel.hard.rawValue {
            applyHarderGameBalance()
        }
        
        print("Applied difficulty settings for: \(settings.name)")
    }
    
    private func applyHarderGameBalance() {
        guard let config = difficultyConfig,
              let balance = config.balanceChangesForHarderGame else { return }
        
        // Enemy buffs
        if let enemyBuffs = balance.enemyBuffs {
            enemyHealthMultiplier *= (1.0 + Float(enemyBuffs.baseHealthIncrease ?? 0) / 100.0)
            enemySpeedMultiplier *= (1.0 + Float(enemyBuffs.baseSpeedIncrease ?? 0) / 100.0)
            armorBonus += enemyBuffs.armorScaling ?? 0
        }
        
        // Tower nerfs
        if let towerNerfs = balance.towerNerfs {
            // These would be applied to tower damage calculations
            towerCostMultiplier *= towerNerfs.upgradeCostIncrease ?? 1.0
        }
        
        // Economy adjustments
        if let economy = balance.economyAdjustments {
            resourcePerKillMultiplier *= economy.killRewardReduction ?? 1.0
            waveBonusMultiplier *= economy.waveBonusReduction ?? 1.0
        }
    }
    
    // MARK: - Wave Management
    
    func getWaveEnemyComposition(wave: Int) -> [String: Float] {
        guard let config = difficultyConfig else {
            return ["alienSwarmer": 1.0]
        }
        
        currentWave = wave
        
        // Determine wave range
        let composition: [String: Float]
        if wave <= 5 {
            composition = config.enemyComposition.wave1to5 ?? [:]
        } else if wave <= 10 {
            composition = config.enemyComposition.wave6to10 ?? [:]
        } else if wave <= 15 {
            composition = config.enemyComposition.wave11to15 ?? [:]
        } else if wave <= 20 {
            composition = config.enemyComposition.wave16to20 ?? [:]
        } else {
            composition = config.enemyComposition.wave21Plus ?? [:]
        }
        
        return composition
    }
    
    func getWaveEnemyCount(wave: Int) -> Int {
        guard let config = difficultyConfig else { return 10 }
        
        let baseCount = config.waveScaling.baseEnemyCount
        let increasePerWave = config.waveScaling.countIncreasePerWave
        
        var count = baseCount + (increasePerWave * wave)
        count = Int(Float(count) * enemyCountMultiplier)
        
        // Special wave modifiers
        if let modifier = getWaveModifier(wave: wave) {
            if modifier.modifier == "swarm" {
                count *= 2 // Double enemies, but they have half health
            }
        }
        
        return count
    }
    
    func getEnemyStatsForWave(wave: Int) -> (health: Float, speed: Float, armor: Int) {
        guard let config = difficultyConfig else {
            return (health: 100, speed: 100, armor: 0)
        }
        
        let healthIncrease = pow(config.waveScaling.healthIncreasePerWave, Float(wave - 1))
        let speedIncrease = pow(config.waveScaling.speedIncreasePerWave, Float(wave - 1))
        
        var health = 100.0 * healthIncrease * enemyHealthMultiplier
        var speed = 100.0 * speedIncrease * enemySpeedMultiplier
        var armor = armorBonus
        
        // Apply wave modifiers
        if let modifier = getWaveModifier(wave: wave) {
            switch modifier.modifier {
            case "speed_burst":
                speed *= 1.5
            case "armor_surge":
                armor += 20
            case "swarm":
                health *= 0.5 // Half health for swarm
            case "shield_wall":
                armor += 10
            default:
                break
            }
        }
        
        return (health: health, speed: speed, armor: armor)
    }
    
    func getWaveModifier(wave: Int) -> WaveModifier? {
        guard let config = difficultyConfig else { return nil }
        
        return config.waveScaling.specialWaveModifiers?.first { $0.wave == wave }
    }
    
    func isBossWave(wave: Int) -> Bool {
        guard let config = difficultyConfig else { return false }
        
        return config.bossWaves[String(wave)] != nil
    }
    
    func getBossConfiguration(wave: Int) -> BossWaveConfig? {
        guard let config = difficultyConfig else { return nil }
        
        return config.bossWaves[String(wave)]
    }
    
    // MARK: - Challenge Modifiers
    
    func activateChallenge(_ challenge: ChallengeModifier) {
        activeChallenges.insert(challenge)
        applyChallengeModifier(challenge)
    }
    
    func deactivateChallenge(_ challenge: ChallengeModifier) {
        activeChallenges.remove(challenge)
        // Reapply base difficulty settings
        applyDifficultySettings()
        
        // Reapply all active challenges
        for activeChallenge in activeChallenges {
            applyChallengeModifier(activeChallenge)
        }
    }
    
    private func applyChallengeModifier(_ challenge: ChallengeModifier) {
        guard let config = difficultyConfig,
              let modifier = config.challengeModifiers[challenge.rawValue] else { return }
        
        switch challenge {
        case .noSelling:
            disableSelling = true
        case .expensiveTowers:
            towerCostMultiplier *= modifier.towerCostMultiplier ?? 1.5
        case .powerShortage:
            powerConsumptionMultiplier *= 2.0 // Inverse of power availability
        case .fogOfWar:
            // This would be applied to tower range calculations
            break
        case .eliteForces:
            eliteSpawnChance = 1.0
        case .speedRun:
            enemySpeedMultiplier *= modifier.speedMultiplier ?? 2.0
        case .ironman:
            startingLives = modifier.lives ?? 1
        }
    }
    
    // MARK: - Score Calculation
    
    func calculateScoreMultiplier() -> Float {
        var multiplier: Float = 1.0
        
        // Base difficulty multiplier
        switch currentDifficulty {
        case .easy:
            multiplier = 0.8
        case .normal:
            multiplier = 1.0
        case .hard:
            multiplier = 1.3
        case .nightmare:
            multiplier = 1.6
        case .impossible:
            multiplier = 2.0
        }
        
        // Challenge modifiers
        guard let config = difficultyConfig else { return multiplier }
        
        for challenge in activeChallenges {
            if let modifier = config.challengeModifiers[challenge.rawValue] {
                multiplier *= modifier.scoreMultiplier
            }
        }
        
        return multiplier
    }
    
    // MARK: - Enemy Creation
    
    func createEnemy(type: String, for wave: Int) -> EnemyConfiguration {
        let stats = getEnemyStatsForWave(wave: wave)
        
        var config = EnemyConfiguration(
            type: type,
            health: stats.health,
            speed: stats.speed,
            armor: stats.armor,
            hasShield: shieldEnemies,
            regeneration: enemyRegen,
            isElite: Float.random(in: 0...1) < eliteSpawnChance
        )
        
        // Apply special enemy abilities from harder game balance
        if let diffConfig = difficultyConfig,
           let abilities = diffConfig.balanceChangesForHarderGame?.specialEnemyAbilities?[type] {
            config.dodgeChance = abilities.dodgeChance ?? 0
            config.speedBoostWhenHurt = abilities.speedBoostWhenHurt ?? 1.0
            config.armorIncrease = abilities.armorIncrease ?? 0
            config.empResistance = abilities.empResistance ?? 0
            config.shieldRegeneration = abilities.shieldRegeneration ?? 0
            config.teleportChance = abilities.teleportChance ?? 0
            config.spawnMinionsOnDamage = abilities.spawnMinionsOnDamage ?? false
            config.rageModeAtHalfHealth = abilities.rageModeAtHalfHealth ?? false
        }
        
        // Elite enemies get additional buffs
        if config.isElite {
            config.health *= 1.5
            config.armor += 10
            config.speed *= 1.2
        }
        
        return config
    }
    
    // MARK: - Tower Cost Calculation
    
    func getTowerCost(baseCost: Int) -> Int {
        return Int(Float(baseCost) * towerCostMultiplier)
    }
    
    func getUpgradeCost(baseCost: Int) -> Int {
        var cost = Float(baseCost) * towerCostMultiplier
        
        // Additional cost increase for upgrades on harder difficulties
        if currentDifficulty.rawValue >= DifficultyLevel.hard.rawValue {
            cost *= 1.3
        }
        
        return Int(cost)
    }
    
    // MARK: - Resource Calculation
    
    func getKillReward(baseReward: Int) -> Int {
        return Int(Float(baseReward) * resourcePerKillMultiplier)
    }
    
    func getWaveBonus(baseBonus: Int) -> Int {
        return Int(Float(baseBonus) * waveBonusMultiplier)
    }
}

// MARK: - Enums

enum DifficultyLevel: String, CaseIterable {
    case easy = "easy"
    case normal = "normal"
    case hard = "hard"
    case nightmare = "nightmare"
    case impossible = "impossible"
    
    var displayName: String {
        switch self {
        case .easy: return "Recruit"
        case .normal: return "Soldier"
        case .hard: return "Veteran"
        case .nightmare: return "Commander"
        case .impossible: return "Legend"
        }
    }
}

enum ChallengeModifier: String {
    case noSelling = "no_selling"
    case expensiveTowers = "expensive_towers"
    case powerShortage = "power_shortage"
    case fogOfWar = "fog_of_war"
    case eliteForces = "elite_forces"
    case speedRun = "speed_run"
    case ironman = "ironman"
}

// MARK: - Configuration Structures

struct DifficultyConfiguration: Codable {
    let difficultyLevels: [String: DifficultySettings]
    let waveScaling: WaveScaling
    let enemyComposition: EnemyComposition
    let bossWaves: [String: BossWaveConfig]
    let challengeModifiers: [String: ChallengeModifierConfig]
    let balanceChangesForHarderGame: BalanceChanges?
    let recommendedDifficulty: String
    let autoScaling: AutoScaling?
    
    enum CodingKeys: String, CodingKey {
        case difficultyLevels = "difficulty_levels"
        case waveScaling = "wave_scaling"
        case enemyComposition = "enemy_composition"
        case bossWaves = "boss_waves"
        case challengeModifiers = "challenge_modifiers"
        case balanceChangesForHarderGame = "balance_changes_for_harder_game"
        case recommendedDifficulty = "recommended_difficulty"
        case autoScaling = "auto_scaling"
    }
}

struct DifficultySettings: Codable {
    let name: String
    let enemyHealthMultiplier: Float
    let enemySpeedMultiplier: Float
    let enemyCountMultiplier: Float
    let enemySpawnRate: Float
    let startingResources: Int
    let startingLives: Int
    let resourcePerKillMultiplier: Float
    let waveBonusMultiplier: Float
    let specialModifiers: SpecialModifiers?
    
    enum CodingKeys: String, CodingKey {
        case name
        case enemyHealthMultiplier = "enemy_health_multiplier"
        case enemySpeedMultiplier = "enemy_speed_multiplier"
        case enemyCountMultiplier = "enemy_count_multiplier"
        case enemySpawnRate = "enemy_spawn_rate"
        case startingResources = "starting_resources"
        case startingLives = "starting_lives"
        case resourcePerKillMultiplier = "resource_per_kill_multiplier"
        case waveBonusMultiplier = "wave_bonus_multiplier"
        case specialModifiers = "special_modifiers"
    }
}

struct SpecialModifiers: Codable {
    let armorBonus: Int?
    let shieldEnemies: Bool?
    let eliteSpawnChance: Float?
    let bossHealthMultiplier: Float?
    let towerCostMultiplier: Float?
    let powerConsumptionMultiplier: Float?
    let enemyRegen: Float?
    let disableSelling: Bool?
    let randomPathSwitching: Bool?
    
    enum CodingKeys: String, CodingKey {
        case armorBonus = "armor_bonus"
        case shieldEnemies = "shield_enemies"
        case eliteSpawnChance = "elite_spawn_chance"
        case bossHealthMultiplier = "boss_health_multiplier"
        case towerCostMultiplier = "tower_cost_multiplier"
        case powerConsumptionMultiplier = "power_consumption_multiplier"
        case enemyRegen = "enemy_regen"
        case disableSelling = "disable_selling"
        case randomPathSwitching = "random_path_switching"
    }
}

struct WaveScaling: Codable {
    let baseEnemyCount: Int
    let countIncreasePerWave: Int
    let healthIncreasePerWave: Float
    let speedIncreasePerWave: Float
    let bossWaveInterval: Int
    let eliteWaveStart: Int
    let specialWaveModifiers: [WaveModifier]?
    
    enum CodingKeys: String, CodingKey {
        case baseEnemyCount = "base_enemy_count"
        case countIncreasePerWave = "count_increase_per_wave"
        case healthIncreasePerWave = "health_increase_per_wave"
        case speedIncreasePerWave = "speed_increase_per_wave"
        case bossWaveInterval = "boss_wave_interval"
        case eliteWaveStart = "elite_wave_start"
        case specialWaveModifiers = "special_wave_modifiers"
    }
}

struct WaveModifier: Codable {
    let wave: Int
    let modifier: String
    let description: String
}

struct EnemyComposition: Codable {
    let wave1to5: [String: Float]?
    let wave6to10: [String: Float]?
    let wave11to15: [String: Float]?
    let wave16to20: [String: Float]?
    let wave21Plus: [String: Float]?
    
    enum CodingKeys: String, CodingKey {
        case wave1to5 = "wave_1_5"
        case wave6to10 = "wave_6_10"
        case wave11to15 = "wave_11_15"
        case wave16to20 = "wave_16_20"
        case wave21Plus = "wave_21_plus"
    }
}

struct BossWaveConfig: Codable {
    let boss: String
    let count: Int?
    let elite: Bool?
    let minions: MinionsConfig
    let minionCount: Int
    let healthMultiplier: Float?
    let special: String?
    
    enum CodingKeys: String, CodingKey {
        case boss
        case count
        case elite
        case minions
        case minionCount = "minion_count"
        case healthMultiplier = "health_multiplier"
        case special
    }
    
    enum MinionsConfig: Codable {
        case array([String])
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let array = try? container.decode([String].self) {
                self = .array(array)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw DecodingError.typeMismatch(MinionsConfig.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected array or string"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .array(let array):
                try container.encode(array)
            case .string(let string):
                try container.encode(string)
            }
        }
    }
}

struct ChallengeModifierConfig: Codable {
    let name: String
    let description: String
    let scoreMultiplier: Float
    let towerCostMultiplier: Float?
    let powerMultiplier: Float?
    let rangeMultiplier: Float?
    let speedMultiplier: Float?
    let lives: Int?
    let eliteOnly: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case scoreMultiplier = "score_multiplier"
        case towerCostMultiplier = "tower_cost_multiplier"
        case powerMultiplier = "power_multiplier"
        case rangeMultiplier = "range_multiplier"
        case speedMultiplier = "speed_multiplier"
        case lives
        case eliteOnly = "elite_only"
    }
}

struct BalanceChanges: Codable {
    let enemyBuffs: EnemyBuffs?
    let towerNerfs: TowerNerfs?
    let economyAdjustments: EconomyAdjustments?
    let specialEnemyAbilities: [String: EnemyAbility]?
    
    enum CodingKeys: String, CodingKey {
        case enemyBuffs = "enemy_buffs"
        case towerNerfs = "tower_nerfs"
        case economyAdjustments = "economy_adjustments"
        case specialEnemyAbilities = "special_enemy_abilities"
    }
}

struct EnemyBuffs: Codable {
    let baseHealthIncrease: Int?
    let baseSpeedIncrease: Int?
    let armorScaling: Int?
    let spawnRateDecrease: Float?
    let pathSpeedVariance: Bool?
    
    enum CodingKeys: String, CodingKey {
        case baseHealthIncrease = "base_health_increase"
        case baseSpeedIncrease = "base_speed_increase"
        case armorScaling = "armor_scaling"
        case spawnRateDecrease = "spawn_rate_decrease"
        case pathSpeedVariance = "path_speed_variance"
    }
}

struct TowerNerfs: Codable {
    let damageReduction: Float?
    let fireRateReduction: Float?
    let rangeReduction: Float?
    let upgradeCostIncrease: Float?
    
    enum CodingKeys: String, CodingKey {
        case damageReduction = "damage_reduction"
        case fireRateReduction = "fire_rate_reduction"
        case rangeReduction = "range_reduction"
        case upgradeCostIncrease = "upgrade_cost_increase"
    }
}

struct EconomyAdjustments: Codable {
    let startingResources: Int?
    let killRewardReduction: Float?
    let waveBonusReduction: Float?
    let noInterestOnSavedResources: Bool?
    
    enum CodingKeys: String, CodingKey {
        case startingResources = "starting_resources"
        case killRewardReduction = "kill_reward_reduction"
        case waveBonusReduction = "wave_bonus_reduction"
        case noInterestOnSavedResources = "no_interest_on_saved_resources"
    }
}

struct EnemyAbility: Codable {
    let dodgeChance: Float?
    let speedBoostWhenHurt: Float?
    let armorIncrease: Int?
    let empResistance: Float?
    let shieldRegeneration: Float?
    let teleportChance: Float?
    let spawnMinionsOnDamage: Bool?
    let rageModeAtHalfHealth: Bool?
    
    enum CodingKeys: String, CodingKey {
        case dodgeChance = "dodge_chance"
        case speedBoostWhenHurt = "speed_boost_when_hurt"
        case armorIncrease = "armor_increase"
        case empResistance = "emp_resistance"
        case shieldRegeneration = "shield_regeneration"
        case teleportChance = "teleport_chance"
        case spawnMinionsOnDamage = "spawn_minions_on_damage"
        case rageModeAtHalfHealth = "rage_mode_at_half_health"
    }
}

struct AutoScaling: Codable {
    let enabled: Bool
    let playerSkillTracking: Bool
    let adjustAfterWaves: Int
    let maxAdjustment: Float
    
    enum CodingKeys: String, CodingKey {
        case enabled
        case playerSkillTracking = "player_skill_tracking"
        case adjustAfterWaves = "adjust_after_waves"
        case maxAdjustment = "max_adjustment"
    }
}

// MARK: - Enemy Configuration

struct EnemyConfiguration {
    var type: String
    var health: Float
    var speed: Float
    var armor: Int
    var hasShield: Bool
    var regeneration: Float
    var isElite: Bool
    
    // Special abilities
    var dodgeChance: Float = 0
    var speedBoostWhenHurt: Float = 1.0
    var armorIncrease: Int = 0
    var empResistance: Float = 0
    var shieldRegeneration: Float = 0
    var teleportChance: Float = 0
    var spawnMinionsOnDamage: Bool = false
    var rageModeAtHalfHealth: Bool = false
}