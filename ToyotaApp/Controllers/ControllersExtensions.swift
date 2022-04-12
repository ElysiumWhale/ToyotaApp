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
        view.addGestureRecognizer(swipe)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Navigation
extension UIViewController {
    func perform(segue: SegueIdentifiers) {
        performSegue(withIdentifier: segue.rawValue, sender: self)
    }

    @IBAction func customDismiss(sender: Any? = nil) {
        dismiss(animated: true)
    }
}

extension UIViewController {
    var wrappedInNavigation: UIViewController {
        UINavigationController(rootViewController: self)
    }
}

extension UIViewController {
    func configureNavBarAppearance(color: UIColor = .appTint(.secondarySignatureRed),
                                   font: UIFont? = .toyotaType(.regular, of: 17)) {
        guard let navigation = navigationController else {
            return
        }

        navigation.navigationBar.tintColor = color
        if let font = font {
            navigation.navigationBar.titleTextAttributes = [
                .font: font
            ]
        }
    }
}

extension UIViewController {
    func addSubview(_ view: UIView) {
        view.addSubview(view)
    }

    func addSubviews(_ views: UIView...) {
        for subview in views {
            view.addSubview(subview)
        }
    }
}
