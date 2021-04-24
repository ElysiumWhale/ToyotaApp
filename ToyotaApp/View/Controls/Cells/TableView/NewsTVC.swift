import UIKit
import Kingfisher

@IBDesignable class NewsTableViewCell: UITableViewCell {
    @IBOutlet private var showroomNameLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var newsImage: UIImageView!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    func configure(with news: News) {
        showroomNameLabel.text = news.showroomName
        contentLabel.text = news.content
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        let dateString = dateFormatter.string(from: news.date)
        titleLabel.text = news.title
        dateLabel.text = dateString
        //guard let imageUrl = news.imgUrl else { newsImage.image = nil; return }
        let resource = ImageResource(downloadURL: news.imgUrl)
        newsImage.kf.indicatorType = .activity
        newsImage.isOpaque = false
        newsImage.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
    }
}
