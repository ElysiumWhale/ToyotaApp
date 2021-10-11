import UIKit

@IBDesignable class CarCollectionViewCell: CollectionCell {
    @IBOutlet private var brandNameLabel: UILabel!
    @IBOutlet private var colorNameLabel: UILabel!
    @IBOutlet private var liscencePlateLabel: UILabel!
    @IBOutlet private var colorDesrLabel: UILabel!
    @IBOutlet private var showroomName: UILabel!
    @IBOutlet private var carImage: UIImageView!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    var removeAction: VoidClosure?
    
    class var identifier: UICollectionView.CollectionCells { .car }
    
    @IBAction func removeCarTapped(sender: Any?) {
        removeAction?()
    }
    
    func configure(brand: String, model: String, color: String,
                   plate: String, colorDesription: String, showroom: String) {
        brandNameLabel.text = "\(brand) \(model)"
        colorNameLabel.text = "Цвет: \(color)"
        liscencePlateLabel.text = plate.uppercased()
        colorDesrLabel.text = "Описание: \(colorDesription)"
        showroomName.text =  "Салон: \(showroom)"
        configureShadow(with: cornerRadius)
        carImage.layer.borderWidth = 1
        carImage.layer.masksToBounds = false
        carImage.layer.borderColor = UIColor.appTint(.mainRed).cgColor
        carImage.layer.cornerRadius = carImage.frame.height/2
        carImage.clipsToBounds = true
    }
}
