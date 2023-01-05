import Foundation

final class PersonalInfoInteractor: PersonalInfoViewOutput {
    private let requestHandler = RequestHandler<CitiesResponse>()

    private var onSavePerson: Closure?

    let infoService: PersonalInfoService
    let presenter: PersonalInfoInteractorOutput
    let state: PersonalDataStoreState

    init(output: PersonalInfoInteractorOutput,
         state: PersonalDataStoreState = .empty,
         service: PersonalInfoService = InfoService()) {
        presenter = output
        infoService = service
        self.state = state

        setupRequestHandlers()
    }

    func setPerson(request: PersonalInfoModels.SetPersonRequest) {
        onSavePerson = { [weak self] in
            KeychainManager.set(Person(
                firstName: request.firstName,
                lastName: request.secondName,
                secondName: request.lastName,
                email: request.email,
                birthday: request.date
            ))
            self?.onSavePerson = nil
        }

        infoService.setProfile(
            with: SetProfileBody.from(request),
            requestHandler
        )
    }

    private func setupRequestHandlers() {
        requestHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak self] error in
                self?.presenter.personDidSet(response: .failure(response: error))
            }
    }

    private func handle(success response: CitiesResponse) {
        onSavePerson?()
        presenter.personDidSet(response: .success(response: response))
    }
}
