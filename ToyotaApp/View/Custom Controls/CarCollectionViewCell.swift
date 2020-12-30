import UIKit

class CarCollectionViewCell: UICollectionViewCell {
    @IBOutlet private(set) var brandNameTextField: UILabel!
    @IBOutlet private(set) var colorNameTextField: UILabel!
    @IBOutlet private(set) var liscencePlateTextField: UILabel!
    @IBOutlet private(set) var colorDesrTextField: UILabel!
    @IBOutlet private(set) var vinTextField: UILabel!
    
    func configure(brand: String, model: String, color: String, plate: String, colorDesription: String, vin: String) {
        brandNameTextField.text = "\(brand) \(model)"
        colorNameTextField.text = color
        liscencePlateTextField.text = plate
        colorDesrTextField.text = colorDesription
        vinTextField.text = vin
    }
}
