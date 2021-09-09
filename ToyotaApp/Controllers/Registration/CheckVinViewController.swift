import UIKit

private enum SkipCheckVin: String {
    case yes = "1"
    case no = "0"
}

class CheckVinViewController: UIViewController {
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: KeyboardBindedButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var skipStepButton: UIButton!

    private var showroom: Showroom?
    private var type: AddInfoType = .register

    private var isSkipped: Bool = false
    private var vin: String = ""

    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.fadeOut(0.3)
        vinCodeTextField.toggleErrorState(hasError: false)
        vin = vinCodeTextField.text ?? ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as? EndRegistrationViewController
            default: return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        skipStepButton.isHidden = type != .register
        view.hideKeyboardWhenSwipedDown()
        checkVinButton.bindToKeyboard()
    }

    func configure(with: Showroom, controlerType: AddInfoType = .register) {
        showroom = with
        type = controlerType
    }
}

// MARK: - SegueWithRequestController
extension CheckVinViewController: SegueWithRequestController {
    typealias TResponse = CarDidCheckResponse

    var segueCode: String { SegueIdentifiers.CarToEndRegistration }

    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard vin.count == 17 else {
            vinCodeTextField.toggleErrorState(hasError: true)
            errorLabel.fadeIn(0.3)
            return
        }
        makeRequest(skip: .no, vin: vin)
    }

    @IBAction func skipButtonDidPressed(sender: Any?) {
        if type != .register { return }
        isSkipped = true
        makeRequest(skip: .yes)
    }

    private func makeRequest(skip: SkipCheckVin, vin: String? = "") {
        checkVinButton.fadeOut()
        indicator.startAnimating()
        
        let userId = KeychainManager.get(UserId.self)!.id
        NetworkService.shared.makePostRequest(page: .regisrtation(.checkVin), params:
                                                [URLQueryItem(.carInfo(.skipStep), skip.rawValue),
                                                 URLQueryItem(.carInfo(.showroomId), showroom!.id),
                                                 URLQueryItem(.carInfo(.vinCode), vin),
                                                 URLQueryItem(.auth(.userId), userId)],
                                              completion: completionForSegue)
    }

    func completionForSegue(for response: Result<CarDidCheckResponse, ErrorResponse>) {
        
        let completion = { [weak self] (isSuccess: Bool, parameter: String) in
            guard let view = self else { return }
            DispatchQueue.main.async {
                view.indicator.stopAnimating()
                view.checkVinButton.fadeIn()
                
                isSuccess ? view.performSegue(withIdentifier: view.segueCode, sender: view)
                          : PopUp.display(.error(description: parameter))
            }
        }
        
        switch response {
            case .success(let data):
                if isSkipped {
                    completion(true, segueCode)
                    return
                }
                guard let car = data.car?.toDomain(with: vin, showroom: showroom!.id) else {
                    completion(false, "Сервер прислал неверные данные, проверьте ввод и повторите регистрацию позже")
                    return
                }
                switch type {
                    case .register:
                        KeychainManager.set(Cars([car]))
                        performSegue(for: segueCode)
                    case .update(let proxy):
                        proxy.update(car, showroom!)
                        PopUp.display(.success(description: "Автомобиль успешно привязан к профилю"))
                        popToRootWithDispatch(animated: true)
                }
            case .failure(let error):
                completion(false, error.message ?? "Ошибка при проверке VIN-кода, проверьте правильность кода и попробуйте снова")
        }
    }
}
