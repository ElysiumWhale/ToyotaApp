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
        modelNameLabel.text = car.car_brand_name + car.car_model_name
        colorNameLabel.text = car.car_color_name
        registrationNumberLabel.text = car.license_plate
        backgroundColor = UIColor(hex: car.color_swatch!) ?? .gray
        
        colorDescr = car.color_description
        metallic = car.color_metallic
        
        showCheckVinView = showCheckView
    }
}
