import UIKit

class BaseTableCell: UITableViewCell, InitialazableView {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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
