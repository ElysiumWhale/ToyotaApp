import UIKit

extension UIImage {
    static var toyotaLogo: UIImage {
        #imageLiteral(resourceName: "ToyotaLogo")
    }

    static var newspaper: UIImage {
        UIImage(systemName: "newspaper",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var fillNewspaper: UIImage {
        UIImage(systemName: "newspaper.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var bookmark: UIImage {
        UIImage(systemName: "bookmark",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var fillBookmark: UIImage {
        UIImage(systemName: "bookmark.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var person: UIImage {
        UIImage(systemName: "person",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var fillPerson: UIImage {
        UIImage(systemName: "person.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var chat: UIImage {
        UIImage(systemName: "text.bubble.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var send: UIImage {
        UIImage(systemName: "arrow.up.square.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var timeDone: UIImage {
        UIImage(systemName: "clock.badge.checkmark.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))!
    }

    static var timeAlert: UIImage {
        UIImage(systemName: "clock.badge.exclamationmark.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))!
    }

    static var statusCirle: UIImage {
        UIImage(systemName: "circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))!
    }

    static var personFill: UIImage {
        UIImage(systemName: "person.fill",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var trashFill: UIImage {
        UIImage(systemName: "trash.fill",
                withConfiguration: SymbolConfiguration(scale: .large))!
    }

    static var settings: UIImage {
        UIImage(systemName: "gearshape",
                withConfiguration: SymbolConfiguration(scale: .large))!
    }

    static var logout: UIImage {
        UIImage(systemName: "rectangle.righthalf.inset.fill.arrow.right",
                withConfiguration: SymbolConfiguration(scale: .large))!
    }

    static var bookings: UIImage {
        UIImage(systemName: "archivebox",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }

    static var car: UIImage {
        UIImage(systemName: "car",
                withConfiguration: SymbolConfiguration(scale: .medium))!
    }
}
