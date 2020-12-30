import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype Response:Codable
    var completionForSegue: (Response?) -> Void  { get }
    var segueCode: String { get }
    func nextButtonDidPressed(sender: Any?)
}

protocol WithUserInfo {
    func setUser(info: UserInfo)
}
