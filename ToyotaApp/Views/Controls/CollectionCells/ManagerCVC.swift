import UIKit
import Nuke

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

        let options = ImageLoadingOptions(transition: .fadeIn(duration: 0.6),
                                          failureImage: UIImage(named: "person.fill"),
                                          failureImageTransition: .fadeIn(duration: 0.3))
        Nuke.loadImage(with: url, options: options, into: photo)
    }
}
