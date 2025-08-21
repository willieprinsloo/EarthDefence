import Foundation

class TowerSystem: BaseSystem {
    private var towers: [Entity] = []
    
    override init() {
        super.init()
        priority = 150
    }
    
    override func update(deltaTime: TimeInterval, entities: [Entity]) {
        // Tower update logic
    }
}