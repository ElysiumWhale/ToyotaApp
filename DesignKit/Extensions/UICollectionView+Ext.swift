import UIKit

public extension UICollectionView {
    convenience init(layout: UICollectionViewLayout) {
        self.init(frame: .zero, collectionViewLayout: layout)
    }

    func setBackground(_ config: BackgroundConfig = .empty) {
        backgroundView = createBackground(config)
    }

    func registerCell(_ cellClass: UICollectionViewCell.Type) {
        register(
            cellClass,
            forCellWithReuseIdentifier: String(describing: cellClass)
        )
    }

    func dequeue<TCell: UICollectionViewCell>(for indexPath: IndexPath) -> TCell {
        let id = String(describing: TCell.self)
        guard let cell = dequeueReusableCell(withReuseIdentifier: id,
                                             for: indexPath) as? TCell else {
            assertionFailure("Can't dequeue cell.")
            return TCell()
        }

        return cell
    }

    func change<TCell: UICollectionViewCell>(
        _ cellType: TCell.Type,
        at indexPath: IndexPath,
        _ changeAction: @escaping (TCell) -> Void
    ) {

        guard let cell = cellForItem(at: indexPath) as? TCell else {
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            changeAction(cell)
        }
    }
}
