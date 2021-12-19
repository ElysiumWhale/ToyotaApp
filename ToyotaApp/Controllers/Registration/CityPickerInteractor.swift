import Foundation

protocol CityPickerView: AnyObject {
    func handleSuccess()
    func handleFailure()
}

class CityPickerInteractor {
    weak var view: CityPickerView?

    private(set) var cities: [City] = [] {
        didSet {
            selectedCity = nil
        }
    }

    private var selectedCity: City?

    private lazy var cityRequestHandler: RequestHandler<CitiesResponse> = {
        let handler = RequestHandler<CitiesResponse>()

        handler.onSuccess = { [weak self] data in
            self?.cities = data.cities
            DispatchQueue.main.async {
                self?.view?.handleSuccess()
            }
        }

        handler.onFailure = { [weak self] _ in
            self?.cities = []
            DispatchQueue.main.async {
                self?.view?.handleFailure()
            }
        }

        return handler
    }()

    func configure(with cities: [City]) {
        if !cities.isEmpty {
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
        NetworkService.makeRequest(page: .profile(.getCities),
                                   params: [(.auth(.brandId), Brand.Toyota)],
                                   handler: cityRequestHandler)
    }

    func saveCity() -> Bool {
        DefaultsManager.pushUserInfo(info: selectedCity)
    }
}
