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

    static func personalInfoModule(_ profile: Profile? = nil) -> UIViewController {
        let pivc: PersonalInfoViewController = storyboard.instantiate(.personalInfo)
        if let profile = profile {
            pivc.configure(with: profile)
        }
        return pivc
    }

    static func personalModule(_ profile: Profile? = nil) -> UIViewController {
        let state: PersonalDataStoreState

        if let profile = profile {
            state = .configured(with: profile)
        } else {
            state = .empty
        }

        let presenter = PersonalInfoPresenter()
        let interactor = PersonalInfoInteractor(output: presenter,
                                                state: state)
        let view = PersonalInfoView(interactor: interactor)
        presenter.controller = view
        return view
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
