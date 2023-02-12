import Foundation

enum CheckUserContext: Hashable {
    case empty
    case startRegister
    case register(_ page: Int, _ user: RegisteredUser, _ cities: [City])
    case main(_ user: RegisteredUser?)

    init(response: CheckUserOrSmsCodeResponse) {
        if response.registerStatus == nil {
            let page = response.registerPage ?? .zero

            if page < 2 {
                self = .startRegister
            } else if let user = response.registeredUser {
                self = .register(page, user, response.cities ?? [])
            } else {
                self = .empty
            }
        } else if response.registerStatus == 1, response.registerPage == nil {
            self = .main(response.registeredUser)
        } else {
            self = .empty
        }
    }

    init?(_ nullableResponse: CheckUserOrSmsCodeResponse?) {
        guard let response = nullableResponse else {
            return nil
        }

        self.init(response: response)
    }
}
