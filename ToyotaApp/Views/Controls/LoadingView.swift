import UIKit

protocol ILoadingView: UIView {
    func startAnimating()
    func stopAnimating()
}

class LoadingView: UIView, ILoadingView {

    private(set) var indicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = .white
        backgroundColor = .appTint(.loading)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func startAnimating() {
        indicator.startAnimating()
    }

    func stopAnimating() {
        indicator.stopAnimating()
    }
}
