import UIKit

final class PickerModuleView: BaseView {
    let picker = UIPickerView()
    let label = UILabel()
    let textField = NoCopyPasteTextField()

    override func addViews() {
        addSubviews(label, textField)
    }

    override func configureLayout() {
        label.edgesToSuperview(excluding: .bottom,
                                          usingSafeArea: true)
        label.bottomToTop(of: textField, offset: -10)

        textField.edgesToSuperview(excluding: .top,
                                   usingSafeArea: true)
        textField.height(45)
    }

    override func configureAppearance() {
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .appTint(.signatureGray)

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
            case .title(let title):
                label.text = title
            case .placeholder(let placeholder):
                textField.placeholder = placeholder
            }
        }
    }
}
