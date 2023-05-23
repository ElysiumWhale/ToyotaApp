import XCTest
import ComposableArchitecture
@testable import ToyotaApp

@MainActor
final class CityPickerFeatureTests: XCTestCase {
    func testLoadingCitiesFailure() async {
        let store = testStore(getCities: { _ in .failure(.corruptedData) })
        await store.send(.loadCities) {
            $0.isLoading = true
        }

        await store.receive(.failureCitiesLoad(.corruptedData)) {
            $0.isLoading = false
            $0.cities = []
            $0.selectedCity = nil
            $0.selectedCityIndex = nil
            $0.popupMessage = NetworkErrors.corruptedData.message
        }

        await store.send(.popupDidShow) {
            $0.popupMessage = nil
        }
    }

    func testLoadingCitiesSuccessWithoutSelection() async {
        let expectedResponse = CitiesResponse.mock
        let store = testStore(getCities: { _ in .success(expectedResponse) })
        await store.send(.loadCities) {
            $0.isLoading = true
        }
        await store.receive(.successfulCitiesLoad(expectedResponse)) {
            $0.isLoading = false
            $0.cities = expectedResponse.cities
        }
    }

    func testLoadingCitiesSuccessWithSelection() async {
        let expectedResponse = CitiesResponse.mock
        let store = testStore(
            state: State(
                brandId: Brand.Toyota,
                cities: [.mock],
                selectedCity: .mock
            ),
            getCities: { _ in .success(expectedResponse) }
        )
        await store.send(.loadCities) {
            $0.isLoading = true
        }
        await store.receive(.successfulCitiesLoad(expectedResponse)) {
            $0.isLoading = false
            $0.cities = expectedResponse.cities
            $0.selectedCity = .mock
            $0.selectedCityIndex = 0
        }
    }

    func testLoadingCitiesSuccessWithNotMatchingSelection() async {
        let expectedResponse = CitiesResponse.mock
        let store = testStore(
            state: State(
                brandId: Brand.Toyota,
                cities: [.mock2],
                selectedCity: .mock2
            ),
            getCities: { _ in .success(expectedResponse) }
        )
        await store.send(.loadCities) {
            $0.isLoading = true
        }
        await store.receive(.successfulCitiesLoad(expectedResponse)) {
            $0.isLoading = false
            $0.cities = expectedResponse.cities
            $0.selectedCity = nil
            $0.selectedCityIndex = nil
        }
    }

    func testSelectCityFailure() async {
        await testStore().send(.cityDidSelect(index: 0))
    }

    func testSelectCitySuccess() async {
        let selectedIndex = 0
        let city = City.mock
        let store = testStore(state: State(brandId: Brand.Toyota, cities: [city]))

        await store.send(.cityDidSelect(index: selectedIndex)) {
            $0.selectedCity = city
            $0.selectedCityIndex = selectedIndex
        }
    }

    func testChooseButtonTapFailure() async {
        let store = testStore(
            storeInDefaults: { _ in XCTFail("No need to store in defaults") },
            outputStore: OutputStore().withOutput { _ in
                XCTFail("No need to send output")
            }
        )

        await store.send(.chooseButtonDidPress) {
            $0.popupMessage = AppErrors.checkInput.rawValue
        }

        await store.send(.popupDidShow) {
            $0.popupMessage = nil
        }
    }

    func testChooseButtonTapSuccess() async {
        var cityDidSave = false
        var outputDidSend = false

        let selectedCity = City.mock
        let store = testStore(
            state: State(
                brandId: Brand.Toyota,
                cities: [selectedCity],
                selectedCity: selectedCity
            ),
            storeInDefaults: { cityDidSave = $0 == selectedCity },
            outputStore: OutputStore().withOutput { _ in
                outputDidSend = true
            }
        )

        await store.send(.chooseButtonDidPress)
        await store.receive(.saveCity(selectedCity))
        await store.receive(.output(.cityDidSelect(selectedCity)))

        XCTAssertTrue(cityDidSave)
        XCTAssertTrue(outputDidSend)
    }
}

private extension CityPickerFeatureTests {
    typealias State = CityPickerFeature.State
    typealias Action = CityPickerFeature.Action
    typealias Output = CityPickerFeature.Output
    typealias GetCities = (_ brandId: String) async -> NewResponse<CitiesResponse>

    func testStore(
        state: State = State(brandId: Brand.Toyota, cities: []),
        storeInDefaults: @escaping (City) -> Void = { _ in },
        outputStore: OutputStore<CityPickerFeature.Output> = OutputStore(),
        getCities: @escaping GetCities = { _ in return .failure(.corruptedData) }
    ) -> TestStore<State, Action, State, Action, Void> {
        TestStore(
            initialState: state,
            reducer: CityPickerFeature(
                storeInDefaults: storeInDefaults,
                getCities: getCities,
                outputStore: outputStore
            )
        )
    }
}

private extension City {
    static let mock = City(id: "1", name: "mock")
    static let mock2 = City(id: "2", name: "mock")
}

private extension CitiesResponse {
    static let mock = CitiesResponse(
        result: "ok",
        cities: [.mock],
        models: nil,
        colors: nil
    )
}
