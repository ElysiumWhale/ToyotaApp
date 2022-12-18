import UIKit
import DesignKit

final class CarCell: BaseCollectionCell {
    private let brandNameLabel = UILabel()
    private let liscencePlateLabel = UILabel()

    private let colorNameLabel = UILabel()
    private let colorDesrLabel = UILabel()
    private let yearLabel = UILabel()
    private let checkStatusLabel = UILabel()
    private let removeButton = TintedImageButton()

    private var infoLabels: [UILabel] {
        [
            brandNameLabel,
            liscencePlateLabel,
            colorNameLabel,
            colorDesrLabel,
            yearLabel
        ]
    }

    var removeAction: Closure?

    override func addViews() {
        contentView.addSubviews(
            brandNameLabel,
            liscencePlateLabel,
            colorNameLabel,
            colorDesrLabel,
            yearLabel,
            checkStatusLabel,
            removeButton
        )
    }

    override func configureLayout() {
        brandNameLabel.topToSuperview(offset: 12)
        brandNameLabel.height(35, relation: .equalOrGreater)
        liscencePlateLabel.topToBottom(of: brandNameLabel, offset: 5)
        liscencePlateLabel.height(35)

        for label in infoLabels {
            label.horizontalToSuperview(insets: .horizontal(12))
        }

        colorNameLabel.topToBottom(of: liscencePlateLabel, offset: 20)
        colorDesrLabel.topToBottom(of: colorNameLabel, offset: 10)
        yearLabel.topToBottom(of: colorDesrLabel, offset: 10)
        yearLabel.bottomToTop(of: checkStatusLabel, offset: -20)
        colorNameLabel.height(30, relation: .equalOrGreater)
        colorDesrLabel.height(30, relation: .equalOrGreater)
        yearLabel.height(30, relation: .equalOrGreater)

        removeButton.trailingToSuperview(offset: 12)
        removeButton.bottomToSuperview(offset: -12)
        checkStatusLabel.leadingToSuperview(offset: 12)
        checkStatusLabel.bottomToSuperview(offset: -12)
    }

    override func configureAppearance() {
        contentView.backgroundColor = .systemBackground

        for label in infoLabels {
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.backgroundColor = contentView.backgroundColor
        }

        brandNameLabel.textAlignment = .center
        brandNameLabel.font = .toyotaType(.bold, of: 24)
        liscencePlateLabel.textAlignment = .center
        liscencePlateLabel.font = .toyotaType(.bold, of: 24)
        yearLabel.font = .toyotaType(.semibold, of: 20)
        colorNameLabel.font = .toyotaType(.semibold, of: 20)
        colorDesrLabel.font = .toyotaType(.semibold, of: 20)

        removeButton.setImage(.trashFill, for: .normal)
        removeButton.normalTintColor = .appTint(.signatureGray)
        removeButton.highlightedTintColor = .appTint(.secondarySignatureRed)

        checkStatusLabel.font = .toyotaType(.semibold, of: 16)
        // Future
        checkStatusLabel.isHidden = true

        cornerRadius = 20
        borderColor = .appTint(.signatureGray)
        borderWidth = 1

        clipsToBounds = true
    }

    override func configureActions() {
        removeButton.addAction { [weak self] in
            self?.removeAction?()
        }
    }

    func configure(car: Car) {
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
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        borderColor = .appTint(.signatureGray)
    }
}
