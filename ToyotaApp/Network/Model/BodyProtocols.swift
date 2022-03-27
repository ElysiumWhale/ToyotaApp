import Foundation

protocol IBody: Encodable {
    var asRequestItems: [URLQueryItem] { get }
}

protocol BodyWithUserId {
    var userId: String { get }
}

extension BodyWithUserId {
    var userIdItem: URLQueryItem {
        .init(.auth(.userId), userId)
    }
}

protocol BodyWithBrandId {
    var brandId: String { get }
}

extension BodyWithBrandId {
    var brandIdItem: URLQueryItem {
        .init(.auth(.brandId), brandId)
    }
}

typealias BodyWithUserAndBrandId = BodyWithUserId & BodyWithBrandId

protocol BodyWithShowroomId {
    var showroomId: String { get }
}

extension BodyWithShowroomId {
    var showroomIdItem: URLQueryItem {
        .init(.carInfo(.showroomId), showroomId)
    }
}

extension IBody where Self: BodyWithUserId {
    var asRequestItems: [URLQueryItem] {
        [userIdItem]
    }
}

extension IBody where Self: BodyWithBrandId {
    var asRequestItems: [URLQueryItem] {
        [brandIdItem]
    }
}

extension IBody where Self: BodyWithUserAndBrandId {
    var asRequestItems: [URLQueryItem] {
        [userIdItem, brandIdItem]
    }
}

extension IBody where Self: BodyWithShowroomId {
    var asRequestItems: [URLQueryItem] {
        [showroomIdItem]
    }
}
