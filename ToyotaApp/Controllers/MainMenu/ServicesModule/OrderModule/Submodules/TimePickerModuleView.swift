import UIKit
import DesignKit

final class TimePickerView: BaseView {
    private let label = UILabel()

    let picker = UIPickerView()

    init(
        delegate: (UIPickerViewDelegate & UIPickerViewDataSource)? = nil,
        alpha: CGFloat = 1
    ) {
        super.init(frame: .zero)

        picker.delegate = delegate
        picker.dataSource = delegate
        self.alpha = alpha
    }

    override func addViews() {
        addSubviews(label, picker)
    }

    override func configureLayout() {
        label.edgesToSuperview(
            excluding: .bottom,
            usingSafeArea: true
        )
        label.bottomToTop(of: picker, offset: -5)

        picker.edgesToSuperview(
            excluding: .top,
            usingSafeArea: true
        )
        picker.height(150)
    }

    override func configureAppearance() {
        label.font = .toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .appTint(.signatureGray)
        label.backgroundColor = .systemBackground
    }

    override func localize() {
        label.text = .common(.chooseDateTime)
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
            case let .title(title):
                label.text = title
            default:
                return
            }
        }
    }

    func dataDidDownload() {
        DispatchQueue.main.async { [weak self] in
            self?.picker.selectRow(0, inComponent: 0, animated: false)
            self?.picker.reloadAllComponents()
            self?.fadeIn()
        }
    }
}
