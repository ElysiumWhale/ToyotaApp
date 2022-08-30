import UIKit

final class PickerModuleView: BaseView {
    let servicePicker: UIPickerView = UIPickerView()

    let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = .common(.chooseService)
        return label
    }()

    let textField: NoCopyPasteTextField = {
        let field = NoCopyPasteTextField()
        field.font = .toyotaType(.light, of: 22)
        field.textColor = .label
        field.textAlignment = .center
        field.tintColor = .clear
        field.cornerRadius = 10
        field.backgroundColor = .appTint(.background)
        return field
    }()

    override class var requiresConstraintBasedLayout: Bool {
        true
    }

    override func addViews() {
        addSubviews(serviceNameLabel, textField)
    }

    override func configureLayout() {
        serviceNameLabel.edgesToSuperview(excluding: .bottom,
                                          usingSafeArea: true)
        serviceNameLabel.bottomToTop(of: textField, offset: -10)

        textField.edgesToSuperview(excluding: .top,
                                   usingSafeArea: true)
        textField.height(45)
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
            case .title(let title):
                serviceNameLabel.text = title
            case .placeholder(let placeholder):
                textField.placeholder = placeholder
            default:
                return
            }
        }
    }
}
