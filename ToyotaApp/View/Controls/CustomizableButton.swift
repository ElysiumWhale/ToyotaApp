import UIKit

@IBDesignable
class CustomizableButton: UIButton {
    @IBInspectable
    var rounded: Bool = false {
        didSet {
            layer.cornerRadius = rounded ? frame.size.height / 2 : 0
        }
    }

    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable
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
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        if rounded {
            clipsToBounds = true
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setTitleColor(.white, for: .highlighted)
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        if rounded {
            clipsToBounds = true
        }
    }
}
