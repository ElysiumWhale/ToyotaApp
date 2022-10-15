import Foundation

struct WeakObserver {
    weak var value: ObservesEvents?
}

protocol ObservesEvents: AnyObject {
    func handle(event: EventNotificator.AppEvents,
                notificator: EventNotificator)
}

final class EventNotificator {

    enum AppEvents {
        case userUpdate
        case phoneUpdate
    }

    static let shared = EventNotificator()

    private let queue = DispatchQueue(label: "EventNotificatorQueue",
                                      attributes: [.concurrent])

    private var observers: [AppEvents: [WeakObserver]] = [:]

    func add(_ observer: ObservesEvents, for event: AppEvents) {
        guard !hasObserver(observer, for: event) else {
            return
        }

        queue.async(flags: .barrier) { [weak self] in
            var existObservers = self?.observers[event]?.compactMap { $0 } ?? []
            existObservers.append(WeakObserver(value: observer))
            self?.observers[event] = existObservers
        }
    }

    func remove(_ observer: ObservesEvents, for event: AppEvents) {
        queue.async(flags: .barrier) { [weak self] in
            guard let observers = self?.observers[event],
                  let index = observers.firstIndex(where: { $0.value === observer }) else {
                return
            }

            self?.observers[event]?.remove(at: index)
            self?.observers[event]?.removeAll(where: { $0.value == nil })
        }
    }

    func notify(with event: AppEvents) {
        queue.sync {
            guard let obs = observers[event] else {
                return
            }

            for observer in obs {
                queue.async {
                    observer.value?.handle(event: event, notificator: self)
                }
            }
        }
    }

    private func hasObserver(_ observer: ObservesEvents,
                             for event: AppEvents) -> Bool {
        queue.sync {
            guard let observers = observers[event] else {
                return false
            }

            return observers.contains(where: { $0.value === observer })
        }
    }
}

// MARK: - CustomStringConvertible
extension EventNotificator: CustomStringConvertible {
    var description: String {
        observers.debugDescription
    }
}
