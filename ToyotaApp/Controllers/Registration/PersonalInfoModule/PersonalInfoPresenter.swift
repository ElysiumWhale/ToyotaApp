import Foundation

protocol PersonalInfoPresenterOutput: AnyObject {
    func handle(state: PersonalInfoModels.SetPersonViewModel)
}

class PersonalInfoPresenter {
    weak var controller: PersonalInfoPresenterOutput?

    init() {
        
    }

    init(output: PersonalInfoPresenterOutput) {
        controller = output
    }

    func personDidSet(response: PersonalInfoModels.SetPersonResponse) {
        let viewModel: PersonalInfoModels.SetPersonViewModel

        switch response {
            case .success(let success):
                viewModel = .success(cities: success.cities,
                                     models: success.models ?? [],
                                     colors: success.colors ?? [])
            case .failure(let failure):
                viewModel = .failure(message: failure.message ?? .error(.requestError))
        }

        controller?.handle(state: viewModel)
    }
}
