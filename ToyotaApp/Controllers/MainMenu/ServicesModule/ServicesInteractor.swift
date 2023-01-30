import Foundation

protocol ServicesView: AnyObject {
    func didSelect(showroom: Showroom, with index: Int?)

    func didLoadShowrooms()
    func didFailShowrooms(with error: String)

    func didLoadServiceTypes()
    func didFailServiceTypes(with error: String)
}

final class ServicesInteractor {
    private let servicesTypesHandler = RequestHandler<ServicesTypesResponse>()
    private let showroomsHandler = RequestHandler<ShowroomsResponse>()
    private let service: ServicesService

    let user: UserProxy

    private(set) var serviceTypes: [ServiceType] = []
    private(set) var showrooms: [Showroom] = []

    weak var view: ServicesView?

    @DefaultsBacked<City>(key: .selectedCity)
    var selectedCity {
        didSet {
            selectedShowroom = nil
        }
    }

    @DefaultsBacked<Showroom>(key: .selectedShowroom)
    private(set) var selectedShowroom {
        didSet {
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

    init(user: UserProxy, service: ServicesService = InfoService()) {
        self.user = user
        self.service = service

        setupRequestHandlers()
    }

    func selectShowroom(for row: Int) {
        guard showrooms.isNotEmpty, showrooms.indices.contains(row),
              showrooms[row].id != selectedShowroom?.id else {
            return
        }

        selectedShowroom = showrooms[row]
    }

    func loadServiceTypes() {
        guard let id = selectedShowroom?.id else {
            return
        }

        service.getServiceTypes(
            with: .init(showroomId: id),
            servicesTypesHandler
        )
    }

    func loadShowrooms() {
        guard let id = selectedCity?.id else {
            return
        }

        service.getShowrooms(
            with: .init(brandId: Brand.Toyota, cityId: id),
            showroomsHandler
        )
    }

    private func didLoad(showrooms: [Showroom]) {
        self.showrooms = showrooms
        view?.didLoadShowrooms()

        guard !showrooms.contains(where: { $0.id == selectedShowroom?.id }) else {
            return
        }

        selectedShowroom = showrooms.first
    }

    private func setupRequestHandlers() {
        servicesTypesHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.serviceTypes = response.serviceType
                self?.view?.didLoadServiceTypes()
            } onFailure: { [weak self] error in
                let errorMessage = error.errorCode == .lostConnection
                    ? .error(.networkError) + " и "
                    : .error(.servicesError) + ". "
                self?.serviceTypes = []
                self?.view?.didFailServiceTypes(with: errorMessage)
            }

        showroomsHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.didLoad(showrooms: response.showrooms)
            } onFailure: { [weak self] error in
                let errorMessage = error.errorCode == .lostConnection
                    ? .error(.networkError) + " и "
                    : .error(.showroomsError) + ". "
                self?.showrooms = []
                self?.selectedShowroom = nil
                self?.view?.didFailShowrooms(with: errorMessage)
            }
    }
}
