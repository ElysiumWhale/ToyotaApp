import UIKit

final class TintedImageButton: CustomizableButton {

    var highlightedTintColor: UIColor = .clear

    var normalTintColor: UIColor = .clear {
        didSet {
            imageView?.tintColor = normalTintColor
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
