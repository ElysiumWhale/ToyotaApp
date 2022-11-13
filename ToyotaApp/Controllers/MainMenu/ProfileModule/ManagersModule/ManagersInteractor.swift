import Foundation

final class ManagersInteractor {
    private let managersService: ManagersService
    private let managersRequestHandler = RequestHandler<ManagersResponse>()
    private let user: UserProxy

    private(set) var managers: [Manager] = []

    var onManagersLoad: Closure?
    var onError: ParameterClosure<String>?

    init(user: UserProxy,
         managersService: ManagersService = InfoService()) {
        self.user = user
        self.managersService = managersService

        setupRequestHandlers()
    }

    func getManagers() {
        managersService.getManagers(
            with: GetManagersBody(userId: user.id, brandId: Brand.Toyota),
            handler: managersRequestHandler
        )
    }

    private func setupRequestHandlers() {
        managersRequestHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(response)
            } onFailure: { [weak self] error in
                let errorText = error.message ?? .error(.managersLoadError)
                self?.onError?(errorText)
            }
    }

    private func handle(_ response: ManagersResponse) {
        managers = response.managers
        #if DEBUG
        if managers.isEmpty {
            managers = Mocks.createManagers()
        }
        #endif
        onManagersLoad?()
    }
}
