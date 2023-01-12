import UIKit
import DesignKit

final class PickerModuleView: BaseView {
    let picker = UIPickerView()
    let label = UILabel()
    let textField = NoCopyPasteTextField(.toyota(tintColor: .clear))

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
