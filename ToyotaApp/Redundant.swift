import Foundation

// MARK: - ShowroomDidSelectResponse
public struct OldCar: IService {
    var name: String { "\(brandName) \(modelName)" }

    let id: String
    let brandName: String
    let modelName: String
    let colorName: String?
    let colorSwatch: String?
    let colorDescription: String?
    let isMetallic: String?
    let licensePlate: String?
    let vin: String?

    private enum CodingKeys: String, CodingKey {
        case id = "car_id"
        case brandName = "car_brand_name"
        case modelName = "car_model_name"
        case colorName = "car_color_name"
        case colorSwatch = "color_swatch"
        case colorDescription = "color_description"
        case isMetallic = "color_metallic"
        case licensePlate = "license_plate"
        case vin = "vin_code"
    }
}

extension OldCar {
    func toDomain(with vin: String = .empty) -> Car {
        Car(id: id, brand: brandName, model: Model(id: .empty, name: modelName, brandId: .empty),
            color: Color(id: .empty, name: colorName ?? .empty,
                         code: .empty, colorDescription: colorDescription ?? .empty,
                         isMetallic: isMetallic ?? .empty, hex: colorSwatch ?? .empty), year: "1960",
            plate: licensePlate ?? .empty, vin: self.vin ?? vin, isChecked: false)
    }
}

// MARK: - CarCheckResponse
public struct CarCheckResponse: IResponse {
    let result: String
    let message: String // todo: delete message
    // let car: OldCar?
}
