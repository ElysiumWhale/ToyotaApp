import UIKit

@IBDesignable class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private(set) var serviceName: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    func configure(with label: String) {
        serviceName.text = label
    }
}
