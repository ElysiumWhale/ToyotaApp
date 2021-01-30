import Foundation
import UIKit

class PickerController: UIViewController {
    func configurePicker<T>(_ picker: UIPickerView, with action: Selector, for textField: UITextField, delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
        picker.dataSource = delegate
        picker.delegate = delegate
        textField.inputAccessoryView = buildToolbar(for: picker, with: action)
        textField.inputView = picker
    }
    
    private func buildToolbar(for pickerView: UIPickerView, with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: action)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

extension UIViewController {
    func displayError(whith text: String) {
        PopUp.displayMessage(with: "Ошибка", description: text, buttonText: "Ок")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
