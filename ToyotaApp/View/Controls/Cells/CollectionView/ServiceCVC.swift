import UIKit

@IBDesignable class ServiceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var serviceName: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    private(set) var serviceType: ServicesControllers!
    
    func configure(with label: String, type: ServicesControllers) {
        serviceName.text = label
        serviceType = type
        configureShadow(with: cornerRadius)
    }
}
