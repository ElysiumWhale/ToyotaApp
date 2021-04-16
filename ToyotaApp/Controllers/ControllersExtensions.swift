import Foundation
import UIKit

//MARK: - Toolbar for controls
extension UIViewController {
    func buildToolbar(with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: action)
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
    
    private var serverDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var clientDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        return formatter
    }
    
    func formatDate(from date: Date, withAssignTo textField: UITextField? = nil) -> String {
        if let textField = textField {
            textField.text = clientDateFormatter.string(from: date)
        }
        return serverDateFormatter.string(from: date)
    }
    
    func formatDateForServer(from date: Date) -> String {
        serverDateFormatter.string(from: date)
    }
    
    func formatDateForClient(from string: String) -> String {
        guard let date = serverDateFormatter.date(from: string) else {
            return "Error while parsing"
        }
        return clientDateFormatter.string(from: date)
    }
}

//MARK: - Error Displaying
extension UIViewController {
    func displayError(whith text: String) {
        PopUp.displayMessage(with: "Ошибка", description: text, buttonText: "Ок")
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
