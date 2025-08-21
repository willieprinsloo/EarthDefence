import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color to verify view is loading
        view.backgroundColor = .darkGray
        
        // Create and configure the view
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.backgroundColor = .black
        view.addSubview(skView)
        
        // Configure view for optimal performance
        configureView(skView)
        
        // Debug: Print to verify this is called
        print("GameViewController loaded, presenting MainMenuScene")
        
        // Present the main menu scene
        presentMainMenu(in: skView)
    }
    
    private func configureView(_ skView: SKView) {
        // Performance optimizations
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        
        #if DEBUG
        // Debug information
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        skView.showsDrawCount = true
        #endif
    }
    
    private func presentMainMenu(in skView: SKView) {
        // Create and present the main menu scene
        let menuScene = MainMenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .aspectFill
        
        skView.presentScene(menuScene)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Landscape only for gameplay
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom, .top]
    }
}