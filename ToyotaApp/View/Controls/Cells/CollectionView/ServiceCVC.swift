import UIKit

@IBDesignable class ServiceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var serviceName: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    private(set) var serviceType: ServicesControllers!
    
    private(set) var controllerType: ControllerServiceType!
    
    func configure(with label: String, type: ServicesControllers) {
        serviceName.text = label
        serviceType = type
        configureShadow(with: cornerRadius)
    }
    
    func configure(name: String, type: ControllerServiceType) {
        serviceName.text = name
        controllerType = type
        configureShadow(with: cornerRadius)
    }
}
