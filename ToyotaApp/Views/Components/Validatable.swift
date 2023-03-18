import Foundation

protocol Validatable {
    var rule: ValidationRule? { get set }

    func validate(for rule: ValidationRule, toggleState: Bool) -> Bool
}

typealias ValidationClosure = (String?) -> Bool

struct ValidationRule {
    let validationClosure: ValidationClosure

    func validate(text: String?) -> Bool {
        validationClosure(text)
    }

    init(_ closure: @escaping ValidationClosure = { _ in true }) {
        self.validationClosure = closure
    }
}

// MARK: - Presets
extension ValidationRule {
    static var personalInfo: ValidationRule {
        ValidationRule { text in
            text != nil && text!.isNotEmpty && text!.count < 25
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

extension ValidationRule {
    static func compose(rules: ValidationRule...) -> ValidationRule {
        ValidationRule { text in
            var result = true
            rules.forEach { rule in
                result = result && rule.validate(text: text)
            }
            return result
        }
    }
}
