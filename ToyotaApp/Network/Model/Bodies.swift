import Foundation

struct AnyBody: IBody {
    let items: RequestItems

    var asRequestItems: [URLQueryItem] {
        items.asQueryItems
    }
}

// MARK: - SimpleBrandBody
struct SimpleBrandBody: IBody, BodyWithBrandId {
    let brandId: String
}

typealias GetCitiesBody = SimpleBrandBody
typealias GetModelsAndColorsBody = SimpleBrandBody

// MARK: - SimpleUserIdBody
struct SimpleUserIdBody: IBody, BodyWithUserId {
    let userId: String
}

typealias GetBookingsBody = SimpleUserIdBody

// MARK: - CheckUserBody
struct CheckUserBody: IBody, BodyWithUserAndBrandId {
    let userId: String
    let secret: String
    let brandId: String

    var asRequestItems: [URLQueryItem] {
        [
            userIdItem,
            brandIdItem,
            .init(.auth(.secretKey), secret)
        ]
    }
}

// MARK: - RegsiterPhoneBody
struct RegisterPhoneBody: IBody {
    let phone: String

    var asRequestItems: [URLQueryItem] {
        [
            .init(.personalInfo(.phoneNumber), phone)
        ]
    }
}

// MARK: - CheckSmsCodeBody
struct CheckSmsCodeBody: IBody, BodyWithBrandId {
    let phone: String
    let code: String
    let brandId: String

    var asRequestItems: [URLQueryItem] {
        [
            .init(.personalInfo(.phoneNumber), phone),
            .init(.auth(.code), code),
            brandIdItem
        ]
    }
}

// MARK: - SetProfileBody
typealias EditProfileBody = SetProfileBody

struct SetProfileBody: IBody, BodyWithUserAndBrandId {
    let brandId: String
    let userId: String
    let firstName: String
    let secondName: String
    let lastName: String
    let email: String
    let birthday: String

    var asRequestItems: [URLQueryItem] {
        [
            brandIdItem,
            userIdItem,
            .init(.personalInfo(.firstName), firstName),
            .init(.personalInfo(.secondName), secondName),
            .init(.personalInfo(.lastName), lastName),
            .init(.personalInfo(.email), email),
            .init(.personalInfo(.birthday), birthday)
        ]
    }
}

// MARK: - SetCarBody
struct SetCarBody: IBody, BodyWithUserAndBrandId {
    let brandId: String
    let userId: String
    let carModelId: String
    let colorId: String
    let licensePlate: String
    let vinCode: String?
    let year: String

    var asRequestItems: [URLQueryItem] {
        [
            brandIdItem,
            userIdItem,
            .init(.carInfo(.modelId), carModelId),
            .init(.carInfo(.colorId), colorId),
            .init(.carInfo(.licensePlate), licensePlate),
            .init(.carInfo(.vinCode), vinCode),
            .init(.carInfo(.releaseYear), year)
        ]
    }
}

// MARK: - DeleteCarBody
struct DeleteCarBody: IBody, BodyWithUserId {
    let userId: String
    let carId: String

    var asRequestItems: [URLQueryItem] {
        [
            userIdItem,
            .init(.carInfo(.carId), carId)
        ]
    }
}

// MARK: - GetShowroomsBody
typealias GetCarsForTestDriveBody = GetShowroomsBody

struct GetShowroomsBody: IBody, BodyWithBrandId {
    let brandId: String
    let cityId: String

    var asRequestItems: [URLQueryItem] {
        [
            brandIdItem,
            .init(.carInfo(.cityId), cityId)
        ]
    }
}

// MARK: - DeletePhoneBody
struct DeletePhoneBody: IBody {
    let phone: String

    var asRequestItems: [URLQueryItem] {
        [
            .init(.personalInfo(.phoneNumber), phone)
        ]
    }
}

// MARK: - GetServiceTypesBody
struct GetServiceTypesBody: IBody, BodyWithShowroomId {
    let showroomId: String
}

// MARK: - GetServicesBody
struct GetServicesBody: IBody, BodyWithShowroomId {
    let showroomId: String
    let serviceTypeId: String

    var asRequestItems: [URLQueryItem] {
        [
            showroomIdItem,
            .init(.services(.serviceTypeId), serviceTypeId)
        ]
    }
}

// MARK: - GetFreeTimeBody
struct GetFreeTimeBody: IBody, BodyWithShowroomId {
    let showroomId: String
    let serviceId: String

    var asRequestItems: [URLQueryItem] {
        [
            showroomIdItem,
            .init(.services(.serviceId), serviceId)
        ]
    }
}

// MARK: - ChangePhoneBody
struct ChangePhoneBody: IBody, BodyWithUserId {
    let userId: String
    let code: String
    let newPhone: String

    var asRequestItems: [URLQueryItem] {
        [
            userIdItem,
            .init(.auth(.code), code),
            .init(.personalInfo(.phoneNumber), newPhone)
        ]
    }
}

// MARK: - GetShowroomsForTestDriveBody
struct GetShowroomsForTestDriveBody: IBody, BodyWithBrandId {
    let brandId: String
    let cityId: String
    let serviceId: String

    var asRequestItems: [URLQueryItem] {
        [
            brandIdItem,
            .init(.carInfo(.cityId), cityId),
            .init(.services(.serviceId), serviceId)
        ]
    }
}

// MARK: - BookServiceBody
typealias BookServiceBody = AnyBody

// MARK: - GetManagersBody
struct GetManagersBody: IBody, BodyWithUserAndBrandId {
    let userId: String
    let brandId: String
}

// MARK: - SkipSetCarBody
struct SkipSetCarBody: IBody, BodyWithUserId {
    let userId: String
    let skipValue = "1"

    var asRequestItems: [URLQueryItem] {
        [
            userIdItem,
            .init(.carInfo(.skipStep), skipValue)
        ]
    }
}
