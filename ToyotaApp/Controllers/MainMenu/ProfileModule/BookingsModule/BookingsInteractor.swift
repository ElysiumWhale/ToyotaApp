import Foundation

protocol BookingsView: AnyObject {
    func handleBookingsSuccess()
    func handleBookingsFailure(with message: String)
}

final class BookingsInteractor {
    private let bookingsHandler = RequestHandler<BookingsResponse>()
    private let bookingsService: BookingsService

    private(set) var bookings: [Booking] = []

    weak var view: BookingsView?

    init(bookingsService: BookingsService = InfoService()) {
        self.bookingsService = bookingsService

        setupRequestHandlers()
    }

    func getBookings() {
        guard let userId = KeychainManager<UserId>.get()?.value else {
            return
        }

        bookingsService.getBookings(
            with: GetBookingsBody(userId: userId),
            handler: bookingsHandler
        )
    }

    private func handle(success response: BookingsResponse) {
        #if DEBUG
        var list = response.booking
        list.append(.todayNotInFuture)
        list.append(.done)
        let response = BookingsResponse(
            result: .common(.ok).lowercased(),
            booking: list,
            count: list.count
        )
        #endif
        bookings = response.booking.sorted(by: { $0.date > $1.date })

        view?.handleBookingsSuccess()
    }

    private func setupRequestHandlers() {
        bookingsHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak view] error in
                view?.handleBookingsFailure(
                    with: error.message ?? .error(.requestError)
                )
            }
    }
}
