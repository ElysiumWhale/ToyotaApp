import UIKit

extension InputTextField {
    struct Configuration {
        let backgroundColor: UIColor
        let textColor: UIColor
        let tintColor: UIColor
        let font: UIFont
        let textAlignment: NSTextAlignment
        let cornerRadius: CGFloat
    }

    func apply(_ configuration: Configuration) {
        backgroundColor = configuration.backgroundColor
        font = configuration.font
        textAlignment = configuration.textAlignment
        textColor = configuration.textColor
        tintColor = configuration.tintColor
        cornerRadius = configuration.cornerRadius
    }

    convenience init(frame: CGRect = .zero, _ configuration: Configuration) {
        self.init(frame: frame)

        apply(configuration)
    }
}

extension InputTextField.Configuration {
    static let toyotaLeft = toyota(alignment: .left)
    static let toyota = toyota()

    static func toyota(
        backgroundColor: UIColor = .appTint(.background),
        textColor: UIColor = .appTint(.signatureGray),
        tintColor: UIColor = .appTint(.secondarySignatureRed),
        font: UIFont = .toyotaType(.light, of: 20),
        alignment: NSTextAlignment = .center,
        radius: CGFloat = 10
    ) -> InputTextField.Configuration {
        .init(
            backgroundColor: backgroundColor,
            textColor: textColor,
            tintColor: tintColor,
            font: font,
            textAlignment: alignment,
            cornerRadius: radius
        )
    }
}
