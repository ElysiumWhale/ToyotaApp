import UIKit

class PersonalInfoViewController: KeyboardableController, PersonalInfoPresenterOutput {
    @IBOutlet private(set) var scrollView: UIScrollView!
    @IBOutlet private var firstNameTextField: InputTextField!
    @IBOutlet private var secondNameTextField: InputTextField!
    @IBOutlet private var lastNameTextField: InputTextField!
    @IBOutlet private var emailTextField: InputTextField!
    @IBOutlet private var birthTextField: InputTextField!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!

    private let datePicker: UIDatePicker = UIDatePicker()

    private lazy var fields = [firstNameTextField,
                               secondNameTextField,
                               lastNameTextField,
                               emailTextField,
                               birthTextField].compactMap { $0 }

    private(set) var interactor: PersonalInfoControllerOutput?
    private(set) var router: PersonalInfoRouter?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        hideKeyboardWhenTappedAround()

        fields.forEach {
            $0.delegate = self
            $0.rule = .personalInfo
        }
    }

    func configure(with profile: Profile) {
        interactor?.state = .configured(with: profile)
    }

    @objc private func dateDidSelect() {
        birthTextField.text = datePicker.date.asString(.client)
        view.endEditing(true)
    }

    private func setup() {
        let presenter = PersonalInfoPresenter(output: self)
        interactor = PersonalInfoInteractor(output: presenter)
        router = PersonalInfoRouter(controller: self)
    }

    @IBAction private func nextButtonDidPressed(sender: Any?) {
        guard fields.allSatisfy({ $0.isValid }) else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        nextButton.fadeOut()
        activitySwitcher.startAnimating()
        interactor?.setPerson(request: .init(firstName: firstNameTextField.inputText,
                                             secondName: secondNameTextField.inputText,
                                             lastName: lastNameTextField.inputText,
                                             email: emailTextField.inputText,
                                             date: datePicker.date.asString(.server)))
    }
}

// MARK: - Navigation
extension PersonalInfoViewController {
    override func viewWillAppear(_ animated: Bool) {
        setupKeyboard(isSubcribing: true)

        if case .configured(let profile) = interactor?.state {
            firstNameTextField.text = profile.firstName
            secondNameTextField.text = profile.secondName
            lastNameTextField.text = profile.lastName
            emailTextField.text = profile.email
            birthTextField.text = profile.birthdayDate?.asString(.client)
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
        router?.prepare(for: segue)
    }
}

// MARK: - PersonalInfoPresenterOutput
extension PersonalInfoViewController {
    func handle(state viewModel: PersonalInfoModels.SetPersonViewModel) {
        activitySwitcher.stopAnimating()
        nextButton.fadeIn()

        switch viewModel {
            case .success(let cities, let models, let colors):
                router?.goToScene(segue: .personInfoToCity, with: (cities, models, colors))
            case .failure(let errorMessage):
                PopUp.display(.error(description: errorMessage))
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
