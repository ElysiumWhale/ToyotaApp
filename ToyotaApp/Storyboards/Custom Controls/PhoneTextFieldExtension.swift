import PhoneNumberKit
import Foundation

class PhoneNumberTextFieldWithDefault: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "RU"
        }
        set {} // exists for backward compatibility
    }
}
