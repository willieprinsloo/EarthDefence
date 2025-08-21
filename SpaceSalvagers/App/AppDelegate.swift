import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let logger = Logger(subsystem: "com.spacesalvagers", category: "AppDelegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure audio session
        configureAudioSession()
        
        // Configure performance settings
        configurePerformanceSettings()
        
        // Load game configurations
        GameConfiguration.shared.loadConfigurations()
        
        AppDelegate.logger.info("Space Salvagers launched successfully")
        
        return true
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            AppDelegate.logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func configurePerformanceSettings() {
        // Disable idle timer during gameplay
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Frame rate will be configured in the GameViewController
        // High-end devices: 60 FPS, Lower-end devices: 30 FPS
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}