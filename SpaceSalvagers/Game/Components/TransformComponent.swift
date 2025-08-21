import Foundation
import simd
import SpriteKit

class TransformComponent: BaseComponent {
    var position: SIMD2<Float> = .zero {
        didSet {
            updateNodePosition()
        }
    }
    
    var rotation: Float = 0 {
        didSet {
            updateNodeRotation()
        }
    }
    
    var scale: SIMD2<Float> = SIMD2<Float>(1, 1) {
        didSet {
            updateNodeScale()
        }
    }
    
    weak var node: SKNode?
    
    override func awake() {
        super.awake()
        updateNodePosition()
        updateNodeRotation()
        updateNodeScale()
    }
    
    private func updateNodePosition() {
        node?.position = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
    
    private func updateNodeRotation() {
        node?.zRotation = CGFloat(rotation)
    }
    
    private func updateNodeScale() {
        node?.xScale = CGFloat(scale.x)
        node?.yScale = CGFloat(scale.y)
    }
    
    func lookAt(target: SIMD2<Float>) {
        let direction = normalize(target - position)
        rotation = atan2(direction.y, direction.x)
    }
    
    func distance(to other: TransformComponent) -> Float {
        return simd_distance(position, other.position)
    }
    
    func distance(to point: SIMD2<Float>) -> Float {
        return simd_distance(position, point)
    }
    
    func direction(to other: TransformComponent) -> SIMD2<Float> {
        return normalize(other.position - position)
    }
}