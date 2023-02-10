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
    struct ServiceOrderPayload {
        let serviceType: ServiceType
        let controlType: ServiceViewType
        let user: UserProxy
    }

    static func serviceOrderModule(
        _ payload: ServiceOrderPayload
    ) -> any ServiceOrderModule {

        let controller: BaseServiceController
        let modules = makeModules(
            with: payload.serviceType,
            for: payload.controlType
        )

        switch payload.serviceType.id {
        case CustomServices.TestDrive:
            controller = TestDriveViewController(
                payload.serviceType,
                modules,
                payload.user
            )
        default:
            controller = BaseServiceController(
                payload.serviceType,
                modules,
                payload.user
            )
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

    private static func makeModules(
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

        return modules
    }
}

extension ServiceOrderModule {
    @MainActor
    func setupOutput(_ router: UINavigationController?) {
        withOutput { [weak router] output in
            switch output {
            case .internalError, .successOrder:
                router?.popViewController(animated: true)
            }
        }
    }
}
