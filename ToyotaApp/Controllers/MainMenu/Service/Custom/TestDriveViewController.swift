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
        modules.first?.customStart(page: RequestPath.Profile.getCities,
                                   with: [URLQueryItem(name: RequestKeys.Auth.brandId,
                                                       value: Brand.Toyota)],
                                   response: CitiesDidGetResponse.self)
    }
    
    override func moduleDidUpdate(_ module: IServiceModule) {
        switch module.state {
            case .idle: return
            case .didDownload:
                DispatchQueue.main.async { [weak self] in
                    self?.loadingView.fadeOut {
                        self?.loadingView.removeFromSuperview()
                    }
                }
            case .error(let error):
                PopUp.displayMessage(with: CommonText.error,
                                     description: error.message ?? AppErrors.requestError.rawValue,
                                     buttonText: CommonText.ok) { [weak self] in
                    self?.loadingView.fadeOut {
                        self?.loadingView.removeFromSuperview()
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            case .didChose(let service):
                guard let index = modules.firstIndex(where: { $0 === module }) else { return }
                switch index {
                    case 0:
                        fadeOutAfter(module: index)
                        modules[1].customStart(page: RequestPath.Services.getTestDriveCars,
                                               with: buildParams(for: index, value: service.id),
                                               response: CarsDidGetResponse.self)
                    case 1:
                        fadeOutAfter(module: index)
                        modules[2].customStart(page: RequestPath.Services.getTestDriveShowrooms,
                                               with: buildParams(for: index, value: service.id),
                                               response: ShoroomsDidGetResponce.self)
                    case 2:
                        fadeOutAfter(module: index)
                        modules[3].customStart(page: RequestPath.Services.getFreeTime,
                                               with: buildParams(for: index, value: service.id),
                                               response: CarsDidGetResponse.self)
                    case 3:
                        DispatchQueue.main.async { [weak self] in
                            self?.loadingView.fadeOut {
                                self?.loadingView.removeFromSuperview()
                            }
                            self?.bookButton.fadeIn()
                        }
                    default: return
                }
        }
    }
    
    private func buildParams(for index: Int, value: String) -> [URLQueryItem] {
        switch index {
            case 0:
                return [URLQueryItem(name: RequestKeys.CarInfo.cityId,
                                     value: value),
                        URLQueryItem(name: RequestKeys.Auth.brandId,
                                     value: Brand.Toyota)]
            case 1:
                return [URLQueryItem(name: RequestKeys.Auth.brandId,
                                     value: Brand.Toyota),
                        URLQueryItem(name: RequestKeys.CarInfo.cityId,
                                     value: modules[0].state.getService()?.id),
                        URLQueryItem(name: RequestKeys.Services.serviceId,
                                     value: value)]
            case 2:
                return [URLQueryItem(name: RequestKeys.CarInfo.showroomId,
                                     value: value),
                        URLQueryItem(name: RequestKeys.Services.serviceId,
                                     value: modules[1].state.getService()?.id)]
            default: return []
        }
    }

    private func fadeOutAfter(module index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let controller = self else { return }
            
            controller.view.addSubview(controller.loadingView)
            controller.loadingView.fadeIn()
            
            if index >= 2 { return }
            
            for index in index+2...3 {
                controller.modules[index].view?.fadeOut()
            }
            controller.bookButton.fadeOut()
        }
    }

    override func bookService() {
        guard let userId = user?.getId, let showroomId = modules[2].state.getService()?.id else { return }
        
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                                      URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId),
                                      URLQueryItem(name: RequestKeys.Services.serviceId, value: serviceType?.id)]
        
        params.append(contentsOf: modules[3].buildQueryItems())
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.bookService, params: params, completion: completion)
        
        func completion(for response: Result<Response, ErrorResponse>) {
            switch response {
                case .success:
                    PopUp.displayMessage(with: CommonText.success,
                                         description: "Заявка оставлена и будет обработана в ближайшее время",
                                         buttonText: CommonText.ok) { [self] in
                        navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    PopUp.displayMessage(with: CommonText.error,
                                         description: error.message ?? CommonText.servicesError,
                                         buttonText: CommonText.ok)
            }
        }
    }
}
