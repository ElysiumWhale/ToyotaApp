import UIKit

// MARK: - Inputable
protocol Inputable<TInput>: AnyObject {
    associatedtype TInput

    func input(_ value: TInput)
}

// MARK: - Outputable
protocol Outputable<TOutput>: AnyObject {
    associatedtype TOutput

    var output: ParameterClosure<TOutput>? { get set }
}

extension Outputable {
    @discardableResult
    func withOutput(_ output: ParameterClosure<TOutput>?) -> Self {
        self.output = output
        return self
    }
}

final class OutputStore<TOutput>: Outputable {
    var output: ParameterClosure<TOutput>?
}
