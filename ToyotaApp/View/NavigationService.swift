import Foundation
import UIKit

class NavigationService {
    
    class func loadAuth() {
        UserDefaults.standard.setValue("1", forKey: DefaultsKeys.brandId)
        let authStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        DispatchQueue.main.async {
            let controller = authStoryboard.instantiateViewController(identifier: AppViewControllers.authNavigation)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
        }
    }
    
    class func loadRegister() {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let controller = regStoryboard.instantiateViewController(identifier:    AppViewControllers.registerNavigation) as? UINavigationController
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller!)
        }
    }
    
    class func loadRegister(with profile: Profile, and cities: [City]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let controller = regStoryboard.instantiateViewController(identifier:    AppViewControllers.registerNavigation) as? UINavigationController
            
            let pivc = regStoryboard.instantiateViewController(identifier:  AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier:   AppViewControllers.dealerViewController) as! DealerViewController
            dvc.configure(cityList: cities)
            
            controller?.viewControllers.remove(at: 0)
            controller?.viewControllers.append(pivc)
            controller?.viewControllers.append(dvc)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller!)
        }
    }
    
    class func loadRegister(with profile: Profile, _ cities: [City], _ showrooms: [RegisteredUser.Showroom], and cars: [Car], selected: [RegisteredUser.Showroom]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let controller = regStoryboard.instantiateViewController(identifier:        AppViewControllers.registerNavigation) as? UINavigationController
            
            let pivc = regStoryboard.instantiateViewController(identifier:      AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier:       AppViewControllers.dealerViewController) as! DealerViewController
            dvc.configure(cityList: cities, showroomList: showrooms, city:      cities[cities.firstIndex(where: { $0.name == selected.first?.cityName })!], showroom:       selected.first)
            
            let acvc = regStoryboard.instantiateViewController(identifier:      AppViewControllers.addingCarViewController) as! AddingCarViewController
            acvc.configure(carsList: cars)
        
        controller?.viewControllers.remove(at: 0)
        //(controller?.viewControllers.first as? PersonalInfoViewController)?.configure(with:   )
            controller?.viewControllers.append(pivc)
            controller?.viewControllers.append(dvc)
            controller?.viewControllers.append(acvc)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller!)
        }
    }
    
    class func loadMain(with profile: Profile, _ showrooms: [RegisteredUser.Showroom], and cars: [Car]) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as? UINavigationController
            //check if user in memory
            //configure
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller!)
        }
    }
}
