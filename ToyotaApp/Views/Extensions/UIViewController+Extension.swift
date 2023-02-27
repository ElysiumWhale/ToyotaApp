import UIKit

// MARK: - Navigation
extension UIViewController {
    @objc private func customDismiss() {
        dismiss(animated: true)
    }

    var wrappedInNavigation: UINavigationController {
        UINavigationController(rootViewController: self)
    }

    func wrappedInNavigation(
        _ navBarTint: UIColor? = nil
    ) -> UINavigationController {
        let router = UINavigationController(rootViewController: self)
        if let navBarTint {
            router.navigationBar.tintColor = navBarTint
        }
        return router
    }

    func addDismissRightButton(
        title: String = .common(.done),
        color: UIColor = .appTint(.secondarySignatureRed)
    ) {
        let buttonItem = UIBarButtonItem(title: title)
        buttonItem.action = #selector(customDismiss)
        buttonItem.tintColor = color
        navigationItem.rightBarButtonItem = buttonItem
    }
}

extension UIViewController {
    func configureNavBarAppearance(
        color: UIColor? = .appTint(.secondarySignatureRed),
        font: UIFont? = .toyotaType(.regular, of: 17)
    ) {
        guard let navigation = navigationController else {
            return
        }

        if let color = color {
            navigation.navigationBar.tintColor = color
        }

        if let font = font {
            navigation.navigationBar.titleTextAttributes = [.font: font]
        }
    }
}

// MARK: - Adding subviews
extension UIViewController {
    func addSubviews(_ views: UIView...) {
        view.addSubviews(views)
    }

    func addSubviews(_ views: [UIView]) {
        view.addSubviews(views)
    }
}
