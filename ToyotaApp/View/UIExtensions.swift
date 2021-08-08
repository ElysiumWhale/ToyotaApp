import Foundation
import UIKit

// MARK: - FadeIn/Out UIView Animation
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.5) {
        if alpha == 0 {
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in self?.alpha = 1 })
        }
    }

    func fadeOut(_ duration: TimeInterval = 0.5, completion: @escaping () -> Void = { }) {
        if alpha == 1 {
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in self?.alpha = 0 },
                           completion: { _ in completion() }
            )
        }
    }
}

// MARK: - UITextField error border
extension UITextField {
    func toggleErrorState(hasError: Bool) {
        layer.borderColor = hasError ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
        layer.borderWidth = hasError ? 1 : 0
    }
}

// MARK: - Configuring shadow for cell
extension UICollectionViewCell {
    func configureShadow(with cornerRadius: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 3.5
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

// MARK: - IBInspectable Corners radius for button
extension UIButton {
    @IBInspectable var rounded: Bool {
        get {
            layer.cornerRadius == 0 ? true : false
        }
        set {
            updateCornerRadius(isRounded: newValue)
        }
    }

    func updateCornerRadius(isRounded: Bool) {
        layer.cornerRadius = isRounded ? frame.size.height / 2 : 0
    }
}

// MARK: - Normal action adding to button
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping() -> Void) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}

// MARK: - UIPicker
extension UIPickerView {
    func configurePicker<T>(with action: Selector, for textField: UITextField, delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
        self.dataSource = delegate
        self.delegate = delegate
        textField.inputAccessoryView = UIToolbar.buildToolBar(for: delegate, with: action)
        textField.inputView = self
    }
}

// MARK: - UIToolBar
extension UIToolbar {
    static func buildToolBar<T>(for delegate: T, with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: delegate, action: nil)
        let doneButton = UIBarButtonItem(title: CommonText.choose, style: .done, target: delegate, action: action)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

// MARK: - Fonts
extension UIFont {
    enum ToyotaFonts: String {
        case semibold = "Semibold"
        case light = "Light"
        case regular = "Regular"
        case book = "Book"
        case bold = "Bold"
        case black = "Black"
        
        case lightItalic = "LightIt"
        case bookItalic = "BookIt"
        case regularItalic = "RegularIt"
        case semiboldItalic = "SemiboldIt"
        case boldItalic = "BoldIt"
        case blackItalic = "BlackIt"

        func getName() -> String {
            return "ToyotaType-\(self.rawValue)"
        }
    }

    static func toyotaType(_ type: ToyotaFonts, of size: CGFloat) -> UIFont {
        UIFont(name: type.getName(), size: size)!
    }
}

// MARK: - Main app tint
extension UIColor {
    static var mainAppTint: UIColor { UIColor(red: 0.63, green: 0.394, blue: 0.396, alpha: 1) }
    static var loadingTint: UIColor { UIColor(white: 0.3, alpha: 0.5) }
}
