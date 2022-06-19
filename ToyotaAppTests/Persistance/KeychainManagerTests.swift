import XCTest
import class SwiftKeychainWrapper.KeychainWrapper
@testable import ToyotaApp

final class KeychainManagerTests: XCTestCase {
    let testUserId = UserId("-100")
    let testPhone = Phone("1")

    override func setUpWithError() throws {
        KeychainManager<UserId>.clear(from: .testWrapper)
    }

    override func tearDownWithError() throws {
        KeychainManager<UserId>.clear(from: .testWrapper)
    }

    func testGetSet() throws {
        XCTAssertNil(KeychainManager<UserId>.get(from: .testWrapper))
        KeychainManager.set(testUserId, to: .testWrapper)
        let result = KeychainManager<UserId>.get(from: .testWrapper)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, testUserId.value)
    }

    func testClear() throws {
        try testGetSet()

        KeychainManager.set(testUserId, to: .testWrapper)
        KeychainManager<UserId>.clear(from: .testWrapper)
        XCTAssertNil(KeychainManager<UserId>.get(from: .testWrapper))

        KeychainManager.set(testUserId, to: .testWrapper)
        KeychainManager.set(testPhone, to: .testWrapper)
        KeychainManager<UserId>.clearAll(from: .testWrapper)
        XCTAssertNil(KeychainManager<UserId>.get(from: .testWrapper))
        XCTAssertNil(KeychainManager<Phone>.get(from: .testWrapper))
    }

    func testDifferentWrappers() throws {
        try testGetSet()

        KeychainManager<UserId>.set(testUserId, to: .testWrapper)
        let idFromAnotherWrapper = KeychainManager<UserId>.get()
        XCTAssertNotEqual(testUserId.value, idFromAnotherWrapper?.value)
    }

    func testUpdate() throws {
        try testGetSet()

        KeychainManager<UserId>.set(testUserId, to: .testWrapper)
        KeychainManager<UserId>.update({ userId in
            XCTAssertNotNil(userId)
            return UserId("-200")
        }, in: .testWrapper)

        let result = KeychainManager<UserId>.get(from: .testWrapper)
        XCTAssertNotEqual(result?.value, testUserId.value)
    }
}

// MARK: - testWrapper
private extension KeychainWrapper {
    static let testWrapper = KeychainWrapper(serviceName: "testWrapper")
}
