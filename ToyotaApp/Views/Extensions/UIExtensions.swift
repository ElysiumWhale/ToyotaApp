import UIKit
import DesignKit

extension UIView {
    static func titleViewFor(
        city: String? = nil,
        action: @escaping () -> Void
    ) -> UIView {
        let button = UIButton.titleButton(
            with: city ?? .common(.chooseCity),
            action: action
        )
        let rightButton = UIButton(frame: .init(
            x: 0, y: 0, width: 20, height: 20)
        )
        rightButton.setImage(UIImage(systemName: "chevron.right"),
                             for: .normal)
        rightButton.tintColor = .appTint(.secondarySignatureRed)
        rightButton.addAction(action)

        let container = UIView(frame: .init(
            x: 0, y: 0, width: 100, height: 30)
        )
        container.addSubviews(button, rightButton)

        button.edgesToSuperview(excluding: .trailing)
        rightButton.trailingToSuperview()
        button.trailingToLeading(of: rightButton)
        button.centerY(to: rightButton, offset: -3)

        return container
    }

    // MARK: - Toolbar for controls
    static func buildToolbar(
        with action: Selector,
        target: Any? = nil
    ) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: target,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: .common(.choose),
            style: .done,
            target: target,
            action: action
        )
        doneButton.tintColor = .appTint(.secondarySignatureRed)
        toolBar.setItems([flexible, doneButton], animated: true)
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
    static func titleButton(
        with text: String,
        action: @escaping () -> Void
    ) -> UIButton {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = .clear
        button.setTitleColor(.appTint(.signatureGray), for: .normal)
        button.setTitleColor(.appTint(.secondarySignatureRed), for: .highlighted)
        button.titleLabel?.font = .toyotaType(.regular, of: 17)
        button.setTitle(text, for: .normal)
        button.addAction(action)
        return button
    }

    static func imageButton(
        imageName: String = "chevron.down",
        action: (() -> Void)? = nil
    ) -> UIButton {
        let button = UIButton()
        let image = UIImage(systemName: imageName)
        button.setImage(image?.applyingSymbolConfiguration(.init(scale: .large)),
                        for: .normal)
        button.imageView?.tintColor = .appTint(.secondarySignatureRed)
        if let action = action {
            button.addAction(action)
        }

        return button
    }
}

// MARK: - City picking cell configuration
extension UIContentConfiguration where Self == UIListContentConfiguration {
    static func cellConfiguration(with text: String, isSelected: Bool) -> Self {
        var result = UIListContentConfiguration.cell()
        result.text = text
        result.textProperties.color = isSelected
            ? .white
            : .appTint(.signatureGray)

        return result
    }
}
