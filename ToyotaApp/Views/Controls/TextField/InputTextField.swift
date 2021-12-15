import UIKit

@IBDesignable
class InputTextField: UITextField {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var leftPadding: CGFloat = 5 {
        didSet {
            // todo
        }
    }

    override func prepareForInterfaceBuilder() {
        customizeView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }

    func customizeView() {
        layer.cornerRadius = cornerRadius
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0))
    }
}
