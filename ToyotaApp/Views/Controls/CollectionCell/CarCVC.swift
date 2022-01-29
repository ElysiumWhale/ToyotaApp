import UIKit

@IBDesignable class CarCollectionViewCell: CollectionCell {
    @IBOutlet private var brandNameLabel: UILabel!
    @IBOutlet private var colorNameLabel: UILabel!
    @IBOutlet private var liscencePlateLabel: UILabel!
    @IBOutlet private var colorDesrLabel: UILabel!
    @IBOutlet private var yearLabel: UILabel!
    @IBOutlet private var checkStatusLabel: UILabel!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    var removeAction: Closure?

    class var identifier: UICollectionView.CollectionCells { .car }

    @IBAction func removeCarTapped(sender: Any?) {
        removeAction?()
    }

    func configure(with car: Car) {
        brandNameLabel.text = car.name
        liscencePlateLabel.text = car.plate.uppercased()
        colorNameLabel.text = "Цвет: \(car.color.name)"
        colorDesrLabel.text = "Описание цвета: \(car.color.colorDescription)"
        yearLabel.text = "Год выпуска: \(car.year)"
        checkStatusLabel.text = car.isChecked ?? false
            ? "Подтверждена"
            : "Не подтверждена"
        checkStatusLabel.textColor = car.isChecked ?? false
            ? .systemGreen
            : .systemRed

        layer.borderColor = UIColor.appTint(.signatureGray).cgColor
        layer.borderWidth = 1
    }
}
