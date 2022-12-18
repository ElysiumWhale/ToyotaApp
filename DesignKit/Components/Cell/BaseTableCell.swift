import UIKit

open class BaseTableCell: UITableViewCell, InitialazableView {
    override public init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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
}
