import UIKit

// MARK: - Navigation
extension UIViewController {
    @objc private func customDismiss() {
        dismiss(animated: true)
    }

    var wrappedInNavigation: UINavigationController {
        UINavigationController(rootViewController: self)
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
