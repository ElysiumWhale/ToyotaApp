import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype Response: Codable
    var completionForSegue: (Response?) -> Void  { get }
    var segueCode: String { get }
    func nextButtonDidPressed(sender: Any?)
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
