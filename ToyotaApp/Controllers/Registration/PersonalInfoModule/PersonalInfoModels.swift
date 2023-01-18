import Foundation

enum PersonalDataStoreState: Equatable {
    case empty
    case configured(with: Profile)

    static func from(_ profile: Profile?) -> Self {
        guard let profile = profile else {
            return empty
        }

        return configured(with: profile)
    }
}

enum PersonalInfoModels {
    struct SetPersonRequest {
        let firstName: String
        let secondName: String
        let lastName: String
        let email: String
        let date: String
    }

    enum SetPersonResponse {
        case success(response: CitiesResponse)
        case failure(response: ErrorResponse)
    }

    enum SetPersonViewModel {
        case success(cities: [City], models: [Model], colors: [Color])
        case failure(message: String)
    }
}

extension IBody where Self == SetProfileBody {
    static func from(_ request: PersonalInfoModels.SetPersonRequest) -> Self {
        .init(brandId: Brand.Toyota,
              userId: KeychainManager<UserId>.get()!.value,
              firstName: request.firstName,
              secondName: request.secondName,
              lastName: request.lastName,
              email: request.email,
              birthday: request.date)
    }
}
