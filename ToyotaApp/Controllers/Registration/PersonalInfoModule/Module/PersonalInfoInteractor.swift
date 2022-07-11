import Foundation

final class PersonalInfoInteractor: PersonalInfoViewOutput {
    private var onSavePerson: Closure?

    let infoService: InfoService
    let presenter: PersonalInfoInteractorOutput
    let state: PersonalDataStoreState

    private lazy var requestHandler =
        RequestHandler<CitiesResponse>()
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak self] error in
                self?.presenter.personDidSet(response: .failure(response: error))
            }

    init(output: PersonalInfoInteractorOutput,
         state: PersonalDataStoreState = .empty,
         service: InfoService = .init()) {
        presenter = output
        infoService = service
        self.state = state
    }

    func setPerson(request: PersonalInfoModels.SetPersonRequest) {
        onSavePerson = { [weak self] in
            KeychainManager.set(Person(firstName: request.firstName,
                                       lastName: request.secondName,
                                       secondName: request.lastName,
                                       email: request.email,
                                       birthday: request.email))
            self?.onSavePerson = nil
        }

        infoService.setProfile(with: .from(request), handler: requestHandler)
    }

    private func handle(success response: CitiesResponse) {
        onSavePerson?()
        presenter.personDidSet(response: .success(response: response))
    }
}
