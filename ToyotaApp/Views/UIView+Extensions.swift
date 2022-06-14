import UIKit

extension UIView {
    // MARK: - Background creating
    func createBackground(labelText: String?) -> UILabel? {
        guard let text = labelText else { return nil }
        let label = UILabel()
        label.text = text
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .toyotaType(.semibold, of: 25)
        label.sizeToFit()
        return label
    }

    // MARK: - Constraints swapping
    @discardableResult
    func swapConstraints(from removingConstraint: NSLayoutConstraint,
                         to addingContsraint: NSLayoutConstraint) -> NSLayoutConstraint {
        removeConstraint(removingConstraint)
        addConstraint(addingContsraint)
        return addingContsraint
    }

    // MARK: - FadeIn UIView Animation
    func fadeIn(_ duration: TimeInterval = 0.5) {
        if alpha == 0 {
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in self?.alpha = 1 })
        }
    }

    // MARK: - FadeOut UIView Animation
    func fadeOut(_ duration: TimeInterval = 0.5, completion: @escaping Closure = { }) {
        if alpha == 1 {
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in self?.alpha = 0 },
                           completion: { _ in completion() }
            )
        }
    }

    // MARK: - Dismiss keyboard on swipe down
    func hideKeyboardWhenSwipedDown() {
        let swipe = UISwipeGestureRecognizer(target: self,
                                             action: #selector(UIView.dismissKeyboard))
        swipe.cancelsTouchesInView = false
        swipe.direction = [.down]
        self.addGestureRecognizer(swipe)
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }

    // MARK: - TitleView
    static func titleViewFor(city: String? = nil, action: @escaping Closure) -> UIStackView {
        let str = city ?? .common(.chooseCity)
        let button = UIButton.titleButton(with: str, action: action)
        let rightButton = UIButton(frame: .init(x: 0, y: 0, width: 20, height: 20))
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightButton.tintColor = .appTint(.secondarySignatureRed)
        rightButton.addAction(action)
        let stack = UIStackView(arrangedSubviews: [button, rightButton])
        stack.axis = .horizontal
        return stack
    }

    // MARK: - SetTitleIfButtonFirst
    func setTitleIfButtonFirst(_ title: String) {
        if let stack = self as? UIStackView,
           let button = stack.arrangedSubviews.first as? UIButton {
            button.setTitle(title, for: .normal)
        }
    }
}

// MARK: - Toolbar for controls
extension UIView {
    static func buildToolbar(with action: Selector, target: Any? = nil) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: target,
                                       action: nil)
        let doneButton = UIBarButtonItem(title: .common(.choose),
                                         style: .done,
                                         target: target,
                                         action: action)
        doneButton.tintColor = .appTint(.secondarySignatureRed)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

// MARK: - Adding subviews
extension UIView {
    func addSubviews(_ views: UIView...) {
        for subview in views {
            addSubview(subview)
        }
    }

    func addSubviews(_ views: [UIView]) {
        for subview in views {
            addSubview(subview)
        }
    }
}
