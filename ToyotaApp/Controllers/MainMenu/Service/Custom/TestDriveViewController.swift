import UIKit

class TestDriveViewController: BaseServiceController {
    override var hasCarSelection: Bool {
        false
    }

    override func start() {
        let configs = configurationForModules()

        for (module, config) in zip(modules, configs) {
            stackView.addArrangedSubview(module.view)
            module.configure(appearance: config)
        }
        stackView.addArrangedSubview(bookButton)
        view.addSubview(loadingView)
        loadingView.fadeIn()
        modules.first?.customStart(page: .profile(.getCities),
                                   with: [(.auth(.brandId), Brand.Toyota)],
                                   response: CitiesResponse.self)
    }

    override func moduleDidUpdate(_ module: IServiceModule) {
        dispatch { [weak self] in
            switch module.state {
                case .idle: return
                case .didDownload: self?.stopLoading()
                case .error(let error): self?.didRaiseError(module, error)
                case .block: break
                case .didChose(let service): self?.didChose(service, in: module)
            }
        }
    }

    override func didChose(_ service: IService, in module: IServiceModule) {
        guard let index = modules.firstIndex(where: { $0 === module }) else { return }
        index < 3 ? fadeOutAfter(module: index) : stopLoading()
        let params = buildParams(for: index, value: service.id)
        switch index {
            case 0:
                module.nextModule?.customStart(page: .services(.getTestDriveCars),
                                               with: params,
                                               response: CarsResponse.self)
            case 1:
                module.nextModule?.customStart(page: .services(.getTestDriveShowrooms),
                                               with: params,
                                               response: ShoroomsResponce.self)
            case 2:
                module.nextModule?.customStart(page: .services(.getFreeTime),
                                               with: params,
                                               response: CarsResponse.self)
            case 3:
                bookButton.fadeIn()
            default: return
        }
    }

    private func buildParams(for index: Int, value: String) -> RequestItems {
        switch index {
            case 0:
                return [(.carInfo(.cityId), value),
                        (.auth(.brandId), Brand.Toyota)]
            case 1:
                return [(.auth(.brandId), Brand.Toyota),
                        (.carInfo(.cityId),
                        modules[0].state.getService()?.id),
                        (.services(.serviceId), value)]
            case 2:
                return [(.carInfo(.showroomId), value),
                        (.services(.serviceId),
                        modules[1].state.getService()?.id)]
            default: return []
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
        guard let userId = user?.id,
              let showroomId = modules[2].state.getService()?.id,
              let carId = modules[1].state.getService()?.id else { return }

        var params: RequestItems = [(.auth(.userId), userId),
                                    (.carInfo(.showroomId), showroomId),
                                    (.services(.serviceId), carId)]
        params.append(contentsOf: modules[3].buildQueryItems())

        NetworkService.makeRequest(page: .services(.bookService),
                                   params: params,
                                   handler: bookingRequestHandler)
    }
}

// MARK: - Modules configurations
extension TestDriveViewController {
    func configurationForModules() -> [[ModuleAppearances]] {
        return [[.title(.common(.chooseCity)), .placeholder(.common(.city))],
                [.title(.common(.chooseCar)), .placeholder(.common(.car))],
                [.title(.common(.chooseShowroom)), .placeholder(.common(.showroom))],
                [.title(.common(.chooseTime))]]
    }
}
