import UIKit
import NukeUI
import DesignKit
import TinyConstraints

final class NewsCell: BaseTableCell {
    private let titleLabel = UILabel()
    private let newsImage = LazyImageView()

    override func addViews() {
        contentView.addSubviews(titleLabel, newsImage)
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
}

// MARK: - State rendering
extension NewsCell {
    struct ViewState {
        let title: String
        let url: URL?
    }

    func render(_ viewState: ViewState) {
        titleLabel.text = viewState.title

        guard let url = viewState.url else {
            return
        }

        newsImage.transition = .fadeIn(duration: 0.6)
        newsImage.failureImage = nil
        newsImage.url = url
    }
}
