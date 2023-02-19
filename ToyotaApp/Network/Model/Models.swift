import Foundation

// MARK: - RegisteredUser
struct RegisteredUser: Codable, Hashable {
    let profile: Profile
    let cars: [Car]?
}

// MARK: - Profile
struct Profile: Codable, Hashable {
    let phone: String?
    let firstName: String?
    let lastName: String?
    let secondName: String?
    let email: String?
    let birthday: String?

    private enum CodingKeys: String, CodingKey {
        case phone, email, birthday
        case firstName = "first_name"
        case lastName = "last_name"
        case secondName = "second_name"
    }

    var birthdayDate: Date? {
        birthday?.asDate(with: .server)
    }

    func toDomain() -> Person {
        Person(firstName: firstName,
               lastName: lastName,
               secondName: secondName,
               email: email,
               birthday: birthday)
    }
}

// MARK: - Car
struct Car: IService, Hashable {
    let id: String
    let brand: String
    let model: Model
    let color: Color
    let year: String
    let plate: String
    let vin: String
    let isChecked: Bool?

    var name: String {
        "\(brand) \(model.name)"
    }

    private enum CodingKeys: String, CodingKey {
        case model, color
        case id = "car_id"
        case brand = "car_brand_name"
        case year = "car_year"
        case plate = "license_plate"
        case vin = "vin_code"
        case isChecked
    }
}

// MARK: - City
struct City: IService, Hashable {
    let id: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "city_name"
    }
}

// MARK: - Showroom
struct Showroom: IService {
    var name: String { showroomName }

    let id: String
    let showroomName: String
    let cityName: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case showroomName = "showroom_name"
        case cityName = "city_name"
    }
}

// MARK: - Model
struct Model: IService, Hashable {
    let id: String
    let name: String
    let brandId: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "car_model_name"
        case brandId = "car_brand_id"
    }
}

// MARK: - Color
struct Color: IService, Hashable {
    let id: String
    let name: String
    let code: String
    let colorDescription: String
    let isMetallic: String
    let hex: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "car_color_name"
        case code = "color_code"
        case colorDescription = "color_description"
        case isMetallic = "color_metallic"
        case hex = "color_swatch"
    }
}

// MARK: - ServiceType
struct ServiceType: IService, Identifiable, Hashable {
    let id: String
    let serviceTypeName: String
    let controlTypeId: String
    let controlTypeDesc: String

    var name: String {
        serviceTypeName
    }

    var serviceViewType: ServiceViewType? {
        .init(rawValue: controlTypeId)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case serviceTypeName = "service_type_name"
        case controlTypeId = "control_type_id"
        case controlTypeDesc = "control_type_desc"
    }
}

// MARK: - Service
struct Service: IService, Hashable {
    let id: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "service_name"
    }
}

extension IService where Self == Service {
    static var empty: Self {
        Service(id: "-1", name: "Нет доступных сервисов")
    }
}

// MARK: - Manager
struct Manager: Codable {
    let id: String
    let userId: String
    let firstName: String
    let secondName: String
    let lastName: String
    let phone: String
    let email: String
    let imageUrl: String
    let showroomName: String

    private enum CodingKeys: String, CodingKey {
        case id, phone, email
        case userId = "user_id"
        case firstName = "first_name"
        case secondName = "second_name"
        case lastName = "last_name"
        case imageUrl = "avatar"
        case showroomName = "showroom_name"
    }
}

// MARK: - Booking
struct Booking: Codable {
    enum BookingStatus: String, Codable {
        case future = "0"
        case cancelled = "1"
        case done = "2"
    }

    let bDate: String
    let cDate: String
    let startTime: String
    let latitude: String
    let longitude: String
    let status: BookingStatus
    let carName: String
    let licensePlate: String
    let showroomName: String
    let serviceName: String
    let postName: String

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, status
        case bDate = "date_booking"
        case cDate = "create_date"
        case startTime = "booking_start_time"
        case carName = "car_model_name"
        case licensePlate = "license_plate"
        case showroomName = "showroom_name"
        case serviceName = "service_name"
        case postName = "post_name"
    }
}

extension Booking {
    var bookingDate: Date? {
        bDate.asDate(with: .server)
    }

    var creationDate: Date? {
        cDate.asDate(with: .serverWithTime)
    }

    var date: Date {
        bookingDate ?? creationDate ?? Date()
    }

    var bookingTime: DateComponents? {
        guard let key = Int(startTime) else {
            return nil
        }

        return TimeMap.clientMap[key]
    }
}

// MARK: - News (Temporary)
/// Temporary struct
struct News {
    let title: String
    let imgUrl: URL?
    let url: URL?
}
