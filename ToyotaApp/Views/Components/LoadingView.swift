import UIKit

final class LoadingView: BaseView, ILoadingView {
    private let indicator = UIActivityIndicatorView(style: .large)

    override func addViews() {
        addSubview(indicator)
    }

    override func configureLayout() {
        indicator.centerInSuperview()
    }

    override func configureAppearance() {
        indicator.tintColor = .white
        backgroundColor = .appTint(.loading)
    }

    func startAnimating() {
        indicator.startAnimating()
    }

    func stopAnimating() {
        indicator.stopAnimating()
    }
}
