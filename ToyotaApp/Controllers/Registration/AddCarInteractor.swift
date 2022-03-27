import Foundation

protocol AddCarViewInput: AnyObject {
    func handleCarAdded()
    func handleFailure(with message: String)
    func handleModelsLoaded()
}

class AddCarInteractor {
    private let service: InfoService

    weak var view: AddCarViewInput?

    var type: AddInfoType = .register
    var vin: String = .empty
    var plate: String = .empty

    private(set) var models: [Model] = []
    private(set) var colors: [Color] = []
    private(set) var years: [String] = .yearsFrom(year: 1950)

    private var selectedModel: Model?
    private var selectedColor: Color?
    private var selectedYear: String = .empty

    private lazy var setCarHandler: RequestHandler<CarSetResponse> = {
        RequestHandler<CarSetResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.saveCar(with: data.carId)
                self?.view?.handleCarAdded()
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(with: error.message ?? .error(.unknownError))
            }
    }()

    private lazy var loadModelsHandler: RequestHandler<ModelsAndColorsResponse> = {
        RequestHandler<ModelsAndColorsResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.models = data.models
                self?.colors = data.colors
                self?.view?.handleModelsLoaded()
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(with: error.message ?? .error(.unknownError))
            }
    }()

    private lazy var skipAddCarHandler: RequestHandler<SimpleResponse> = {
        RequestHandler<SimpleResponse>()
            .observe(on: .main)
            .bind { [weak self] _ in
                if case .register = self?.type {
                    self?.view?.handleCarAdded()
                }
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(with: error.message ?? .error(.requestError))
            }
    }()

    var loadNeeded: Bool {
        models.isEmpty && colors.isEmpty
    }

    init(service: InfoService = .init()) {
        self.service = service
    }

    // MARK: - Public methods
    func configure(type: AddInfoType, models: [Model], colors: [Color]) {
        self.type = type
        self.models = models
        self.colors = colors
    }

    func setSelectedModel(for row: Int) -> String? {
        guard models.indices.contains(row) else {
            return nil
        }

        selectedModel = models[row]
        return selectedModel?.name
    }

    func setSelectedColor(for row: Int) -> String? {
        guard colors.indices.contains(row) else {
            return nil
        }

        selectedColor = colors[row]
        return selectedColor?.name
    }

    func setSelectedYear(for row: Int) -> String? {
        guard years.indices.contains(row) else {
            return nil
        }

        selectedYear = years[row]
        return selectedYear
    }

    func setCar() {
        guard let modelId = selectedModel?.id,
              let colorId = selectedColor?.id,
              let userId = KeychainManager<UserId>.get()?.value else {
            return
        }

        let body = SetCarBody(brandId: Brand.Toyota, userId: userId, carModelId: modelId,
                              colorId: colorId, licensePlate: plate, vinCode: vin,
                              year: selectedYear)
        service.addCar(with: body, handler: setCarHandler)
    }

    func skipRegister() {
        service.skipSetCar(with: .init(userId: KeychainManager<UserId>.get()!.value),
                           handler: skipAddCarHandler)
    }

    func loadModelsAndColors() {
        service.getModelsAndColors(with: .init(brandId: Brand.Toyota), handler: loadModelsHandler)
    }

    // MARK: - Private methods
    private func saveCar(with id: String) {
        guard let selectedModel = selectedModel,
              let selectedColor = selectedColor,
              selectedYear.isNotEmpty, vin.isNotEmpty else {
            return
        }

        let car = Car(id: id, brand: Brand.ToyotaName, model: selectedModel,
                      color: selectedColor, year: selectedYear, plate: plate,
                      vin: vin, isChecked: false)

        switch type {
            case .register:
                KeychainManager.set(Cars([car]))
            case .update(let userProxy):
                userProxy.addNew(car: car)
        }
    }
}
