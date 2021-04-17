import Foundation

public class Test {
    class func AddCarToUser(completion: @escaping (Car, Showroom) -> Void) {
        let car = Car(id: "-1", showroomId: "-1", brand: "ToyotaToyota", model: "OutlanderOutlander OutlanderOutlander", color: "BlackBlack BlackBlackBlack BlackBlack", colorSwatch: "", colorDescription: "VeryBlack VeryBlackVeryBlackVeryBlack VeryBlack", isMetallic: "1", plate: "a568aa163rus", vin: "12345678901234567")
        let show = Showroom(id: "-1", showroomName: "Test", cityName: "Samara")
        completion(car, show)
    }
    
    class func CreateOrder() -> Service {
        .init(id: "1", showroomId: "1", serviceTypeId: "1", serviceName: "1", koeffTime: "1", multiply: "1")
    }
    
    class func PushTestCars() {
        let car = Car(id: "1", showroomId: "1", brand: "Toyota", model: "Supra A90", color: "Белый жемчуг", colorSwatch: "#eeee", colorDescription: "Белый красивый", isMetallic: "1", plate: "а228аа163rus", vin: "22822822822822822")
        let car1 = Car(id: "2", showroomId: "1", brand: "Toyota", model: "Camry 3.5", color: "Черный жемчуг", colorSwatch: "#eeee", colorDescription: "Черный красивый", isMetallic: "1", plate: "м148мм163rus", vin: "22822822822822822")
        DefaultsManager.pushUserInfo(info: Cars([car, car1], chosen: car))
    }
    
    class func CreateNews() -> [News] {
        let url = URL(string: "https://www.vhv.rs/dpng/d/522-5221969_toyota-logo-symbol-vector-vector-toyota-logo-png.png")!
        return [News(title: "Функционал в разработке", content: "Скоро здесь появятся различные новости от дилеров и специальные предложения!", date: Date(), showroomId: "-1", showroomName: "Тойота Самара Юг", imgUrl: url), News(title: "Функционал в разработке", content: "Скоро здесь появятся различные новости от дилеров и специальные предложения!", date: Date(), showroomId: "-1", showroomName: "Тойота Самара Север", imgUrl: url)]
    }
}
