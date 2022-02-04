import Foundation

public class Mocks {
    class func createOrder() -> Service {
        .init(id: "1", name: "1")
    }

    class func createFreeTimeDict() -> [String: [Int]] {
        var result = [String: [Int]]()
        var date: Date = Calendar.current.date(byAdding: DateComponents(hour: 4, minute: 30), to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = .yyyyMMdd
        for var index in 0...5 {
            result[formatter.string(from: date)] = [1+index*2, 3+index*3, 4+index*3,
                                                    5+index*3-1, 6+index*3+1, 7+index*3+3]
            date = Calendar.current.date(byAdding: DateComponents(day: 10, hour: 3), to: date)!
            index+=1
        }
        return result
    }

    class func createManagers() -> [Manager] {
        return [Manager(id: "-1", userId: "", firstName: "Valery",
                        secondName: "Aboba", lastName: "Aboba",
                        phone: "8-800-535-35-35", email: "aboba.val@gmail.com",
                        imageUrl: "public/images/avatars/toyota/sh1/foto-ava.jpg",
                        showroomName: "Тойота Самара Юг"),
                Manager(id: "-1", userId: "", firstName: "Valery",
                        secondName: "Aboba", lastName: "Aboba",
                        phone: "8-800-535-35-35", email: "aboba.val@gmail.com",
                        imageUrl: "public/images/avatars/toyota/sh1/foto-ava.jpg",
                        showroomName: "Тойота Самара Север")]
    }
}

extension Booking {
    static var todayNotInFuture: Booking {
        .init(bDate: Date().asString(.server), cDate: .empty, startTime: "-1",
              latitude: .empty, longitude: .empty, status: .future,
              carName: "Toyota RAV4", licensePlate: "А344РС163RUS", showroomName: "Mock Центр Самара Юг",
              serviceName: "Mock Mock Mock", postName: .empty)
    }
}
