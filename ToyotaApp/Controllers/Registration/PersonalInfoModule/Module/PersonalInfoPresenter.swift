import Foundation

final class PersonalInfoPresenter: PersonalInfoInteractorOutput {
    weak var view: PersonalInfoPresenterOutput?

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

        view?.handle(state: viewModel)
    }
}
