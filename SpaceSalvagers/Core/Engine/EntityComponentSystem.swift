import Foundation
import simd

// MARK: - Entity

protocol Entity: AnyObject {
    var id: UUID { get }
    var isActive: Bool { get set }
    var components: [ObjectIdentifier: Component] { get set }
    
    func addComponent(_ component: Component)
    func removeComponent<T: Component>(_ type: T.Type)
    func getComponent<T: Component>(_ type: T.Type) -> T?
    func hasComponent<T: Component>(_ type: T.Type) -> Bool
}

class BaseEntity: Entity {
    let id = UUID()
    var isActive = true
    var components: [ObjectIdentifier: Component] = [:]
    
    func addComponent(_ component: Component) {
        let key = ObjectIdentifier(type(of: component))
        components[key] = component
        component.entity = self
        component.awake()
    }
    
    func removeComponent<T: Component>(_ type: T.Type) {
        let key = ObjectIdentifier(type)
        if let component = components.removeValue(forKey: key) {
            component.destroy()
            component.entity = nil
        }
    }
    
    func getComponent<T: Component>(_ type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        return components[key] as? T
    }
    
    func hasComponent<T: Component>(_ type: T.Type) -> Bool {
        let key = ObjectIdentifier(type)
        return components[key] != nil
    }
}

// MARK: - Component

protocol Component: AnyObject {
    var entity: Entity? { get set }
    var isEnabled: Bool { get set }
    
    func awake()
    func update(deltaTime: TimeInterval)
    func destroy()
}

class BaseComponent: Component {
    weak var entity: Entity?
    var isEnabled = true
    
    func awake() {
        // Override in subclasses for initialization
    }
    
    func update(deltaTime: TimeInterval) {
        // Override in subclasses for per-frame updates
    }
    
    func destroy() {
        // Override in subclasses for cleanup
    }
}

// MARK: - System

protocol System: AnyObject {
    var priority: Int { get }
    var isEnabled: Bool { get set }
    
    func update(deltaTime: TimeInterval, entities: [Entity])
    func entityAdded(_ entity: Entity)
    func entityRemoved(_ entity: Entity)
}

class BaseSystem: System {
    var priority: Int = 0
    var isEnabled = true
    
    func update(deltaTime: TimeInterval, entities: [Entity]) {
        // Override in subclasses
    }
    
    func entityAdded(_ entity: Entity) {
        // Override if needed
    }
    
    func entityRemoved(_ entity: Entity) {
        // Override if needed
    }
}

// MARK: - World

class World {
    private var entities: [UUID: Entity] = [:]
    private var systems: [System] = []
    private var entityGroups: [String: Set<UUID>] = [:]
    
    func addEntity(_ entity: Entity, groups: [String] = []) {
        entities[entity.id] = entity
        
        for group in groups {
            if entityGroups[group] == nil {
                entityGroups[group] = Set<UUID>()
            }
            entityGroups[group]?.insert(entity.id)
        }
        
        systems.forEach { $0.entityAdded(entity) }
    }
    
    func removeEntity(_ entity: Entity) {
        guard entities.removeValue(forKey: entity.id) != nil else { return }
        
        // Remove from all groups
        for (_, group) in entityGroups.enumerated() {
            entityGroups[group.key]?.remove(entity.id)
        }
        
        systems.forEach { $0.entityRemoved(entity) }
    }
    
    func addSystem(_ system: System) {
        systems.append(system)
        systems.sort { $0.priority < $1.priority }
    }
    
    func removeSystem<T: System>(_ type: T.Type) {
        systems.removeAll { $0 is T }
    }
    
    func update(deltaTime: TimeInterval) {
        let activeEntities = entities.values.filter { $0.isActive }
        
        // Update all systems
        for system in systems where system.isEnabled {
            system.update(deltaTime: deltaTime, entities: Array(activeEntities))
        }
        
        // Update all components
        for entity in activeEntities {
            for component in entity.components.values where component.isEnabled {
                component.update(deltaTime: deltaTime)
            }
        }
    }
    
    func getEntities(inGroup group: String) -> [Entity] {
        guard let ids = entityGroups[group] else { return [] }
        return ids.compactMap { entities[$0] }
    }
    
    func query<T: Component>(withComponent type: T.Type) -> [Entity] {
        return entities.values.filter { $0.hasComponent(type) }
    }
}