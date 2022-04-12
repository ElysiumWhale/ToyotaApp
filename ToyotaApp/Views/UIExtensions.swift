import UIKit

// MARK: - UICollectionView set background text
extension UICollectionView {
    func setBackground(text: String?) {
        backgroundView = createBackground(labelText: text)
    }
}

// MARK: - UITableView set background text
extension UITableView {
    func setBackground(text: String?) {
        backgroundView = createBackground(labelText: text)
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
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0,
                                                       options: [.curveEaseOut], animations: {
            self.layer.borderColor = hasError ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
            self.layer.borderWidth = hasError ? 1 : 0
        })
    }

    func setRightView(from view: UIView, width: Double, height: Double) {
        NSLayoutConstraint.deactivate(rightView?.constraints ?? [])
        rightView = nil
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        view.frame = rect
        let resultView = UIView(frame: rect)
        resultView.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: resultView.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -10)
        ])
        rightView = resultView
    }
}

// MARK: - Configuring shadow for cell
extension UICollectionViewCell {
    func configureShadow(with cornerRadius: CGFloat, shadowRadius: CGFloat = 3) {
        layer.shadowColor = UIColor.black.cgColor.copy(alpha: 0.5)
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

// MARK: - Normal action adding to button
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping Closure) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}

// MARK: - Start and stop refreshing
extension UIRefreshControl {
    func startRefreshing(title: String = .common(.loading)) {
        attributedTitle = NSAttributedString(string: title)
        beginRefreshing()
    }

    func stopRefreshing(title: String = .common(.pullToRefresh)) {
        endRefreshing()
        attributedTitle = NSAttributedString(string: title)
    }
}

// MARK: - UIPicker
extension UIPickerView {
    func configure(delegate: UIPickerViewDelegate & UIPickerViewDataSource,
                   with action: Selector,
                   for textField: UITextField) {
        self.dataSource = delegate
        self.delegate = delegate
        textField.inputAccessoryView = .buildToolbar(with: action)
        textField.inputView = self
    }

    var selectedRow: Int {
        selectedRow(inComponent: 0)
    }
}

// MARK: - UIDatePicker
extension UIDatePicker {
    func configure(with action: Selector,
                   for textField: UITextField) {
        preferredDatePickerStyle = .wheels
        locale = Locale(identifier: "ru")
        datePickerMode = .date
        maximumDate = Date()
        textField.inputAccessoryView = .buildToolbar(with: action)
        textField.inputView = self
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
        case dimmedSignatureRed = "DimmedSignatureRed"
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
        let controller = instantiateViewController(withIdentifier: viewController.rawValue) as? ViewController
        if let result = controller {
            return result
        }

        assertionFailure("Identifier \(viewController) is not mapped to type \(ViewController.Type.self)")
        return ViewController()
    }
}

// MARK: - Dequeue helpers
extension UITableView {
    enum TableCells: String {
        /// BookingCell
        case bookingCell = "BookingCell"
        /// CityCell
        case cityCell = "CityCell"
        /// NewsCell
        case newsCell = "NewsCell"
    }

    func dequeue<TCell: IdentifiableTableCell>(for indexPath: IndexPath) -> TCell {
        let cell = dequeueReusableCell(withIdentifier: TCell.identifier.rawValue, for: indexPath) as? TCell
        if let result = cell {
            return result
        }

        assertionFailure("Can't dequeue cell.")
        return TCell()
    }
}

extension UICollectionView {
    enum CollectionCells: String {
        /// CarCell
        case car = "CarCell"
        /// ManagerCell
        case manager = "ManagerCell"
    }

    func dequeue<TCell: IdentifiableCollectionCell>(for indexPath: IndexPath) -> TCell {
        let cell = dequeueReusableCell(withReuseIdentifier: TCell.identifier.rawValue, for: indexPath) as? TCell
        if let result = cell {
            return result
        }

        assertionFailure("Can't dequeue cell.")
        return TCell()
    }
}

// MARK: - Changing cell with animation
extension UICollectionView {
    func change<TCell: UICollectionViewCell>(_ cellType: TCell.Type,
                                             at indexPath: IndexPath,
                                             _ changeAction: @escaping ParameterClosure<TCell>) {
        guard let cell = cellForItem(at: indexPath) as? TCell else {
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                       delay: 0,
                                                       options: [.curveEaseOut]) {
            changeAction(cell)
        }
    }
}

// MARK: - SegueCode enum property
extension UIStoryboardSegue {
    var code: SegueIdentifiers? {
        guard let id = identifier else {
            assertionFailure("\nWarning: Segue code is empty\n")
            return nil
        }

        guard let result = SegueIdentifiers(rawValue: id) else {
            assertionFailure("Identifier \(id) is not mapped to storyboard segue!")
            return nil
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

// MARK: - TitleButton
extension UIButton {
    static func titleButton(with text: String, action: @escaping Closure) -> UIButton {
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

    static func imageButton(imageName: String = "chevron.down",
                            action: @escaping Closure) -> UIButton {
        let button = UIButton()
        let image = UIImage(systemName: imageName)
        button.setImage(image?.applyingSymbolConfiguration(.init(scale: .large)),
                        for: .normal)
        button.imageView?.tintColor = .appTint(.secondarySignatureRed)
        button.addAction(action)
        return button
    }
}

// MARK: - UIStackView
extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            addArrangedSubview(view)
        }
    }

    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}
