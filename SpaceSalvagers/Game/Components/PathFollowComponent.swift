import Foundation
import simd

class PathFollowComponent: BaseComponent {
    // Path data
    private var pathPoints: [SIMD2<Float>] = []
    private var currentSegmentIndex: Int = 0
    
    // Movement along path
    private(set) var progress: Float = 0  // 0 to 1 representing total path progress
    private var segmentProgress: Float = 0  // Progress on current segment
    
    // Configuration
    var moveSpeed: Float = 100.0
    var rotateTowardsPath: Bool = true
    var stopAtEnd: Bool = false
    var loop: Bool = false
    
    // Callbacks
    var onPathComplete: (() -> Void)?
    var onWaypointReached: ((Int) -> Void)?
    
    // Components
    private var transform: TransformComponent?
    private var movement: MovementComponent?
    
    // Path state
    private(set) var isMoving = false
    private var totalPathLength: Float = 0
    private var segmentLengths: [Float] = []
    private var distanceTraveled: Float = 0
    
    override func awake() {
        super.awake()
        transform = entity?.getComponent(TransformComponent.self)
        movement = entity?.getComponent(MovementComponent.self)
    }
    
    func setPath(_ points: [SIMD2<Float>]) {
        pathPoints = points
        currentSegmentIndex = 0
        segmentProgress = 0
        progress = 0
        distanceTraveled = 0
        
        calculatePathMetrics()
        
        // Move to start position
        if let firstPoint = pathPoints.first {
            transform?.position = firstPoint
        }
        
        isMoving = !pathPoints.isEmpty
    }
    
    func setPath(from startPoint: SIMD2<Float>, to endPoint: SIMD2<Float>) {
        setPath([startPoint, endPoint])
    }
    
    private func calculatePathMetrics() {
        segmentLengths.removeAll()
        totalPathLength = 0
        
        for i in 0..<max(0, pathPoints.count - 1) {
            let length = simd_distance(pathPoints[i], pathPoints[i + 1])
            segmentLengths.append(length)
            totalPathLength += length
        }
    }
    
    override func update(deltaTime: TimeInterval) {
        guard isMoving,
              let transform = transform,
              currentSegmentIndex < pathPoints.count - 1 else { return }
        
        let currentPoint = pathPoints[currentSegmentIndex]
        let nextPoint = pathPoints[currentSegmentIndex + 1]
        
        // Calculate movement for this frame
        let moveDistance = moveSpeed * Float(deltaTime)
        
        // Move along current segment
        let segmentVector = nextPoint - currentPoint
        let segmentLength = segmentLengths[currentSegmentIndex]
        
        if segmentLength > 0 {
            // Update position
            let moveAmount = min(moveDistance / segmentLength, 1.0 - segmentProgress)
            segmentProgress += moveAmount
            distanceTraveled += moveAmount * segmentLength
            
            // Interpolate position
            let newPosition = mix(currentPoint, nextPoint, t: segmentProgress)
            transform.position = newPosition
            
            // Update rotation if needed
            if rotateTowardsPath {
                let direction = normalize(segmentVector)
                transform.rotation = atan2(direction.y, direction.x)
            }
            
            // Update movement component if available
            if let movement = movement {
                let velocity = normalize(segmentVector) * moveSpeed
                movement.velocity = velocity
            }
            
            // Check if reached waypoint
            if segmentProgress >= 1.0 {
                onWaypointReached?(currentSegmentIndex + 1)
                moveToNextSegment()
            }
        } else {
            // Zero-length segment, skip to next
            moveToNextSegment()
        }
        
        // Update overall progress
        if totalPathLength > 0 {
            progress = distanceTraveled / totalPathLength
        }
    }
    
    private func moveToNextSegment() {
        currentSegmentIndex += 1
        segmentProgress = 0
        
        if currentSegmentIndex >= pathPoints.count - 1 {
            // Reached end of path
            handlePathComplete()
        }
    }
    
    private func handlePathComplete() {
        if loop && pathPoints.count > 1 {
            // Reset to beginning
            currentSegmentIndex = 0
            segmentProgress = 0
            distanceTraveled = 0
            progress = 0
            
            if let firstPoint = pathPoints.first {
                transform?.position = firstPoint
            }
        } else {
            // Stop at end
            isMoving = false
            progress = 1.0
            
            if let movement = movement {
                movement.velocity = .zero
            }
            
            onPathComplete?()
        }
    }
    
    func pause() {
        isMoving = false
    }
    
    func resume() {
        isMoving = currentSegmentIndex < pathPoints.count - 1
    }
    
    func getDistanceToPathEnd() -> Float {
        guard totalPathLength > 0 else { return 0 }
        return totalPathLength - distanceTraveled
    }
    
    func getCurrentWaypoint() -> Int {
        return min(currentSegmentIndex + 1, pathPoints.count - 1)
    }
    
    func getNextWaypoint() -> SIMD2<Float>? {
        guard currentSegmentIndex + 1 < pathPoints.count else { return nil }
        return pathPoints[currentSegmentIndex + 1]
    }
    
    func getRemainingPath() -> [SIMD2<Float>] {
        guard currentSegmentIndex < pathPoints.count else { return [] }
        return Array(pathPoints[currentSegmentIndex...])
    }
    
    func setSpeed(_ speed: Float) {
        moveSpeed = max(0, speed)
    }
    
    // Helper function for linear interpolation
    private func mix(_ a: SIMD2<Float>, _ b: SIMD2<Float>, t: Float) -> SIMD2<Float> {
        return a + (b - a) * t
    }
}

// MARK: - Path Manager
class PathManager {
    static let shared = PathManager()
    
    private var paths: [String: [SIMD2<Float>]] = [:]
    
    private init() {
        setupDefaultPaths()
    }
    
    private func setupDefaultPaths() {
        // Define default enemy paths
        paths["main_path"] = [
            SIMD2<Float>(0, 384),      // Start (left middle)
            SIMD2<Float>(200, 384),
            SIMD2<Float>(200, 500),
            SIMD2<Float>(400, 500),
            SIMD2<Float>(400, 300),
            SIMD2<Float>(600, 300),
            SIMD2<Float>(600, 384),
            SIMD2<Float>(800, 384),    // End (right middle)
        ]
        
        paths["alternate_path"] = [
            SIMD2<Float>(512, 0),      // Start (top middle)
            SIMD2<Float>(512, 200),
            SIMD2<Float>(400, 300),
            SIMD2<Float>(300, 300),
            SIMD2<Float>(300, 400),
            SIMD2<Float>(500, 400),
            SIMD2<Float>(512, 384),    // End (center)
        ]
    }
    
    func getPath(named name: String) -> [SIMD2<Float>]? {
        return paths[name]
    }
    
    func registerPath(name: String, points: [SIMD2<Float>]) {
        paths[name] = points
    }
    
    func getAllPaths() -> [String: [SIMD2<Float>]] {
        return paths
    }
}