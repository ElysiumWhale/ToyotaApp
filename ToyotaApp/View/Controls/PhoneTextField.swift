import Foundation
import UIKit

enum CountryPrefix: String {
    case ru = " 🇷🇺+7"
    case kz = " 🇰🇿+7"
    case uzb = "🇺🇿+998"
}

@IBDesignable
class PhoneTextField: UITextField {
    private var prefixLabel: UILabel!
    
    var countryPrefix: CountryPrefix = .ru
    
    var prefix: String? { prefixLabel.text?.filter({ $0.isMathSymbol || $0.isNumber}) }
    var phone: String? {
        if let prefix = prefix, let text = text {
            return prefix + text
        }
        else { return nil }
    }
    
    override func draw(_ rect: CGRect) {
        prefixLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.height + 10, height: frame.size.height))
        prefixLabel.font = UIFont.toyotaLight(of: 22)
        prefixLabel.backgroundColor = .clear
        prefixLabel.textAlignment = .center
        prefixLabel.textColor = .label
        prefixLabel.text = countryPrefix.rawValue
        leftView = prefixLabel
        leftViewMode = .always
    }
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
    }
    
    func customizeView() {
        delegate = self
        layer.cornerRadius = 10
        clipsToBounds = true
        
        if let p = placeholder {
            let place = NSAttributedString(string: p, attributes: [.foregroundColor: UIColor.placeholderText])
            attributedPlaceholder = place
            textColor = .label
        }
    }
    
    var validPhone: String? {
        guard let phone = phone, let prefixCount = prefix?.filter({$0.isNumber}).count else {
            return nil
        }
        var numberOfDigits = 0
        switch prefixCount {
            case 1: numberOfDigits = 10
            case 2: numberOfDigits = 9
            case 3: numberOfDigits = 8
            default: numberOfDigits = 0
        }
        let regEx = "^\\+[0-9]{\(prefixCount)}[0-9]{\(numberOfDigits)}$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: phone) ? phone : nil
    }
}

extension PhoneTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location >= 10 {
            return false
        }
        return true
    }
}
