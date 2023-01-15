import UIKit

public enum BackgroundConfig {
    case empty
    case label(_ text: String, _ font: UIFont)
}

public extension UIView {
    func applyCornerMask(radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: .init(width: radius, height: radius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.frame = bounds
        layer.mask = maskLayer
    }

    // MARK: - Background creating
    func createBackground(_ config: BackgroundConfig = .empty) -> UILabel? {
        switch config {
        case .empty:
            return nil
        case let .label(text, font):
            let label = UILabel()
            label.text = text
            label.textColor = .systemGray
            label.numberOfLines = .zero
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.font = font
            label.sizeToFit()
            return label
        }
    }

    // MARK: - FadeIn UIView Animation
    func fadeIn(_ duration: TimeInterval = 0.5) {
        guard alpha == 0 else {
            return
        }

        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 1 }
        )
    }

    // MARK: - FadeOut UIView Animation
    func fadeOut(
        _ duration: TimeInterval = 0.5,
        completion: @escaping () -> Void = { }
    ) {
        guard alpha == 1 else {
            return
        }

        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 0 },
            completion: { _ in completion() }
        )
    }

    // MARK: - Dismiss keyboard on swipe down
    func hideKeyboardWhenSwipedDown() {
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(UIView.dismissKeyboard)
        )
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
            addSwipeRecognizer()
        case .tapAndSwipe:
            let tap = addTapRecognizer()
            let swipe = addSwipeRecognizer()
            tap.require(toFail: swipe)
        }
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }

    @discardableResult
    private func addTapRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIView.dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        return tap
    }

    @discardableResult
    private func addSwipeRecognizer() -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(UIView.dismissKeyboard)
        )
        swipe.cancelsTouchesInView = false
        swipe.direction = [.up, .down, .left, .right]
        addGestureRecognizer(swipe)

        return swipe
    }

    // MARK: - SetTitleIfButtonFirst
    func setTitleIfButtonFirst(_ title: String) {
        if let button = self.subviews.first as? UIButton {
            button.setTitle(title, for: .normal)
        }
    }
}

// MARK: - UIView
public extension UIView {
    struct ShadowState {
        let color: UIColor
        let offset: CGSize
        let radius: CGFloat
        let opacity: Float
        let cornerRadius: CGFloat

        public init(
            color: UIColor,
            offset: CGSize,
            radius: CGFloat,
            opacity: Float,
            cornerRadius: CGFloat
        ) {
            self.color = color
            self.offset = offset
            self.radius = radius
            self.opacity = opacity
            self.cornerRadius = cornerRadius
        }
    }

    func renderShadow(_ shadowState: ShadowState, in layer: CALayer) {
        layer.shadowColor = shadowState.color.cgColor
        layer.shadowOffset = shadowState.offset
        layer.shadowRadius = shadowState.radius
        layer.shadowOpacity = shadowState.opacity
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: shadowState.cornerRadius
        ).cgPath
    }
}

// MARK: - Adding subviews
public extension UIView {
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

public extension UITableViewCell {
    func addViews(_ views: UIView...) {
        contentView.addSubviews(views)
    }

    func addViews(_ views: [UIView]) {
        contentView.addSubviews(views)
    }
}

// MARK: - Customization
public extension UIView {
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    var borderColor: UIColor {
        get {
            guard let cgColor = layer.borderColor else {
                return .clear
            }

            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}
