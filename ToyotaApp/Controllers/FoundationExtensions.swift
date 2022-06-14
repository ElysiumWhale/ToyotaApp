import Foundation

typealias ParameterClosure<T> = (T) -> Void
typealias Closure = () -> Void
typealias ValueClosure<T> = () -> T
typealias ParameterValueClosure<T1, T2> = (T1) -> T2

extension Int {
    static let vinLength = 17
}

// MARK: - Init with request key
extension URLQueryItem {
    init(_ key: RequestKeys, _ value: String?) {
        self.init(name: key.rawValue, value: value)
    }
}

// MARK: - Collection helpers
extension Collection {
    func any(_ condition: (Self.Element) -> Bool) -> Bool {
        first(where: condition) != nil
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - Years strings
extension Array where Element == String {
    static func yearsFrom(year: Int = 1950) -> Self {
        var result: [String] = []
        var currentYear = Calendar.current.component(.year, from: Date())
        while currentYear >= year {
            result.append("\(currentYear)")
            currentYear -= 1
        }
        return result
    }
}
