import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var secondNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var birthTextField: UITextField!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!
    
    private var textFieldsWithError: [UITextField : Bool]!
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private var cities: [City] = [City]()
    private var date: String = ""
    
    private var isConfigured: Bool = false
    private var configuredProfile: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(doneDidPress), for: birthTextField)
        hideKeyboardWhenTappedAround()
        textFieldsWithError = [firstNameTextField : true, secondNameTextField : true,
                               lastNameTextField : true, emailTextField : true, birthTextField : true]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func textDidChange(sender: UITextField) {
        if let text = sender.text, text.count > 0, text.count < 25 {
            sender.borderStyle = .none
            sender.layer.borderColor = UIColor.gray.cgColor
            sender.layer.borderWidth = 0.15
            textFieldsWithError[sender] = false
        } else {
            textFieldsWithError[sender] = true
        }
    }
    
    func configure(with profile: Profile) {
        configuredProfile = profile
        isConfigured = true
    }
    
    @IBAction private func doneDidPress(sender: Any?) {
        date = formatSelectedDate(from: datePicker, to: birthTextField)
        view.endEditing(true)
    }
    
    private func buildRequestParams(from profile: Profile, date: String) -> [URLQueryItem] {
        var params = [URLQueryItem]()
        let userId = DefaultsManager.getUserInfo(UserId.self)!.id
        params.append(URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.id)))
        params.append(URLQueryItem(name: RequestKeys.Auth.userId, value: userId))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: profile.firstName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: profile.secondName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: profile.lastName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: profile.email))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: date))
        return params
    }
    
    private func displayErrors() {
        DispatchQueue.main.async { [self] in
            for (field, hasError) in textFieldsWithError {
                if hasError {
                    field.borderStyle = .roundedRect
                    field.layer.borderColor = UIColor.systemRed.cgColor
                    field.layer.borderWidth = 0.5
                }
            }
        }
        PopUp.displayMessage(with: "Неккоректные данные", description: "Проверьте введенную информацию!", buttonText: "Ок")
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
    
//    override func viewWillDisappear(_ animated: Bool) {
//        removeKeyboardObserver()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as! DealerViewController
                destinationVC.configure(cityList: cities)
            default: return
        }
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
        guard textFieldsWithError.allSatisfy({ !$0.value }) else {
            displayErrors()
            return
        }
        
        activitySwitcher.startAnimating()
        nextButton.isHidden = true
        configuredProfile = Profile(phone: nil, firstName: firstNameTextField.text!,
                                    lastName: lastNameTextField.text!,
                                    secondName: secondNameTextField.text!,
                                    email: emailTextField.text!,
                                    birthday: date)
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.setProfile, params: buildRequestParams(from: configuredProfile!, date: date), completion: completionForSegue)
    }
}

