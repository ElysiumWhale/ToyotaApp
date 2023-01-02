import Foundation
import UIKit

struct CustomServices {
    static let TestDrive = "3"
}

enum ServiceViewType: String {
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

enum ServicesFlow {
    static func buildModule(
        serviceType: ServiceType,
        for controlType: ServiceViewType,
        user: UserProxy
    ) -> UIViewController {

        let controller: BaseServiceController
        let modules = makeChainedModules(with: serviceType, for: controlType)

        switch serviceType.id {
        case CustomServices.TestDrive:
            controller = TestDriveViewController(serviceType, modules, user)
        default:
            controller = BaseServiceController(serviceType, modules, user)
        }

        modules.forEach {
            $0.onUpdate = { [weak controller] module in
                DispatchQueue.main.async {
                    controller?.moduleDidUpdate(module)
                }
            }
        }

        return controller
    }

    private static func makeChainedModules(
        with serviceType: ServiceType,
        for controlType: ServiceViewType
    ) -> [IServiceModule] {

        var modules: [IServiceModule] = []
        switch controlType {
        case .notDefined:
            break
        case .timepick:
            modules.append(TimePickerModule(serviceType))
        case .map:
            modules.append(MapModule())
        case .onePick:
            modules.append(PickerModule(serviceType))
        case .onePickMap:
            modules.append(PickerModule(serviceType))
            modules.append(MapModule())
        case .onePickTime:
            modules.append(PickerModule(serviceType))
            modules.append(TimePickerModule(serviceType))
        case .onePickTimeMap:
            modules.append(PickerModule(serviceType))
            modules.append(TimePickerModule(serviceType))
            modules.append(MapModule())
        case .threePicksTime:
            modules.append(PickerModule(serviceType))
            modules.append(PickerModule(serviceType))
            modules.append(PickerModule(serviceType))
            modules.append(TimePickerModule(serviceType))
        default:
            break
        }

        return modules.chained()
    }
}

private extension Array where Element == IServiceModule {
    func chained() -> Self {
        guard !isEmpty else {
            return self
        }

        for i in 0..<count {
            self[i].nextModule = self[safe: i + 1]
        }

        return self
    }
}
