import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype TResponse: Codable
    var segueCode: String { get }
    func completionForSegue(for response: TResponse?)
    func nextButtonDidPressed(sender: Any?)
}

extension SegueWithRequestController {
    func completionForSegue(for response: TResponse?) { }
}

protocol WithUserInfo: AnyObject {
    func setUser(info: UserProxy)
    func subscribe(on proxy: UserProxy)
    func unsubscribe(from proxy: UserProxy)
    func userDidUpdate()
}

extension WithUserInfo {
    func subscribe(on proxy: UserProxy) { }
    func unsubscribe(from proxy: UserProxy) { }
    func userDidUpdate() { }
}

protocol DisplayError {
    func displayError(_ error: String?) -> Void
}

protocol ServicesMapped {
    func configure(with service: ServiceType, car: Car)
}
