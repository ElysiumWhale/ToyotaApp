import UIKit

@IBDesignable
class TintedImageButton: CustomizableButton {

    @IBInspectable
    var highlightedTintColor: UIColor = .clear

    @IBInspectable
    var normalTintColor: UIColor = .clear {
        didSet {
            imageView?.tintColor = normalTintColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            imageView?.tintColor = isHighlighted
                ? highlightedTintColor
                : normalTintColor
        }
    }
}
