import Foundation

// MARK: - Context for navigation
struct CheckUserContext {
    enum States {
        case empty
        case startRegister
        case register(_ page: Int, _ user: RegisteredUser, _ cities: [City])
        case main(_ user: RegisteredUser?)
    }

    private let response: CheckUserOrSmsCodeResponse

    var state: States {
        if response.registerStatus == nil {
            let page = response.registerPage ?? .zero

            if page < 2 {
                return .startRegister
            } else if let user = response.registeredUser {
                return .register(page, user, response.cities ?? [])
            } else {
                return .empty
            }
        }

        if response.registerStatus == 1, response.registerPage == nil {
            return .main(response.registeredUser)
        }

        return .empty
    }

    init(response: CheckUserOrSmsCodeResponse) {
        self.response = response
    }

    init?(_ nullableResponse: CheckUserOrSmsCodeResponse?) {
        guard let response = nullableResponse else {
            return nil
        }

        self.response = response
    }
}
