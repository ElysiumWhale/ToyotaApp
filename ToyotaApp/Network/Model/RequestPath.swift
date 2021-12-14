import Foundation

enum RequestPath {
    case start(_ page: Start)
    case registration(_ page: Registration)
    case services(_ page: Services)
    case profile(_ page: Profile)
    case setting(_ page: Settings)

    var rawValue: String {
        switch self {
            case .start(let page): return page.rawValue
            case .registration(let page): return page.rawValue
            case .services(let page): return page.rawValue
            case .profile(let page): return page.rawValue
            case .setting(let page): return page.rawValue
        }
    }

    enum Start: String {
        case checkUser = "check_user.php"
    }

    enum Registration: String {
        case registerPhone = "register_phone.php"
        case checkCode = "check_code.php"
        case setProfile = "set_profile.php"
        case setCar = "set_car.php"
        case getShowrooms = "get_showrooms.php"
        case setShowroom = "set_showroom.php"
        case checkCar = "check_car.php"
        case checkVin = "check_vin_code.php"
        case deleteTemp = "delete_tmp_record.php"
        case getModelsAndColors = "get_models_and_colors.php"
    }

    enum Services: String {
        case getServicesTypes = "get_service_type.php"
        case getServices = "get_services.php"
        case getFreeTime = "get_free_time.php"
        case bookService = "book_service.php"
        case getTestDriveCars = "get_cars_ftd.php"
        case getTestDriveShowrooms = "get_showrooms_list_ftd.php"
        case getTestDriveServiceId = "get_service_id.php"
    }

    enum Profile: String {
        case getCities = "get_cities.php"
        case addShowroom = "add_showroom.php"
        case editProfile = "edit_profile.php"
        case getManagers = "get_managers.php"
        case getBookings = "get_users_booking.php"
        case removeCar = "delete_user_car.php"
    }

    enum Settings: String {
        case changePhone = "change_phone_number.php"
    }
}
