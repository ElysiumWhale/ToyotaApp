import Foundation

protocol Validatable {
    var rule: ValidationRule? { get set }
    func validate(for rule: ValidationRule, toggleState: Bool) -> Bool
}

typealias ValidationClosure = (String?) -> Bool

class ValidationRule {
    let validationClouse: ValidationClosure

    func validate(text: String?) -> Bool {
        validationClouse(text)
    }

    init(_ closure: @escaping ValidationClosure = { _ in true }) {
        self.validationClouse = closure
    }
}

// MARK: Presets
extension ValidationRule {
    static var personalInfo: ValidationRule {
        ValidationRule { text in
            text != nil && text!.isNotEmpty && text!.count < 25
        }
    }

    static var empty: ValidationRule {
        ValidationRule { _ in
            true
        }
    }

    static var notEmpty: ValidationRule {
        ValidationRule { text in
            text != nil && text!.isNotEmpty
        }
    }

    static func requiredSymbolsCount(_ count: UInt) -> ValidationRule {
        ValidationRule { text in
            text?.count ?? 0 >= count
        }
    }
}
