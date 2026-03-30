import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        print("✅ SceneDelegate scene willConnectTo")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ No windowScene")
            return
        }
        
        print("✅ Creating window")
        window = UIWindow(windowScene: windowScene)
        
        let cuentaVC = CuentaViewController()
        print("✅ Created CuentaViewController")
        
        let navigationController = UINavigationController(rootViewController: cuentaVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        print("✅ Window is visible")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
