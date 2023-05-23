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
    private let notificator: EventNotificator

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

    static func make(
        _ keychain: any ModelKeyedCodableStorage<KeychainKeys>
    ) -> Result<UserProxy, AppErrors> {
        guard
            let userId: UserId = keychain.get(),
            let phone: Phone = keychain.get()
        else  {
            return Result.failure(.noUserIdAndPhone)
        }

        guard
            let person: Person = keychain.get()
        else {
            return Result.failure(.notFullProfile)
        }

        let cars: Cars = keychain.get() ?? Cars([])

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
        cars.cars.append(car)
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
        cars.cars.removeAll(where: { $0.id == id })
        if cars.defaultCar?.id == id {
            cars.defaultCar = cars.cars.first
        }
        keychain.set(cars)
        notificator.notify(with: .userUpdate)
    }
}

#if DEBUG
extension UserProxy where Self == UserInfo {
    static var mock: UserInfo {
        UserInfo(
            .init(value: .empty),
            .init(value: .empty),
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
#endif
