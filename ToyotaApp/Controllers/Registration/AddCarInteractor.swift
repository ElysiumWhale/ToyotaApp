import Foundation

protocol AddCarViewInput: AnyObject {
    func handleCarAdded()
    func handleFailure(with message: String)
    func handleModelsLoaded()
}

class AddCarInteractor {
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
        let handler = RequestHandler<CarSetResponse>()

        handler.onSuccess = { [weak self] data in
            self?.saveCar(with: data.carId)
            DispatchQueue.main.async {
                self?.view?.handleCarAdded()
            }
        }

        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.view?.handleFailure(with: error.message ?? .error(.unknownError))
            }
        }

        return handler
    }()

    private lazy var loadModelsHandler: RequestHandler<ModelsAndColorsResponse> = {
        let handler = RequestHandler<ModelsAndColorsResponse>()

        handler.onSuccess = { [weak self] data in
            self?.models = data.models
            self?.colors = data.colors
            DispatchQueue.main.async {
                self?.view?.handleModelsLoaded()
            }
        }

        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.view?.handleFailure(with: error.message ?? .error(.unknownError))
            }
        }

        return handler
    }()

    var loadNeeded: Bool {
        models.isEmpty && colors.isEmpty
    }

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
              let colorId = selectedColor?.id else {
            return
        }

        NetworkService.makeRequest(page: .registration(.setCar),
                                   params: [(.auth(.brandId), Brand.Toyota),
                                            (.auth(.userId), KeychainManager<UserId>.get()?.id),
                                            (.carInfo(.modelId), modelId),
                                            (.carInfo(.colorId), colorId),
                                            (.carInfo(.vinCode), vin),
                                            (.carInfo(.licensePlate), plate),
                                            (.carInfo(.releaseYear), selectedYear)],
                                   handler: setCarHandler)
    }

    func loadModelsAndColors() {
        NetworkService.makeRequest(page: .registration(.getModelsAndColors),
                                   params: [(.auth(.brandId), Brand.Toyota)],
                                   handler: loadModelsHandler)
    }

    private func saveCar(with id: String) {
        guard let selectedModel = selectedModel,
              let selectedColor = selectedColor,
              !selectedYear.isEmpty, !vin.isEmpty else {
            return
        }

        let car = Car(id: id, brand: Brand.Toyota, model: selectedModel,
                      color: selectedColor, plate: plate, vin: vin, isChecked: false)

        switch type {
            case .register:
                KeychainManager.set(Cars([car]))
            case .update(let userProxy):
                userProxy.addNew(car: car)
        }
    }
}
