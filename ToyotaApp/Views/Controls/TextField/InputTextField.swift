import UIKit

@IBDesignable
class InputTextField: UITextField, Validatable {
    // MARK: - Inspectables
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

    // MARK: - Properties
    var rule: ValidationRule?
    var validationEnabled: Bool = true

    private(set) var isValid: Bool = true
    /// Safe `text` property for using **not only** on `Main` thread
    private(set) var inputText: String = .empty

    override var text: String? {
        didSet {
            inputDidChanged(sender: self)
        }
    }

    // MARK: - Methods
    func isValid(for rule: ValidationRule) -> Bool {
        rule.validate(text: inputText)
    }

    func validate(newText: String?) {
        inputText = newText ?? .empty
        guard validationEnabled, let rule = rule else {
            return
        }

        isValid = isValid(for: rule)
        toggle(state: isValid ? .normal : .error)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addTarget(self, action: #selector(inputDidChanged), for: .editingChanged)
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

    @objc private func inputDidChanged(sender: UITextField?) {
        guard self === sender else {
            return
        }

        if let text = text, text.count >= maxSymbolCount {
            self.text = inputText
            return
        }

        validate(newText: text)
    }
}
