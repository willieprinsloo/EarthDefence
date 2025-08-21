import SpriteKit

// Test file to verify map rendering visually
class TestMapRender {
    
    static func testMapRendering() {
        print("🧪 Testing Map Rendering...")
        
        // Test 1: Verify SimpleMapLoader initialization
        let loader = SimpleMapLoader.shared
        print("✅ SimpleMapLoader initialized")
        
        // Test 2: Load Map 1
        if let mapData = loader.loadCustomMap(mapNumber: 1) {
            print("✅ Map 1 loaded successfully")
            print("  - Path points: \(mapData.path.count)")
            print("  - Build nodes: \(mapData.buildNodes.count)")
            print("  - Spawn points: \(mapData.spawnPoints.count)")
            print("  - End point: \(mapData.endPoint)")
            
            // Check if points are within screen bounds
            let screenBounds = CGRect(x: -400, y: -200, width: 800, height: 400)
            
            var pathInBounds = true
            for point in mapData.path {
                if !screenBounds.contains(point) {
                    pathInBounds = false
                    print("  ⚠️ Path point out of bounds: \(point)")
                }
            }
            
            var buildInBounds = true
            for point in mapData.buildNodes {
                if !screenBounds.contains(point) {
                    buildInBounds = false
                    print("  ⚠️ Build node out of bounds: \(point)")
                }
            }
            
            if pathInBounds && buildInBounds {
                print("✅ All map elements within screen bounds")
            } else {
                print("❌ Some map elements outside screen bounds")
            }
            
        } else {
            print("❌ Failed to load Map 1")
        }
        
        // Test 3: Check path creation
        if let path = loader.createPathForMap(mapNumber: 1) {
            print("✅ Path created for Map 1")
            let bounds = path.boundingBox
            print("  - Path bounds: x:\(bounds.origin.x) y:\(bounds.origin.y) w:\(bounds.width) h:\(bounds.height)")
            
            // Check if path fits on screen
            let screenWidth: CGFloat = 800
            let screenHeight: CGFloat = 400
            
            if bounds.width <= screenWidth && bounds.height <= screenHeight {
                print("✅ Path fits within screen dimensions")
            } else {
                print("❌ Path too large for screen!")
                print("  - Path width: \(bounds.width) (max: \(screenWidth))")
                print("  - Path height: \(bounds.height) (max: \(screenHeight))")
            }
        } else {
            print("❌ Failed to create path for Map 1")
        }
        
        // Test 4: Verify all maps
        var allMapsValid = true
        for i in 1...10 {
            if let mapData = loader.loadCustomMap(mapNumber: i) {
                if mapData.spawnPoints.isEmpty || mapData.endPoint == .zero || mapData.buildNodes.count < 3 {
                    print("⚠️ Map \(i) has issues:")
                    if mapData.spawnPoints.isEmpty { print("  - No spawn points") }
                    if mapData.endPoint == .zero { print("  - No end point") }
                    if mapData.buildNodes.count < 3 { print("  - Only \(mapData.buildNodes.count) build nodes") }
                    allMapsValid = false
                }
            } else {
                print("❌ Failed to load Map \(i)")
                allMapsValid = false
            }
        }
        
        if allMapsValid {
            print("✅ All 10 maps are valid")
        } else {
            print("⚠️ Some maps have issues")
        }
        
        print("\n🏁 Test Complete")
    }
}