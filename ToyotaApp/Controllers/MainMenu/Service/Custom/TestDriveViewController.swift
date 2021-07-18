import UIKit

class TestDriveViewController: BaseServiceController {
    override func start() {
        let labels = ["Выберите город", "Выберите машину", "Выберите салон", "Выберите время"]
        for (module, text) in zip(modules, labels) {
            stackView.addArrangedSubview(module.view ?? UIView())
            module.configureViewText(with: text)
        }
        stackView.addArrangedSubview(bookButton)
        modules.first?.customStart(page: RequestPath.Profile.getCities, with: [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota)], response: CitiesDidGetResponse.self)
    }
    
    override func moduleDidUpdated(_ module: IServiceModule) {
        var message: String = "Ошибка при запросе данных"
        switch module.result {
            case .failure(let error):
                if let mes = error.message { message = mes }
                fallthrough
            case .none:
                PopUp.displayMessage(with: CommonText.error, description: message, buttonText: CommonText.ok) { [self] in
                    navigationController?.popViewController(animated: true)
                }
            case .success(let service):
                guard let index = modules.firstIndex(where: { $0 === module }) else { return }
                switch index {
                    case 0:
                        fadeOutAfter(module: index)
                        let params = [URLQueryItem(name: RequestKeys.CarInfo.cityId, value: service.id), URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota)]
                        modules[1].customStart(page: RequestPath.Services.getTestDriveCars, with: params, response: CarsDidGetResponse.self)
                    case 1:
                        fadeOutAfter(module: index)
                        let params = [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota), URLQueryItem(name: RequestKeys.CarInfo.cityId, value: try? modules[0].result?.get().id), URLQueryItem(name: RequestKeys.Services.serviceId, value: service.id)]
                        modules[2].customStart(page: RequestPath.Services.getTestDriveShowrooms, with: params, response: ShoroomsDidGetResponce.self)
                    case 2:
                        fadeOutAfter(module: index)
                        let params = [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: service.id), URLQueryItem(name: RequestKeys.Services.sId, value: try? modules[1].result?.get().id)]
                        NetworkService.shared.makePostRequest(page: RequestPath.Services.getTestDriveServiceId, params: params, completion: completion)
                    case 3:
                        bookButton.fadeIn(0.6)
                    default: return
                }
                
                func completion(for response: Result<ServiceIdDidGetResponse, ErrorResponse>) {
                    switch response {
                        case .failure(let error):
                            PopUp.displayMessage(with: CommonText.error, description: error.message ?? message, buttonText: CommonText.ok) { [self] in
                                navigationController?.popViewController(animated: true)
                            }
                        case .success(let data):
                            let params = [URLQueryItem(name: RequestKeys.Services.sId, value: data.serviceId), URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: service.id)]
                            modules[3].customStart(page: RequestPath.Services.getFreeTime, with: params, response: CarsDidGetResponse.self)
                    }
                }
        }
    }
    
    private func fadeOutAfter(module index: Int) {
        if index+1 > 3 { return }
        
        for i in index+1...3 {
            modules[i].view?.fadeOut(0.6)
        }
        bookButton.fadeOut(0.6)
    }
    
    override func bookService() {
        guard let userId = user?.getId, let showroomId = try? modules[2].result?.get().id else { return }
        
        
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                                      URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId)]
        
        params.append(contentsOf: modules[3].buildQueryItems())
        
        func completion(for response: Result<Response, ErrorResponse>) {
            switch response {
                case .success:
                    PopUp.displayMessage(with: CommonText.success, description: "Заявка оставлена и будет обработана в ближайшее время", buttonText: CommonText.ok) { [self] in
                        navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    PopUp.displayMessage(with: CommonText.error, description: error.message ?? CommonText.servicesError, buttonText: CommonText.ok)
            }
        }
    }
}
