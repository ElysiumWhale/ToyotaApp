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
        addGestureRecognizer(swipe)
    }

    enum Gesture {
        case tap
        case swipe
        case tapAndSwipe
    }

    func hideKeyboard(when option: Gesture) {
        switch option {
        case .tap:
            addTapRecognizer()
        case .swipe:
            addSwipeRecongizer()
        case .tapAndSwipe:
            let tap = addTapRecognizer()
            let swipe = addSwipeRecongizer()
            tap.require(toFail: swipe)
        }
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }

    @discardableResult
    private func addTapRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        return tap
    }

    @discardableResult
    private func addSwipeRecongizer() -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer(target: self,
                                             action: #selector(UIView.dismissKeyboard))
        swipe.cancelsTouchesInView = false
        swipe.direction = [.up, .down, .left, .right]
        addGestureRecognizer(swipe)

        return swipe
    }

    // MARK: - TitleView
    static func titleViewFor(city: String? = nil, action: @escaping Closure) -> UIView {
        let button = UIButton.titleButton(with: city ?? .common(.chooseCity),
                                          action: action)
        let rightButton = UIButton(frame: .init(x: 0, y: 0, width: 20, height: 20))
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightButton.tintColor = .appTint(.secondarySignatureRed)
        rightButton.addAction(action)

        let container = UIView(frame: .init(x: 0, y: 0, width: 100, height: 30))
        container.addSubviews(button, rightButton)

        button.edgesToSuperview(excluding: .trailing)
        rightButton.trailingToSuperview()
        button.trailingToLeading(of: rightButton)
        button.centerY(to: rightButton, offset: -3)

        return container
    }

    // MARK: - SetTitleIfButtonFirst
    func setTitleIfButtonFirst(_ title: String) {
        if let button = self.subviews.first as? UIButton {
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
