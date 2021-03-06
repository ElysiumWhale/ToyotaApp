import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype TResponse: Codable
    var completionForSegue: (TResponse?) -> Void { get }
    var segueCode: String { get }
    func nextButtonDidPressed(sender: Any?)
}

extension SegueWithRequestController {
    var completionForSegue: (TResponse?) -> Void { { _ in  } }
}

protocol WithUserInfo {
    func setUser(info: UserProxy)
}

protocol DisplayError {
    func displayError(_ error: String?) -> Void
}

protocol ServicesMapped {
    func configure(with service: ServiceType, car: Car)
}
