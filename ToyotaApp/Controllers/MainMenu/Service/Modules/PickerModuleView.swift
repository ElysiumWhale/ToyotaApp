import UIKit

class PickerModuleView: UIView {
    let servicePicker: UIPickerView = UIPickerView()

    private(set) lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = .common(.chooseService)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var textField: NoPasteTextField = {
        let field = NoPasteTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .toyotaType(.light, of: 22)
        field.textColor = .label
        field.textAlignment = .center
        field.tintColor = .clear
        field.cornerRadius = 10
        field.backgroundColor = .appTint(.background)
        return field
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(serviceNameLabel)
        addSubview(textField)
        setupLayout()
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
                case .title(let title):
                    serviceNameLabel.text = title
                case .placeholder(let placeholder):
                    textField.placeholder = placeholder
                default: return
            }
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            serviceNameLabel.topAnchor.constraint(equalTo: topAnchor),
            serviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            serviceNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 45),
            serviceNameLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -10)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool { true }
}
