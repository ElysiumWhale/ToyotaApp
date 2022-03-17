import UIKit

typealias ToCityModel = (cities: [City], models: [Model], colors: [Color])

class PersonalInfoRouter {
    private(set) weak var controller: PersonalInfoViewController?

    private var toCityModel: ToCityModel = ([], [], [])

    init(controller: PersonalInfoViewController) {
        self.controller = controller
    }

    func goToScene(segue: SegueIdentifiers, with model: ToCityModel) {
        toCityModel = model
        controller?.perform(segue: segue)
    }

    func prepare(for segue: UIStoryboardSegue) {
        switch segue.code {
            case .personInfoToCity:
                let controller = segue.destination as? CityPickerViewController
                controller?.configure(with: toCityModel.cities,
                                      models: toCityModel.models,
                                      colors: toCityModel.colors)
            default:
                return
        }
    }
}
