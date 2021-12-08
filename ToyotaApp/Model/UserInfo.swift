import Foundation

protocol UserProxy {
    func update(_ add: Car, _ from: Showroom)
    func update(_ selected: Car)
    var getId: String { get }
    var getPhone: String { get }
    var getPerson: Person { get }
    var getShowrooms: Showrooms { get }
    var getSelectedShowroom: Showroom? { get }
    var selectedCity: City? { get }
    var getCars: Cars { get }
    var getNotificator: Notificator { get }

    func updatePerson(from person: Person)
    func updateSelected(city: City)
    func removeCar(with id: String)

    static func build() -> Result<UserProxy, AppErrors>
}

class UserInfo {
    let id: UserId
    private var phone: Phone
    private var person: Person
    private var showrooms: Showrooms
    private var cars: Cars

    private let notificator: Notificator

    fileprivate class func buildUser() -> Result<UserProxy, AppErrors> {
        guard let userId = KeychainManager<UserId>.get(),
              let phone = KeychainManager<Phone>.get(),
              let person = KeychainManager<Person>.get(),
              let showrooms = KeychainManager<Showrooms>.get() else {
            return Result.failure(.notFullProfile)
        }
        let cars = KeychainManager<Cars>.get() ?? Cars([])
        
        return Result.success(UserInfo(userId, phone, person, showrooms, cars))
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

// MARK: - UserProxy
extension UserInfo: UserProxy {
    static func build() -> Result<UserProxy, AppErrors> {
        buildUser()
    }

    var getNotificator: Notificator { notificator }

    var getId: String { id.id }

    var getPhone: String { phone.phone }

    var getPerson: Person { person }

    var getSelectedShowroom: Showroom? { showrooms.value.first(where: {$0.id == cars.chosenCar?.showroomId}) }

    var getShowrooms: Showrooms { showrooms }

    var getCars: Cars { cars }
    var selectedCity: City? {
        DefaultsManager.getUserInfo(City.self)
    }

    func updatePerson(from person: Person) {
        self.person = person
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

    func updateSelected(city: City) {
        DefaultsManager.pushUserInfo(info: city)
    }

    func removeCar(with id: String) {
        let updatedCars = cars
        updatedCars.array.removeAll(where: { $0.id == id })
        if cars.chosenCar?.id == id {
            updatedCars.chosenCar = updatedCars.array.first
        }
        KeychainManager.set(updatedCars)
        notificator.notificateObservers()
    }
}
