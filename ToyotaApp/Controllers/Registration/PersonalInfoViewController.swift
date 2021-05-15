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
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private var textFieldsWithError: [UITextField : Bool]!
    
    private var cities: [City] = []
    private var date: String = ""
    
    private var isConfigured: Bool = false
    private var configuredProfile: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        hideKeyboardWhenTappedAround()
        textFieldsWithError = [firstNameTextField : true, secondNameTextField : true,
                               lastNameTextField : true, emailTextField : true, birthTextField : true]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configure(with profile: Profile) {
        configuredProfile = profile
        isConfigured = true
    }
    
    private var hasErrors: Bool {
        return !textFieldsWithError.values.allSatisfy({ !$0 })
    }
    
    @IBAction private func textDidChange(sender: UITextField) {
        if let text = sender.text, text.count > 0, text.count < 25 {
            sender.borderStyle = .none
            sender.layer.borderColor = UIColor.gray.cgColor
            sender.layer.borderWidth = 0.15
            textFieldsWithError[sender] = false
        } else {
            sender.borderStyle = .roundedRect
            sender.layer.borderColor = UIColor.systemRed.cgColor
            sender.layer.borderWidth = 0.5
            textFieldsWithError[sender] = true
        }
    }
    
    @IBAction private func dateDidSelect(sender: Any?) {
        date = formatDate(from: datePicker.date, withAssignTo: birthTextField)
        textFieldsWithError[birthTextField] = false
        view.endEditing(true)
    }
}

//MARK: - Navigation
extension PersonalInfoViewController {
    override func viewWillAppear(_ animated: Bool) {
        //addKeyboardObserver()
        if isConfigured, let profile = configuredProfile {
            firstNameTextField.text = profile.firstName
            secondNameTextField.text = profile.secondName
            lastNameTextField.text = profile.lastName
            emailTextField.text = profile.email
            birthTextField.text = formatDateForClient(from: profile.birthday!)
            date = profile.birthday!
        }
        
        if activitySwitcher.isAnimating {
            activitySwitcher.stopAnimating()
            activitySwitcher.isHidden = true
            nextButton.isHidden = false
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
    @IBAction func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        scrollView.contentInset = contentInsets
        //scrollView.setContentOffset(CGPoint(x: 0.0, y: keyboardSize.height-30), animated: true)
        scrollView.scrollIndicatorInsets = contentInsets
      }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

//MARK: - SegueWithRequestController
extension PersonalInfoViewController: SegueWithRequestController {
    typealias TResponse = ProfileDidSetResponse
    
    var segueCode: String { SegueIdentifiers.PersonInfoToDealer }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        if hasErrors {
            PopUp.displayMessage(with: "Неккоректные данные", description: "Проверьте введенную информацию!", buttonText: CommonText.ok)
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
    
    func completionForSegue(for response: Result<ProfileDidSetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                cities = data.cities.map { City(id: $0.id, name: $0.name) }
                DefaultsManager.pushUserInfo(info: Person.toDomain(configuredProfile!))
                performSegue(for: segueCode)
            case .failure(let error):
                displayError(with: error.message ?? "Ошибка при отправке запроса") { [self] in
                    activitySwitcher.stopAnimating()
                    nextButton.isHidden = false
                }
        }
    }
    
    private func buildRequestParams(from profile: Profile, date: String) -> [URLQueryItem] {
        var params = [URLQueryItem]()
        let userId = DefaultsManager.getUserInfo(UserId.self)!.id
        params.append(URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.Toyota)))
        params.append(URLQueryItem(name: RequestKeys.Auth.userId, value: userId))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: profile.firstName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: profile.secondName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: profile.lastName))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: profile.email))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: date))
        return params
    }
}
