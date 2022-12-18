import UIKit
import DesignKit
import NukeUI

final class ManagerCell: BaseCollectionCell {
    private let showroomLabel = UILabel()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    private let photoView = LazyImageView()

    override func addViews() {
        contentView.addSubviews(showroomLabel, nameLabel, infoLabel, photoView)
    }

    override func configureLayout() {
        showroomLabel.edgesToSuperview(excluding: .bottom, insets: .uniform(5))
        photoView.centerXToSuperview()
        photoView.topToBottom(of: showroomLabel, offset: 10)
        photoView.size(.init(width: 120, height: 120))
        nameLabel.horizontalToSuperview(insets: .horizontal(10))
        nameLabel.topToBottom(of: photoView, offset: 10)
        nameLabel.height(50, relation: .equalOrGreater)
        infoLabel.topToBottom(of: nameLabel, offset: 10)
        infoLabel.horizontalToSuperview(insets: .horizontal(10))
        infoLabel.bottomToSuperview(offset: -10)
        infoLabel.height(50, relation: .equalOrGreater)
    }

    override func configureAppearance() {
        photoView.contentMode = .scaleAspectFit
        photoView.tintColor = .appTint(.secondarySignatureRed)
        showroomLabel.font = .toyotaType(.semibold, of: 20)
        showroomLabel.textColor = .appTint(.secondarySignatureRed)
        showroomLabel.textAlignment = .center

        for label in [nameLabel, infoLabel] {
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .toyotaType(.semibold, of: 20)
            label.textColor = .appTint(.signatureGray)
            label.textAlignment = .center
        }

        contentView.backgroundColor = .appTint(.background)
        contentView.layer.cornerRadius = 15
    }

    func configure(from manager: Manager) {
        showroomLabel.text = manager.showroomName
        nameLabel.text = "\(manager.firstName) \(manager.lastName)"
        infoLabel.text = "\(manager.phone) \(manager.email)"

        guard manager.imageUrl.isNotEmpty,
              let url = NetworkService.buildImageUrl(manager.imageUrl) else {
                  return
              }

        photoView.transition = .fadeIn(duration: 0.6)
        photoView.failureImage = .personFill
        photoView.url = url
    }
}
