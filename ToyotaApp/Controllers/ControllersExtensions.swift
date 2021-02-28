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

extension UITabBarController {
    func updateControllers(with user: UserProxy) {
        guard let controllers = viewControllers, !controllers.isEmpty else { return }
        for vc in controllers {
            if let controller = vc as? WithUserInfo {
                controller.setUser(info: user)
            }
        }
    }
}
