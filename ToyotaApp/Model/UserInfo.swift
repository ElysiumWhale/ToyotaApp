import Foundation

protocol UserProxy {
    var getId: String { get }
    var getPhone: String { get }
    var getPerson: Person { get }
    var selectedShowroom: Showroom? { get }
    var selectedCity: City? { get }
    var getCars: Cars { get }
    var getNotificator: Notificator { get }

    func updatePerson(from person: Person)
    func updateSelected(car: Car)
    func addNew(car: Car)
    func removeCar(with id: String)

    static func build() -> Result<UserProxy, AppErrors>
}

class UserInfo {
    let id: UserId
    private var phone: Phone
    private var person: Person
    private var cars: Cars

    private let notificator: Notificator

    fileprivate class func buildUser() -> Result<UserProxy, AppErrors> {
        guard let userId = KeychainManager<UserId>.get(),
              let phone = KeychainManager<Phone>.get(),
              let person = KeychainManager<Person>.get() else {
            return Result.failure(.notFullProfile)
        }

        let cars = KeychainManager<Cars>.get() ?? Cars([])

        return Result.success(UserInfo(userId, phone, person, cars))
    }

    private init(_ userId: UserId, _ userPhone: Phone,
                 _ personInfo: Person, _ carsInfo: Cars) {
        id = userId
        phone = userPhone
        person = personInfo
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

    var getCars: Cars { cars }

    var selectedShowroom: Showroom? {
        DefaultsManager.getUserInfo(for: .selectedShowroom)
    }

    var selectedCity: City? {
        DefaultsManager.getUserInfo(for: .selectedCity)
    }

    func updatePerson(from person: Person) {
        self.person = person
        KeychainManager.set(person)
        notificator.notificateObservers()
    }

    func addNew(car: Car) {
        cars.array.append(car)
        if cars.defaultCar == nil {
            cars.defaultCar = car
        }
        KeychainManager.set(cars)
        notificator.notificateObservers()
    }

    func updateSelected(car: Car) {
        cars.defaultCar = car
        KeychainManager.set(cars)
        notificator.notificateObservers()
    }

    func removeCar(with id: String) {
        let updatedCars = cars
        updatedCars.array.removeAll(where: { $0.id == id })
        if cars.defaultCar?.id == id {
            updatedCars.defaultCar = updatedCars.array.first
        }
        KeychainManager.set(updatedCars)
        notificator.notificateObservers()
    }
}
