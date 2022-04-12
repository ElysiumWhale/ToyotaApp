import UIKit

// MARK: - Toolbar for controls
extension UIViewController {
    func buildToolbar(with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: .common(.choose), style: .done, target: nil, action: action)
        doneButton.tintColor = .appTint(.secondarySignatureRed)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

// MARK: - UIPicker
protocol PickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func configurePicker(_ picker: UIPickerView, with action: Selector, for textField: UITextField)
}

extension PickerController {
    func configurePicker(_ picker: UIPickerView, with action: Selector, for textField: UITextField) {
        picker.dataSource = self
        picker.delegate = self
        textField.inputAccessoryView = buildToolbar(with: action)
        textField.inputView = picker
    }
}

// MARK: - UIDatePicker & Date Formatting
extension UIViewController {
    func configureDatePicker(_ datePicker: UIDatePicker, with action: Selector, for textField: UITextField) {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        textField.inputAccessoryView = buildToolbar(with: action)
        textField.inputView = datePicker
    }
}

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
