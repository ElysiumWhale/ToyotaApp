import Foundation

enum AppEvents {
    case userUpdate
}

struct WeakObserver {
    weak var value: ObservesEvents?
}

protocol ObservesEvents: AnyObject {
    func handle(event: AppEvents, object: Any?, notificator: EventNotificator)
}

final class EventNotificator {

    static let shared = EventNotificator()

    private let queue = DispatchQueue(label: "EventNotificatorQueue",
                                      attributes: [.concurrent])

    private var observers: [AppEvents: [WeakObserver]] = [:]

    func add(_ observer: ObservesEvents, for event: AppEvents) {
        guard !hasObserver(observer, for: event) else {
            return
        }

        queue.async(flags: .barrier) { [weak self] in
            var existObservers = self?.observers[event] ?? []
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
        }
    }

    func notify(with event: AppEvents, object: AnyObject? = nil) {
        queue.sync {
            guard let obs = observers[event] else {
                return
            }

            for observer in obs {
                queue.async {
                    observer.value?.handle(event: event, object: object, notificator: self)
                }
            }
        }
    }

    private func hasObserver(_ observer: ObservesEvents, for event: AppEvents) -> Bool {
        queue.sync {
            guard let observers = observers[event] else {
                return false
            }

            return observers.contains(where: { $0.value === observer })
        }
    }
}
