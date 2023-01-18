import XCTest
@testable import ToyotaApp

final class ResourcesTests: XCTestCase {
    func testToyotaFonts() throws {
        for type in UIFont.ToyotaFonts.allCases {
            let font = UIFont(name: type.name, size: 10)
            print("[TEST] Font name: \(type.name), Value: \(String(describing: font))")
            XCTAssertNotNil(font)
        }
    }

    func testAppTints() throws {
        for tint in UIColor.AppTints.allCases {
            let color = UIColor(named: tint.rawValue)
            print("[TEST] Color name: \(tint.rawValue), Value: \(String(describing: color))")
            XCTAssertNotNil(color)
        }
    }
}
