import UIKit

protocol InitialazableView {
    func addViews()
    func configureLayout()
    func configureAppearance()
    func localize()
    func configureActions()
}

extension InitialazableView {
    func initialize() {
        addViews()
        configureLayout()
        configureAppearance()
        localize()
        configureActions()
    }

    func addViews() { }

    func configureLayout() { }

    func configureAppearance() { }

    func localize() { }

    func configureActions() { }
}

// MARK: - Identifiable cells
typealias CollectionCell = IdentifiableCollectionCell & UICollectionViewCell

protocol IdentifiableCollectionCell: UICollectionViewCell {
    static var identifier: UICollectionView.CollectionCells { get }
}
