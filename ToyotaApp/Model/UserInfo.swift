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
        let phone: Phone? = KeychainService.shared.get()
        return phone?.value ?? .empty
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
        DefaultsService.shared.get(key: .selectedShowroom)
    }

    var selectedCity: City? {
        DefaultsService.shared.get(key: .selectedCity)
    }

    func updatePerson(from person: Person) {
        self.person = person
        KeychainService.shared.set(person)
        notificator.notify(with: .userUpdate)
    }

    func addNew(car: Car) {
        cars.value.append(car)
        if cars.defaultCar == nil {
            cars.defaultCar = car
        }
        KeychainService.shared.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func updateSelected(car: Car) {
        cars.defaultCar = car
        KeychainService.shared.set(cars)
        notificator.notify(with: .userUpdate)
    }

    func removeCar(with id: String) {
        let updatedCars = cars
        updatedCars.value.removeAll(where: { $0.id == id })
        if cars.defaultCar?.id == id {
            updatedCars.defaultCar = updatedCars.value.first
        }
        KeychainService.shared.set(updatedCars)
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
