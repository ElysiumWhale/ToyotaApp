import UIKit
import DesignKit
import NukeUI

final class ManagerCell: BaseCollectionCell {
    private let showroomLabel = UILabel()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    private let photoView = LazyImageView()

    override func addViews() {
        contentView.addSubviews(
            showroomLabel,
            nameLabel,
            infoLabel,
            photoView
        )
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
        contentView.backgroundColor = .appTint(.background)
        cornerRadius = 15
        clipsToBounds = true

        photoView.contentMode = .scaleAspectFit
        photoView.tintColor = .appTint(.secondarySignatureRed)
        showroomLabel.font = .toyotaType(.semibold, of: 20)
        showroomLabel.textColor = .appTint(.secondarySignatureRed)
        showroomLabel.textAlignment = .center
        showroomLabel.backgroundColor = contentView.backgroundColor

        for label in [nameLabel, infoLabel] {
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .toyotaType(.semibold, of: 20)
            label.textColor = .appTint(.signatureGray)
            label.textAlignment = .center
            label.backgroundColor = contentView.backgroundColor
        }
    }
}

// MARK: - State rendering
extension ManagerCell {
    struct ViewState {
        let manager: Manager
        let photoUrl: URL?
    }

    func render(_ viewState: ViewState) {
        let manager = viewState.manager

        showroomLabel.text = manager.showroomName
        nameLabel.text = "\(manager.firstName) \(manager.lastName)"
        infoLabel.text = "\(manager.phone) \(manager.email)"

        guard let url = viewState.photoUrl else {
            return
        }

        photoView.transition = .fadeIn(duration: 0.6)
        photoView.failureImage = .personFill
        photoView.url = url
    }
}
