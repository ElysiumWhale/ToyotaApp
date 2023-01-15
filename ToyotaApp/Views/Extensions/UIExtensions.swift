import UIKit
import DesignKit

// MARK: - Toolbar for controls
extension UIView {
    static func makeToolbar(
        _ action: Selector,
        target: Any? = nil,
        title: String = .common(.choose),
        tintColor: UIColor = .appTint(.secondarySignatureRed)
    ) -> UIToolbar {
        let toolBar = UIToolbar()
        let flexible = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: title,
            style: .done,
            target: target,
            action: action
        )
        doneButton.tintColor = tintColor
        toolBar.setItems([flexible, doneButton], animated: false)
        toolBar.sizeToFit()

        return toolBar
    }
}

// MARK: - UIFont
extension UIFont {
    enum ToyotaFonts: String, CaseIterable {
        case semibold = "Semibold"
        case light = "Light"
        case regular = "Regular"
        case book = "Book"
        case bold = "Bold"
        case black = "Black"

        case lightItalic = "LightIt"
        case bookItalic = "BookIt"
        case regularItalic = "Italic" // something wrong with this type
        case semiboldItalic = "SemiboldIt"
        case boldItalic = "BoldIt"
        case blackItalic = "BlackIt"

        var name: String {
            "ToyotaType-\(rawValue)"
        }
    }

    static func toyotaType(_ type: ToyotaFonts, of size: CGFloat) -> UIFont {
        UIFont(name: type.name, size: size)!
    }
}

// MARK: - UIColor
extension UIColor {
    enum AppTints: String, CaseIterable {
        case loading = "Loading"
        case signatureRed = "SignatureRed"
        case secondarySignatureRed = "SecondarySignatureRed"
        case signatureGray = "SignatureGray"
        case secondaryGray = "SecondaryGray"
        case background = "Background"
        case blackBackground = "BackgroundBlack"
        case cell = "Cell"
        case darkCell = "DarkCell"
        case dimmedSignatureRed = "DimmedSignatureRed"
    }

    static func appTint(_ tint: AppTints) -> UIColor {
        UIColor(named: tint.rawValue)!
    }
}

// MARK: - UIButton
extension UIButton {
    static func imageButton(
        image: UIImage = .chevronDown,
        action: @escaping () -> Void = { }
    ) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .appTint(.secondarySignatureRed)
        button.addAction(action)
        return button
    }
}

// MARK: - Size presets
extension CGSize {
    static let toyotaActionL = CGSize(width: 244, height: 44)
    static let toyotaActionS = CGSize(width: 160, height: 44)
}

// MARK: - City picking cell configuration
extension UIContentConfiguration where Self == UIListContentConfiguration {
    static func cellConfiguration(with text: String?, isSelected: Bool) -> Self {
        var result = UIListContentConfiguration.cell()
        result.text = text
        result.textProperties.color = isSelected
            ? .white
            : .appTint(.signatureGray)

        return result
    }
}

// MARK: - CustomizableButton.Configuration presets
extension CustomizableButton.Configuration {
    static func toyotaAction(
        _ fontSize: CGFloat = 22
    ) -> CustomizableButton.Configuration {
        .init(
            font: .toyotaType(.regular, of: fontSize),
            titleColor: .white,
            normalColor: .appTint(.secondarySignatureRed),
            highlightedColor: .appTint(.dimmedSignatureRed),
            tintColor: .white,
            rounded: true
        )
    }

    static var toyotaSecondary: CustomizableButton.Configuration {
        .init(
            font: .toyotaType(.semibold, of: 18),
            titleColor: .appTint(.signatureGray),
            normalColor: .appTint(.background),
            highlightedColor: .appTint(.secondarySignatureRed),
            tintColor: .appTint(.signatureGray),
            rounded: false
        )
    }
}
