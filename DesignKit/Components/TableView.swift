import UIKit

open class TableView<TCell: BaseTableCell>: UITableView {

    override public init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)

        registerCell(TCell.self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
