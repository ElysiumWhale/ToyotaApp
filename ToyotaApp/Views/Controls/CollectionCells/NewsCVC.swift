import UIKit
import Nuke

@IBDesignable class NewsCollectionViewCell: CollectionCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var newsImage: UIImageView!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    class var identifier: UICollectionView.CollectionCells { .news }

    func configure(with news: News) {
        titleLabel.text = news.title
        configureShadow(with: cornerRadius)

        guard let url = news.imgUrl else {
            return
        }

        let options = ImageLoadingOptions(transition: .fadeIn(duration: 0.6),
                                          failureImage: nil,
                                          failureImageTransition: .fadeIn(duration: 0.3))
        Nuke.loadImage(with: url, options: options, into: newsImage)
    }
}
