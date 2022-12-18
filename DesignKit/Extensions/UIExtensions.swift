import UIKit

// MARK: - UITextField
public extension UITextField {
    enum FieldState {
        case error
        case normal
    }

    func toggle(state: FieldState) {
        let hasError = state == .error
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.layer.borderColor = hasError
                ? UIColor.systemRed.cgColor
                : UIColor.clear.cgColor
                self.layer.borderWidth = hasError ? 1 : 0
            }
        )
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
public extension UICollectionViewCell {
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
public extension UIControl {
    func addAction(
        for controlEvents: UIControl.Event = .touchUpInside,
        _ closure: @escaping () -> Void
    ) {
        addAction(UIAction { _ in closure() }, for: controlEvents)
    }
}

// MARK: - UIRefreshControl
public extension UIRefreshControl {
    func startRefreshing(title: String = "Загрузка") {
        attributedTitle = NSAttributedString(string: title)
        beginRefreshing()
    }

    func stopRefreshing(title: String = "Потяните для обновления") {
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
public extension UIPickerView {
    func configure(
        delegate: UIPickerViewDelegate & UIPickerViewDataSource,
        for textField: UITextField,
        _ accessoryViewFactory: @autoclosure () -> UIView
    ) {
        self.dataSource = delegate
        self.delegate = delegate
        textField.inputAccessoryView = accessoryViewFactory()
        textField.inputView = self
    }

    var selectedRow: Int {
        selectedRow(inComponent: 0)
    }
}

// MARK: - UIDatePicker
public extension UIDatePicker {
    func configure(
        _ accessoryViewFactory: @autoclosure () -> UIView,
        for textField: UITextField
    ) {
        preferredDatePickerStyle = .wheels
        locale = Locale(identifier: "ru")
        datePickerMode = .date
        maximumDate = Date()
        textField.inputAccessoryView = accessoryViewFactory()
        textField.inputView = self
    }
}

// MARK: - UIStackView
public extension UIStackView {
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
