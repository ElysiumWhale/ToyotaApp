import Foundation

private struct CustomServices {
    static let TestDrive = "3"
}

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
        var controller: IServiceController!
        switch serviceType.id {
            case CustomServices.TestDrive: controller = TestDriveViewController()
            default: controller = BaseServiceController()
        }
        let modules = buildModules(with: serviceType, for: controlType, controller: controller)
        controller.configure(with: serviceType, modules: modules, user: user)
        return controller
    }
    
    class func buildModules(with serviceType: ServiceType, for controlType: ControllerServiceType, controller: IServiceController) -> [IServiceModule] {
        var modules: [IServiceModule] = []
        switch controlType {
            case .notDefined: break
            case .timepick:
                modules.append(TimePickerModule(with: serviceType, for: controller))
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
            case .threePicksTime:
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(PickerModule(with: serviceType, for: controller))
                modules.append(TimePickerModule(with: serviceType, for: controller))
            default: break
        }
        return modules
    }
}
