import UIKit
import TinyConstraints
import DesignKit

final class ServiceTypeCell: BaseCollectionCell {
    let typeNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .toyotaType(.semibold, of: 17)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .appTint(.signatureGray)
        return label
    }()

    override func addViews() {
        addSubview(typeNameLabel)
    }

    override func configureLayout() {
        typeNameLabel.edgesToSuperview(insets: .uniform(16))

        layer.cornerRadius = 8
        configureShadow(with: 8)
        backgroundColor = .appTint(.cell)
    }

    func configure(name: String) {
        typeNameLabel.text = name.firstCapitalized
    }
}
