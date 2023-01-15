import UIKit

extension UIImage {
    private static func image(
        name: String,
        scale: UIImage.SymbolScale
    ) -> UIImage {
        UIImage(
            systemName: name,
            withConfiguration: SymbolConfiguration(scale: scale)
        )!.withRenderingMode(.automatic)
    }

    static var toyotaLogo: UIImage {
        #imageLiteral(resourceName: "ToyotaLogo")
    }

    static var newspaper: UIImage {
        image(name: "newspaper", scale: .medium)
    }

    static var fillNewspaper: UIImage {
        image(name: "newspaper.fill", scale: .medium)
    }

    static var bookmark: UIImage {
        image(name: "bookmark", scale: .medium)
    }

    static var fillBookmark: UIImage {
        image(name: "bookmark.fill", scale: .medium)
    }

    static var person: UIImage {
        image(name: "person", scale: .medium)
    }

    static var fillPerson: UIImage {
        image(name: "person.fill", scale: .medium)
    }

    static var chat: UIImage {
        image(name: "text.bubble.fill", scale: .medium)
    }

    static var send: UIImage {
        image(name: "arrow.up.square.fill", scale: .medium)
    }

    static var timeDone: UIImage {
        image(name: "clock.badge.checkmark.fill", scale: .small)
    }

    static var timeAlert: UIImage {
        image(name: "clock.badge.exclamationmark.fill", scale: .small)
    }

    static var statusCircle: UIImage {
        image(name: "circle.fill", scale: .small)
    }

    static var personFill: UIImage {
        image(name: "person.fill", scale: .medium)
    }

    static var trashFill: UIImage {
        image(name: "trash.fill", scale: .large)
    }

    static var settings: UIImage {
        image(name: "gearshape", scale: .large)
    }

    static var logout: UIImage {
        image(name: "rectangle.righthalf.inset.fill.arrow.right",
              scale: .large)
    }

    static var bookings: UIImage {
        image(name: "archivebox", scale: .medium)
    }

    static var car: UIImage {
        image(name: "car", scale: .medium)
    }

    static var chevronRight: UIImage {
        image(name: "chevron.right", scale: .default)
    }

    static var chevronDown: UIImage {
        image(name: "chevron.down", scale: .large)
    }
}
