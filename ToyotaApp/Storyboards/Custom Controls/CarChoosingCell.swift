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
    
    private var checkVin: ((UICollectionViewCell) -> Void)?
    
    @IBAction private func didCheckVinPress(sender: Any?) { checkVin!(self) }
    
    @IBInspectable var rounded: Bool = false {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 15
    
    func updateCornerRadius() { layer.cornerRadius = rounded ? cornerRadius : 0 }
    
    func configureCell(car: Car, checkVinFunc: ((UICollectionViewCell) -> Void)? = {_ in }) {
        cellCar = car
        modelNameLabel.text = car.brand_name + car.model_name
        colorNameLabel.text = car.color_name
        registrationNumberLabel.text = car.license_plate
        backgroundColor = hexStringToUIColor(hex: car.color_swatch!)
        
        colorDescr = car.color_description
        metallic = car.color_metallic
        
        checkVin = checkVinFunc
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
