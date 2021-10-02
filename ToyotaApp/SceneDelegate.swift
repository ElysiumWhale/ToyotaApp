import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene as? UIWindowScene == nil { return }
        
        NavigationService.switchRootView = changeRootViewController
        
        guard let userId = KeychainManager.get(UserId.self)?.id,
              let secretKey = KeychainManager.get(SecretKey.self)?.secret else {
            NavigationService.loadAuth()
            return
        }
        NetworkService.makePostRequest(page: .start(.checkUser),
                                       params: [(.auth(.userId), userId),
                                                (.auth(.brandId), Brand.Toyota),
                                                (.auth(.secretKey), secretKey)],
                                       completion: resolveNavigation)
    }
}

// MARK: - Navigation
extension SceneDelegate {
    func changeRootViewController(_ vc: UIViewController) {
        guard let window = window else { return }
        window.rootViewController = vc
        
        UIView.transition(with: window,
        duration: 0.5,
        options: [.transitionFlipFromLeft],
        animations: nil,
        completion: nil)
    }
    
    func resolveNavigation(for response: Result<CheckUserOrSmsCodeResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                KeychainManager.set(SecretKey(data.secretKey))
                NavigationService.resolveNavigation(with: CheckUserContext(response: data)) {
                    NavigationService.loadAuth()
                }
            case .failure(let error):
                switch error.errorCode {
                    case .lostConnection:
                        NavigationService.loadConnectionLost()
                    default:
                        KeychainManager.clear(SecretKey.self)
                        NavigationService.loadAuth(with: error.message ?? "При входе произошла ошибка, войдите повторно")
                }
        }
    }
}

// MARK: - SceneDid... EventHandlers
extension SceneDelegate {
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
