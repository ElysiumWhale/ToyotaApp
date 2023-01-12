import UIKit

public extension CustomizableButton {
    struct Configuration {
        let font: UIFont
        let titleColor: UIColor
        let normalColor: UIColor
        let highlightedColor: UIColor
        let tintColor: UIColor
        let rounded: Bool

        public init(
            font: UIFont,
            titleColor: UIColor,
            normalColor: UIColor,
            highlightedColor: UIColor,
            tintColor: UIColor,
            rounded: Bool
        ) {
            self.font = font
            self.titleColor = titleColor
            self.normalColor = normalColor
            self.highlightedColor = highlightedColor
            self.tintColor = tintColor
            self.rounded = rounded
        }
    }

    func apply(configuration: Configuration) {
        titleLabel?.font = configuration.font
        setTitleColor(configuration.titleColor, for: .normal)
        normalColor = configuration.normalColor
        highlightedColor = configuration.highlightedColor
        tintColor = configuration.tintColor
        rounded = configuration.rounded
    }

    convenience init(frame: CGRect = .zero, _ configuration: Configuration) {
        self.init(frame: frame)

        apply(configuration: configuration)
    }
}
