import UIKit
import DesignKit
import TinyConstraints
import Nuke

final class NewsCell: BaseTableCell {
    private let titleLabel = UILabel()
    private let newsImage = UIImageView()

    override func addViews() {
        addSubviews(titleLabel, newsImage)
    }

    override func configureLayout() {
        newsImage.horizontalToSuperview(insets: .horizontal(16))
        newsImage.topToSuperview(offset: 10)
        newsImage.bottomToTop(of: titleLabel)
        newsImage.height(160)
        newsImage.clipsToBounds = true

        titleLabel.horizontalToSuperview(insets: .horizontal(16))
        titleLabel.bottomToSuperview(offset: -10)
    }

    override func configureAppearance() {
        titleLabel.font = .toyotaType(.regular, of: 17)
        titleLabel.textColor = .appTint(.signatureGray)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 3

        newsImage.contentMode = .scaleAspectFill
    }

    func configure(with news: News) {
        titleLabel.text = news.title

        guard let url = news.imgUrl else {
            return
        }

        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.6),
            failureImage: nil,
            failureImageTransition: .fadeIn(duration: 0.3)
        )
        Nuke.loadImage(with: url, options: options, into: newsImage)
    }
}
