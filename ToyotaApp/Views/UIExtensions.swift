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

// MARK: - Dismiss keyboard on swipe down
extension UIView {
    func hideKeyboardWhenSwipedDown() {
        let swipe = UISwipeGestureRecognizer(target: self,
                                             action: #selector(UIViewController.dismissKeyboard))
        swipe.cancelsTouchesInView = false
        swipe.direction = [.down]
        self.addGestureRecognizer(swipe)
    }

    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}

// MARK: - UITextField error border
extension UITextField {
    enum FieldState {
        case error
        case normal
    }

    func toggle(state: FieldState) {
        let hasError = state == .error
        layer.borderColor = hasError ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
        layer.borderWidth = hasError ? 1 : 0
    }
}

// MARK: - Configuring shadow for cell
extension UICollectionViewCell {
    func configureShadow(with cornerRadius: CGFloat, shadowRadius: CGFloat = 3) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

// MARK: - Normal action adding to button
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}

// MARK: - UIPicker
extension UIPickerView {
    func configurePicker<T>(with action: Selector,
                            for textField: UITextField,
                            delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
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
        let doneButton = UIBarButtonItem(title: .common(.choose), style: .done, target: delegate, action: action)
        doneButton.tintColor = .appTint(.secondarySignatureRed)
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

        func getName() -> String { "ToyotaType-\(self.rawValue)" }
    }

    static func toyotaType(_ type: ToyotaFonts, of size: CGFloat) -> UIFont {
        UIFont(name: type.getName(), size: size)!
    }
}

// MARK: - Main app tint
extension UIColor {
    enum AppTints: String {
        case mainRed = "MainTint"
        case loading = "Loading"
        case signatureRed = "SignatureRed"
        case secondarySignatureRed = "SecondarySignatureRed"
        case signatureGray = "SignatureGray"
        case secondaryGray = "SecondaryGray"
        case background = "Background"
        case cell = "Cell"
    }

    static func appTint(_ tint: AppTints) -> UIColor { UIColor(named: tint.rawValue)! }
}

// MARK: - Sugar init and instatiate
extension UIStoryboard {
    convenience init(_ identifier: AppStoryboards, bundle: Bundle = .main) {
        self.init(name: identifier.rawValue, bundle: .main)
    }

    /// Causes **fatalError()** when `ViewController` is not mapped to identifier
    func instantiate<ViewController: UIViewController>(_ viewController: ViewControllers) -> ViewController {
        guard let result = instantiateViewController(withIdentifier: viewController.rawValue) as? ViewController else {
            fatalError("Identifier \(viewController) is not mapped to type \(ViewController.Type.self)")
        }
        return result
    }
}

// MARK: - Dequeue helpers
extension UITableView {
    enum TableCells: String {
        /// BookingCell
        case bookingCell = "BookingCell"
        /// CityCell
        case cityCell = "CityCell"
    }

    func dequeue<TCell: IdentifiableTableCell>(for indexPath: IndexPath) -> TCell {
        let cell = dequeueReusableCell(withIdentifier: TCell.identifier.rawValue, for: indexPath) as? TCell
        if let result = cell {
            return result
        } else {
            fatalError("Can't dequeue cell.")
        }
    }
}

extension UICollectionView {
    enum CollectionCells: String {
        /// CarCell
        case car = "CarCell"
        /// NewsCell
        case news = "NewsCell"
        /// ServiceCell
        case service = "ServiceCell"
        /// ManagerCell
        case manager = "ManagerCell"
    }

    func dequeue<TCell: IdentifiableCollectionCell>(for indexPath: IndexPath) -> TCell {
        let cell = dequeueReusableCell(withReuseIdentifier: TCell.identifier.rawValue, for: indexPath) as? TCell
        if let result = cell {
            return result
        } else {
            fatalError("Can't dequeue cell.")
        }
    }
}

// MARK: - SegueCode enum property
extension UIStoryboardSegue {
    var code: SegueIdentifiers? {
        guard let id = identifier else {
            print("\nWarning: Segue code is empty\n")
            return nil
        }

        guard let result = SegueIdentifiers(rawValue: id) else {
            fatalError("Identifier \(id) is not mapped to storyboard segue!")
        }

        return result
    }
}

// MARK: - City picking cell coniguration
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
