import UIKit

/// Protocol for UIViewController with UIRefreshControl
public protocol Refreshable: UIViewController {
    associatedtype RefreshableView: UIScrollView

    var refreshControl: UIRefreshControl { get }
    var refreshableView: RefreshableView { get }

    func configureRefresh()
    func startRefreshing()
    func endRefreshing()
}

public extension Refreshable {
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
                                      execute: { [weak refreshControl] in
            refreshControl?.stopRefreshing()
        })
    }
}
