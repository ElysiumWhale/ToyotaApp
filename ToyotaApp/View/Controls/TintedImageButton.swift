import UIKit

class TintedImageButton: UIButton {
    @IBInspectable
    var highlightedTintColor: UIColor = .clear

    @IBInspectable
    var normalTintColor: UIColor = .clear {
        didSet {
            tintColor = normalTintColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            tintColor = isHighlighted ? highlightedTintColor : normalTintColor
        }
    }

    override func prepareForInterfaceBuilder() {
        tintColor = normalTintColor
    }
}
