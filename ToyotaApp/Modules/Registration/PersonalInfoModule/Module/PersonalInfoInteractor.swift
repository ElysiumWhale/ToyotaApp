import Foundation

final class PersonalInfoInteractor: PersonalInfoViewOutput {
    private let requestHandler = RequestHandler<CitiesResponse>()
    private let keychain: any ModelKeyedCodableStorage<KeychainKeys>

    private var onSavePerson: Closure?

    let infoService: PersonalInfoService
    let state: PersonalDataStoreState

    weak var view: PersonalInfoView?

    init(
        state: PersonalDataStoreState = .empty,
        service: PersonalInfoService = InfoService(),
        keychain: any ModelKeyedCodableStorage<KeychainKeys> = KeychainService.shared
    ) {
        infoService = service
        self.state = state
        self.keychain = keychain

        setupRequestHandlers()
    }

    func setPerson(request: PersonalInfoModels.SetPersonRequest) {
        onSavePerson = { [weak self] in
            self?.keychain.set(Person(
                firstName: request.firstName,
                lastName: request.secondName,
                secondName: request.lastName,
                email: request.email,
                birthday: request.date
            ))
            self?.onSavePerson = nil
        }

        guard let userId: UserId = keychain.get() else {
            return
        }

        infoService.setProfile(
            with: SetProfileBody.from(request, userId: userId.value),
            requestHandler
        )
    }

    private func setupRequestHandlers() {
        requestHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak self] error in
                self?.view?.handle(state: .failure(message: error.message ?? .error(.requestError)))
            }
    }

    private func handle(success response: CitiesResponse) {
        onSavePerson?()
        view?.handle(state: .success(
            cities: response.cities,
            models: response.models ?? [],
            colors: response.colors ?? []
        ))
    }
}
