import UIKit

class PickerModuleView: UIView {
    private(set) var servicePicker: UIPickerView = UIPickerView()

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
        field.borderStyle = .roundedRect
        return field
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
    }

    private func configureSubviews() {
        addSubview(serviceNameLabel)
        addSubview(textField)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            serviceNameLabel.topAnchor.constraint(equalTo: topAnchor),
            serviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            serviceNameLabel.leadingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.leadingAnchor.constraint(equalTo: trailingAnchor),
            textField.widthAnchor.constraint(equalTo: widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: 45),
            serviceNameLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -10)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool { true }
}
