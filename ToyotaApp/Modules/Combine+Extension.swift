import Combine
import Foundation

extension Publisher where Failure == Never {
    /// Attaches a subscriber with closure-based behaviour to a publisher that never fails
    /// and specifies the scheduler on which to receive elements from the publisher.
    func sinkOn<S: Scheduler>(
        scheduler: S,
        options: S.SchedulerOptions? = nil,
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        receive(on: scheduler, options: options)
            .sink(receiveValue: receiveValue)
    }
    /// Attaches a subscriber with closure-based behaviour
    /// on **DispatchQueue.main** scheduler to a publisher that never fails
    func sinkOnMain(
        options: DispatchQueue.SchedulerOptions? = nil,
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        sinkOn(
            scheduler: DispatchQueue.main,
            options: options,
            receiveValue: receiveValue
        )
    }
}
