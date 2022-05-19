import Foundation

protocol AuthService {
    func registerPhone(with body: RegsiterPhoneBody, handler: RequestHandler<SimpleResponse>)
}

class InfoService: AuthService {
    func perform<TResponse: IResponse>(with handler: RequestHandler<TResponse>,
                                       _ requestCreator: ValueClosure<Request>) {
        NetworkService.makeRequest(requestCreator(), handler: handler)
    }

    func setProfile(with body: SetProfileBody, handler: RequestHandler<CitiesResponse>) {
        let request = Request(page: .registration(.setProfile), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func updateProfile(with body: SetProfileBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .profile(.editProfile), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getCities(with body: GetCitiesBody, handler: RequestHandler<CitiesResponse>) {
        let request = Request(page: .profile(.getCities), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getShowrooms(with body: GetShowroomsBody, handler: RequestHandler<ShowroomsResponse>) {
        let request = Request(page: .registration(.getShowrooms), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getShowroomsFTD(with body: GetShowroomsForTestDriveBody, handler: RequestHandler<ShowroomsResponse>) {
        let request = Request(page: .services(.getTestDriveShowrooms), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func addCar(with body: SetCarBody, handler: RequestHandler<CarSetResponse>) {
        let request = Request(page: .registration(.setCar), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getServiceTypes(with body: GetServiceTypesBody, handler: RequestHandler<ServicesTypesResponse>) {
        let request = Request(page: .services(.getServicesTypes), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getServices(with body: GetServicesBody, handler: RequestHandler<ServicesResponse>) {
        let request = Request(page: .services(.getServices), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func checkUser(with body: CheckUserBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        let request = Request(page: .start(.checkUser), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func registerPhone(with body: RegsiterPhoneBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .registration(.registerPhone), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func changePhone(with body: ChangePhoneBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .setting(.changePhone), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func checkCode(with body: CheckSmsCodeBody, handler: RequestHandler<CheckUserOrSmsCodeResponse>) {
        let request = Request(page: .registration(.checkCode), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getModelsAndColors(with body: GetModelsAndColorsBody, handler: RequestHandler<ModelsAndColorsResponse>) {
        let request = Request(page: .registration(.getModelsAndColors), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func bookService(with body: BookServiceBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .services(.bookService), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getManagers(with body: GetManagersBody, handler: RequestHandler<ManagersResponse>) {
        let request = Request(page: .profile(.getManagers), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getCarsFTD(with body: GetCarsForTestDriveBody, handler: RequestHandler<CarsResponse>) {
        let request = Request(page: .services(.getTestDriveCars), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func getFreeTime(with body: GetFreeTimeBody, handler: RequestHandler<FreeTimeResponse>) {
        let request = Request(page: .services(.getFreeTime), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    func skipSetCar(with body: SkipSetCarBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .registration(.checkVin), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }

    @available(*, unavailable)
    func addShowroom(with body: AddShowroomBody, handler: RequestHandler<SimpleResponse>) {
        let request = Request(page: .profile(.addShowroom), body: body)
        NetworkService.makeRequest(request, handler: handler)
    }
}
