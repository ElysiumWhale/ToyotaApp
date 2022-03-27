import Foundation

protocol CityPickerView: AnyObject {
    func handleSuccess()
    func handleFailure()
}

protocol CityPickerDelegate: AnyObject {
    func cityDidSelect(_ city: City)
    var cityPickButtonText: String { get }
    var dismissAfterPick: Bool { get }
}

class CityPickerInteractor {
    private let service: InfoService

    weak var view: CityPickerView?
    weak var cityPickerDelegate: CityPickerDelegate?

    private(set) var cities: [City] = [] {
        didSet {
            selectedCity = nil
        }
    }

    private var selectedCity: City?

    private lazy var cityRequestHandler: RequestHandler<CitiesResponse> = {
        RequestHandler<CitiesResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.cities = data.cities
                self?.view?.handleSuccess()
            } onFailure: { [weak self] _ in
                self?.cities = []
                self?.view?.handleFailure()
            }
    }()

    init(service: InfoService = .init()) {
        self.service = service
    }

    func configure(with cities: [City]) {
        if cities.isNotEmpty {
            self.cities = cities
        }
    }

    func selectCity(for row: Int) {
        guard cities.indices.contains(row) else {
            return
        }

        selectedCity = cities[row]
    }

    func loadCities() {
        service.getCities(with: .init(brandId: Brand.Toyota), handler: cityRequestHandler)
    }

    func saveCity() -> Bool {
        guard let selectedCity = selectedCity else {
            return false
        }

        cityPickerDelegate?.cityDidSelect(selectedCity)
        return DefaultsManager.push(info: selectedCity, for: .selectedCity)
    }
}
