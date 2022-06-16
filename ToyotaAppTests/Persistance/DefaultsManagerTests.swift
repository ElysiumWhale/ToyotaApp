import XCTest
@testable import ToyotaApp

final class DefaultsManagerTests: XCTestCase {
    private let testCity = City(id: "1", name: "Samara")
    private let container = UserDefaults.defaultsManagerTestContainer

    override func setUpWithError() throws {
        DefaultsManager.removeData(for: .testSelectedCity, from: container)
    }

    override func tearDownWithError() throws {
        DefaultsManager.removeData(for: .testSelectedCity, from: container)
        UserDefaults.standard.removeSuite(named: "DefaultsManagerTest")
    }

    func testPushRetrieve() throws {
        var retrieved: City? = DefaultsManager.retrieve(for: .testSelectedCity,
                                                        from: container)
        XCTAssertNil(retrieved)

        retrieved = testCity
        DefaultsManager.push(info: retrieved,
                             for: .testSelectedCity,
                             to: container)
        retrieved = DefaultsManager.retrieve(for: .testSelectedCity,
                                             from: container)
        XCTAssertNotNil(retrieved)

        let car: Car? = DefaultsManager.retrieve(for: .testSelectedCity,
                                                 from: container)
        XCTAssertNil(car)

        try testDataSafety(for: retrieved!)
    }

    func testDataSafety(for retrieved: City) throws {
        XCTAssertEqual(retrieved.id, testCity.id)
        XCTAssertEqual(retrieved.name, testCity.name)
    }

    func testClearing() throws {
        try testPushRetrieve()

        DefaultsManager.removeData(for: .testSelectedCity, from: container)
        let retrieved: City? = DefaultsManager.retrieve(for: .testSelectedCity,
                                                        from: container)
        XCTAssertNil(retrieved)
    }
}

// MARK: - defaultsManagerTestContainer
private extension UserDefaults {
    static var defaultsManagerTestContainer: UserDefaults {
        let name = "DefaultsManagerTest"
        if let container = UserDefaults(suiteName: name) {
            return container
        }

        standard.addSuite(named: name)
        return UserDefaults(suiteName: name)!
    }
}
