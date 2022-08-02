import UIKit

final class TimePickerView: BaseView {
    let datePicker = UIPickerView()

    let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = .common(.chooseDateTime)
        return label
    }()

    override class var requiresConstraintBasedLayout: Bool {
        true
    }

    override func addViews() {
        addSubviews(dateTimeLabel, datePicker)
    }

    override func configureLayout() {
        dateTimeLabel.edgesToSuperview(excluding: .bottom,
                                       usingSafeArea: true)
        dateTimeLabel.bottomToTop(of: datePicker, offset: -5)

        datePicker.edgesToSuperview(excluding: .top, usingSafeArea: true)
        datePicker.height(150)
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
            case .title(let title):
                dateTimeLabel.text = title
            default:
                return
            }
        }
    }

    func dataDidDownload() {
        DispatchQueue.main.async { [weak self] in
            self?.datePicker.selectRow(0, inComponent: 0, animated: false)
            self?.datePicker.reloadAllComponents()
            self?.fadeIn()
        }
    }
}
