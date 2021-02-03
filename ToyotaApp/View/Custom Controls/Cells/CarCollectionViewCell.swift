import UIKit

class CarCollectionViewCell: UICollectionViewCell {
    @IBOutlet private(set) var brandNameLabel: UILabel!
    @IBOutlet private(set) var colorNameLabel: UILabel!
    @IBOutlet private(set) var liscencePlateLabel: UILabel!
    @IBOutlet private(set) var colorDesrLabel: UILabel!
    @IBOutlet private(set) var vinTextLabel: UILabel!
    
    func configure(brand: String, model: String, color: String, plate: String, colorDesription: String, vin: String) {
        brandNameLabel.text = "\(brand) \(model)"
        colorNameLabel.text = color
        liscencePlateLabel.text = plate
        colorDesrLabel.text = colorDesription
        vinTextLabel.text = vin
    }
}
