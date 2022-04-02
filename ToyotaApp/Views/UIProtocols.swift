import UIKit

protocol InitialazableView: UIView {
    func addViews()
    func configureLayout()
    func configureAppearance()
    func localize()
}

extension InitialazableView {
    func initialize() {
        addViews()
        configureLayout()
        configureAppearance()
        localize()
    }

    func addViews() { }

    func configureLayout() { }

    func configureAppearance() { }

    func localize() { }
}

enum Storyboards: String {
    case main = "Main"
    case launchScreen = "LaunchScreen"
    case auth = "Authentification"
    case register = "FirstLaunchRegistration"
    case mainMenu = "MainMenu"
}

// MARK: - Identifiable cells
typealias TableCell = IdentifiableTableCell & UITableViewCell

typealias CollectionCell = IdentifiableCollectionCell & UICollectionViewCell

protocol IdentifiableTableCell: UITableViewCell {
    static var identifier: UITableView.TableCells { get }
}

protocol IdentifiableCollectionCell: UICollectionViewCell {
    static var identifier: UICollectionView.CollectionCells { get }
}
