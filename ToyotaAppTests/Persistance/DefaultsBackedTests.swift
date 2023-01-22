import XCTest
@testable import ToyotaApp

final class DefaultsBackedTest: XCTestCase {
    @DefaultsBacked<City>(
        key: .testSelectedCity,
        container: .init(name: "DefaultsBackedTest")
    )
    var city

    let comparingCity = City(id: "1", name: "Самара")

    override func setUpWithError() throws {
        city = nil
        let testCity: City? = nil
        DefaultsManager.push(info: testCity, for: .testSelectedCity)
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

        let anotherContainerCity: City? = DefaultsManager.retrieve(for: .testSelectedCity)
        XCTAssertNil(anotherContainerCity)
    }
}
