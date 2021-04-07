import UIKit

@IBDesignable class CarCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var brandNameLabel: UILabel!
    @IBOutlet private var colorNameLabel: UILabel!
    @IBOutlet private var liscencePlateLabel: UILabel!
    @IBOutlet private var colorDesrLabel: UILabel!
    @IBOutlet private var vinTextLabel: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    func configure(brand: String, model: String, color: String, plate: String, colorDesription: String, vin: String) {
        brandNameLabel.text = "\(brand) \(model)"
        colorNameLabel.text = "Цвет: \(color)"
        liscencePlateLabel.text = plate.uppercased()
        colorDesrLabel.text = "Описание цвета: \(colorDesription)"
        vinTextLabel.text =  "VIN: \(vin.map { _ in "*" }.joined())"
        configureShadow(with: cornerRadius)
    }
}
