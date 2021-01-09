import Foundation

struct UserInfo: Codable {
    let id: String
    var phone: Phone?
    var secretKey = ""
    var isAuthorized: Bool = false
    var isFullAccess: Bool = false
    
    typealias Phone = String
    
    private(set) var person: PersonInfo = PersonInfo()
    private(set) var showrooms: Showrooms = Showrooms()
    private(set) var cars: Cars = Cars()
    
    //MARK: - Inner Structs
    struct PersonInfo: WithDefaultsKey {
        var key: String = DefaultsKeys.person
        
        var firstName: String?
        var lastName: String?
        var secondName: String?
        var email: String?
        var birthday: String?
        
        static func toDomain(profile: Profile) -> PersonInfo {
            return PersonInfo(firstName: profile.firstName, lastName: profile.lastName, secondName: profile.secondName, email: profile.email, birthday: profile.birthday)
        }
    }
    
    struct Cars: WithDefaultsKey {
        var key: String { DefaultsKeys.cars }
        var chosenCar: Car?
        var array: [Car] = [Car]()
    }
    
    struct Showrooms: WithDefaultsKey {
        var key: String { DefaultsKeys.showrooms }
        var array: [Showroom] = [Showroom]()
        
        init(_ showrooms: [Showroom]) {
            array = showrooms
        }
        
        init() { }
    }
    
    //MARK: - Constructors
    init(userId: String) {
        id = userId
        isAuthorized = true
    }
    
    init(userId: String, personInfo: PersonInfo) {
        id = userId
        isAuthorized = true
        person = personInfo
    }
    
    init(userId: String, personInfo: PersonInfo, showroomsList: Showrooms) {
        id = userId
        isAuthorized = true
        person = personInfo
        showrooms = showroomsList
    }
    
    init(userId: String, personInfo: PersonInfo, showroomsList: Showrooms, carsList: Cars) {
        id = userId
        isAuthorized = true
        person = personInfo
        showrooms = showroomsList
        cars = carsList
        isFullAccess = true
    }
}

struct Showroom: Codable {
    let id: String
    let showroomName: String
    let cityName: String
    
    init(_ sId: String, _ name: String, _ city: String) {
        id = sId
        showroomName = name
        cityName = city
    }
}

struct Car: Codable {
    let id: String
    let showroomId: String
    let brand: String
    let model: String
    let color: String
    let colorSwatch: String
    let colorDescription: String
    let isMetallic: String
    let plate: String
    let vin: String
}

extension UserInfo.Phone: WithDefaultsKey {
    var key: String { DefaultsKeys.phone }
}
