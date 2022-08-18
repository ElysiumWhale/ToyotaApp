import Foundation

enum RequestPath {
    case start(_ page: Start)
    case registration(_ page: Registration)
    case services(_ page: Services)
    case profile(_ page: Profile)
    case setting(_ page: Settings)

    var rawValue: String {
        switch self {
        case .start(let page):
            return page.rawValue
        case .registration(let page):
            return page.rawValue
        case .services(let page):
            return page.rawValue
        case .profile(let page):
            return page.rawValue
        case .setting(let page):
            return page.rawValue
        }
    }

    enum Start: String {
        /// check_user.php
        case checkUser = "check_user.php"
    }

    enum Registration: String {
        /// register_phone.php
        case registerPhone = "register_phone.php"
        /// check_code.php
        case checkCode = "check_code.php"
        /// set_profile.php
        case setProfile = "set_profile.php"
        /// set_car.php
        case setCar = "set_car.php"
        /// get_showrooms.php
        case getShowrooms = "get_showrooms.php"
        /// set_showroom.php
        case setShowroom = "set_showroom.php"
        /// check_car.php
        case checkCar = "check_car.php"
        /// check_vin_code.php
        case checkVin = "check_vin_code.php"
        /// delete_tmp_record.php
        case deleteTemp = "delete_tmp_record.php"
        /// get_models_and_colors.php
        case getModelsAndColors = "get_models_and_colors.php"
    }

    enum Services: String {
        /// get_service_type.php
        case getServicesTypes = "get_service_type.php"
        /// get_services.ph
        case getServices = "get_services.php"
        /// get_free_time.php
        case getFreeTime = "get_free_time.php"
        /// book_service.php
        case bookService = "book_service.php"
        /// get_cars_ftd.php
        case getTestDriveCars = "get_cars_ftd.php"
        /// get_showrooms_list_ftd.php
        case getTestDriveShowrooms = "get_showrooms_list_ftd.php"
        /// get_service_id.php
        case getTestDriveServiceId = "get_service_id.php"
    }

    enum Profile: String {
        /// get_cities.php
        case getCities = "get_cities.php"
        /// add_showroom.php
        case addShowroom = "add_showroom.php"
        /// edit_profile.php
        case editProfile = "edit_profile.php"
        /// get_managers.php
        case getManagers = "get_managers.php"
        /// get_users_booking.php
        case getBookings = "get_users_booking.php"
        /// delete_user_car.php
        case removeCar = "delete_user_car.php"
    }

    enum Settings: String {
        /// change_phone_number.php
        case changePhone = "change_phone_number.php"
    }
}
