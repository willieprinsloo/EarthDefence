import Foundation

/// Deterministic random number generator using Linear Congruential Generator (LCG)
/// This ensures reproducible gameplay for testing and replay systems
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var seed: UInt64
    
    init(seed: UInt64) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        // LCG parameters from Numerical Recipes
        seed = seed &* 1664525 &+ 1013904223
        return seed
    }
    
    mutating func nextInt(in range: Range<Int>) -> Int {
        let diff = range.upperBound - range.lowerBound
        guard diff > 0 else { return range.lowerBound }
        return Int(next() % UInt64(diff)) + range.lowerBound
    }
    
    mutating func nextFloat() -> Float {
        return Float(next()) / Float(UInt64.max)
    }
    
    mutating func nextFloat(in range: ClosedRange<Float>) -> Float {
        let t = nextFloat()
        return range.lowerBound + t * (range.upperBound - range.lowerBound)
    }
    
    mutating func nextBool(probability: Float = 0.5) -> Bool {
        return nextFloat() < probability
    }
    
    mutating func pick<T>(from array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        let index = nextInt(in: 0..<array.count)
        return array[index]
    }
    
    mutating func shuffle<T>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        
        for i in 0..<(array.count - 1) {
            let j = nextInt(in: i..<array.count)
            array.swapAt(i, j)
        }
    }
}

/// Global RNG manager for deterministic gameplay
class RandomManager {
    static let shared = RandomManager()
    
    private var generators: [String: SeededRandomNumberGenerator] = [:]
    private var masterSeed: UInt64
    
    private init() {
        self.masterSeed = UInt64(Date().timeIntervalSince1970)
    }
    
    func setSeed(_ seed: UInt64) {
        self.masterSeed = seed
        generators.removeAll()
    }
    
    func generator(for key: String) -> SeededRandomNumberGenerator {
        if let existing = generators[key] {
            return existing
        }
        
        // Create new generator with derived seed
        var tempGen = SeededRandomNumberGenerator(seed: masterSeed)
        let derivedSeed = tempGen.next() ^ UInt64(key.hashValue)
        let newGenerator = SeededRandomNumberGenerator(seed: derivedSeed)
        generators[key] = newGenerator
        return newGenerator
    }
    
    func updateGenerator(for key: String, generator: SeededRandomNumberGenerator) {
        generators[key] = generator
    }
}

// MARK: - Replay System Support

struct RandomState: Codable {
    let masterSeed: UInt64
    let checksum: UInt64  // For verification
    let frameCount: Int
    
    init(seed: UInt64, frameCount: Int) {
        self.masterSeed = seed
        self.frameCount = frameCount
        
        // Generate checksum for replay validation
        var gen = SeededRandomNumberGenerator(seed: seed)
        for _ in 0..<frameCount {
            _ = gen.next()
        }
        self.checksum = gen.next()
    }
    
    func verify() -> Bool {
        var gen = SeededRandomNumberGenerator(seed: masterSeed)
        for _ in 0..<frameCount {
            _ = gen.next()
        }
        return gen.next() == checksum
    }
}