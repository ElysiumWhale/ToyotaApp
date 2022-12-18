import UIKit
import DesignKit

final class CityCell: BaseTableCell {
    private let cityNameLabel = UILabel()

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if !highlighted {
            contentView.backgroundColor = .appTint(.background)
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.contentView.backgroundColor = .appTint(.secondarySignatureRed)
            }
        )
    }

    override func addViews() {
        contentView.addSubview(cityNameLabel)
    }

    override func configureLayout() {
        cityNameLabel.edgesToSuperview()
    }

    override func configureAppearance() {
        cityNameLabel.textColor = .appTint(.signatureGray)
        cityNameLabel.font = .toyotaType(.regular, of: 18)
    }
}
