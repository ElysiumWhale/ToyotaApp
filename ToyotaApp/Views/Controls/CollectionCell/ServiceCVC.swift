import UIKit

@IBDesignable class ServiceCollectionViewCell: CollectionCell {
    @IBOutlet private(set) var serviceName: UILabel!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    class var identifier: UICollectionView.CollectionCells { .service }

    func configure(name: String) {
        serviceName.text = name
        configureShadow(with: cornerRadius)
    }
}
