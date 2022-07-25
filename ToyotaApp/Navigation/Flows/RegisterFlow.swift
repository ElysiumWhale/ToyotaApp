import UIKit

enum RegisterFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.register)

    static func cityModule(_ cities: [City] = []) -> CityPikerModule {
        let interactor = CityPickerInteractor(cities: cities)
        let module = CityPickerView(interactor: interactor)
        interactor.view = module

        return module
    }

    static func personalModule(_ profile: Profile? = nil) -> UIViewController {
        let presenter = PersonalInfoPresenter()
        let interactor = PersonalInfoInteractor(output: presenter,
                                                state: .from(profile))
        let view = PersonalInfoView(interactor: interactor)
        presenter.view = view
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
        nvc.navigationBar.prefersLargeTitles = true
        nvc.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
        let vcs = controllers.isNotEmpty ? controllers : [personalModule()]
        nvc.setViewControllers(vcs, animated: false)
        return nvc
    }
}
