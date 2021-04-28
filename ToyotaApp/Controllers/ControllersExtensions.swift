import Foundation
import UIKit

//MARK: - Toolbar for controls
extension UIViewController {
    func buildToolbar(with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: CommonText.choose, style: .done, target: self, action: action)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

//MARK: - UIPicker
extension UIViewController {
    func configurePicker<T>(_ picker: UIPickerView, with action: Selector, for textField: UITextField, delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
        picker.dataSource = delegate
        picker.delegate = delegate
        textField.inputAccessoryView = buildToolbar(with: action)
        textField.inputView = picker
    }
}

//MARK: - UIDatePicker & Date Formatting
extension UIViewController {
    func configureDatePicker(_ datePicker: UIDatePicker, with action: Selector, for textField: UITextField) {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        textField.inputAccessoryView = buildToolbar(with: action)
        textField.inputView = datePicker
    }
    
    func formatDate(from date: Date, withAssignTo textField: UITextField? = nil) -> String {
        if let textField = textField {
            textField.text = DateFormatter.ClientDateFormatter.string(from: date)
        }
        return DateFormatter.ServerDateFormatter.string(from: date)
    }
    
    func formatDateForServer(from date: Date) -> String {
        DateFormatter.ServerDateFormatter.string(from: date)
    }
    
    func formatDateForClient(from string: String) -> String {
        guard let date = DateFormatter.ServerDateFormatter.date(from: string) else {
            return DateFormatter.ServerDateFormatter.string(from: Date())
        }
        return DateFormatter.ClientDateFormatter.string(from: date)
    }
    
    func dateFromClient(date string: String) -> Date {
        return DateFormatter.ClientDateFormatter.date(from: string) ?? Date()
    }
    
    func dateFromServer(date string: String) -> Date {
        return DateFormatter.ServerDateFormatter.date(from: string) ?? Date()
    }
}

//MARK: - Error Displaying
extension UIViewController {
    func displayError(with text: String, beforePopUpAction: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            beforePopUpAction()
            PopUp.displayMessage(with: CommonText.error, description: text, buttonText: CommonText.ok)
        }
    }
}

//MARK: - Dismissing controls
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

//MARK: - Navigation
extension UIViewController {
    func performSegue(for identifier: String, beforeAction: @escaping () -> Void = { }) {
        DispatchQueue.main.async { [self] in
            beforeAction()
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    func dismissNavigationWithDispatch(animated: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [self] in
            if let navigation = navigationController {
                navigation.dismiss(animated: animated, completion: completion)
            }
        }
    }
}

extension UINavigationController {
    func popToRootWithDispatch(animated: Bool, beforeAction: @escaping () -> Void = { }) {
        DispatchQueue.main.async { [self] in
            beforeAction()
            popToRootViewController(animated: animated)
        }
    }
}

protocol BackgroundText {
    func createBackground(with text: String?) -> UILabel?
}

extension BackgroundText {
    func createBackground(with text: String?) -> UILabel? {
        if let txt = text {
            let messageLabel = UILabel()
            messageLabel.text = txt
            messageLabel.textColor = .systemGray
            messageLabel.numberOfLines = 0;
            messageLabel.lineBreakMode = .byWordWrapping
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "ToyotaType-Semibold", size: 25)
            messageLabel.sizeToFit()
            return messageLabel
        } else { return nil }
    }
}
