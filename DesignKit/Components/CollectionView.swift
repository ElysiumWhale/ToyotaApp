import UIKit

open class CollectionView<TCell: BaseCollectionCell>: UICollectionView {

    override init(
        frame: CGRect = .zero,
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(frame: frame, collectionViewLayout: layout)

        registerCell(TCell.self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
