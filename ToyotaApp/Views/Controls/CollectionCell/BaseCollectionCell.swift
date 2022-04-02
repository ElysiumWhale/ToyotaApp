import UIKit

class BaseCollectionCell: UICollectionViewCell, InitialazableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    func addViews() {
        // override in subclasses
    }

    func configureLayout() {
        // override in subclasses
    }

    func configureAppearance() {
        // override in subclasses
    }

    func localize() {
        // override in subclasses
    }
}
