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
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 3.5
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
