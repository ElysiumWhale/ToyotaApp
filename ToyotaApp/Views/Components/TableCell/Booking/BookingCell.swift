import UIKit

final class BookingCell: BaseTableCell {
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let titleLabel = UILabel()
    private let carLabel = UILabel()
    private let licenseLabel = UILabel()
    private let statusView = StatusView()
    private let timeView = TimeView()

    override func addViews() {
        contentView.addSubviews(dateLabel,
                                contentLabel,
                                titleLabel,
                                carLabel,
                                licenseLabel,
                                statusView,
                                timeView)
    }

    override func configureLayout() {
        titleLabel.topToSuperview(offset: 10)
        titleLabel.leadingToSuperview(offset: 10)
        contentLabel.topToBottom(of: titleLabel, offset: 5)
        contentLabel.trailingToLeading(of: licenseLabel, offset: -20)
        licenseLabel.contentCompressionResistancePriority = .required

        contentLabel.leadingToSuperview(offset: 10)
        statusView.topToBottom(of: contentLabel,
                               offset: 10,
                               relation: .equalOrGreater)
        statusView.leading(to: titleLabel)
        statusView.bottomToSuperview(offset: -8)
        statusView.height(20)

        dateLabel.top(to: titleLabel)
        dateLabel.trailingToSuperview(offset: 10)
        carLabel.topToBottom(of: dateLabel, offset: 5)
        carLabel.trailing(to: dateLabel)
        licenseLabel.topToBottom(of: carLabel)
        licenseLabel.trailing(to: dateLabel)
        timeView.topToBottom(of: licenseLabel,
                             offset: 10,
                             relation: .equalOrGreater)
        timeView.trailing(to: dateLabel)
        timeView.height(20)
        timeView.bottomToSuperview(offset: -8)
    }

    override func configureAppearance() {
        titleLabel.font = .toyotaType(.semibold, of: 15)
        titleLabel.textColor = .appTint(.signatureGray)

        dateLabel.font = .toyotaType(.semibold, of: 17)
        dateLabel.textColor = .appTint(.signatureGray)

        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.font = .toyotaType(.book, of: 17)
        contentLabel.textColor = .appTint(.signatureGray)

        for label in [carLabel, licenseLabel] {
            label.font = .toyotaType(.book, of: 14)
            label.textColor = .appTint(.signatureGray)
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .right
        }
    }

    func configure(with booking: Booking) {
        titleLabel.text = booking.showroomName
        contentLabel.text = booking.serviceName
        carLabel.text = booking.carName.isEmptyOrWithoutAuto ? .empty : booking.carName
        licenseLabel.text = booking.licensePlate.uppercased()
        dateLabel.text = booking.date.asString(.display)
        statusView.configure(with: booking)
        timeView.configure(with: .init(
            dateComponents: booking.bookingTime,
            status: booking.status,
            date: booking.date
        ))
    }
}

private extension String {
    var isEmptyOrWithoutAuto: Bool {
        self.isEmpty || self == "Без авто"
    }
}
