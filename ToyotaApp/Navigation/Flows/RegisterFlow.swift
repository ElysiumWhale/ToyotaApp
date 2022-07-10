import UIKit

enum RegisterFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.register)

    static func cityModule(_ cities: [City]?, models: [Model] = [], colors: [Color] = []) -> UIViewController {
        let cpvc: CityPickerViewController = storyboard.instantiate(.cityPick)
        if let cities = cities {
            cpvc.configure(with: cities, models: models, colors: colors)
        }
        return cpvc
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
        let nvc = UINavigationController()
        nvc.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
        let vcs = controllers.isNotEmpty ? controllers : [personalModule()]
        nvc.setViewControllers(vcs, animated: false)
        return nvc
    }
}
