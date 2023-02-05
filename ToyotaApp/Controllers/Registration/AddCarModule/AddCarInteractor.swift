import Foundation

protocol AddCarViewInput: AnyObject {
    func handleCarAdded()
    func handleFailure(with message: String)
    func handleModelsLoaded()
}

final class AddCarInteractor {
    private let setCarHandler = RequestHandler<CarSetResponse>()
    private let modelsAndColorsHandler = RequestHandler<ModelsAndColorsResponse>()
    private let skipAddCarHandler = DefaultRequestHandler()
    private let service: CarsService
    private let keychain: any ModelKeyedCodableStorage<KeychainKeys>

    weak var view: AddCarViewInput?

    let type: AddInfoScenario

    private(set) var models: [Model] = []
    private(set) var colors: [Color] = []
    private(set) var years: [String] = .yearsFrom(year: 1950)

    private var selectedModel: Model?
    private var selectedColor: Color?
    private var selectedYear: String = .empty
    private var vin: String = .empty
    private var plate: String = .empty

    var loadNeeded: Bool {
        models.isEmpty && colors.isEmpty
    }

    init(
        type: AddInfoScenario = .register,
        models: [Model] = [],
        colors: [Color] = [],
        service: CarsService = InfoService(),
        keychain: any ModelKeyedCodableStorage<KeychainKeys> = KeychainService.shared
    ) {
        self.type = type
        self.models = models
        self.colors = colors
        self.service = service
        self.keychain = keychain

        setupRequestHandlers()
    }

    // MARK: - Public methods
    func setSelectedModel(for row: Int) -> String? {
        selectedModel = models[safe: row]
        return selectedModel?.name
    }

    func setSelectedColor(for row: Int) -> String? {
        selectedColor = colors[safe: row]
        return selectedColor?.name
    }

    func setSelectedYear(for row: Int) -> String? {
        selectedYear = years[safe: row] ?? .empty
        return selectedYear
    }

    func setCar(vin: String, plate: String) {
        guard
            let modelId = selectedModel?.id,
            let colorId = selectedColor?.id,
            let userId: UserId = keychain.get()
        else {
            return
        }

        self.vin = vin
        self.plate = plate
        let body = SetCarBody(
            brandId: Brand.Toyota,
            userId: userId.value,
            carModelId: modelId,
            colorId: colorId,
            licensePlate: plate,
            vinCode: vin,
            year: selectedYear
        )
        service.addCar(with: body, setCarHandler)
    }

    func skipRegister() {
        guard let userId: UserId = keychain.get() else {
            return
        }

        service.skipSetCar(
            with: SkipSetCarBody(userId: userId.value),
            skipAddCarHandler
        )
    }

    func loadModelsAndColors() {
        service.getModelsAndColors(
            with: GetModelsAndColorsBody(brandId: Brand.Toyota),
            modelsAndColorsHandler
        )
    }

    // MARK: - Private methods
    private func setupRequestHandlers() {
        setCarHandler
            .observe(on: .main)
            .bind { [weak self] data in
                self?.saveCar(with: data.carId)
                self?.view?.handleCarAdded()
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(
                    with: error.message ?? .error(.unknownError)
                )
            }

        modelsAndColorsHandler
            .observe(on: .main)
            .bind { [weak self] data in
                self?.models = data.models
                self?.colors = data.colors
                self?.view?.handleModelsLoaded()
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(
                    with: error.message ?? .error(.unknownError)
                )
            }

        skipAddCarHandler
            .observe(on: .main)
            .bind { [weak self, type] _ in
                if case .register = type {
                    self?.view?.handleCarAdded()
                }
            } onFailure: { [weak self] error in
                self?.view?.handleFailure(
                    with: error.message ?? .error(.requestError)
                )
            }
    }

    private func saveCar(with id: String) {
        guard
            let selectedModel = selectedModel,
            let selectedColor = selectedColor,
            selectedYear.isNotEmpty,
            vin.isNotEmpty
        else {
            return
        }

        let car = Car(
            id: id,
            brand: Brand.ToyotaName,
            model: selectedModel,
            color: selectedColor,
            year: selectedYear,
            plate: plate,
            vin: vin,
            isChecked: false
        )

        switch type {
        case .register:
            keychain.set(Cars([car]))
        case let .update(userProxy):
            userProxy.addNew(car: car)
        }
    }
}
