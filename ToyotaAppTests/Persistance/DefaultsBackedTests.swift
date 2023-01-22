import XCTest
@testable import ToyotaApp

final class DefaultsBackedTest: XCTestCase {
    private let defaults = DefaultsService(container: .testContainer)

    @DefaultsBacked<City>(
        key: .testSelectedCity,
        container: .testContainer
    )
    var city

    let comparingCity = City(id: "1", name: "Самара")

    override func setUpWithError() throws {
        city = nil
        defaults.set(value: city, key: .testSelectedCity)
    }

    override func tearDownWithError() throws {
        city = nil
        UserDefaults.standard.removeSuite(named: "DefaultsBackedTest")
    }

    func testWrapperGetSet() throws {
        XCTAssertNil(city)
        city = comparingCity
        XCTAssertNotNil(city)
        city = nil
        XCTAssertNil(city)
    }

    func testDataSafety() throws {
        try testWrapperGetSet()

        city = comparingCity
        XCTAssertEqual(city?.id, comparingCity.id)
        XCTAssertEqual(city?.name, comparingCity.name)
    }

    func testAnotherContainer() throws {
        try testDataSafety()

        let anotherContainerCity: City? = DefaultsService.shared.get(key: .testSelectedCity)
        XCTAssertNil(anotherContainerCity)
    }
}

private extension DefaultsContainer {
    static var testContainer: Self {
        DefaultsContainer(name: "DefaultsBackedTest")
    }
}
