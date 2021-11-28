import UIKit
import Kingfisher

@IBDesignable class ManagerCollectionViewCell: CollectionCell {
    @IBOutlet private var showroomLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var photo: UIImageView!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    class var identifier: UICollectionView.CollectionCells { .manager }

    func configure(from manager: Manager) {
        showroomLabel.text = manager.showroomName
        nameLabel.text = "\(manager.firstName) \(manager.lastName)"
        infoLabel.text = "\(manager.phone) \(manager.email)"
        configureShadow(with: cornerRadius)

        guard !manager.imageUrl.isEmpty,
              let url = NetworkService.buildImageUrl(manager.imageUrl) else {
                  return
              }

        photo.kf.indicatorType = .activity
        photo.isOpaque = false
        photo.kf.setImage(with: ImageResource(downloadURL: url),
                          placeholder: UIImage(named: "person.fill"),
                          options: [.transition(.fade(0.7))], progressBlock: nil)
    }
}
