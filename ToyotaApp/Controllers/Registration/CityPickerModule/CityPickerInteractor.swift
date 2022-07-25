import Foundation

protocol CityPickerDelegate: AnyObject {
    var cityPickButtonText: String { get }
    var dismissAfterPick: Bool { get }

    func cityDidSelect(_ city: City)
}

class CityPickerInteractor {
    private let service: InfoService

    private lazy var cityRequestHandler = RequestHandler<CitiesResponse>()
        .observe(on: .main)
        .bind { [weak self] data in
            self?.cities = data.cities
            self?.view?.handleSuccess()
        } onFailure: { [weak self] _ in
            self?.cities = []
            self?.view?.handleFailure()
        }

    private(set) var cities: [City] = [] {
        didSet {
            selectedCity = nil
        }
    }

    private(set) var selectedCity: City?

    weak var view: CityPickerView?

    init(cities: [City] = [], service: InfoService = .init()) {
        self.cities = cities
        self.service = service
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

        return DefaultsManager.push(info: selectedCity, for: .selectedCity)
    }
}
