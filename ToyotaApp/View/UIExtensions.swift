import Foundation
import UIKit

// MARK: - FadeIn/Out UIView Animation
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.05, onCompletion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let view = self, !view.isHidden { return }
            self?.alpha = 0
            self?.isHidden = false
            UIView.animate(withDuration: duration,
                           animations: { self?.alpha = 1 },
                           completion: { (value: Bool) in
                              if let complete = onCompletion { complete() }
                           }
            )
        }
    }

    func fadeOut(_ duration: TimeInterval = 0.05, onCompletion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            if let view = self, view.isHidden { return }
            UIView.animate(withDuration: duration,
                           animations: { self?.alpha = 0 },
                           completion: { (value: Bool) in
                            self?.isHidden = true
                            if let complete = onCompletion { complete() }
                           }
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
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
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
}
