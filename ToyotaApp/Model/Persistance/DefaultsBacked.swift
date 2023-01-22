import Foundation

@propertyWrapper
struct DefaultsBacked<T: Codable> {
    let key: DefaultKeys
    let defaultsService: DefaultsService

    var wrappedValue: T? {
        get {
            defaultsService.get(key: key)
        }
        set {
            defaultsService.set(value: newValue, key: key)
        }
    }

    init(key: DefaultKeys, container: DefaultsContainer = .standard) {
        self.key = key
        self.defaultsService = .init(container: container)
    }
}
