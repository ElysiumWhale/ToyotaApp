import UIKit

/// Protocol for controllers which work with `UserProxy`
protocol WithUserInfo: AnyObject {
    func setUser(info: UserProxy)
    func subscribe(on proxy: UserProxy)
    func unsubscribe(from proxy: UserProxy)
    func userDidUpdate()
}

extension WithUserInfo {
    func subscribe(on proxy: UserProxy) { }
    func unsubscribe(from proxy: UserProxy) { }
    func userDidUpdate() { }
}

// MARK: - Refreshable
typealias RefreshableController = UIViewController & Refreshable

/// Protocol for UIViewController with UIRefreshControl
protocol Refreshable: UIViewController {
    associatedtype RefreshableView: UIScrollView

    var refreshControl: UIRefreshControl { get }
    var refreshableView: RefreshableView! { get }

    func configureRefresh()
    func startRefreshing()
    func endRefreshing()
}

extension Refreshable {
    func setTitle(with string: String) {
        refreshControl.attributedTitle = NSAttributedString(string: string)
    }

    func configureRefresh() {
        refreshableView.alwaysBounceVertical = true
        refreshControl.isEnabled = true
        refreshControl.addAction(for: .valueChanged) { [weak self] in
            self?.startRefreshing()
        }
        refreshControl.layer.zPosition = -1
        refreshableView.refreshControl = refreshControl
    }

    func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                      execute: { [weak self] in
            self?.refreshControl.stopRefreshing()
        })
    }
}

// MARK: - Keyboard auto insets
typealias KeyboardableController = UIViewController & Keyboardable

protocol Keyboardable: UIViewController {
    associatedtype ScrollableView: UIScrollView

    var scrollView: ScrollableView! { get }

    func setupKeyboard(isSubcribing: Bool)
}

extension Keyboardable {
    func setupKeyboard(isSubcribing: Bool) {
        guard isSubcribing else {
            NotificationCenter.default.removeObserver(self)
            return
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillShow(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillHide(notification: notification)
        }
    }

    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                  return
              }

        // Workaround of the situation when height is less than 300 inset does not change
        let heightInset = keyboardSize.cgRectValue.height < 300 ? 300 : keyboardSize.cgRectValue.height
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0,
                                         bottom: heightInset, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
      }

    private func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

// MARK: - Loadable

/// Default loading view with indicator handling
protocol Loadable: UIViewController {
    var loadingView: LoadingView { get }
    var isLoading: Bool { get set }

    func startLoading()
    func stopLoading()
}

extension Loadable {
    func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
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

protocol MainQueueRunnable { }

extension MainQueueRunnable {
    func dispatch(action: Closure?) {
        DispatchQueue.main.async {
            action?()
        }
    }

    static func dispatch(action: Closure?) {
        DispatchQueue.main.async {
            action?()
        }
    }
}

extension UIViewController: MainQueueRunnable { }
