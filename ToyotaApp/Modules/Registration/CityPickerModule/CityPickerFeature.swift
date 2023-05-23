import Foundation
import ComposableArchitecture

struct CityPickerFeature: ReducerProtocol {
    struct State: Equatable {
        let brandId: String

        var cities: [City]
        var selectedCity: City?
        var selectedCityIndex: Int?

        var isLoading: Bool = false
        var popupMessage: String?
    }

    enum Action: Equatable {
        case loadCities
        case cityDidSelect(index: Int)
        case successfulCitiesLoad(CitiesResponse)
        case failureCitiesLoad(ErrorResponse)
        case chooseButtonDidPress
        case saveCity(City)
        case popupDidShow
        case output(Output)
        case cancelTasks
    }

    enum Output: Equatable {
        case cityDidSelect(City)
    }

    enum TaskId { }

    let storeInDefaults: (City) -> Void
    let getCities: (_ brandId: String) async -> NewResponse<CitiesResponse>
    let outputStore: OutputStore<Output>

    // MARK: - Reduce
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .popupDidShow:
            state.popupMessage = nil
            return .none
        case .cancelTasks:
            return .cancel(id: TaskId.self)
        case let .saveCity(city):
            storeInDefaults(city)
            return .none
        case let .output(output):
            outputStore.output?(output)
            return .none
        case .loadCities:
            state.isLoading = true
            return .task { [brandId = state.brandId] in
                switch await getCities(brandId) {
                case let .success(response):
                    return .successfulCitiesLoad(response)
                case let .failure(error):
                    return .failureCitiesLoad(error)
                }
            }.cancellable(id: TaskId.self)
        case let .cityDidSelect(index):
            guard let selectedCity = state.cities[safe: index] else {
                return .none
            }

            state.selectedCity = selectedCity
            state.selectedCityIndex = index
            return .none
        case let .successfulCitiesLoad(response):
            state.isLoading = false
            state.cities = response.cities

            guard let selectedCity = state.selectedCity else {
                return .none
            }

            if let index = state.cities.firstIndex(of: selectedCity) {
                state.selectedCity = state.cities[index]
                state.selectedCityIndex = index
            } else {
                state.selectedCity = nil
                state.selectedCityIndex = nil
            }
            return .none
        case let .failureCitiesLoad(error):
            state.isLoading = false
            state.cities = []
            state.selectedCity = nil
            state.selectedCityIndex = nil
            state.popupMessage = error.message ?? .error(.requestError)
            return .none
        case .chooseButtonDidPress:
            guard let selectedCity = state.selectedCity else {
                state.popupMessage = .error(.checkInput)
                return .none
            }

            return .concatenate(
                .send(.saveCity(selectedCity)),
                .send(.output(.cityDidSelect(selectedCity)))
            )
        }
    }
}
