import UIKit

class BookButton: UIButton {
    override open var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor.appTint(.mainRed) : UIColor.appTint(.loading)
        }
    }
}
