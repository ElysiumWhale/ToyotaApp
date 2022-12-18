import UIKit
import DesignKit

final class TimeView: BaseView {
    private let timeLabel = UILabel()
    private let timeImage = UIImageView()

    override func addViews() {
        addSubviews(timeImage, timeLabel)
    }

    override func configureLayout() {
        timeImage.leadingToSuperview(offset: 5)
        timeLabel.trailingToSuperview(offset: 5)
        timeLabel.leadingToTrailing(of: timeImage, offset: 5)
        timeLabel.topToSuperview()
        timeLabel.bottomToSuperview(offset: -2)
        timeImage.verticalToSuperview()
    }

    override func configureAppearance() {
        layer.cornerRadius = 5
        backgroundColor = .systemGroupedBackground

        timeLabel.textColor = .appTint(.signatureGray)
        timeLabel.font = .toyotaType(.regular, of: 16)
    }
}

// MARK: - Configuration with ViewModel
extension TimeView {
    struct ViewModel {
        let dateComponents: DateComponents?
        let status: Booking.BookingStatus
        let date: Date
    }

    func configure(with viewModel: ViewModel) {
        if let text = viewModel.dateComponents?.hourAndMinute {
            timeLabel.text = text
            let (image, color) = timeAppearance(for: viewModel)
            timeImage.image = image
            timeImage.tintColor = color
            isHidden = false
        } else {
            isHidden = true
        }
    }

    private func timeAppearance(for viewModel: ViewModel) -> (UIImage, UIColor) {
        switch viewModel.status {
        case .future:
            return viewModel.date.inFuture(concreteTime: viewModel.dateComponents)
                ? (.timeAlert, .systemRed)
                : (.timeDone, .systemGray)
        case .cancelled:
            return (.timeDone, .systemGray)
        case .done:
            return (.timeDone, .systemGreen)
        }
    }
}
