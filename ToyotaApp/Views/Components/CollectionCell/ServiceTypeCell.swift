import UIKit
import TinyConstraints
import DesignKit

final class ServiceTypeCell: BaseCollectionCell {
    private let typeNameLabel = UILabel()

    override func addViews() {
        contentView.addSubview(typeNameLabel)
    }

    override func configureLayout() {
        typeNameLabel.edgesToSuperview(insets: .uniform(16))

        layer.cornerRadius = 8
        configureShadow(with: 8)
        clipsToBounds = true
    }

    override func configureAppearance() {
        contentView.backgroundColor = .appTint(.cell)
        typeNameLabel.layer.backgroundColor = contentView.backgroundColor?.cgColor
        typeNameLabel.numberOfLines = 2
        typeNameLabel.font = .toyotaType(.semibold, of: 17)
        typeNameLabel.lineBreakMode = .byWordWrapping
        typeNameLabel.textAlignment = .center
        typeNameLabel.textColor = .appTint(.signatureGray)
    }

    func configure(name: String) {
        typeNameLabel.text = name.firstCapitalized
    }
}

// MARK: - State rendering
extension ServiceTypeCell {
    struct ViewState {
        let backgroundColor: UIColor
        let textColor: UIColor
    }

    func render(_ viewState: ViewState) {
        contentView.backgroundColor = viewState.backgroundColor
        typeNameLabel.textColor = viewState.textColor
        typeNameLabel.layer.backgroundColor = viewState.backgroundColor.cgColor
    }
}
