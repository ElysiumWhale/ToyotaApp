import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let loggedUserId = UserDefaults.standard.string(forKey: DefaultsKeys.userId), let secretKey = UserDefaults.standard.string(forKey: DefaultsKeys.secretKey), let brandId = UserDefaults.standard.string(forKey: DefaultsKeys.brandId) {
            
            NetworkService.shared.makePostRequest(page: PostRequestPath.checkUser, params: [URLQueryItem(name: PostRequestKeys.userId, value: loggedUserId), URLQueryItem(name: PostRequestKeys.brandId, value: brandId), URLQueryItem(name: PostRequestKeys.secretKey, value: secretKey)], completion: resolveNavigation)
        } else { loadAuth() }
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
        guard let data = data else { loadAuth(); return }
        do {
            let response = try JSONDecoder().decode(CheckUserResponse.self, from: data)
            UserDefaults.standard.setValue(response.secretKey, forKey: DefaultsKeys.secretKey)
            if let regPage = response.registerPage {
                switch regPage {
                    case 1: loadRegister()
                    case 2:
                        if let profile = response.registeredUser?.profile, let cities = response.cities {
                            loadRegister(with: profile, and: cities)
                        } else { loadAuth() }
                    case 3:
                        if let profile = response.registeredUser?.profile, let cities = response.cities, let showrooms = response.registeredUser?.showroom, let cars = response.cars, let selectedShowroom = response.registeredUser?.showroom {
                            loadRegister(with: profile, cities, showrooms, and: cars, selected: selectedShowroom)
                        }
                    case 4:
                        if let profile = response.registeredUser?.profile, let showrooms = response.registeredUser?.showroom, let cars = response.registeredUser?.car {
                            loadMain(with: profile, showrooms, and: cars)
                        }
                    default: loadAuth()
                }
            } else { loadAuth() }
        }
        catch { loadAuth() }
    }
    
    func loadAuth() {
        UserDefaults.standard.setValue("1", forKey: DefaultsKeys.brandId)
        let authStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        DispatchQueue.main.async { [self] in
            let controller = authStoryboard.instantiateViewController(identifier: AppViewControllers.authNavigation)
            window?.rootViewController = controller
        }
    }
    
    func loadMain(with profile: Profile, _ showrooms: [RegisteredUser.Showroom], and cars: [Car]) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async { [self] in
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as? UINavigationController
            //check if user in memory
            //configure
            window?.rootViewController = controller!
        }
    }
    
    func loadRegister() {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async { [self] in
            let controller = regStoryboard.instantiateViewController(identifier:    AppViewControllers.registerNavigation) as? UINavigationController
            window?.rootViewController = controller!
        }
    }
    
    func loadRegister(with profile: Profile, and cities: [City]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async { [self] in
            let controller = regStoryboard.instantiateViewController(identifier:    AppViewControllers.registerNavigation) as? UINavigationController
            
            let pivc = regStoryboard.instantiateViewController(identifier:  AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier:   AppViewControllers.dealerViewController) as! DealerViewController
            dvc.configure(cityList: cities)
            
            controller?.viewControllers.remove(at: 0)
            controller?.viewControllers.append(pivc)
            controller?.viewControllers.append(dvc)
            window?.rootViewController = controller!
        }
    }
    
    func loadRegister(with profile: Profile, _ cities: [City], _ showrooms: [RegisteredUser.Showroom], and cars: [Car], selected: [RegisteredUser.Showroom]) {
            let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
            DispatchQueue.main.async { [self] in
            let controller = regStoryboard.instantiateViewController(identifier:    AppViewControllers.registerNavigation) as? UINavigationController
            
            let pivc = regStoryboard.instantiateViewController(identifier:  AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier:   AppViewControllers.dealerViewController) as! DealerViewController
            dvc.configure(cityList: cities, showroomList: showrooms, city:  cities[cities.firstIndex(where: { $0.name == selected.first?.cityName })!], showroom:   selected.first)
            
            let acvc = regStoryboard.instantiateViewController(identifier:  AppViewControllers.addingCarViewController) as! AddingCarViewController
            acvc.configure(carsList: cars)
            
            controller?.viewControllers.remove(at: 0)
            controller?.viewControllers.append(pivc)
            controller?.viewControllers.append(dvc)
            controller?.viewControllers.append(acvc)
            window?.rootViewController = controller!
        }
    }
}
