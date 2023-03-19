@testable import ToyotaApp

#if DEBUG
extension ProfileOutput: CaseIterable {
    public static var allCases: [ProfileOutput] {
        [.logout, .showBookings, .showCars, .showManagers, .showSettings]
    }
}

extension SettingsOutput: CaseIterable {
    public static var allCases: [SettingsOutput] {
        [.showAgreement, .changePhone(.empty)]
    }
}

extension CityPickerOutput: CaseIterable {
    public static var allCases: [CityPickerOutput] {
        [.cityDidPick(.init(id: .empty, name: .empty))]
    }
}

extension AddCarOutput: CaseIterable {
    public static var allCases: [AddCarOutput] {
        [.carDidAdd(.register), .carDidAdd(.update(with: .mock))]
    }
}

extension ServicesOutput: CaseIterable {
    public static var allCases: [ServicesOutput] {
        [.showChat, .showCityPick, .showServiceOrder(.mock)]
    }
}

extension CarsOutput: CaseIterable {
    public static var allCases: [CarsOutput] {
        [.addCar(models: [], colors: [])]
    }
}
#endif
