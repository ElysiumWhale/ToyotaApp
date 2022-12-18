import UIKit

/// Default loading view with indicator handling
public protocol Loadable: UIViewController {
    associatedtype TLoadingView: ILoadingView

    var loadingView: TLoadingView { get }
    var isLoading: Bool { get set }

    func startLoading()
    func stopLoading()
}

public extension Loadable {
    func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let ref = self, ref.isLoading else {
                return
            }

            ref.loadingView.alpha = 0
            ref.view.addSubview(ref.loadingView)
            ref.loadingView.frame = ref.view.frame
            ref.loadingView.startAnimating()
            ref.loadingView.fadeIn()
            ref.isLoading = false
        }
    }

    func stopLoading() {
        isLoading = false
        loadingView.fadeOut(1) { [weak self] in
            self?.loadingView.stopAnimating()
            self?.loadingView.removeFromSuperview()
        }
    }
}

