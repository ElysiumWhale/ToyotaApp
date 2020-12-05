import UIKit

protocol RoundedControl {
    var rounded: Bool { get set }
    var cornerRadius: CGFloat { get set }
    func updateCornerRadius()
}

@IBDesignable class CarChoosingCell: UICollectionViewCell, RoundedControl {
    
    private(set) var cellCar: Car?
    @IBOutlet var modelNameLabel: UILabel!
    @IBOutlet var colorNameLabel: UILabel!
    @IBOutlet var registrationNumberLabel: UILabel!
    
    private var colorName: String?
    private var colorDescr: String?
    private var metallic: String?
    
    private var showCheckVinView: ((UICollectionViewCell) -> Void)?
    
    @IBAction private func didCheckVinPress(sender: Any?) { showCheckVinView!(self) }
    
    @IBInspectable var rounded: Bool = false {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 15
    
    func updateCornerRadius() { layer.cornerRadius = rounded ? cornerRadius : 0 }
    
    func configureCell(car: Car, showCheckView: ((UICollectionViewCell) -> Void)? = {_ in }) {
        cellCar = car
        modelNameLabel.text = car.brandName + car.modelName
        colorNameLabel.text = car.colorName
        registrationNumberLabel.text = car.licensePlate
        backgroundColor = UIColor(hex: car.colorSwatch!) ?? .gray
        
        colorDescr = car.colorDescription
        metallic = car.isMetallic
        
        showCheckVinView = showCheckView
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
    }
}
