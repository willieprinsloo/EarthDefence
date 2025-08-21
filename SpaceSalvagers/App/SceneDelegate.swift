import UIKit
import SpriteKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Create the game view controller
        let gameViewController = GameViewController()
        
        window?.rootViewController = gameViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Save game state when scene disconnects
        GameStateManager.shared.saveState()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume game when scene becomes active
        GameEngine.shared.resume()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause game when scene resigns active
        GameEngine.shared.pause()
        GameStateManager.shared.saveState()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save game state when entering background
        GameStateManager.shared.saveState()
    }
}