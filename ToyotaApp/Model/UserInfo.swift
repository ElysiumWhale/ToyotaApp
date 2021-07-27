import Foundation

protocol UserProxy {
    static func build() -> Result<UserProxy, AppErrors>
    func update(_ personData: Person)
    func update(_ add: Car, _ from: Showroom)
    func update(_ selected: Car)
    var getId: String { get }
    var getPhone: String { get }
    var getPerson: Person { get }
    var getShowrooms: Showrooms { get }
    var getSelectedShowroom: Showroom? { get }
    var getCars: Cars { get }
    var getNotificator: Notificator { get }
}

extension UserProxy {
    static func build() -> Result<UserProxy, AppErrors> { UserInfo.buildUser() }
}

class UserInfo {
    let id: UserId
    private var phone: Phone
    private var person: Person
    private var showrooms: Showrooms
    private var cars: Cars
    
    private let notificator: Notificator
    
    fileprivate class func buildUser() -> Result<UserProxy, AppErrors> {
        let userId = KeychainManager.get(UserId.self)
        let userPhone = KeychainManager.get(Phone.self)
        let personInfo = KeychainManager.get(Person.self)
        let showroomsInfo = KeychainManager.get(Showrooms.self)
        
        guard let id = userId, let phone = userPhone, let person = personInfo, let showrooms = showroomsInfo else {
            return Result.failure(.notFullProfile)
        }
        let cars = KeychainManager.get(Cars.self) ?? Cars([])
        
        return Result.success(UserInfo(id, phone, person, showrooms, cars))
    }
    
    private init(_ userId: UserId, _ userPhone: Phone, _ personInfo: Person,
                 _ showroomsInfo: Showrooms, _ carsInfo: Cars) {
        id = userId
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = carsInfo
        notificator = NotificationCentre()
    }
}

//MARK: - UserProxy
extension UserInfo: UserProxy {
    var getNotificator: Notificator { notificator }
    
    var getId: String { id.id }
    
    var getPhone: String { phone.phone }
    
    var getPerson: Person { person }
    
    var getSelectedShowroom: Showroom? { showrooms.value.first(where: {$0.id == cars.chosenCar?.showroomId}) }
    
    var getShowrooms: Showrooms { showrooms }
    
    var getCars: Cars { cars }
    
    func update(_ personData: Person) {
        person = personData
        KeychainManager.set(person)
        notificator.notificateObservers()
    }
    
    func update(_ add: Car, _ from: Showroom) {
        if showrooms.value.first(where: {$0.id == from.id}) == nil {
            showrooms.value.append(from)
            KeychainManager.set(showrooms)
        }
        cars.array.append(add)
        if cars.chosenCar == nil {
            cars.chosenCar = add
        }
        KeychainManager.set(cars)
        notificator.notificateObservers()
    }
    
    func update(_ selected: Car) {
        cars.chosenCar = selected
        KeychainManager.set(cars)
        notificator.notificateObservers()
    }
}
