import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var secondNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var birthTextField: UITextField!
    @IBOutlet var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet var nextButton: UIButton!
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private let segueCode = SegueIdentifiers.PersonInfoToDealer
    private var cities: [City] = [City]()
    private var date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
    }
    
    @IBAction func buttonNextDidPressed(_ sender: UIButton) {
        guard checkFields() else { return }
        activitySwitcher.startAnimating()
        nextButton.isHidden = true
        NetworkService.shared.makePostRequest(page: PostRequestPath.profile, params: buildParamsForRequest()) { [self] data in
            do {
                let rawCities = try JSONDecoder().decode(ProfileDidSetResponse.self, from: data!)
                cities = rawCities.cities.map {
                    City(id: $0.id, name: String(data: $0.name.data(using: .nonLossyASCII)!, encoding: String.Encoding.nonLossyASCII)!)
                }
                DispatchQueue.main.async {
                    performSegue(withIdentifier: segueCode, sender: self)
                }
            }
            catch let decodeError as NSError {
                print("Decoder error: \(decodeError.localizedDescription)")
                DispatchQueue.main.async {
                    activitySwitcher.stopAnimating()
                    nextButton.isHidden = false
                }
            }
        }
    }
    
    private func checkFields() -> Bool {
        var res = true
        if (firstNameTextField.text?.isEmpty ?? true) {
            firstNameTextField?.layer.borderColor = UIColor.systemRed.cgColor
            firstNameTextField?.layer.borderWidth = 1.0
            res = false
        }
        if (secondNameTextField.text?.isEmpty ?? true) {
            secondNameTextField?.layer.borderColor = UIColor.systemRed.cgColor
            secondNameTextField?.layer.borderWidth = 1.0
            res = false
        }
        if (lastNameTextField.text?.isEmpty ?? true) {
            lastNameTextField?.layer.borderColor = UIColor.systemRed.cgColor
            lastNameTextField?.layer.borderWidth = 1.0
            res = false
        }
        if (emailTextField.text?.isEmpty ?? true) {
            emailTextField?.layer.borderColor = UIColor.systemRed.cgColor
            emailTextField?.layer.borderWidth = 1.0
            res = false
        }
        if (birthTextField.text?.isEmpty ?? true || date.isEmpty) {
            birthTextField?.layer.borderColor = UIColor.systemRed.cgColor
            birthTextField?.layer.borderWidth = 1.0
            res = false
        }
        return res
    }
}

//MARK: - DatePicker logic
extension PersonalInfoViewController {
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: nil, action: #selector(doneDidPress))
        toolBar.setItems([flexible, doneButton], animated: true)
        birthTextField.inputAccessoryView = toolBar
        birthTextField.inputView = datePicker
    }
    
    @objc private func doneDidPress(sender: Any?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        let formattedDate = formatter.string(from: datePicker.date)
        
        let internalFormatter = DateFormatter()
        internalFormatter.dateFormat = "yyyy-MM-dd"
        date = internalFormatter.string(from: datePicker.date)
        
        birthTextField.text = formattedDate
        view.endEditing(true)
    }
}
    
// MARK: - Navigation
extension PersonalInfoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as? DealerViewController
                destinationVC?.cities = cities
            default: return
        }
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
            default: return false
        }
    }
}

//MARK: - Build parameters logic
extension PersonalInfoViewController {
    private func buildParamsForRequest() -> [URLQueryItem] {
        var requestParams = [URLQueryItem]()
        requestParams.append(URLQueryItem(name: PostRequestKeys.brandId, value: String(Brand.id)))
        requestParams.append(URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId))
        requestParams.append(URLQueryItem(name: PostRequestKeys.firstName, value: firstNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.secondName, value: secondNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.lastName, value: lastNameTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.email, value: emailTextField.text))
        requestParams.append(URLQueryItem(name: PostRequestKeys.birthday, value: date))
        return requestParams
    }
}
