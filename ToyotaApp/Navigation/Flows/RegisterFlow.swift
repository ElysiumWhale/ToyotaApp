import UIKit

enum RegisterFlow {

    static func cityModule(_ cities: [City] = []) -> CityPikerModule {
        let interactor = CityPickerInteractor(cities: cities)
        let module = CityPickerViewController(interactor: interactor)
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

    static func addCarModule(scenario: AddInfoType = .register,
                             models: [Model] = [],
                             colors: [Color] = []) -> UIViewController {

        let interactor = AddCarInteractor(type: scenario,
                                          models: models,
                                          colors: colors)
        let vc = AddCarViewController(intercator: interactor)
        interactor.view = vc

        return vc
    }

    static func endRegistrationModule() -> UIViewController {
        EndRegistrationViewController()
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
