import UIKit

class BaseView: UIView, InitialazableView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func configureActions() {
        // override in subclasses
    }
}
