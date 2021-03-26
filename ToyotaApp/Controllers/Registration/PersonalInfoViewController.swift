import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet private(set) var scrollView: UIScrollView!
    @IBOutlet private(set) var firstNameTextField: UITextField!
    @IBOutlet private(set) var secondNameTextField: UITextField!
    @IBOutlet private(set) var lastNameTextField: UITextField!
    @IBOutlet private(set) var emailTextField: UITextField!
    @IBOutlet private(set) var birthTextField: UITextField!
    @IBOutlet private(set) var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet private(set) var nextButton: UIButton!
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private var cities: [City] = [City]()
    private var date: String = ""
    
    private var isConfigured: Bool = false
    private var configuredProfile: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(doneDidPress), for: birthTextField)
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func configure(with profile: Profile) {
        configuredProfile = profile
        isConfigured = true
    }
}

//MARK: - DatePicker logic
extension PersonalInfoViewController {
    @IBAction private func doneDidPress(sender: Any?) {
        date = formatSelectedDate(from: datePicker, to: birthTextField)
        view.endEditing(true)
    }
}

//MARK: - Navigation
extension PersonalInfoViewController {
    override func viewWillAppear(_ animated: Bool) {
        //addKeyboardObserver()
        if isConfigured {
            firstNameTextField.text = configuredProfile!.firstName
            secondNameTextField.text = configuredProfile!.secondName
            lastNameTextField.text = configuredProfile!.lastName
            emailTextField.text = configuredProfile!.email
            #warning("to-do: Format data")
            birthTextField.text  = configuredProfile!.birthday
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //removeKeyboardObserver()
    }
    
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
    private func buildParamsForRequest(from profile: Profile, date: String) -> [URLQueryItem] {
        var requestParams = [URLQueryItem]()
        let userId = DefaultsManager.getUserInfo(UserId.self)!.id
        requestParams.append(URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.id)))
        requestParams.append(URLQueryItem(name: RequestKeys.Auth.userId, value: userId))
        requestParams.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: profile.firstName))
        requestParams.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: profile.secondName))
        requestParams.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: profile.lastName))
        requestParams.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: profile.email))
        requestParams.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: date))
        return requestParams
    }
}

//MARK: - Keyboard methods
extension PersonalInfoViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        scrollView.contentInset = contentInsets
        //scrollView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height-30), animated: true)
        scrollView.scrollIndicatorInsets = contentInsets
      }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
}

//MARK: - SegueWithRequestController
extension PersonalInfoViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.PersonInfoToDealer }
    
    func completionForSegue(for response: ProfileDidSetResponse?) {
        guard let data = response else {
            activitySwitcher.stopAnimating()
            nextButton.isHidden = false
            displayError(whith: response?.message ?? "Ошибка при отправке запроса")
            return
        }
        cities = data.cities.map {
            City(id: $0.id, name: String(data: $0.name.data(using: .nonLossyASCII)!, encoding: String.Encoding.nonLossyASCII)!)
        }
        DefaultsManager.pushUserInfo(info: Person.toDomain(configuredProfile!))
        DispatchQueue.main.async { [self] in
            performSegue(withIdentifier: segueCode, sender: self)
        }
    }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard checkFields() else { return }
        activitySwitcher.startAnimating()
        nextButton.isHidden = true
        
        configuredProfile = Profile(phone: nil, firstName: firstNameTextField.text!,
                                    lastName: lastNameTextField.text!,
                                    secondName: secondNameTextField.text!,
                                    email: emailTextField.text!,
                                    birthday: date)
        let params = buildParamsForRequest(from: configuredProfile!, date: date)
        
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.setProfile, params: params, completion: completionForSegue)
    }
}

