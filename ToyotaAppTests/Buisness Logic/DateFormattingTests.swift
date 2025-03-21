import XCTest
@testable import ToyotaApp

final class DateFormattingTests: XCTestCase {
    func testFormatter(
        _ formatter: DateFormatter,
        expectation: (string: String, date: Date)
    ) {
        let noDateExpectation = ""
        XCTAssertNil(noDateExpectation.asDate(with: formatter))
        let normalDateExpectation = expectation.string
        let normalDateResult = normalDateExpectation.asDate(with: formatter)
        XCTAssertNotNil(normalDateResult)
        XCTAssertEqual(normalDateResult, expectation.date)
        XCTAssertEqual(
            normalDateExpectation,
            expectation.date.asString(formatter)
        )
    }

    func testFormatters() throws {
        let commonDate = Date(timeIntervalSince1970: 1608854400)

        let serverExpectation = ("2020-12-25", commonDate)
        testFormatter(
            .server.withTimeZone("UTC"),
            expectation: serverExpectation
        )

        let serverWithTimeExpectation = (
            "2020-12-25 23:04:45",
            Date(timeIntervalSince1970: 1608937485)
        )
        testFormatter(
            .serverWithTime.withTimeZone("UTC"),
            expectation: serverWithTimeExpectation
        )

        let clientExpectation = (
            "26 янв. 2077 г.",
            Date(timeIntervalSince1970: 3378844800)
        )
        testFormatter(
            .client.withTimeZone("UTC"),
            expectation: clientExpectation
        )

        let displayExpectation = ("25.12.2020", commonDate)
        testFormatter(
            .display.withTimeZone("UTC"),
            expectation: displayExpectation
        )
    }

    func testDateComponentsUtils() throws {
        // 2020-12-25 23:04:45
        let date = Calendar.current.date(from: DateComponents(
            year: 2020,
            month: 12,
            day: 25,
            hour: 23,
            minute: 4,
            second: 45
        ))!

        XCTAssertEqual(date.day, 25)
        XCTAssertEqual(date.hour, 23)
        XCTAssertEqual(date.minute, 04)

        let components1 = DateComponents(hour: 00, minute: 00)
        XCTAssertEqual("00:00", components1.hourAndMinute)
        let components2 = DateComponents(hour: 01, minute: 01)
        XCTAssertEqual("01:01", components2.hourAndMinute)
        let components3 = DateComponents(hour: 11, minute: 11)
        XCTAssertEqual("11:11", components3.hourAndMinute)
    }
}
