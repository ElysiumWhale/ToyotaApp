import UIKit

open class CustomizableButton: UIButton, BottomKeyboardBinded {
    public var keyboardConstraint: NSLayoutConstraint? {
        didSet {
            constant = keyboardConstraint?.constant ?? .zero
        }
    }

    private(set) public var constant: CGFloat = .zero

    public var rounded: Bool = false

    public var highlightedColor: UIColor = .clear

    public var normalColor: UIColor = .clear {
        didSet {
            backgroundColor = normalColor
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : normalColor
        }
    }

    open override var backgroundColor: UIColor? {
        didSet {
            titleLabel?.backgroundColor = backgroundColor
        }
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        layer.cornerRadius = rounded ? frame.size.height / 2 : .zero
        if rounded {
            clipsToBounds = true
        }
    }
}
