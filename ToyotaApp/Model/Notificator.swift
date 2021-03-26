import Foundation

protocol Notificator {
    func add(observer: WithUserInfo)
    func remove(obsever: WithUserInfo)
    func notificateObservers()
}

class NotificationCentre: Notificator {
    
    private var observers: [ObjectIdentifier : Observer] = [:]
    
    func add(observer: WithUserInfo) {
        let id = ObjectIdentifier(observer)
        observers[id] = Observer(value: observer)
    }
    
    func remove(obsever: WithUserInfo) {
        observers.removeValue(forKey: ObjectIdentifier(obsever))
    }
    
    func notificateObservers() {
        for (id, observer) in observers {
            guard let observer = observer.value else {
                observers.removeValue(forKey: id)
                continue
            }
            
            observer.userDidUpdate()
        }
    }
}

extension NotificationCentre {
    struct Observer {
        weak var value: WithUserInfo?
    }
}
