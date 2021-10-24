import UIKit
import Kingfisher

@IBDesignable class NewsCollectionViewCell: CollectionCell {
    @IBOutlet private var showroomNameLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var newsImage: UIImageView!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    class var identifier: UICollectionView.CollectionCells { .news }
    
    func configure(with news: News) {
        showroomNameLabel.text = news.showroomName
        contentLabel.text = news.content
        titleLabel.text = news.title
        dateLabel.text = DateFormatter.common.string(from: news.date)
        // guard let imageUrl = news.imgUrl else { newsImage.image = nil; return }
        newsImage.kf.indicatorType = .activity
        newsImage.isOpaque = false
        newsImage.kf.setImage(with: ImageResource(downloadURL: news.imgUrl), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)

        configureShadow(with: cornerRadius)
        layer.borderColor = UIColor.appTint(.secondarySignatureRed).cgColor
        layer.borderWidth = 1
    }
}
