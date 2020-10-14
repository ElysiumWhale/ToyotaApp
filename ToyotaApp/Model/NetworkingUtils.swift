import Foundation

enum PostRequests: String {
    case phoneNumber = "register_phone.php"
    case smsCode = "check_code.php"
    case profile = "set_profile.php"
}

enum PostRequestsKeys: String {
    case phoneNumber = "phone_number"
}
