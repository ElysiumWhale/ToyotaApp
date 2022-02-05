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

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(dateTimeLabel)
        addSubview(datePicker)
        setupLayout()
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
                case .title(let title):
                    dateTimeLabel.text = title
                default: return
            }
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateTimeLabel.topAnchor.constraint(equalTo: topAnchor),
            dateTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
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
