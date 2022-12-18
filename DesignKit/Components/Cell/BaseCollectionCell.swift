import UIKit

open class BaseCollectionCell: UICollectionViewCell, InitialazableView {
    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    open func addViews() {
        // override in subclasses
    }

    open func configureLayout() {
        // override in subclasses
    }

    open func configureAppearance() {
        // override in subclasses
    }

    open func localize() {
        // override in subclasses
    }

    open func configureActions() {
        // override in subclasses
    }
}
