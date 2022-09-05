import UIKit

// MARK: - UITableView
extension UITableView {
    func setBackground(text: String?) {
        backgroundView = createBackground(labelText: text)
    }

    func registerCell(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    func dequeue<TCell: UITableViewCell>(for indexPath: IndexPath) -> TCell {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: TCell.self),
                                             for: indexPath) as? TCell else {
            assertionFailure("Can't dequeue cell.")
            return TCell()
        }

        return cell
    }
}

// MARK: - UITextField
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

    func setRightView(from view: UIView, width: Double = 30, height: Double) {
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

// MARK: - UICollectionViewCell
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

// MARK: - UIControl
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside,
                   _ closure: @escaping Closure) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}

// MARK: - UIRefreshControl
extension UIRefreshControl {
    func startRefreshing(title: String = .common(.loading)) {
        attributedTitle = NSAttributedString(string: title)
        beginRefreshing()
    }

    func stopRefreshing(title: String = .common(.pullToRefresh)) {
        endRefreshing()
        attributedTitle = NSAttributedString(string: title)
    }

    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            let y = scrollView.contentOffset.y - frame.height
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }

        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}

// MARK: - UIPickerView
extension UIPickerView {
    func configure(delegate: UIPickerViewDelegate & UIPickerViewDataSource,
                   with action: Selector,
                   for textField: UITextField) {
        self.dataSource = delegate
        self.delegate = delegate
        textField.inputAccessoryView = .buildToolbar(with: action, target: delegate)
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
        case dimmedSignatureRed = "DimmedSignatureRed"
    }

    static func appTint(_ tint: AppTints) -> UIColor {
        UIColor(named: tint.rawValue)!
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

// MARK: - UIButton
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
