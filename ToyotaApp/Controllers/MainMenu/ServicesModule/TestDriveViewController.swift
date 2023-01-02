import UIKit

final class TestDriveViewController: BaseServiceController {
    override var hasCarSelection: Bool {
        false
    }

    override func start() {
        configureModulesAppearance()
        stackView.addArrangedSubview(bookButton)
        view.addSubview(loadingView)
        loadingView.fadeIn()
        modules.first?.customStart(
            request: (
                path: .profile(.getCities),
                items: [(.auth(.brandId), Brand.Toyota)]
            ),
            response: CitiesResponse.self
        )
    }

    override func moduleDidUpdate(_ module: IServiceModule) {
        switch module.state {
        case .idle, .block:
            return
        case .didDownload:
            stopLoading()
        case let .error(error):
            didRaiseError(module, error)
        case let .didChose(service):
            didChose(service, in: module)
        }
    }

    override func didChose(_ service: IService, in module: IServiceModule) {
        guard let index = modules.firstIndex(where: { $0 === module }) else {
            return
        }

        if index < 3 {
            fadeOutAfter(module: index)
        } else {
            stopLoading()
        }

        let params = buildParams(for: index, value: service.id)
        switch index {
        case 0:
            module.nextModule?.customStart(
                request: (.services(.getTestDriveCars), params),
                response: CarsResponse.self
            )
        case 1:
            module.nextModule?.customStart(
                request: (.services(.getTestDriveShowrooms), params),
                response: ShowroomsResponse.self
            )
        case 2:
            module.nextModule?.customStart(
                request: (.services(.getFreeTime), params),
                response: CarsResponse.self
            )
        case 3:
            bookButton.fadeIn()
        default:
            return
        }
    }

    private func buildParams(for index: Int, value: String) -> RequestItems {
        switch index {
        case 0:
            return [
                (.carInfo(.cityId), value),
                (.auth(.brandId), Brand.Toyota)
            ]
        case 1:
            return [
                (.auth(.brandId), Brand.Toyota),
                (.carInfo(.cityId), modules[0].state.service?.id),
                (.services(.serviceId), value)
            ]
        case 2:
            return [
                (.carInfo(.showroomId), value),
                (.services(.serviceId), modules[1].state.service?.id)
            ]
        default:
            return []
        }
    }

    private func fadeOutAfter(module index: Int) {
        startLoading()

        if index >= 2 { return }

        for index in index+2...3 {
            modules[index].view.fadeOut()
        }

        bookButton.fadeOut()
    }

    override func bookService() {
        guard let showroomId = modules[2].state.service?.id,
              let carId = modules[1].state.service?.id else {
            return
        }

        var params: RequestItems = [
            (.auth(.userId), user.id),
            (.carInfo(.showroomId), showroomId),
            (.services(.serviceId), carId)
        ]
        params.append(contentsOf: modules[3].buildQueryItems())

        Task {
            await makeBookingRequest(params)
        }
    }
}

// MARK: - Modules configurations
extension TestDriveViewController {
    func configureModulesAppearance() {
        let configs = configurationForModules()
        for (module, config) in zip(modules, configs) {
            stackView.addArrangedSubview(module.view)
            module.configure(appearance: config)
        }
    }

    func configurationForModules() -> [[ModuleAppearances]] {
        [
            [.title(.common(.chooseCity)), .placeholder(.common(.city))],
            [.title(.common(.chooseCar)), .placeholder(.common(.car))],
            [.title(.common(.chooseShowroom)), .placeholder(.common(.showroom))],
            [.title(.common(.chooseTime))]
        ]
    }
}
