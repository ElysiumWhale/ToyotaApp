import XCTest
import class SwiftKeychainWrapper.KeychainWrapper
@testable import ToyotaApp

final class KeychainServiceTests: XCTestCase {
    let testUserId = UserId("-100")
    let testPhone = Phone("1")
    let keychain = KeychainService(wrapper: .testWrapper)

    override func tearDownWithError() throws {
        keychain.removeAll()
    }

    func testGetSet() {
        let nilExpectation: UserId? = keychain.get()
        XCTAssertNil(nilExpectation)
        keychain.set(testUserId)
        let notNilExpectation: UserId? = keychain.get()
        XCTAssertEqual(notNilExpectation?.value, testUserId.value)
    }

    func testClear() {
        testGetSet()

        keychain.remove(UserId.self)
        let nilExpectation: UserId? = keychain.get()
        XCTAssertNil(nilExpectation)

        keychain.set(testUserId)
        keychain.set(testPhone)
        keychain.removeAll()
        let nilExpectation1: UserId? = keychain.get()
        let nilExpectation2: Phone? = keychain.get()
        XCTAssertNil(nilExpectation1)
        XCTAssertNil(nilExpectation2)
    }

    func testDifferentWrappers() {
        testGetSet()

        keychain.set(testUserId)
        let anotherKeychain = KeychainService(wrapper: .anotherTestWrapper)
        let idFromAnotherWrapper: UserId? = anotherKeychain.get()
        XCTAssertNotEqual(testUserId.value, idFromAnotherWrapper?.value)
    }

    func testUpdate() {
        testGetSet()

        keychain.set(testUserId)
        keychain.update { _ in UserId("-200") }

        let result: UserId? = keychain.get()
        XCTAssertNotEqual(result?.value, testUserId.value)
    }

    func testUpdateWhenEmpty() {
        testGetSet()

        keychain.remove(Phone.self)
        keychain.update { _ in Phone("123") }
        let notNilExpectation: Phone? = keychain.get()
        XCTAssertNotNil(notNilExpectation)
    }
}

// MARK: - testWrapper
private extension KeychainWrapper {
    static let testWrapper = KeychainWrapper(serviceName: "testWrapper")
    static let anotherTestWrapper = KeychainWrapper(serviceName: "anotherTestWrapper")
}
