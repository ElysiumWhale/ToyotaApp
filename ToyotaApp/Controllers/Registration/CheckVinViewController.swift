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

    private let segueCode = SegueIdentifiers.carToEndRegistration

    private var showroom: Showroom?
    private var type: AddInfoType = .register

    private var isSkipped: Bool = false
    private var vin: String = .empty

    private lazy var requestHandler: RequestHandler<CarCheckResponse> = {
        let handler = RequestHandler<CarCheckResponse>()
        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handleSuccess(data)
            }
        }
        handler.onFailure = { [weak self] error in
            self?.interfaceCompletion(false, error.message ?? .error(.vinCodeError))
        }
        return handler
    }()

    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.fadeOut(0.3)
        vinCodeTextField.toggle(state: .normal)
        vin = vinCodeTextField.text ?? .empty
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.code {
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
extension CheckVinViewController {
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard vin.count == 17 else {
            vinCodeTextField.toggle(state: .error)
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

    private func makeRequest(skip: SkipCheckVin, vin: String = .empty) {
        checkVinButton.fadeOut()
        indicator.startAnimating()
        
        let userId = KeychainManager<UserId>.get()!.id
        NetworkService.makeRequest(page: .registration(.checkVin),
                                   params: [(.carInfo(.skipStep), skip.rawValue),
                                            (.carInfo(.showroomId), showroom!.id),
                                            (.carInfo(.vinCode), vin),
                                            (.auth(.userId), userId)],
                                   handler: requestHandler)
    }

    private func handleSuccess(_ response: CarCheckResponse) {
        if isSkipped {
            interfaceCompletion(true)
            return
        }
        guard let car = response.car?.toDomain(with: vin, showroom: showroom!.id) else {
            interfaceCompletion(false, .error(.serverBadResponse))
            return
        }
        switch type {
            case .register:
                KeychainManager.set(Cars([car]))
                perform(segue: segueCode)
            case .update(let proxy):
                proxy.updateSelected(car: car)
                PopUp.display(.success(description: .common(.autoLinked)))
                popToRootWithDispatch(animated: true)
        }
    }

    private func interfaceCompletion(_ isSuccess: Bool, _ parameter: String = .empty) {
        DispatchQueue.main.async { [self] in
            indicator.stopAnimating()
            checkVinButton.fadeIn()
            
            isSuccess ? perform(segue: segueCode)
                      : PopUp.display(.error(description: parameter))
        }
    }
}
