import XCTest
@testable import ToyotaApp

final class DefaultsManagerTests: XCTestCase {
    private let testCity = City(id: "1", name: "Samara")
    private let defaultsService = DefaultsService(container: .init(
        name: "DefaultsManagerTest"
    ))

    override func setUpWithError() throws {
        defaultsService.removeAll()
    }

    override func tearDownWithError() throws {
        defaultsService.removeAll()
    }

    func testGetSet() {
        var retrieved: City? = defaultsService.get(key: .testSelectedCity)
        XCTAssertNil(retrieved)

        retrieved = testCity
        defaultsService.set(value: retrieved, key: .testSelectedCity)
        retrieved = defaultsService.get(key: .testSelectedCity)
        XCTAssertNotNil(retrieved)

        let car: Car? = defaultsService.get(key: .testSelectedCity)
        XCTAssertNil(car)

        XCTAssertEqual(retrieved?.id, testCity.id)
        XCTAssertEqual(retrieved?.name, testCity.name)
    }

    func testRemove() {
        testGetSet()

        defaultsService.set(value: testCity, key: .testSelectedCity)
        defaultsService.remove(key: .testSelectedCity)
        var retrieved: City? = defaultsService.get(key: .testSelectedCity)
        XCTAssertNil(retrieved)

        defaultsService.set(value: testCity, key: .testSelectedCity)
        defaultsService.removeAll()
        retrieved = defaultsService.get(key: .testSelectedCity)
        XCTAssertNil(retrieved)
    }
}
