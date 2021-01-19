import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let defaults = UserDefaults.standard
        
        if let loggedUserId = defaults.string(forKey: DefaultsKeys.userId), let secretKey = defaults.string(forKey: DefaultsKeys.secretKey) {
            
            NetworkService.shared.makePostRequest(page: RequestPath.Start.checkUser, params:
            [URLQueryItem(name: RequestKeys.Auth.userId, value: loggedUserId),
             URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id),
             URLQueryItem(name: RequestKeys.Auth.secretKey, value: secretKey)],
            completion: resolveNavigation)
        } else { NavigationService.loadAuth() }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

//MARK: - Navigation
extension SceneDelegate {
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = window else { return }
        window.rootViewController = vc
        
        UIView.transition(with: window,
        duration: 0.5,
        options: [.transitionFlipFromLeft],
        animations: nil,
        completion: nil)
    }
    
    var resolveNavigation: (CheckUserOrSmsCodeResponse?) -> Void {
        { response in
            guard let response = response else { NavigationService.loadAuth(); return }
            
            UserDefaults.standard.setValue(response.secretKey, forKey: DefaultsKeys.secretKey)
            NavigationService.resolveNavigation(with: response, fallbackCompletion: NavigationService.loadAuth)
        }
    }
}
