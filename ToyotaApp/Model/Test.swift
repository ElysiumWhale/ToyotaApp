import Foundation

public class Test {
    class func addCarToUser(completion: @escaping (Car, Showroom) -> Void) {
        let car = Car(id: "-1", showroomId: "-1", brand: "ToyotaToyota",
                      model: "OutlanderOutlander OutlanderOutlander",
                      color: "BlackBlack BlackBlackBlack BlackBlack",
                      colorSwatch: "",
                      colorDescription: "VeryBlack VeryBlackVeryBlackVeryBlack VeryBlack",
                      isMetallic: "1", plate: "a568aa163rus", vin: "12345678901234567")
        let show = Showroom(id: "-1", showroomName: "Test", cityName: "Samara")
        completion(car, show)
    }
    
    class func createOrder() -> Service {
        .init(id: "1", name: "1")
    }
    
    class func pushTestCars() {
        let car = Car(id: "1", showroomId: "1", brand: "Toyota",
                      model: "Supra A90", color: "Белый жемчуг",
                      colorSwatch: "#eeee", colorDescription: "Белый красивый",
                      isMetallic: "1", plate: "а228аа163rus", vin: "22822822822822822")
        let car1 = Car(id: "2", showroomId: "1", brand: "Toyota",
                       model: "Camry 3.5", color: "Черный жемчуг",
                       colorSwatch: "#eeee", colorDescription: "Черный красивый",
                       isMetallic: "1", plate: "м148мм163rus", vin: "22822822822822822")
        // DefaultsManager.pushUserInfo(info: Cars([car, car1], chosen: car))
        KeychainManager.set(Cars([car, car1]))
    }
    
    class func createNews() -> [News] {
        let url = URL(string: "https://www.vhv.rs/dpng/d/522-5221969_toyota-logo-symbol-vector-vector-toyota-logo-png.png")!
        return [News(title: "Функционал в разработке", imgUrl: url, url: nil),
                News(title: "Функционал в разработке", imgUrl: url, url: nil)]
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
    static let mock = Booking(date: "2021.09.11", startTime: "21", latitude: "89.12",
                              longitude: "-35.54", status: .done, carName: "Toyota RAV4",
                              licensePlate: "А344РС163RUS", showroomName: "Тойота Центр Самара Юг",
                              serviceName: "Плановый технический осмотр", postName: "Samara Gorod")
}
