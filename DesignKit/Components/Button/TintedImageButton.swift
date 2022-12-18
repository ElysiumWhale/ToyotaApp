import UIKit

final public class TintedImageButton: CustomizableButton {

    public var highlightedTintColor: UIColor = .clear

    public var normalTintColor: UIColor = .clear {
        didSet {
            imageView?.tintColor = normalTintColor
        }
    }

    public override var isHighlighted: Bool {
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
