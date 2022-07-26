import UIKit

final class CityCell: UITableViewCell, InitialazableView {
    private let cityNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if !highlighted {
            contentView.backgroundColor = .appTint(.background)
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                       delay: 0.0,
                                                       options: .curveEaseOut,
                                                       animations: {
            self.contentView.backgroundColor = .appTint(.secondarySignatureRed)
        })
    }

    func addViews() {
        contentView.addSubview(cityNameLabel)
    }

    func configureLayout() {
        cityNameLabel.edgesToSuperview()
    }

    func configureAppearance() {
        cityNameLabel.textColor = .appTint(.signatureGray)
        cityNameLabel.font = .toyotaType(.regular, of: 18)
    }
}
