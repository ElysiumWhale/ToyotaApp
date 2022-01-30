import UIKit

enum RegisterFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.register)

    static func cityModule(_ cities: [City]?) -> UIViewController {
        let cpvc: CityPickerViewController = storyboard.instantiate(.cityPick)
        if let cities = cities {
            cpvc.configure(with: cities)
        }
        return cpvc
    }

    static func personalInfoModule(_ profile: Profile) -> UIViewController {
        let pivc: PersonalInfoViewController = storyboard.instantiate(.personalInfo)
        pivc.configure(with: profile)
        return pivc
    }

    static func addCarModule(models: [Model] = [],
                             colors: [Color] = [],
                             controllerType: AddInfoType = .register) -> UIViewController {
        let acvc: AddCarViewController = storyboard.instantiate(.addCar)
        acvc.configure(models: models, colors: colors, controllerType: controllerType)
        return acvc
    }

    static func entryPoint(with controllers: [UIViewController] = []) -> UIViewController {
        let nvc: UINavigationController = storyboard.instantiate(.registerNavigation)
        nvc.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
        if controllers.isNotEmpty {
            nvc.setViewControllers(controllers, animated: false)
        }
        return nvc
    }
}
