import UIKit

open class BaseView: UIView, InitialazableView {

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
