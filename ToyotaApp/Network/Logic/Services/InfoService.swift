import Foundation

final class InfoService {
    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func perform<TResponse>(
        _ request: Request,
        with handler: RequestHandler<TResponse>
    ) where TResponse: IResponse {
        networkService.makeRequest(request, handler)
    }
}

// MARK: - AuthService
extension InfoService: AuthService {
    func registerPhone(
        with body: RegisterPhoneBody,
        _ handler: RequestHandler<SimpleResponse>
    ) {
        perform(
            Request(page: .registration(.registerPhone), body: body),
            with: handler
        )
    }

    func changePhone(
        with body: ChangePhoneBody,
        _ handler: RequestHandler<SimpleResponse>
    ) {
        perform(
            Request(page: .setting(.changePhone), body: body),
            with: handler
        )
    }

    func deleteTemporaryPhone(with body: DeletePhoneBody) {
        perform(
            Request(page: .registration(.deleteTemp), body: body),
            with: RequestHandler<SimpleResponse>()
        )
    }

    func checkCode(
        with body: CheckSmsCodeBody,
        _ handler: RequestHandler<CheckUserOrSmsCodeResponse>
    ) {
        perform(
            Request(page: .registration(.checkCode), body: body),
            with: handler
        )
    }
}

// MARK: - ReconnectionService
extension InfoService: ReconnectionService {
    func checkUser(
        with body: CheckUserBody,
        _ handler: RequestHandler<CheckUserOrSmsCodeResponse>
    ) {
        perform(
            Request(page: .start(.checkUser), body: body),
            with: handler
        )
    }
}

// MARK: - PersonalInfoService
extension InfoService: PersonalInfoService {
    func setProfile(
        with body: SetProfileBody,
        _ handler: RequestHandler<CitiesResponse>
    ) {
        perform(
            Request(page: .registration(.setProfile), body: body),
            with: handler
        )
    }

    func updateProfile(
        with body: EditProfileBody,
        _ handler: RequestHandler<SimpleResponse>
    ) {
        perform(
            Request(page: .profile(.editProfile), body: body),
            with: handler
        )
    }
}

// MARK: - AddCarService
extension InfoService: CarsService {
    func addCar(
        with body: SetCarBody,
        _ handler: RequestHandler<CarSetResponse>
    ) {
        perform(
            Request(page: .registration(.setCar), body: body),
            with: handler
        )
    }

    func removeCar(
        with body: DeleteCarBody,
        _ handler: RequestHandler<SimpleResponse>
    ) {
        perform(
            Request(page: .profile(.removeCar), body: body),
            with: handler
        )
    }

    func skipSetCar(
        with body: SkipSetCarBody,
        _ handler: RequestHandler<SimpleResponse>
    ) {
        perform(
            Request(page: .registration(.checkVin), body: body),
            with: handler
        )
    }

    func getModelsAndColors(
        with body: GetModelsAndColorsBody,
        _ handler: RequestHandler<ModelsAndColorsResponse>
    ) {
        perform(
            Request(page: .registration(.getModelsAndColors), body: body),
            with: handler
        )
    }
}

// MARK: - BookingsService
extension InfoService: BookingsService {
    func getBookings(
        with body: GetBookingsBody,
        _ handler: RequestHandler<BookingsResponse>
    ) {
        perform(
            Request(page: .profile(.getBookings), body: body),
            with: handler
        )
    }
}

// MARK: - ManagersService
extension InfoService: ManagersService {
    func getManagers(
        with body: GetManagersBody,
        _ handler: RequestHandler<ManagersResponse>
    ) {
        perform(
            Request(page: .profile(.getManagers), body: body),
            with: handler
        )
    }
}

// MARK: - ServicesService
extension InfoService: ServicesService {
    func getShowrooms(
        with body: GetShowroomsBody,
        _ handler: RequestHandler<ShowroomsResponse>
    ) {
        perform(
            Request(page: .registration(.getShowrooms), body: body),
            with: handler
        )
    }

    func getServiceTypes(
        with body: GetServiceTypesBody,
        _ handler: RequestHandler<ServicesTypesResponse>
    ) {
        perform(
            Request(page: .services(.getServicesTypes), body: body),
            with: handler
        )
    }
}

// MARK: - CitiesService
extension InfoService: CitiesService {
    func getCities(
        with body: GetCitiesBody,
        _ handler: RequestHandler<CitiesResponse>
    ) {
        perform(
            Request(page: .profile(.getCities), body: body),
            with: handler
        )
    }
}
