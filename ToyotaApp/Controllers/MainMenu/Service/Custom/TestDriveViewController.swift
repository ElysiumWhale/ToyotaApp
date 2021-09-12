import UIKit

class TestDriveViewController: BaseServiceController {
    override func start() {
        let labels = ["Выберите город", "Выберите машину", "Выберите салон", "Выберите время"]
        for (module, text) in zip(modules, labels) {
            stackView.addArrangedSubview(module.view ?? UIView())
            module.configureViewText(with: text)
        }
        stackView.addArrangedSubview(bookButton)
        view.addSubview(loadingView)
        loadingView.fadeIn()
        modules.first?.customStart(page: .profile(.getCities),
                                   with: [URLQueryItem(.auth(.brandId), Brand.Toyota)],
                                   response: CitiesDidGetResponse.self)
    }
    
    override func moduleDidUpdate(_ module: IServiceModule) {
        DispatchQueue.main.async { [weak self] in
            switch module.state {
                case .idle: return
                case .didDownload: self?.endLoading()
                case .error(let error): self?.didRaiseError(module, error)
                case .block: break
                case .didChose(let service): self?.didChose(service, in: module)
            }
        }
    }
    
    override func didChose(_ service: IService, in module: IServiceModule) {
        guard let index = modules.firstIndex(where: { $0 === module }) else { return }
        index < 3 ? fadeOutAfter(module: index) : endLoading()
        let params = buildParams(for: index, value: service.id)
        switch index {
            case 0:
                modules[1].customStart(page: .services(.getTestDriveCars),
                                       with: params,
                                       response: CarsDidGetResponse.self)
            case 1:
                modules[2].customStart(page: .services(.getTestDriveShowrooms),
                                       with: params,
                                       response: ShoroomsDidGetResponce.self)
            case 2:
                modules[3].customStart(page: .services(.getFreeTime),
                                       with: params,
                                       response: CarsDidGetResponse.self)
            case 3:
                bookButton.fadeIn()
            default: return
        }
    }
    
    private func buildParams(for index: Int, value: String) -> [URLQueryItem] {
        switch index {
            case 0:
                return [URLQueryItem(.carInfo(.cityId), value),
                        URLQueryItem(.auth(.brandId), Brand.Toyota)]
            case 1:
                return [URLQueryItem(.auth(.brandId), Brand.Toyota),
                        URLQueryItem(.carInfo(.cityId),
                                     modules[0].state.getService()?.id),
                        URLQueryItem(.services(.serviceId), value)]
            case 2:
                return [URLQueryItem(.carInfo(.showroomId), value),
                        URLQueryItem(.services(.serviceId),
                                     modules[1].state.getService()?.id)]
            default: return []
        }
    }

    private func fadeOutAfter(module index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let controller = self else { return }
            controller.startLoading()
            
            if index >= 2 { return }
            
            for index in index+2...3 {
                controller.modules[index].view?.fadeOut()
            }
            controller.bookButton.fadeOut()
        }
    }

    override func bookService() {
        guard let userId = user?.getId,
              let showroomId = modules[2].state.getService()?.id,
              let carId = modules[1].state.getService()?.id else { return }
        
        var params: [URLQueryItem] = [URLQueryItem(.auth(.userId), userId),
                                      URLQueryItem(.carInfo(.showroomId), showroomId),
                                      URLQueryItem(.services(.serviceId), carId)]
        
        params.append(contentsOf: modules[3].buildQueryItems())
        
        NetworkService.shared.makePostRequest(page: .services(.bookService), params: params, completion: completion)
        
        func completion(for response: Result<Response, ErrorResponse>) {
            switch response {
                case .success:
                    PopUp.displayMessage(with: CommonText.success, description: "Заявка оставлена и будет обработана в ближайшее время") { [self] in
                        navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    PopUp.display(.error(description: error.message ?? CommonText.servicesError))
            }
        }
    }
}
