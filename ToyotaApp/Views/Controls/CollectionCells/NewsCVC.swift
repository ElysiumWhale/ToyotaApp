import UIKit
//import Kingfisher

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

        //newsImage.kf.indicatorType = .activity
        //newsImage.isOpaque = false
//        newsImage.kf.setImage(with: ImageResource(downloadURL: url),
//                              placeholder: nil,
//                              options: [.transition(.fade(0.7))],
//                              progressBlock: nil)
    }
}
