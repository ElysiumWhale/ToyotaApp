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
    private let defaults: any KeyedCodableStorage<DefaultKeys>
    private let keychain: any ModelKeyedCodableStorage<KeychainKeys>

    let notificator: EventNotificator
    let id: String

    private(set) var person: Person
    private(set) var cars: Cars

    var phone: String {
        let phone: Phone? = KeychainService.shared.get()
        return phone?.value ?? .empty
    }

    fileprivate init(
        _ userId: UserId,
        _ userPhone: Phone,
        _ person: Person,
        _ cars: Cars,
        notificator: EventNotificator = .shared,
        defaults: any KeyedCodableStorage<DefaultKeys> = DefaultsService.shared,
        keychain: any ModelKeyedCodableStorage<KeychainKeys> = KeychainService.shared
    ) {
        self.id = userId.value
        self.person = person
        self.cars = cars
        self.notificator = notificator
        self.defaults = defaults
        self.keychain = keychain
    }

    static func build() -> Result<UserProxy, AppErrors> {
        guard let userId: UserId = KeychainService.shared.get(),
              let phone: Phone = KeychainService.shared.get(),
              let person: Person = KeychainService.shared.get() else {
            return Result.failure(.notFullProfile)
        }

        let cars: Cars = KeychainService.shared.get() ?? Cars([])

        return Result.success(UserInfo(userId, phone, person, cars))
    }
}

// MARK: - UserProxy
extension UserInfo: UserProxy {
    var selectedShowroom: Showroom? {
        defaults.get(key: .selectedShowroom)
    }

    var selectedCity: City? {
        defaults.get(key: .selectedCity)
    }

    func updatePerson(from person: Person) {
        self.person = person
        keychain.set(person)
        notificator.notify(with: .userUpdate)
    }

    func addNew(car: Car) {
        cars.value.append(car)
        if cars.defaultCar == nil {
            cars.defaultCar = car
        }
        keychain.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func updateSelected(car: Car) {
        cars.defaultCar = car
        keychain.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func removeCar(with id: String) {
        let updatedCars = cars
        updatedCars.value.removeAll(where: { $0.id == id })
        if cars.defaultCar?.id == id {
            updatedCars.defaultCar = updatedCars.value.first
        }
        keychain.set(updatedCars)
        notificator.notify(with: .userUpdate)
    }
}

extension UserProxy where Self == UserInfo {
    static var mock: UserInfo {
        UserInfo(
            .init(.empty),
            .init(.empty),
            .init(
                firstName: .empty,
                lastName: .empty,
                secondName: .empty,
                email: .empty,
                birthday: .empty
            ),
            .init([])
        )
    }
}
