import UIKit

@IBDesignable class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private(set) var serviceName: UILabel!
    
    private(set) var serviceType: ServicesControllers!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    func configure(with label: String, type: ServicesControllers) {
        serviceName.text = label
        serviceType = type
    }
}
