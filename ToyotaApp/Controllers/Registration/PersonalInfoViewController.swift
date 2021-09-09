import UIKit

class PersonalInfoViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var firstNameTextField: InputTextField!
    @IBOutlet private var secondNameTextField: InputTextField!
    @IBOutlet private var lastNameTextField: InputTextField!
    @IBOutlet private var emailTextField: InputTextField!
    @IBOutlet private var birthTextField: InputTextField!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!

    private let datePicker: UIDatePicker = UIDatePicker()

    private var textFieldsWithError: [UITextField: Bool] = [:]

    private var cities: [City] = []
    private var date: String = ""

    private var isConfigured: Bool = false
    private var configuredProfile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        hideKeyboardWhenTappedAround()
        textFieldsWithError = [firstNameTextField: true, secondNameTextField: true,
                               lastNameTextField: true, emailTextField: true, birthTextField: true]
    }

    func configure(with profile: Profile) {
        configuredProfile = profile
        isConfigured = true
    }

    private var hasErrors: Bool {
        return !textFieldsWithError.values.allSatisfy({ !$0 })
    }

    @IBAction private func textDidChange(sender: UITextField) {
        let isNormal = sender.text != nil && !sender.text!.isEmpty && sender.text!.count < 25
        sender.toggleErrorState(hasError: !isNormal)
        textFieldsWithError[sender] = !isNormal
    }

    @IBAction private func dateDidSelect(sender: Any?) {
        date = formatDate(from: datePicker.date, withAssignTo: birthTextField)
        textFieldsWithError[birthTextField] = false
        view.endEditing(true)
    }
}

// MARK: - Navigation
extension PersonalInfoViewController {
    override func viewWillAppear(_ animated: Bool) {
        setupKeyboard(isSubcribing: true)
        
        if isConfigured, let profile = configuredProfile {
            firstNameTextField.text = profile.firstName
            secondNameTextField.text = profile.secondName
            lastNameTextField.text = profile.lastName
            emailTextField.text = profile.email
            birthTextField.text = formatDateForClient(from: profile.birthday!)
            date = profile.birthday!
            textFieldsWithError.forEach {
                textFieldsWithError[$0.key] = false
            }
        }
        
        if activitySwitcher.isAnimating {
            activitySwitcher.stopAnimating()
            nextButton.fadeIn()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        setupKeyboard(isSubcribing: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as? DealerViewController
                destinationVC?.configure(cityList: cities)
            default: return
        }
    }
}

// MARK: - Keyboard methods
extension PersonalInfoViewController {
    private func setupKeyboard(isSubcribing: Bool) {
        if isSubcribing {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                                   name: UIResponder.keyboardWillShowNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                                   name: UIResponder.keyboardWillHideNotification,
                                                   object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }

    @IBAction func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
      }

    @IBAction func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

// MARK: - SegueWithRequestController
extension PersonalInfoViewController: SegueWithRequestController {
    typealias TResponse = CitiesDidGetResponse

    var segueCode: String { SegueIdentifiers.PersonInfoToDealer }

    @IBAction func nextButtonDidPressed(sender: Any?) {
        if hasErrors {
            PopUp.display(.error(description: "Неккоректные данные. Проверьте введенную информацию!"))
            return
        }
        
        nextButton.fadeOut()
        activitySwitcher.startAnimating()
        configuredProfile = Profile(phone: nil, firstName: firstNameTextField.text!,
                                    lastName: lastNameTextField.text!,
                                    secondName: secondNameTextField.text!,
                                    email: emailTextField.text!,
                                    birthday: date)
        NetworkService.shared.makePostRequest(page: .regisrtation(.setProfile),
                                              params: buildRequestParams(from: configuredProfile!, date: date),
                                              completion: completionForSegue)
    }

    func completionForSegue(for response: Result<CitiesDidGetResponse, ErrorResponse>) {
        
        let completion = { [weak self] (isSuccess: Bool, parameter: String) in
            guard let view = self else { return }
            DispatchQueue.main.async {
                view.activitySwitcher.stopAnimating()
                view.nextButton.fadeIn()
                isSuccess ? view.performSegue(withIdentifier: view.segueCode, sender: view)
                          : PopUp.display(.error(description: parameter))
            }
        }
        
        switch response {
            case .success(let data):
                cities = data.cities.map { City(id: $0.id, name: $0.name) }
                KeychainManager.set(Person.toDomain(configuredProfile!))
                completion(true, segueCode)
            case .failure(let error):
                completion(false, error.message ?? "Ошибка при отправке запроса")
        }
    }

    private func buildRequestParams(from profile: Profile, date: String) -> [URLQueryItem] {
        var params = [URLQueryItem]()
        let userId = KeychainManager.get(UserId.self)!.id
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
