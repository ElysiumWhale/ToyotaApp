import Foundation

protocol Validatable {
    var rule: ValidationRule? { get set }
    var isValid: Bool { get }
    var validationEnabled: Bool { get set }
    func isValid(for rule: ValidationRule) -> Bool
}

class ValidationRule {
    let validationClouse: (String?) -> Bool

    func validate(text: String?) -> Bool {
        validationClouse(text)
    }

    init(_ closure: @escaping (String?) -> Bool = { _ in true }) {
        self.validationClouse = closure
    }
}

extension ValidationRule {
    static let personalInfo = ValidationRule { text in
        text != nil && text!.isNotEmpty && text!.count < 25
    }
}
