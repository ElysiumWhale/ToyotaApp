import UIKit

extension UIImage {
    static var toyotaLogo: UIImage {
        UIImage(imageLiteralResourceName: "ToyotaLogo")
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
}
