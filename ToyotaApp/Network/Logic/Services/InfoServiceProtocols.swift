import Foundation

protocol AuthService {
    func registerPhone(
        with body: RegisterPhoneBody,
        _ handler: RequestHandler<SimpleResponse>
    )
    func checkCode(
        with body: CheckSmsCodeBody,
        _ handler: RequestHandler<CheckUserOrSmsCodeResponse>
    )
    func changePhone(
        with body: ChangePhoneBody,
        _ handler: RequestHandler<SimpleResponse>
    )
    func deleteTemporaryPhone(with body: DeletePhoneBody)
}

protocol ReconnectionService {
    func checkUser(
        with body: CheckUserBody,
        _ handler: RequestHandler<CheckUserOrSmsCodeResponse>
    )
}

protocol PersonalInfoService {
    func setProfile(
        with body: SetProfileBody,
        _ handler: RequestHandler<CitiesResponse>
    )
    func updateProfile(
        with body: EditProfileBody,
        _ handler: RequestHandler<SimpleResponse>
    )
}

protocol CarsService {
    func addCar(
        with body: SetCarBody,
        _ handler: RequestHandler<CarSetResponse>
    )
    func skipSetCar(
        with body: SkipSetCarBody,
        _ handler: RequestHandler<SimpleResponse>
    )
    func getModelsAndColors(
        with body: GetModelsAndColorsBody,
        _ handler: RequestHandler<ModelsAndColorsResponse>
    )
    func removeCar(
        with body: DeleteCarBody,
        _ handler: RequestHandler<SimpleResponse>
    )
}

protocol BookingsService {
    func getBookings(
        with body: GetBookingsBody,
        _ handler: RequestHandler<BookingsResponse>
    )
}

protocol ManagersService {
    func getManagers(
        with body: GetManagersBody,
        _ handler: RequestHandler<ManagersResponse>
    )
}

protocol ServicesService {
    func getShowrooms(
        with body: GetShowroomsBody,
        _ handler: RequestHandler<ShowroomsResponse>
    )
    func getServiceTypes(
        with body: GetServiceTypesBody,
        _ handler: RequestHandler<ServicesTypesResponse>
    )
}

protocol CitiesService {
    func getCities(
        with body: GetCitiesBody,
        _ handler: RequestHandler<CitiesResponse>
    )
}
