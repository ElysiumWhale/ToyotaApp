import Foundation

final class CityPickerInteractor {
    private let cityRequestHandler = RequestHandler<CitiesResponse>()
    private let service: CitiesService
    private let defaults: any KeyedCodableStorage<DefaultKeys>

    private(set) var cities: [City] = [] {
        didSet {
            selectedCity = nil
        }
    }

    private(set) var selectedCity: City?

    weak var view: CityPickerViewController?

    init(
        cities: [City] = [],
        service: CitiesService = InfoService(),
        defaults: any KeyedCodableStorage<DefaultKeys> = DefaultsService.shared
    ) {
        self.cities = cities
        self.service = service
        self.defaults = defaults

        setupRequestHandlers()
    }

    func selectCity(for row: Int) {
        guard cities.indices.contains(row) else {
            return
        }

        selectedCity = cities[row]
    }

    func loadCities() {
        service.getCities(
            with: GetCitiesBody(brandId: Brand.Toyota),
            cityRequestHandler
        )
    }

    func saveCity() -> Bool {
        guard let selectedCity = selectedCity else {
            return false
        }

        defaults.set(value: selectedCity, key: .selectedCity)
        return true
    }

    private func setupRequestHandlers() {
        cityRequestHandler
            .observe(on: .main)
            .bind { [weak self] data in
                self?.cities = data.cities
                self?.view?.handleSuccess()
            } onFailure: { [weak self] _ in
                self?.cities = []
                self?.view?.handleFailure()
            }
    }
}
