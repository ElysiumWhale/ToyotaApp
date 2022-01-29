import UIKit

class PersonalInfoViewController: KeyboardableController {
    @IBOutlet private(set) var scrollView: UIScrollView!
    @IBOutlet private var firstNameTextField: InputTextField!
    @IBOutlet private var secondNameTextField: InputTextField!
    @IBOutlet private var lastNameTextField: InputTextField!
    @IBOutlet private var emailTextField: InputTextField!
    @IBOutlet private var birthTextField: InputTextField!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!

    private let datePicker: UIDatePicker = UIDatePicker()

    private var textFieldsWithError: [UITextField: Bool] = [:]

    private var date: String = .empty
    private var isConfigured: Bool = false
    private var configuredProfile: Profile?
    private var configureSelectCity: ParameterClosure<CityPickerViewController?>?

    private lazy var requestHandler: RequestHandler<CitiesResponse> = {
        RequestHandler<CitiesResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.handle(data)
                self?.handleUI(isSuccess: true)
            } onFailure: { [weak self] error in
                self?.handleUI(isSuccess: false)
                PopUp.display(.error(description: error.message ?? .error(.requestError)))
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        hideKeyboardWhenTappedAround()
        textFieldsWithError = [
            firstNameTextField: true, secondNameTextField: true,
            lastNameTextField: true, emailTextField: true, birthTextField: true
        ]
        textFieldsWithError.keys.forEach {
            $0.delegate = self
        }
    }

    func configure(with profile: Profile) {
        configuredProfile = profile
        isConfigured = true
    }

    private var hasErrors: Bool {
        return !textFieldsWithError.values.allSatisfy { !$0 }
    }

    @IBAction private func textDidChange(sender: UITextField) {
        let isNormal = sender.text != nil && sender.text!.isNotEmpty && sender.text!.count < 25
        sender.toggle(state: isNormal ? .normal : .error)
        textFieldsWithError[sender] = !isNormal
    }

    @objc private func dateDidSelect() {
        date = datePicker.date.asString(.server)
        birthTextField.text = datePicker.date.asString(.client)
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
            birthTextField.text = profile.birthdayDate?.asString(.client)
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
        switch segue.code {
            case .personInfoToCity:
                let destinationVC = segue.destination as? CityPickerViewController
                configureSelectCity?(destinationVC)
            default: return
        }
    }
}

// MARK: - UITextFieldDelegate
extension PersonalInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case firstNameTextField:
                lastNameTextField.becomeFirstResponder()
            case lastNameTextField:
                secondNameTextField.becomeFirstResponder()
            case secondNameTextField:
                emailTextField.becomeFirstResponder()
            case emailTextField:
                birthTextField.becomeFirstResponder()
            default:
                view.endEditing(false)
        }

        return false
    }
}

// MARK: - Request handling
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

    private func handle(_ response: CitiesResponse) {
        configureSelectCity = { vc in
            vc?.configure(with: response.cities.map { City(id: $0.id, name: $0.name) },
                          models: response.models ?? [],
                          colors: response.colors ?? [])
        }
        KeychainManager.set(Person.toDomain(configuredProfile!))
    }

    private func handleUI(isSuccess: Bool) {
        activitySwitcher.stopAnimating()
        nextButton.fadeIn()
        if isSuccess {
            perform(segue: .personInfoToCity)
        }
    }

    private func buildRequestParams(from profile: Profile, date: String) -> RequestItems {
        [((.auth(.brandId), Brand.Toyota)),
         ((.auth(.userId), KeychainManager<UserId>.get()!.id)),
         ((.personalInfo(.firstName), profile.firstName)),
         ((.personalInfo(.secondName), profile.secondName)),
         ((.personalInfo(.lastName), profile.lastName)),
         ((.personalInfo(.email), profile.email)),
         ((.personalInfo(.birthday), date))]
    }
}
