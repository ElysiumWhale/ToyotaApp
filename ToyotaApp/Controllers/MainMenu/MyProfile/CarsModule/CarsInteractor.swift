import Foundation

final class CarsInteractor {
    private let carsService: CarsService
    private let modelsAndColorsHandler = RequestHandler<ModelsAndColorsResponse>()
    private let removeCarHandler = DefaultRequestHandler()

    let user: UserProxy

    var onModelsAndColorsLoad: ParameterClosure<ModelsAndColorsResponse>?
    var onRemoveCar: Closure?
    var onRequestError: ParameterClosure<String>?

    var cars: [Car] {
        user.cars.value
    }

    init(carsService: CarsService = InfoService(), user: UserProxy) {
        self.carsService = carsService
        self.user = user

        setupRequestHandlers()
    }

    func getModelsAndColors() {
        carsService.getModelsAndColors(with: .init(brandId: Brand.Toyota),
                                       handler: modelsAndColorsHandler)
    }

    func removeCar(with id: String) {
        carsService.removeCar(with: .init(userId: user.id, carId: id),
                              handler: removeCarHandler)
    }

    private func setupRequestHandlers() {
        modelsAndColorsHandler
            .observe(on: .main, mode: .onSuccess)
            .bind { [weak self] response in
                self?.onModelsAndColorsLoad?(response)
            } onFailure: { [weak self] error in
                self?.onRequestError?(error.message ?? .error(.citiesLoadError))
            }

        removeCarHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.onRemoveCar?()
            } onFailure: { [weak self] error in
                self?.onRequestError?(error.message ?? .error(.citiesLoadError))
            }
    }
}
