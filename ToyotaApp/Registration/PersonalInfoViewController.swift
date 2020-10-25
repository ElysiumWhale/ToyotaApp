import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var secondNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var birthTextField: UITextField!
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
    }
    
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(doneDidPress))
        toolBar.setItems([doneButton], animated: true)
        birthTextField.inputAccessoryView = toolBar
        birthTextField.inputView = datePicker
    }
    
    @objc func doneDidPress() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        let formattedDate = formatter.string(from: datePicker.date)
        
        let internalFormatter = DateFormatter()
        internalFormatter.dateFormat = "yyyy-MM-dd"
        date = internalFormatter.string(from: datePicker.date)
        
        birthTextField.text = formattedDate
        self.view.endEditing(true)
    }
    
// MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
}
