import Foundation

class EconomySystem: BaseSystem {
    private(set) var salvage: Int = 0
    
    override init() {
        super.init()
        priority = 50
    }
    
    func setSalvage(_ amount: Int) {
        salvage = amount
        NotificationCenter.default.post(name: .salvageUpdated, object: salvage)
    }
    
    func addSalvage(_ amount: Int) {
        salvage += amount
        NotificationCenter.default.post(name: .salvageUpdated, object: salvage)
    }
    
    func spendSalvage(_ amount: Int) -> Bool {
        guard salvage >= amount else { return false }
        salvage -= amount
        NotificationCenter.default.post(name: .salvageUpdated, object: salvage)
        return true
    }
}