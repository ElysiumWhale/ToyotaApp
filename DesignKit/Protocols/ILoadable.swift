import UIKit

/// Default loading view with indicator handling
public protocol Loadable: UIViewController {
    associatedtype TLoadingView: ILoadingView

    var loadingView: TLoadingView { get }

    func startLoading()
    func stopLoading()
}

public extension Loadable {
    func startLoading() {
        loadingView.isUserInteractionEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.animateLoadingViewIfNeeded()
        }
    }

    func stopLoading() {
        loadingView.isUserInteractionEnabled = false
        loadingView.fadeOut() { [weak self] in
            self?.loadingView.stopAnimating()
            self?.loadingView.removeFromSuperview()
        }
    }

    private func animateLoadingViewIfNeeded() {
        guard loadingView.isUserInteractionEnabled else {
            return
        }

        loadingView.alpha = 0
        view.addSubview(loadingView)
        loadingView.frame = view.frame
        loadingView.startAnimating()
        loadingView.fadeIn()
        loadingView.isUserInteractionEnabled = false
    }
}
