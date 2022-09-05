import UIKit

class CustomizableButton: UIButton, BottomKeyboardBinded {
    var keyboardConstraint: NSLayoutConstraint? {
        didSet {
            constant = keyboardConstraint?.constant ?? .zero
        }
    }

    private(set) var constant: CGFloat = .zero

    var rounded: Bool = false {
        didSet {
            layer.cornerRadius = rounded ? frame.size.height / 2 : .zero
        }
    }

    var highlightedColor: UIColor = .clear

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
