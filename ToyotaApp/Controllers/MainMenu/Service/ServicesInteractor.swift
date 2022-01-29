import Foundation

protocol ServicesView: AnyObject {
    func didSelect(showroom: Showroom, with index: Int?)
    func didLoadShowrooms()
    func didLoadServiceTypes()
    func didFailShowrooms(with error: String)
    func didFailServiceTypes(with error: String)
}

class ServicesInteractor {
    weak var view: ServicesView?

    private let servicesTypesHandler = RequestHandler<ServicesTypesResponse>()
    private let showroomsHandler = RequestHandler<ShowroomsResponse>()

    private(set) var serviceTypes: [ServiceType] = []
    private(set) var showrooms: [Showroom] = []

    var selectedCity: City? = DefaultsManager.getUserInfo(for: .selectedCity) {
        didSet {
            DefaultsManager.push(info: selectedCity, for: .selectedCity)
        }
    }

    var selectedShowroom: Showroom? = DefaultsManager.getUserInfo(for: .selectedShowroom) {
        didSet {
            DefaultsManager.push(info: selectedShowroom, for: .selectedShowroom)
            guard let showroom = selectedShowroom else {
                return
            }

            let index = showrooms.firstIndex(where: { $0.id == showroom.id })
            DispatchQueue.main.async { [weak self] in
                self?.view?.didSelect(showroom: showroom, with: index)
            }
        }
    }

    var selectedShowroomIndex: Int? {
        guard let showroom = selectedShowroom,
              showrooms.isNotEmpty else {
            return nil
        }

        return showrooms.firstIndex(where: { $0.id == showroom.id })
    }

    init() {
        bindHandlers()
    }

    func selectShowroom(for row: Int) {
        guard showrooms.isNotEmpty, showrooms.indices.contains(row),
              showrooms[row].id != selectedShowroom?.id else {
            return
        }

        selectedShowroom = showrooms[row]
    }

    func loadServiceTypes() {
        NetworkService.makeRequest(page: .services(.getServicesTypes),
                                   params: [(.carInfo(.showroomId),
                                             selectedShowroom?.id)],
                                   handler: servicesTypesHandler)
    }

    func loadShowrooms() {
        NetworkService.makeRequest(page: .registration(.getShowrooms),
                                   params: [(.auth(.brandId), Brand.Toyota),
                                            (.carInfo(.cityId), selectedCity?.id)],
                                   handler: showroomsHandler)
    }

    private func didLoad(showrooms: [Showroom]) {
        self.showrooms = showrooms
        view?.didLoadShowrooms()

        guard !showrooms.contains(where: { $0.id == selectedShowroom?.id }) else {
            return
        }

        selectedShowroom = showrooms.first
    }

    private func bindHandlers() {
        servicesTypesHandler
            .bind { [weak self] response in
                self?.serviceTypes = response.serviceType
                DispatchQueue.main.async {
                    self?.view?.didLoadServiceTypes()
                }
            } onFailure: { [weak self] error in
                let errorMessage = error.errorCode == .lostConnection
                    ? .error(.networkError) + " и "
                    : .error(.servicesError) + ". "
                DispatchQueue.main.async {
                    self?.serviceTypes = []
                    self?.view?.didFailServiceTypes(with: errorMessage)
                }
            }

        showroomsHandler
            .bind { [weak self] response in
                DispatchQueue.main.async {
                    self?.didLoad(showrooms: response.showrooms)
                }
            } onFailure: { [weak self] error in
                let errorMessage = error.errorCode == .lostConnection
                    ? .error(.networkError) + " и "
                    : .error(.showroomsError) + ". "
                DispatchQueue.main.async {
                    self?.showrooms = []
                    self?.selectedShowroom = nil
                    self?.view?.didFailShowrooms(with: errorMessage)
                }
            }
    }
}
