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

    private let segueCode = SegueIdentifiers.PersonInfoToDealer
    private let datePicker: UIDatePicker = UIDatePicker()

    private var textFieldsWithError: [UITextField: Bool] = [:]

    private var cities: [City] = []
    private var date: String = ""

    private var isConfigured: Bool = false
    private var configuredProfile: Profile?

    private lazy var requestHandler: RequestHandler<CitiesDidGetResponse> = {
        let handler = RequestHandler<CitiesDidGetResponse>()
        
        handler.onSuccess = { [weak self] data in
            self?.handle(data)
            DispatchQueue.main.async {
                self?.handleUI(isSuccess: true)
            }
        }
        
        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.handleUI(isSuccess: false)
                PopUp.display(.error(description: error.message ?? .error(.requestError)))
            }
        }
        
        return handler
    }()

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

// MARK: - Requrst handling
extension PersonalInfoViewController {
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard !hasErrors, let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let secondName = secondNameTextField.text,
              let email = emailTextField.text else {
                  PopUp.display(.error(description: .error(.checkInput)))
                  return
        }
        
        nextButton.fadeOut()
        activitySwitcher.startAnimating()
        configuredProfile = Profile(phone: nil, firstName: firstName,
                                    lastName: lastName, secondName: secondName,
                                    email: email, birthday: date)
        NetworkService.makeRequest(page: .registration(.setProfile),
                                   params: buildRequestParams(from: configuredProfile!, date: date),
                                   handler: requestHandler)
    }

    private func handle(_ response: CitiesDidGetResponse) {
        cities = response.cities.map { City(id: $0.id, name: $0.name) }
        KeychainManager.set(Person.toDomain(configuredProfile!))
    }

    private func handleUI(isSuccess: Bool) {
        activitySwitcher.stopAnimating()
        nextButton.fadeIn()
        if isSuccess {
            performSegue(withIdentifier: segueCode, sender: self)
        }
    }

    private func buildRequestParams(from profile: Profile, date: String) -> [URLQueryItem] {
        var params = [URLQueryItem]()
        let userId = KeychainManager.get(UserId.self)!.id
        params.append(URLQueryItem(.auth(.brandId), Brand.Toyota))
        params.append(URLQueryItem(.auth(.userId), userId))
        params.append(URLQueryItem(.personalInfo(.firstName), profile.firstName))
        params.append(URLQueryItem(.personalInfo(.secondName), profile.secondName))
        params.append(URLQueryItem(.personalInfo(.lastName), profile.lastName))
        params.append(URLQueryItem(.personalInfo(.email), profile.email))
        params.append(URLQueryItem(.personalInfo(.birthday), date))
        return params
    }
}
