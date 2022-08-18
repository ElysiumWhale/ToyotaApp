import UIKit

// MARK: - Dismissing controls
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        swipe.cancelsTouchesInView = false
        swipe.direction = [.up, .down, .left, .right]
        tap.require(toFail: swipe)
        view.addGestureRecognizer(swipe)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Navigation
extension UIViewController {

    @IBAction func customDismiss(sender: Any? = nil) {
        dismiss(animated: true)
    }

    var wrappedInNavigation: UINavigationController {
        UINavigationController(rootViewController: self)
    }

    func addDismissRightButton(title: String = .common(.done),
                               color: UIColor = .appTint(.secondarySignatureRed)) {
        let buttonItem = UIBarButtonItem(title: title)
        buttonItem.action = #selector(customDismiss)
        buttonItem.tintColor = color
        navigationItem.rightBarButtonItem = buttonItem
    }
}

extension UIViewController {
    func configureNavBarAppearance(color: UIColor? = .appTint(.secondarySignatureRed),
                                   font: UIFont? = .toyotaType(.regular, of: 17)) {
        guard let navigation = navigationController else {
            return
        }

        if let color = color {
            navigation.navigationBar.tintColor = color
        }

        if let font = font {
            navigation.navigationBar.titleTextAttributes = [
                .font: font
            ]
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
