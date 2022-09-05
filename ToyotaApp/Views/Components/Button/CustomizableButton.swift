import UIKit

@IBDesignable
class CustomizableButton: UIButton, BottomKeyboardBinded {
    @IBOutlet
    var keyboardConstraint: NSLayoutConstraint? {
        didSet {
            constant = keyboardConstraint?.constant ?? .zero
        }
    }

    private(set) var constant: CGFloat = .zero

    @IBInspectable
    var rounded: Bool = false {
        didSet {
            layer.cornerRadius = rounded ? frame.size.height / 2 : .zero
        }
    }

    var highlightedColor: UIColor = .clear

    @IBInspectable
    var normalColor: UIColor = .clear {
        didSet {
            backgroundColor = normalColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : normalColor
        }
    }

    override func prepareForInterfaceBuilder() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : .zero
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        if rounded {
            clipsToBounds = true
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        setTitleColor(.white, for: .highlighted)
        layer.cornerRadius = rounded ? frame.size.height / 2 : .zero
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        if rounded {
            clipsToBounds = true
        }
    }
}
