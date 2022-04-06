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
    func popToRootWithDispatch(animated: Bool,
                               beforeAction: @escaping Closure = { },
                               afterAction: @escaping Closure = { }) {
        DispatchQueue.main.async { [weak self] in
            beforeAction()
            self?.navigationController?.popToRootViewController(animated: animated)
            afterAction()
        }
    }
}

extension UIViewController {
    func configureDefaultNavBarAppearance() {
        navigationController?.navigationBar.tintColor = .appTint(.secondarySignatureRed)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
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
