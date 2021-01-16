import Foundation
import UIKit

class PickerController: UIViewController {
    func configurePicker<T>(view: UIPickerView, with action: Selector, for textField: UITextField, delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
        view.dataSource = delegate
        view.delegate = delegate
        textField.inputAccessoryView = buildToolbar(for: view, with: action)
        textField.inputView = view
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
