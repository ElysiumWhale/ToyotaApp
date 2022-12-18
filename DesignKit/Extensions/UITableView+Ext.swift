import UIKit

public extension UITableView {
    func setBackground(_ config: BackgroundConfig = .empty) {
        backgroundView = createBackground(config)
    }

    func registerCell(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    func dequeue<TCell: UITableViewCell>(for indexPath: IndexPath) -> TCell {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: TCell.self),
                                             for: indexPath) as? TCell else {
            assertionFailure("Can't dequeue cell.")
            return TCell()
        }

        return cell
    }
}
