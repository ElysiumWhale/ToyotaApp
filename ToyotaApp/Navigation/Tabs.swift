import UIKit

private typealias TabConfiguration = Tabs.TabConfiguration

enum Tabs {
    case news
    case services
    case profile

    struct TabConfiguration: Hashable {
        let tabTitle: String
        let image: UIImage
        let selectedImage: UIImage
        let navTitle: String
    }

    var configuration: TabConfiguration {
        switch self {
        case .news:
            return .newsConfiguration
        case .profile:
            return .profileTabConfiguration
        case .services:
            return .servicesConfiguration
        }
    }
}

// MARK: - Configurations
private extension TabConfiguration {
    static var newsConfiguration: TabConfiguration {
        TabConfiguration(
            tabTitle: .common(.offers),
            image: .newspaper,
            selectedImage: .fillNewspaper,
            navTitle: .common(.offers)
        )
    }

    static var servicesConfiguration: TabConfiguration {
        TabConfiguration(
            tabTitle: .common(.services),
            image: .bookmark,
            selectedImage: .fillBookmark,
            navTitle: .common(.services)
        )
    }

    static var profileTabConfiguration: TabConfiguration {
        TabConfiguration(
            tabTitle: .common(.profile),
            image: .person,
            selectedImage: .fillPerson,
            navTitle: .common(.profile)
        )
    }
}
