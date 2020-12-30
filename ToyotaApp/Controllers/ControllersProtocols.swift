import Foundation
import UIKit

protocol SegueWithRequestController {
    var segueCode: String { get }
    var completionForSegue: (Data?) -> Void { get }
    func nextButtonDidPressed(sender: Any?)
}

protocol WithUserInfo {
    func setUser(info: UserInfo)
}
