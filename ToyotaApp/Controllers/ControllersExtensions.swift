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

extension String {
    static func formatDate(from date: Date, withAssignTo textField: UITextField? = nil) -> String {
        if let textField = textField {
            textField.text = DateFormatter.client.string(from: date)
        }
        return DateFormatter.server.string(from: date)
    }

    static func formatDateForServer(from date: Date) -> String {
        DateFormatter.server.string(from: date)
    }

    static func formatDateForClient(from string: String) -> String {
        DateFormatter.client.string(from: DateFormatter.server.date(from: string) ?? Date())
    }
}

extension Date {
    static func dateFromClient(date string: String) -> Date {
        DateFormatter.client.date(from: string) ?? Date()
    }

    static func dateFromServer(date string: String) -> Date {
        DateFormatter.server.date(from: string) ?? Date()
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
    
    func performSegue(for identifier: String) {
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    func dismissNavigationWithDispatch(animated: Bool, completion: @escaping () -> Void = { }) {
        DispatchQueue.main.async { [self] in
            if let navigation = navigationController {
                navigation.dismiss(animated: animated, completion: completion)
            }
        }
    }

    @IBAction func customDismiss(sender: Any?) {
        dismiss(animated: true)
    }
}

extension UIViewController {
    func popToRootWithDispatch(animated: Bool, beforeAction: @escaping () -> Void = { }) {
        DispatchQueue.main.async { [weak self] in
            beforeAction()
            self?.navigationController?.popToRootViewController(animated: animated)
        }
    }
}
