import UIKit

@IBDesignable
class TintedImageButton: CustomizableButton {

    @IBInspectable
    var highlightedTintColor: UIColor = .clear {
        didSet {
            setTitleColor(highlightedTintColor, for: .highlighted)
        }
    }

    @IBInspectable
    var normalTintColor: UIColor = .clear {
        didSet {
            imageView?.tintColor = normalTintColor
            setTitleColor(normalTintColor, for: .normal)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? highlightedColor
                : normalColor
            imageView?.tintColor = isHighlighted
                ? highlightedTintColor
                : normalTintColor
        }
    }
}
