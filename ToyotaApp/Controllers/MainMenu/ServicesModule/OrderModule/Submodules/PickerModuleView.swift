import UIKit
import DesignKit

final class PickerModuleView: BaseView {
    let picker = UIPickerView()
    let label = UILabel()
    let textField = NoCopyPasteTextField()

    override func addViews() {
        addSubviews(label, textField)
    }

    override func configureLayout() {
        label.bottomToTop(of: textField, offset: -10)
        label.edgesToSuperview(
            excluding: .bottom,
            usingSafeArea: true
        )

        textField.height(45)
        textField.edgesToSuperview(
            excluding: .top,
            usingSafeArea: true
        )
    }

    override func configureAppearance() {
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .appTint(.signatureGray)
        label.backgroundColor = .systemBackground

        textField.font = .toyotaType(.light, of: 22)
        textField.textColor = .appTint(.signatureGray)
        textField.textAlignment = .center
        textField.tintColor = .clear
        textField.cornerRadius = 10
        textField.backgroundColor = .appTint(.background)
    }

    override func localize() {
        label.text = .common(.chooseService)
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
            case let .title(title):
                label.text = title
            case let .placeholder(placeholder):
                textField.placeholder = placeholder
            }
        }
    }
}
