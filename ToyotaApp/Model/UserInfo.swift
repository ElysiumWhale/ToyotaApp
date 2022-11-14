import Foundation

protocol UserProxy: UserStorage {
    func updatePerson(from person: Person)
    func updateSelected(car: Car)
    func addNew(car: Car)
    func removeCar(with id: String)
}

protocol UserStorage {
    var id: String { get }
    var phone: String { get }
    var person: Person { get }
    var cars: Cars { get }

    var selectedShowroom: Showroom? { get }
    var selectedCity: City? { get }
}

final class UserInfo {
    let notificator: EventNotificator
    let id: String

    private(set) var person: Person
    private(set) var cars: Cars

    var phone: String {
        KeychainManager<Phone>.get()?.value ?? .empty
    }

    fileprivate init(
        _ userId: UserId,
        _ userPhone: Phone,
        _ personInfo: Person,
        _ carsInfo: Cars,
        notificator: EventNotificator = .shared
    ) {
        id = userId.value
        person = personInfo
        cars = carsInfo
        self.notificator = notificator
    }

    static func build() -> Result<UserProxy, AppErrors> {
        guard let userId = KeychainManager<UserId>.get(),
              let phone = KeychainManager<Phone>.get(),
              let person = KeychainManager<Person>.get() else {
            return Result.failure(.notFullProfile)
        }

        let cars = KeychainManager<Cars>.get() ?? Cars([])

        return Result.success(UserInfo(userId, phone, person, cars))
    }
}

// MARK: - UserProxy
extension UserInfo: UserProxy {
    var selectedShowroom: Showroom? {
        DefaultsManager.retrieve(for: .selectedShowroom)
    }

    var selectedCity: City? {
        DefaultsManager.retrieve(for: .selectedCity)
    }

    func updatePerson(from person: Person) {
        self.person = person
        KeychainManager.set(person)
        notificator.notify(with: .userUpdate)
    }

    func addNew(car: Car) {
        cars.value.append(car)
        if cars.defaultCar == nil {
            cars.defaultCar = car
        }
        KeychainManager.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func updateSelected(car: Car) {
        cars.defaultCar = car
        KeychainManager.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func removeCar(with id: String) {
        let updatedCars = cars
        updatedCars.value.removeAll(where: { $0.id == id })
        if cars.defaultCar?.id == id {
            updatedCars.defaultCar = updatedCars.value.first
        }
        KeychainManager.set(updatedCars)
        notificator.notify(with: .userUpdate)
    }
}

extension UserProxy where Self == UserInfo {
    static var mock: UserInfo {
        UserInfo(.init(.empty),
                 .init(.empty),
                 .init(firstName: .empty,
                       lastName: .empty,
                       secondName: .empty,
                       email: .empty,
                       birthday: .empty),
                 .init([]))
    }
}
