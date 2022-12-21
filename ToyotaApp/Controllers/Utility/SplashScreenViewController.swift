import UIKit

final class SplashScreenViewController: BaseViewController {
    private let logoView = UIImageView(image: .toyotaLogo)
    private let indicatorView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorView.fadeIn(0.3)
        indicatorView.startAnimating()
    }

    override func addViews() {
        addSubviews(logoView, indicatorView)
    }

    override func configureLayout() {
        indicatorView.centerInSuperview()
        logoView.centerXToSuperview()
        logoView.size(CGSize(width: 128, height: 128))
        logoView.bottomToTop(of: indicatorView, offset: -50)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        indicatorView.alpha = .zero
    }
}
