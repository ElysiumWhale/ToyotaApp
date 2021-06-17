import Foundation

enum ControllerServiceType: String {
    case notDefined = "0"
    case timepick = "1"
    case map = "2"
    case onePick = "3"
    case twoPicks = "4"
    case threePicks = "5"
    case onePickTime = "6"
    case twoPicksTime = "7"
    case threePicksTime = "8"
    case onePickMap = "9"
    case twoPicksMap = "10"
    case threePicksMap = "11"
    case onePickTimeMap = "12"
    case twoPicksTimeMap = "13"
    case threePicksTimeMap = "14"
}

class ServiceModuleBuilder {
    class func buildController(serviceType: ServiceType, for controlType: ControllerServiceType, user: UserProxy) -> IServiceController {
        let controller: IServiceController = BaseServiceController()
        var modules: [IServiceModule] = []
        switch controlType {
            case .notDefined: break
            case .map:
                modules.append(MapModule(with: serviceType, for: controller))
            case .onePick:
                modules.append(PickerModule(with: serviceType, for: controller))
            case .onePickMap:
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(MapModule(with: serviceType, for: controller))
            case .onePickTime:
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(TimePickerModule(with: serviceType, for: controller))
            case .onePickTimeMap:
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(TimePickerModule(with: serviceType, for: controller))
                modules.append(MapModule(with: serviceType, for: controller))
            default: break
        }
        controller.configure(with: serviceType, modules: modules, user: user)
        return controller
    }
}
