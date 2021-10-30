import UIKit

@IBDesignable class ServiceCollectionViewCell: CollectionCell {
    @IBOutlet private var serviceName: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    private(set) var controllerType: ControllerServiceType!
    
    class var identifier: UICollectionView.CollectionCells { .service }
    
    func configure(name: String, type: ControllerServiceType) {
        serviceName.text = name
        controllerType = type
        configureShadow(with: cornerRadius)
    }
}
