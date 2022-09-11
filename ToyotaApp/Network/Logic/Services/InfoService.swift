import Foundation

protocol AuthService {
    func registerPhone(with body: RegsiterPhoneBody,
                       handler: RequestHandler<SimpleResponse>)
    func checkCode(with body: CheckSmsCodeBody,
                   handler: RequestHandler<CheckUserOrSmsCodeResponse>)
    func changePhone(with body: ChangePhoneBody,
                     handler: RequestHandler<SimpleResponse>)
    func deleteTemporaryPhone(with body: DeletePhoneBody)
}

protocol ReconnectionService {
    func checkUser(with body: CheckUserBody,
                   handler: RequestHandler<CheckUserOrSmsCodeResponse>)
}

protocol PersonalInfoService {
    func setProfile(with body: SetProfileBody,
                    handler: RequestHandler<CitiesResponse>)
    func updateProfile(with body: EditProfileBody,
                       handler: RequestHandler<SimpleResponse>)
}

protocol CarsService {
    func addCar(with body: SetCarBody, handler: RequestHandler<CarSetResponse>)
    func skipSetCar(with body: SkipSetCarBody,
                    handler: RequestHandler<SimpleResponse>)
    func getModelsAndColors(with body: GetModelsAndColorsBody,
                            handler: RequestHandler<ModelsAndColorsResponse>)
    func removeCar(with body: DeleteCarBody, handler: RequestHandler<SimpleResponse>)
}

protocol BookingsService {
    func getBookings(with body: GetBookingsBody,
                     handler: RequestHandler<BookingsResponse>)
}

protocol ManagersService {
    func getManagers(with body: GetManagersBody,
                     handler: RequestHandler<ManagersResponse>)
}

protocol ServicesService {
    func getShowrooms(with body: GetShowroomsBody,
                      handler: RequestHandler<ShowroomsResponse>)
    func getServiceTypes(with body: GetServiceTypesBody,
                         handler: RequestHandler<ServicesTypesResponse>)
}

protocol CitiesService {
    func getCities(with body: GetCitiesBody, handler: RequestHandler<CitiesResponse>)
}

final class InfoService {
    func perform<TResponse: IResponse>(with handler: RequestHandler<TResponse>,
                                       _ requestFactory: ValueClosure<Request>) {
        NetworkService.makeRequest(requestFactory(), handler: handler)
    }

    func getCities(with body: GetCitiesBody, handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getCities), body: body)
        }
    }

    func getShowroomsFTD(with body: GetShowroomsForTestDriveBody, handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .services(.getTestDriveShowrooms), body: body)
        }
    }

    func getServices(with body: GetServicesBody, handler: RequestHandler<ServicesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServices), body: body)
        }
    }

    func bookService(with body: BookServiceBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .services(.bookService), body: body)
        }
    }

    func getCarsFTD(with body: GetCarsForTestDriveBody, handler: RequestHandler<CarsResponse>) {
        perform(with: handler) {
            Request(page: .services(.getTestDriveCars), body: body)
        }
    }

    func getFreeTime(with body: GetFreeTimeBody, handler: RequestHandler<FreeTimeResponse>) {
        perform(with: handler) {
            Request(page: .services(.getFreeTime), body: body)
        }
    }
}

// MARK: - AuthService
extension InfoService: AuthService {
    func registerPhone(with body: RegsiterPhoneBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .registration(.registerPhone), body: body)
        }
    }

    func changePhone(with body: ChangePhoneBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .setting(.changePhone), body: body)
        }
    }

    func deleteTemporaryPhone(with body: DeletePhoneBody) {
        let request = Request(page: .registration(.deleteTemp), body: body)
        NetworkService.makeRequest(request)
    }

    func checkCode(with body: CheckSmsCodeBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        perform(with: handler) {
            Request(page: .registration(.checkCode), body: body)
        }
    }
}

// MARK: - ReconnectionService
extension InfoService: ReconnectionService {
    func checkUser(with body: CheckUserBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        perform(with: handler) {
            Request(page: .start(.checkUser), body: body)
        }
    }
}

// MARK: - PersonalInfoService
extension InfoService: PersonalInfoService {
    func setProfile(with body: SetProfileBody, handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setProfile), body: body)
        }
    }

    func updateProfile(with body: EditProfileBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.editProfile), body: body)
        }
    }
}

// MARK: - AddCarService
extension InfoService: CarsService {
    func addCar(with body: SetCarBody, handler: RequestHandler<CarSetResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setCar), body: body)
        }
    }

    func removeCar(with body: DeleteCarBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.removeCar), body: body)
        }
    }

    func skipSetCar(with body: SkipSetCarBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .registration(.checkVin), body: body)
        }
    }

    func getModelsAndColors(with body: GetModelsAndColorsBody, handler: RequestHandler<ModelsAndColorsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getModelsAndColors), body: body)
        }
    }
}

// MARK: - BookingsService
extension InfoService: BookingsService {
    func getBookings(with body: GetBookingsBody, handler: RequestHandler<BookingsResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getBookings), body: body)
        }
    }
}

// MARK: - ManagersService
extension InfoService: ManagersService {
    func getManagers(with body: GetManagersBody, handler: RequestHandler<ManagersResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getManagers), body: body)
        }
    }
}

// MARK: - ServicesService
extension InfoService: ServicesService {
    func getShowrooms(with body: GetShowroomsBody, handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getShowrooms), body: body)
        }
    }

    func getServiceTypes(with body: GetServiceTypesBody, handler: RequestHandler<ServicesTypesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServicesTypes), body: body)
        }
    }
}

// MARK: - CitiesService
extension InfoService: CitiesService {
    func getCities(with body: GetCitiesBody, handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getCities), body: body)
        }
    }
}
