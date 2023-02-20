import Foundation

typealias ParameterClosure<T> = (T) -> Void
typealias Closure = () -> Void
typealias ValueClosure<T> = () -> T

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

    subscript(safe index: Self.Index) -> Self.Element? {
        indices.contains(index) ? self[index] : nil
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

extension Bundle {
    var appBuild: String { getInfo("CFBundleVersion") }
    var appVersionLong: String { getInfo("CFBundleShortVersionString") }

    fileprivate func getInfo(_ str: String) -> String {
        infoDictionary?[str] as? String ?? "⚠️"
    }
}
