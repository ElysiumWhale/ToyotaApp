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
            if response.registerPage == nil || response.registerPage == 1 {
                return .startRegister
            } else if let page = response.registerPage {
                return response.registeredUser != nil
                    ? .register(page, response.registeredUser!, response.cities ?? [])
                    : .empty
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
