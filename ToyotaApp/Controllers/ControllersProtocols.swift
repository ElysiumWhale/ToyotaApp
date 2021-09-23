import Foundation
import UIKit

protocol SegueWithRequestController {
    associatedtype TResponse: Codable
    var segueCode: String { get }
    func completionForSegue(for response: Result<TResponse, ErrorResponse>)
    func nextButtonDidPressed(sender: Any?)
}

extension SegueWithRequestController {
    func completionForSegue(for response: TResponse?) { }
}

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
    func configureRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: .common(.pullToRefresh))
        refreshControl.addAction(for: .valueChanged, startRefreshing)
        refreshControl.layer.zPosition = -1
        refreshableView.refreshControl = refreshControl
    }

    func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                      execute: { [weak self] in self?.refreshControl.endRefreshing() })
    }
}
