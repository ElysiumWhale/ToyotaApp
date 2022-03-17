import Foundation

protocol PersonalInfoControllerOutput: PersonalInfoDataStore {
    func setPerson(request: PersonalInfoModels.SetPersonRequest)
}

protocol PersonalInfoDataStore {
    var state: PersonalDataStoreState { get set }
}

enum PersonalDataStoreState {
    case empty
    case configured(with: Profile)
}

class PersonalInfoInteractor: PersonalInfoDataStore, PersonalInfoControllerOutput {
    let presenter: PersonalInfoPresenter

    var state: PersonalDataStoreState

    init(output: PersonalInfoPresenter) {
        presenter = output
        state = .empty
    }

    private lazy var requestHandler: RequestHandler<CitiesResponse> = {
        RequestHandler<CitiesResponse>()
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak self] error in
                self?.presenter.personDidSet(response: .failure(response: error))
            }
    }()

    private var onSavePerson: Closure?

    func setPerson(request: PersonalInfoModels.SetPersonRequest) {
        var params = buildParams(firstName: request.firstName,
                                 secondName: request.secondName,
                                 lastName: request.lastName,
                                 email: request.email,
                                 date: request.date)
        onSavePerson = { [weak self] in
            KeychainManager.set(Person(firstName: request.firstName,
                                       lastName: request.secondName,
                                       secondName: request.lastName,
                                       email: request.email,
                                       birthday: request.email))
            self?.onSavePerson = nil
        }

        NetworkService.makeRequest(page: .registration(.setProfile),
                                   params: params.withUserId(),
                                   handler: requestHandler)
    }

    private func handle(success response: CitiesResponse) {
        onSavePerson?()
        presenter.personDidSet(response: .success(response: response))
    }
}

// MARK: - Parameters building
extension PersonalInfoInteractor {
    private func buildParams(firstName: String?,
                             secondName: String?,
                             lastName: String?,
                             email: String?,
                             date: String) -> RequestItems {
        [(.auth(.brandId), Brand.Toyota),
         ((.personalInfo(.firstName), firstName)),
         ((.personalInfo(.secondName), secondName)),
         ((.personalInfo(.lastName), lastName)),
         ((.personalInfo(.email), email)),
         ((.personalInfo(.birthday), date))]
    }
}
