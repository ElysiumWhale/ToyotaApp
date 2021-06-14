import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype TResponse: Codable
    var segueCode: String { get }
    func completionForSegue(for response: Result<TResponse, ErrorResponse>)
    func nextButtonDidPressed(sender: Any?)
}

extension SegueWithRequestController {
    func completionForSegue(for response: TResponse?) { }
}

///Protocol for controllers which work with `UserProxy`
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
