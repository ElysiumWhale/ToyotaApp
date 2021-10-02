import UIKit

class TimePickerView: UIView {
    private(set) lazy var datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private(set) lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = .common(.chooseDateTime)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubview(dateTimeLabel)
        addSubview(datePicker)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateTimeLabel.topAnchor.constraint(equalTo: topAnchor),
            dateTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateTimeLabel.leadingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.leadingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.widthAnchor.constraint(equalTo: widthAnchor, constant: 0),
            datePicker.heightAnchor.constraint(equalToConstant: 150),
            dateTimeLabel.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -5)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    func dataDidDownload() {
        DispatchQueue.main.async { [weak self] in
            self?.datePicker.selectRow(0, inComponent: 0, animated: false)
            self?.datePicker.reloadAllComponents()
            self?.fadeIn()
        }
    }
}
