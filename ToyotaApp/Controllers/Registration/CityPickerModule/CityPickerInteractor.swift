import Foundation

final class CityPickerInteractor {
    private let cityRequestHandler = RequestHandler<CitiesResponse>()
    private let service: CitiesService

    private(set) var cities: [City] = [] {
        didSet {
            selectedCity = nil
        }
    }

    private(set) var selectedCity: City?

    weak var view: CityPickerViewController?

    init(cities: [City] = [], service: CitiesService = InfoService()) {
        self.cities = cities
        self.service = service

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
            handler: cityRequestHandler
        )
    }

    func saveCity() -> Bool {
        guard let selectedCity = selectedCity else {
            return false
        }

        return DefaultsManager.push(info: selectedCity,
                                    for: .selectedCity)
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
