import Foundation

final class InfoService {
    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func perform<TResponse>(
        with handler: RequestHandler<TResponse>,
        _ requestFactory: ValueClosure<Request>
    ) where TResponse: IResponse {
        networkService.makeRequest(requestFactory(), handler: handler)
    }

    func getShowroomsFTD(with body: GetShowroomsForTestDriveBody,
                         handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .services(.getTestDriveShowrooms), body: body)
        }
    }

    func getServices(with body: GetServicesBody,
                     handler: RequestHandler<ServicesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServices), body: body)
        }
    }

    func getCarsFTD(with body: GetCarsForTestDriveBody,
                    handler: RequestHandler<CarsResponse>) {
        perform(with: handler) {
            Request(page: .services(.getTestDriveCars), body: body)
        }
    }

    func getFreeTime(with body: GetFreeTimeBody,
                     handler: RequestHandler<FreeTimeResponse>) {
        perform(with: handler) {
            Request(page: .services(.getFreeTime), body: body)
        }
    }
}

// MARK: - AuthService
extension InfoService: AuthService {
    func registerPhone(with body: RegisterPhoneBody,
                       handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .registration(.registerPhone), body: body)
        }
    }

    func changePhone(with body: ChangePhoneBody,
                     handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .setting(.changePhone), body: body)
        }
    }

    func deleteTemporaryPhone(with body: DeletePhoneBody) {
        let request = Request(page: .registration(.deleteTemp), body: body)
        networkService.makeRequest(request)
    }

    func checkCode(with body: CheckSmsCodeBody,
                   handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        perform(with: handler) {
            Request(page: .registration(.checkCode), body: body)
        }
    }
}

// MARK: - ReconnectionService
extension InfoService: ReconnectionService {
    func checkUser(with body: CheckUserBody,
                   handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        perform(with: handler) {
            Request(page: .start(.checkUser), body: body)
        }
    }
}

// MARK: - PersonalInfoService
extension InfoService: PersonalInfoService {
    func setProfile(with body: SetProfileBody,
                    handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setProfile), body: body)
        }
    }

    func updateProfile(with body: EditProfileBody,
                       handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.editProfile), body: body)
        }
    }
}

// MARK: - AddCarService
extension InfoService: CarsService {
    func addCar(with body: SetCarBody,
                handler: RequestHandler<CarSetResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setCar), body: body)
        }
    }

    func removeCar(with body: DeleteCarBody,
                   handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.removeCar), body: body)
        }
    }

    func skipSetCar(with body: SkipSetCarBody,
                    handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .registration(.checkVin), body: body)
        }
    }

    func getModelsAndColors(with body: GetModelsAndColorsBody,
                            handler: RequestHandler<ModelsAndColorsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getModelsAndColors), body: body)
        }
    }
}

// MARK: - BookingsService
extension InfoService: BookingsService {
    func getBookings(with body: GetBookingsBody,
                     handler: RequestHandler<BookingsResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getBookings), body: body)
        }
    }
}

// MARK: - ManagersService
extension InfoService: ManagersService {
    func getManagers(with body: GetManagersBody,
                     handler: RequestHandler<ManagersResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getManagers), body: body)
        }
    }
}

// MARK: - ServicesService
extension InfoService: ServicesService {
    func getShowrooms(with body: GetShowroomsBody,
                      handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getShowrooms), body: body)
        }
    }

    func getServiceTypes(with body: GetServiceTypesBody,
                         handler: RequestHandler<ServicesTypesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServicesTypes), body: body)
        }
    }
}

// MARK: - CitiesService
extension InfoService: CitiesService {
    func getCities(with body: GetCitiesBody,
                   handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getCities), body: body)
        }
    }
}
