import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var secondNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var birthTextField: UITextField!
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private let segueCode = SegueIdentifiers.PersonInfoToDealer
    private var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
    }
    
    //MARK: - DatePicker logic
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                NetworkService.shared.makePostRequest(page: PostRequestPath.profile, params: buildParamsForRequest()) { [self] data in
                    //parse data
                    //DEBUG
                    print(String(data: data!, encoding: String.Encoding.nonLossyASCII))
                    //let destinationVC = segue.destination as? DealerViewController
                    //destinationVC?.field = ...
                }
            default: return
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        return
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case segueCode:
                guard (firstNameTextField.text != nil) else { return false }
                guard (secondNameTextField.text != nil) else { return false }
                guard (lastNameTextField.text != nil) else { return false }
                guard (emailTextField.text != nil) else { return false }
                guard (birthTextField.text != nil && !date.isEmpty) else { return false }
                return true
            default:
                return false
        }
    }
}

//MARK: - Build parameters logic
extension PersonalInfoViewController {
    private func buildParamsForRequest() -> [URLQueryItem] {
        var requestParams = [URLQueryItem]()
        requestParams.append(URLQueryItem(name: PostRequestKeys.brand_id, value: String(Brand.id)))
        requestParams.append(URLQueryItem(name: PostRequestKeys.user_id, value: DebugUserId.userId))
        requestParams.append(URLQueryItem(name: PostRequestKeys.first_name, value: firstNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.second_name, value: secondNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.last_name, value: lastNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.email, value: emailTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.birthday, value: date))
        return requestParams
    }
}
