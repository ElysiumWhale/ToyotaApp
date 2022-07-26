import UIKit

@IBDesignable
class InputTextField: UITextField, Validatable, BottomKeyboardBinded {
    // MARK: - BottomKeyboardBinded
    @IBInspectable
    var keyboardConstraint: NSLayoutConstraint? {
        didSet {
            constant = keyboardConstraint?.constant ?? .zero
        }
    }

    private(set) var constant: CGFloat = .zero

    // MARK: - Additional properties
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var leftPadding: CGFloat = 5

    @IBInspectable
    var maxSymbolCount: Int = 50

    var rule: ValidationRule? {
        didSet {
            if let rule = rule {
                validate(for: rule)
            }
        }
    }

    private(set) var inputText: String = .empty

    override var text: String? {
        didSet {
            textDidChange()
        }
    }

    var isValid: Bool {
        if let rule = rule {
            return validate(for: rule, toggleState: true)
        } else {
            return true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    // MARK: - Methods
    @discardableResult
    func validate(for rule: ValidationRule, toggleState: Bool = false) -> Bool {
        let isValid = rule.validate(text: inputText)

        if toggleState {
            toggle(state: isValid ? .normal : .error)
        }

        return isValid
    }

    func invalidate() {
        if let rule = rule {
            validate(for: rule, toggleState: true)
        } else {
            toggle(state: .normal)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: withPaddingInset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: withPaddingInset)
    }
}

extension InputTextField {
    var withPaddingInset: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
    }

    @objc private func textDidChange() {
        guard let text = text, text.count <= maxSymbolCount else {
            self.text = inputText
            return
        }

        inputText = text
        if let rule = rule {
            validate(for: rule, toggleState: true)
        }
    }
}

extension Sequence where Element == InputTextField {
    func allSatisfy(rule: ValidationRule, toggleState: Bool = true) -> Bool {
        reduce(true, {
            $1.validate(for: rule, toggleState: toggleState) && $0
        })
    }

    var areValid: Bool {
        reduce(true, { $1.isValid && $0 })
    }
}
