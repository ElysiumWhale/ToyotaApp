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
    private var secretKey: SecretKey
    private var person: Person
    private var showrooms: Showrooms
    private var cars: Cars
    
    private let notificator: Notificator
    
    fileprivate class func buildUser() -> Result<UserProxy, AppErrors> {
        let userId = DefaultsManager.getUserInfo(UserId.self)
        let secretKey = DefaultsManager.getUserInfo(SecretKey.self)
        let userPhone = DefaultsManager.getUserInfo(Phone.self)
        let personInfo = DefaultsManager.getUserInfo(Person.self)
        let showroomsInfo = DefaultsManager.getUserInfo(Showrooms.self)
        
        guard let id = userId, let key = secretKey, let phone = userPhone, let person = personInfo, let showrooms = showroomsInfo else {
            return Result.failure(.notFullProfile)
        }
        var res: UserInfo
        if let cars = DefaultsManager.getUserInfo(Cars.self) {
            res = UserInfo(id, key, phone, person, showrooms, cars)
        } else {
            res = UserInfo(id, key, phone, person, showrooms)
        }
        return Result.success(res)
    }
    
    //MARK: - Constructors
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone,
                 _ personInfo: Person, _ showroomsInfo: Showrooms, _ carsInfo: Cars) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = carsInfo
        notificator = NotificationCentre()
    }
    
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone,
                 _ personInfo: Person, _ showroomsInfo: Showrooms) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = Cars([Car]())
        notificator = NotificationCentre()
    }
}

//MARK: - UserProxy
extension UserInfo: UserProxy {
    var getNotificator: Notificator { notificator }
    
    var getId: String { id.id }
    
    var getPhone: String { phone.phone }
    
    var getPerson: Person { person }
    
    var getSelectedShowroom: Showroom? { showrooms.value.first(where: {$0.id == cars.chosenCar!.showroomId}) }
    
    var getShowrooms: Showrooms { showrooms }
    
    var getCars: Cars { cars }
    
    func update(_ personData: Person) {
        person = personData
        DefaultsManager.pushUserInfo(info: person)
        notificator.notificateObservers()
    }
    
    func update(_ add: Car, _ from: Showroom) {
        if showrooms.value.first(where: {$0.id == from.id}) == nil {
            showrooms.value.append(from)
            DefaultsManager.pushUserInfo(info: showrooms)
        }
        cars.array.append(add)
        DefaultsManager.pushUserInfo(info: cars)
        notificator.notificateObservers()
    }
    
    func update(_ selected: Car) {
        cars.chosenCar = selected
        DefaultsManager.pushUserInfo(info: cars)
        notificator.notificateObservers()
    }
}
