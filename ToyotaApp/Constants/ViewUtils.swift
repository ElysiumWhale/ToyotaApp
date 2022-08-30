import Foundation

enum AuthType: Equatable {
    case register
    case changeNumber
}

/// **Warning!** Equality comparison will result `false` **ONLY** if one operator is `.register` and another is `.update`.
/// In **rest** cases it will return `true`.
enum AddInfoType: Equatable {
    case register
    case update(with: UserProxy)

    static func == (lhs: AddInfoType, rhs: AddInfoType) -> Bool {
        if case register = lhs, case register = rhs {
            return true
        }
        if case update = lhs, case update = rhs {
            return true
        }
        return false
    }
}

// MARK: - Structs with view constants
enum AppStoryboards: String {
    /// MyProfile
    case myProfile = "MyProfile"
}

enum ViewControllers: String {
    /// MyProfileViewController
    case myProfile = "MyProfileViewController"
}

enum TimeMap {
    static func getFullSchedule(after hour: Int? = nil) -> [DateComponents] {
        var times: [DateComponents] = []
        for key in 18...38 {
            if let now = hour, clientMap[key]!.hour ?? -1 < now + 1 {
                continue
            }
            times.append(clientMap[key]!)
        }
        return times
    }

    static let clientMap: [Int: DateComponents] = [
        -1: .init(hour: 00, minute: 01),
        14: .init(hour: 07, minute: 00), 15: .init(hour: 07, minute: 30),
        16: .init(hour: 08, minute: 00), 17: .init(hour: 08, minute: 30),
        18: .init(hour: 09, minute: 00), 19: .init(hour: 09, minute: 30),
        20: .init(hour: 10, minute: 00), 21: .init(hour: 10, minute: 30),
        22: .init(hour: 11, minute: 00), 23: .init(hour: 11, minute: 30),
        24: .init(hour: 12, minute: 00), 25: .init(hour: 12, minute: 30),
        26: .init(hour: 13, minute: 00), 27: .init(hour: 13, minute: 30),
        28: .init(hour: 14, minute: 00), 29: .init(hour: 14, minute: 30),
        30: .init(hour: 15, minute: 00), 31: .init(hour: 15, minute: 30),
        32: .init(hour: 16, minute: 00), 33: .init(hour: 16, minute: 30),
        34: .init(hour: 17, minute: 00), 35: .init(hour: 17, minute: 30),
        36: .init(hour: 18, minute: 00), 37: .init(hour: 18, minute: 30),
        38: .init(hour: 19, minute: 00), 39: .init(hour: 19, minute: 30),
        40: .init(hour: 20, minute: 00), 41: .init(hour: 20, minute: 30)
    ]

    static let serverMap: [String: Int] = [
        "00:00": 0, "00:30": 1,
        "01:00": 2, "01:30": 3,
        "02:00": 4, "02:30": 5,
        "03:00": 6, "03:30": 7,
        "04:00": 8, "04:30": 9,
        "05:00": 10, "05:30": 11,
        "06:00": 12, "06:30": 13,
        "07:00": 14, "07:30": 15,
        "08:00": 16, "08:30": 17,
        "09:00": 18, "09:30": 19,
        "10:00": 20, "10:30": 21,
        "11:00": 22, "11:30": 23,
        "12:00": 24, "12:30": 25,
        "13:00": 26, "13:30": 27,
        "14:00": 28, "14:30": 29,
        "15:00": 30, "15:30": 31,
        "16:00": 32, "16:30": 33,
        "17:00": 34, "17:30": 35,
        "18:00": 36, "18:30": 37,
        "19:00": 38, "19:30": 39,
        "20:00": 40, "20:30": 41,
        "21:00": 42, "21:30": 43,
        "22:00": 44, "22:30": 45,
        "23:00": 46, "23:30": 47
    ]
}
