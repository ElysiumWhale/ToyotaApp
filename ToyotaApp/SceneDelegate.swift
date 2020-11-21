import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let loggedUserId = UserDefaults.standard.string(forKey: DefaultsKeys.userId), let secretKey = UserDefaults.standard.string(forKey: DefaultsKeys.secretKey), let brandId = UserDefaults.standard.string(forKey: DefaultsKeys.brandId) {
            
            NetworkService.shared.makePostRequest(page: PostRequestPath.checkUser, params: [URLQueryItem(name: PostRequestKeys.userId, value: loggedUserId), URLQueryItem(name: PostRequestKeys.brandId, value: brandId), URLQueryItem(name: PostRequestKeys.secretKey, value: secretKey)], completion: resolveNavigation)
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

//MARK: - Switch Root Controller with flip animation
extension SceneDelegate {
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
        
        UIView.transition(with: window,
        duration: 0.5,
        options: [.transitionFlipFromLeft],
        animations: nil,
        completion: nil)
    }
    
    func resolveNavigation(data: Data?) -> Void {
        guard let data = data else { NavigationService.loadAuth(); return }
        do {
            let response = try JSONDecoder().decode(CheckUserResponse.self, from: data)
            UserDefaults.standard.setValue(response.secretKey, forKey: DefaultsKeys.secretKey)
            
            if let regPage = response.registerPage {
                switch regPage {
                    case 1: NavigationService.loadRegister()
                    case 2:
                        if let profile = response.registeredUser?.profile, let cities = response.cities {
                            NavigationService.loadRegister(with: profile, and: cities)
                        } else { NavigationService.loadAuth() }
                    case 3:
                        if let profile = response.registeredUser?.profile, let cities = response.cities, let showrooms = response.registeredUser?.showroom, let cars = response.cars, let selectedShowroom = response.registeredUser?.showroom {
                            NavigationService.loadRegister(with: profile, cities, showrooms, and: cars, selected: selectedShowroom)
                        }
                    case 4:
                        if let profile = response.registeredUser?.profile, let showrooms = response.registeredUser?.showroom, let cars = response.registeredUser?.car {
                            NavigationService.loadMain(with: profile, showrooms, and: cars)
                        }
                    default: NavigationService.loadAuth()
                }
            } else { NavigationService.loadAuth() }
        }
        catch { NavigationService.loadAuth() }
    }
}
