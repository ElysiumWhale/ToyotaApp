import Foundation

public struct PhoneDidSendResponse: Codable {
    let firstTimeFlag: Int
    let id: Int
    let authKey: Data
}
