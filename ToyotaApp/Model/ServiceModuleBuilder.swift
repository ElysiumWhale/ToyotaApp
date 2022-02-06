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
    class func buildModule(serviceType: ServiceType,
                           for controlType: ControllerServiceType,
                           user: UserProxy) -> IServiceController {
        var controller: IServiceController!
        let modules = buildModules(with: serviceType, for: controlType)
        switch serviceType.id {
            case CustomServices.TestDrive: controller = TestDriveViewController(serviceType, modules, user)
            default: controller = BaseServiceController(serviceType, modules, user)
        }
        modules.forEach { $0.delegate = controller }
        return controller
    }

    class func buildModules(with serviceType: ServiceType,
                            for controlType: ControllerServiceType) -> [IServiceModule] {
        var modules: [IServiceModule] = []
        switch controlType {
            case .notDefined: break
            case .timepick:
                modules.append(TimePickerModule(with: serviceType))
            case .map:
                modules.append(MapModule(with: serviceType))
            case .onePick:
                modules.append(PickerModule(with: serviceType))
            case .onePickMap:
                modules.append(PickerModule(with: serviceType))
                modules.append(MapModule(with: serviceType))
            case .onePickTime:
                modules.append(PickerModule(with: serviceType))
                modules.append(TimePickerModule(with: serviceType))
            case .onePickTimeMap:
                modules.append(PickerModule(with: serviceType))
                modules.append(TimePickerModule(with: serviceType))
                modules.append(MapModule(with: serviceType))
            case .threePicksTime:
                modules.append(PickerModule(with: serviceType))
                modules.append(PickerModule(with: serviceType))
                modules.append(PickerModule(with: serviceType))
                modules.append(TimePickerModule(with: serviceType))
            default: break
        }

        return modules.chained()
    }
}

private extension Array where Element == IServiceModule {
    func chained() -> Self {
        guard isNotEmpty else {
            return self
        }

        for i in 0...count - 1 {
            self[i].nextModule = i + 1 <= count - 1 ? self[i + 1] : nil
        }

        return self
    }
}
