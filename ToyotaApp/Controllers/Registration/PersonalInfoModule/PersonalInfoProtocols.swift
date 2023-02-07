import Foundation

// MARK: - View
protocol PersonalInfoPresenterOutput: AnyObject {
    func handle(state: PersonalInfoModels.SetPersonViewModel)
}

// MARK: - Interactor
protocol PersonalInfoDataStore {
    var state: PersonalDataStoreState { get }
}

protocol PersonalInfoViewOutput: PersonalInfoDataStore {
    func setPerson(request: PersonalInfoModels.SetPersonRequest)
}
