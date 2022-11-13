import Foundation

final class CarsInteractor {
    private let carsService: CarsService
    private let modelsAndColorsHandler = RequestHandler<ModelsAndColorsResponse>()
    private let removeCarHandler = DefaultRequestHandler()

    private var removingCarId: String?

    let user: UserProxy

    var onModelsAndColorsLoad: ParameterClosure<ModelsAndColorsResponse>?
    var onRemoveCar: Closure?
    var onRequestError: ParameterClosure<String>?

    var cars: [Car] {
        #if DEBUG
        user.cars.value + Mocks.createCars()
        #else
        user.cars.value
        #endif
    }

    init(carsService: CarsService = InfoService(), user: UserProxy) {
        self.carsService = carsService
        self.user = user

        setupRequestHandlers()
    }

    func getModelsAndColors() {
        carsService.getModelsAndColors(
            with: GetModelsAndColorsBody(brandId: Brand.Toyota),
            handler: modelsAndColorsHandler
        )
    }

    func removeCar(with id: String) {
        removingCarId = id
        carsService.removeCar(
            with: DeleteCarBody(userId: user.id, carId: id),
            handler: removeCarHandler
        )
    }

    private func setupRequestHandlers() {
        modelsAndColorsHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.onModelsAndColorsLoad?(response)
            } onFailure: { [weak self] error in
                self?.onRequestError?(error.message ?? .error(.citiesLoadError))
            }

        removeCarHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.removeCarIfNeeded()
                self?.onRemoveCar?()
            } onFailure: { [weak self] error in
                self?.onRequestError?(error.message ?? .error(.citiesLoadError))
                self?.removingCarId = nil
            }
    }

    private func removeCarIfNeeded() {
        guard let id = removingCarId else {
            return
        }

        user.removeCar(with: id)
        removingCarId = nil
    }
}
