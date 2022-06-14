import Foundation

protocol AuthService {
    func registerPhone(with body: RegsiterPhoneBody, handler: RequestHandler<SimpleResponse>)

    func checkCode(with body: CheckSmsCodeBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>)
    func changePhone(with body: ChangePhoneBody, handler: RequestHandler<SimpleResponse>)
    func deleteTemporaryPhone(with body: DeletePhoneBody)
}

protocol ReconnectionService {
    func checkUser(with body: CheckUserBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>)
}

final class InfoService: AuthService, ReconnectionService {
    func perform<TResponse: IResponse>(with handler: RequestHandler<TResponse>,
                                       _ requestFactory: ValueClosure<Request>) {
        NetworkService.makeRequest(requestFactory(), handler: handler)
    }

    func setProfile(with body: SetProfileBody, handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setProfile), body: body)
        }
    }

    func updateProfile(with body: SetProfileBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.editProfile), body: body)
        }
    }

    func getCities(with body: GetCitiesBody, handler: RequestHandler<CitiesResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getCities), body: body)
        }
    }

    func getShowrooms(with body: GetShowroomsBody, handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getShowrooms), body: body)
        }
    }

    func getShowroomsFTD(with body: GetShowroomsForTestDriveBody, handler: RequestHandler<ShowroomsResponse>) {
        perform(with: handler) {
            Request(page: .services(.getTestDriveShowrooms), body: body)
        }
    }

    func addCar(with body: SetCarBody, handler: RequestHandler<CarSetResponse>) {
        perform(with: handler) {
            Request(page: .registration(.setCar), body: body)
        }
    }

    func getServiceTypes(with body: GetServiceTypesBody, handler: RequestHandler<ServicesTypesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServicesTypes), body: body)
        }
    }

    func getServices(with body: GetServicesBody, handler: RequestHandler<ServicesResponse>) {
        perform(with: handler) {
            Request(page: .services(.getServices), body: body)
        }
    }

    func checkUser(with body: CheckUserBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        perform(with: handler) {
            Request(page: .start(.checkUser), body: body)
        }
    }

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

    func getModelsAndColors(with body: GetModelsAndColorsBody, handler: RequestHandler<ModelsAndColorsResponse>) {
        perform(with: handler) {
            Request(page: .registration(.getModelsAndColors), body: body)
        }
    }

    func bookService(with body: BookServiceBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .services(.bookService), body: body)
        }
    }

    func getManagers(with body: GetManagersBody, handler: RequestHandler<ManagersResponse>) {
        perform(with: handler) {
            Request(page: .profile(.getManagers), body: body)
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

    func skipSetCar(with body: SkipSetCarBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .registration(.checkVin), body: body)
        }
    }

    @available(*, unavailable)
    func addShowroom(with body: AddShowroomBody, handler: RequestHandler<SimpleResponse>) {
        perform(with: handler) {
            Request(page: .profile(.addShowroom), body: body)
        }
    }
}
