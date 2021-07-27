import UIKit

fileprivate enum SkipCheckVin: String {
    case yes = "1"
    case no = "0"
}

class CheckVinViewController: UIViewController {
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var skipStepButton: UIButton!
    
    private var showroom: Showroom?
    private var type: AddInfoType = .register
    
    private var isSkipped: Bool = false
    private var vin: String = ""
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
        vin = vinCodeTextField.text ?? ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as! EndRegistrationViewController
            default: return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipStepButton.isEnabled = type == .register
        skipStepButton.isHidden = type != .register
        hideKeyboardWhenTappedAround()
    }
    
    func configure(with: Showroom, controlerType: AddInfoType = .register) {
        showroom = with
        type = controlerType
    }
}

//MARK: - SegueWithRequestController
extension CheckVinViewController: SegueWithRequestController {
    typealias TResponse = CarDidCheckResponse
    
    var segueCode: String { SegueIdentifiers.CarToEndRegistration }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard vin.count == 17 else {
            vinCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            vinCodeTextField.layer.borderWidth = 1
            errorLabel.fadeIn(0.3)
            if checkVinButton.isHidden {
                indicator.stopAnimating()
                checkVinButton.fadeIn(0.6)
            }
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
        indicator.startAnimating()
        checkVinButton.fadeOut(0.6)
        
        let userId = KeychainManager.get(UserId.self)!.id
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkVin, params:
                    [URLQueryItem(name: RequestKeys.CarInfo.skipStep, value: skip.rawValue),
                     URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroom!.id),
                     URLQueryItem(name: RequestKeys.CarInfo.vinCode, value: vin),
                     URLQueryItem(name: RequestKeys.Auth.userId, value: userId)],
                    completion: completionForSegue)
    }
    
    func completionForSegue(for response: Result<CarDidCheckResponse, ErrorResponse>) {
        
        func failureCompletion(_ error: ErrorResponse) {
            displayError(with: error.message ?? "Ошибка при проверке VIN-кода, проверьте правильность кода и попробуйте снова") { [self] in
                indicator.stopAnimating()
                checkVinButton.fadeIn(0.6)
            }
        }
        
        switch response {
            case .success(let data):
                if isSkipped {
                    performSegue(for: segueCode)
                } else if let car = data.car?.toDomain(with: vin, showroom: showroom!.id) {
                    switch type {
                        case .register:
                            KeychainManager.set(Cars([car]))
                            performSegue(for: segueCode)
                        case .update(let proxy):
                            proxy.update(car, showroom!)
                            popToRootWithDispatch(animated: true) {
                                PopUp.displayMessage(with: "Успешно", description: "Автомобиль успешно привязан к профилю", buttonText: CommonText.ok)
                            }
                    }
                } else {
                    failureCompletion(ErrorResponse(code: "0", message: "Сервер прислал неверные данные, проверьте ввод и повторите регистрацию позже"))
                }
            case .failure(let error):
                failureCompletion(error)
        }
    }
}
