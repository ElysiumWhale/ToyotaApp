import HelpCrunchSDK

private extension String {
    static let hcsSecret = "SKl5I1y9TyZsljWFNOZs2+DHlE1qHVoehfIvZ8ldr76TtXWNtkmS0prGmVX4K8GQ9W4JLwJcjrCt6/JH84w3Lw=="
    static let appId = "2"
    static let organization = "alyanspro"
}

private extension HCSConfiguration {
    static var configuration: HCSConfiguration {
        HCSConfiguration(forOrganization: .organization,
                         applicationId: .appId,
                         applicationSecret: .hcsSecret)
    }
}

private extension HCSUser {
    convenience init(from user: UserProxy) {
        self.init()

        email = user.getPerson.email
        phone = user.getPhone
        userId = user.getId
        name = "\(user.getPerson.firstName) \(user.getPerson.lastName)"
    }
}

extension NavigationService {
    static func configureChat(with user: UserProxy, onSuccessConfigure: @escaping Closure) {
        HelpCrunch.initWith(.configuration, user: .init(from: user)) { _ in
            onSuccessConfigure()
        }
    }
}
