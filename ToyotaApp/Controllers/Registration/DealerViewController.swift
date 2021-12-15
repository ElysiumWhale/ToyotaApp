import UIKit

class DealerViewController: UIViewController, PickerController {
    // MARK: - UI
    @IBOutlet private var cityTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomStackView: UIStackView!
    @IBOutlet private var cityTextFieldIndicator: UIActivityIndicatorView!
    @IBOutlet private var nextButtonIndicator: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!

    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()

    // MARK: - Data
    private let segueCode = SegueIdentifiers.dealerToCheckVin

    private var type: AddInfoType = .register
    private var cities: [City] = []
    private var selectedCity: City?
    private var showrooms: [Showroom] = []
    private var selectedShowroom: Showroom?

    // MARK: - Request handlers
    private lazy var showroomsHandler: RequestHandler<ShoroomsDidGetResponce> = {
        let handler = RequestHandler<ShoroomsDidGetResponce>()
        handler.onSuccess = { [weak self] data in
            self?.showrooms = data.showrooms
            DispatchQueue.main.async {
                self?.cityTextFieldIndicator.stopAnimating()
                self?.showroomStackView.fadeIn()
            }
        }
        
        handler.onFailure = { [weak self] error in
            PopUp.display(.error(description: error.message ?? "Попробуйте выбрать город еще раз"))
            DispatchQueue.main.async {
                self?.cityTextFieldIndicator.stopAnimating()
            }
        }
        return handler
    }()
    
    private lazy var setInfoHandler: RequestHandler<Response> = {
        let handler = RequestHandler<Response>()
        handler.onSuccess = { [weak self] data in
            self?.handleSuccess(response: data)
        }
        handler.onFailure = { [weak self] error in
            self?.interfaceCompletion(for: .fail(message: error.message ?? .error(.unknownError)))
        }
        return handler
    }()
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.alpha = 0
        showroomStackView.alpha = 0
        hideKeyboardWhenTappedAround()
        configurePicker(cityPicker, with: #selector(cityDidSelect), for: cityTextField)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomTextField)
    }

    func configure(cityList: [City], showroomList: [Showroom]? = nil,
                   city: City? = nil, showroom: Showroom? = nil,
                   controllerType: AddInfoType = .register) {
        cities = cityList
        if let list = showroomList, let city = city, let showroom = showroom {
            selectedCity = city
            showrooms = list
            selectedShowroom = showroom
        }
        type = controllerType
    }
}

// MARK: - Navigation
extension DealerViewController {
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCity = selectedCity, let selectedShowroom = selectedShowroom {
            cityPicker.selectRow(cities.firstIndex(where: {$0.id == selectedCity.id})!, inComponent: 0, animated: true)
            cityTextField.text = selectedCity.name
            showroomTextField.text = selectedShowroom.showroomName
            showroomPicker.selectRow(showrooms.firstIndex(where: {$0.id == selectedShowroom.id})!, inComponent: 0, animated: true)
            showroomStackView.fadeIn()
            nextButton.fadeIn()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.code {
            case segueCode:
                let destinationVC = segue.destination as? CheckVinViewController
                let showroom = Showroom(id: selectedShowroom!.id,
                                        showroomName: selectedShowroom!.showroomName,
                                        cityName: selectedCity!.name)
                destinationVC?.configure(with: showroom, controlerType: type)
            default: return
        }
    }
}

// MARK: - Pickers actions
extension DealerViewController {
    @objc private func cityDidSelect() {
        nextButton.fadeOut()
        selectedShowroom = nil
        showroomTextField.text = ""
        showrooms.removeAll()
        showroomPicker.reloadComponent(0)
        let row = cityPicker.selectedRow(inComponent: 0)
        selectedCity = cities[row]
        cityTextField?.text = cities[row].name
        cityTextFieldIndicator.startAnimating()
        view.endEditing(true)
        NetworkService.makeRequest(page: .registration(.getShowrooms),
                                   params: [(.auth(.brandId), Brand.Toyota),
                                            (.carInfo(.cityId), selectedCity!.id)],
                                   handler: showroomsHandler)
    }

    @objc private func showroomDidSelect() {
        let row = showroomPicker.selectedRow(inComponent: 0)
        selectedShowroom = showrooms[row]
        showroomTextField?.text = showrooms[row].showroomName
        view.endEditing(true)
        nextButton.fadeIn()
    }
}

// MARK: - Settings showroom button handling
extension DealerViewController {
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let showroom = selectedShowroom else {
            PopUp.display(.error(description: .common(.chooseShowroom)))
            return
        }
        
        if let showrooms = KeychainManager<Showrooms>.get()?.value, !showrooms.isEmpty,
           showrooms.any({ $0.id == showroom.id }) {
            perform(segue: segueCode)
            return
        }
        
        nextButton.fadeOut()
        nextButtonIndicator.startAnimating()
        let userId = KeychainManager<UserId>.get()!.id
        let page: RequestPath = type == .register ? .registration(.setShowroom)
                                                  : .profile(.addShowroom)
        NetworkService.makeRequest(page: page,
                                   params: [(.auth(.userId), userId),
                                            (.carInfo(.showroomId), showroom.id)],
                                   handler: setInfoHandler)
    }

    private enum UIResult {
        case fail(message: String)
        case success
    }

    private func handleSuccess(response: Response) {
        guard let showroom = selectedShowroom,
              let city = selectedCity else {
                  interfaceCompletion(for: .fail(message: .error(.unknownError)))
                  return
              }
        
        KeychainManager<Showrooms>.update { showrooms in
            let showroom = Showroom(id: showroom.id, showroomName: showroom.showroomName, cityName: city.name)
            guard let showrooms = showrooms else { return Showrooms([showroom]) }
            
            showrooms.value.append(showroom)
            return showrooms
        }
        
        interfaceCompletion(for: .success)
    }

    private func interfaceCompletion(for result: UIResult) {
        DispatchQueue.main.async { [self] in
            nextButtonIndicator.stopAnimating()
            nextButton.fadeIn()
            
            switch result {
                case .fail(let message):
                    PopUp.display(.error(description: message))
                case .success:
                    perform(segue: .dealerToCheckVin)
            }
        }
    }
}

// MARK: - UIPickerViewDataSource
extension DealerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case cityPicker: return cities.count
            case showroomPicker: return showrooms.count
            default: return 1
        }
    }
}

// MARK: - UIPickerViewDelegate
extension DealerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case cityPicker: return cities[row].name
            case showroomPicker: return showrooms[row].showroomName
            default: return "Object is missing"
        }
    }
}
