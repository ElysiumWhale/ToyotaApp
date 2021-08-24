import UIKit

class DealerViewController: UIViewController {
    @IBOutlet private var cityTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomStackView: UIStackView!
    @IBOutlet private var cityTextFieldIndicator: UIActivityIndicatorView!
    @IBOutlet private var nextButtonIndicator: UIActivityIndicatorView!
    @IBOutlet private var nextButton: UIButton!

    private var type: AddInfoType = .register

    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()

    private var cities: [City] = []
    private var selectedCity: City?
    private var showrooms: [DTOShowroom] = []
    private var selectedShowroom: DTOShowroom?

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.alpha = 0
        showroomStackView.alpha = 0
        hideKeyboardWhenTappedAround()
        configurePicker(cityPicker, with: #selector(cityDidSelect), for: cityTextField, delegate: self)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomTextField, delegate: self)
    }

    func configure(cityList: [City], showroomList: [DTOShowroom]? = nil,
                   city: City? = nil, showroom: DTOShowroom? = nil,
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
        switch segue.identifier {
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
    @IBAction private func cityDidSelect(sender: Any?) {
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
        let params = [URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.Toyota)),
                      URLQueryItem(name: RequestKeys.CarInfo.cityId, value: selectedCity!.id)]
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.getShowrooms,
                                              params: params,
                                              completion: completionForSelectedCity)
    }

    private func completionForSelectedCity(for response: Result<ShoroomsDidGetResponce, ErrorResponse>) {
        switch response {
            case .success(let data):
                showrooms = data.showrooms
                DispatchQueue.main.async { [weak self] in
                    self?.cityTextFieldIndicator.stopAnimating()
                    self?.showroomStackView.fadeIn()
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.cityTextFieldIndicator.stopAnimating()
                    PopUp.display(.error(description: error.message ?? "Попробуйте выбрать город еще раз"))
                }
        }
    }

    @IBAction private func showroomDidSelect(sender: Any?) {
        let row = showroomPicker.selectedRow(inComponent: 0)
        selectedShowroom = showrooms[row]
        showroomTextField?.text = showrooms[row].showroomName
        view.endEditing(true)
        nextButton.fadeIn()
    }
}

// MARK: - SegueWithRequestController
extension DealerViewController: SegueWithRequestController {
    typealias TResponse = Response

    var segueCode: String { SegueIdentifiers.DealerToCheckVin }

    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let showroom = selectedShowroom else {
            PopUp.display(.error(description: "Выберите салон"))
            return
        }
        
        if let showrooms = KeychainManager.get(Showrooms.self)?.value, !showrooms.isEmpty,
           showrooms.first(where: { $0.id == showroom.id }) != nil {
            performSegue(for: segueCode)
        } else {
            nextButton.fadeOut()
            nextButtonIndicator.startAnimating()
            let userId = KeychainManager.get(UserId.self)!.id
            let page = type == .register ? RequestPath.Registration.setShowroom : RequestPath.Profile.addShowroom
            let params = [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                          URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroom.id)]
            NetworkService.shared.makePostRequest(page: page, params: params,
                                                  completion: completionForSegue)
        }
    }
    
    private enum UIResult {
        case fail(message: String)
        case success
    }
    
    private func interfaceCompletion(for result: UIResult) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self else { return }
            view.nextButtonIndicator.stopAnimating()
            view.nextButton.fadeIn()
            
            switch result {
                case .fail(let message):
                    PopUp.display(.error(description: message))
                case .success:
                    view.performSegue(withIdentifier: view.segueCode, sender: view)
            }
        }
    }
    
    func completionForSegue(for response: Result<Response, ErrorResponse>) {
        switch response {
            case .success:
                guard let showroom = selectedShowroom,
                      let city = selectedCity else {
                    interfaceCompletion(for: .fail(message: AppErrors.unknownError.rawValue))
                    return
                }
                
                KeychainManager.update(Showrooms.self) { showrooms in
                    let showroom = Showroom(id: showroom.id, showroomName: showroom.showroomName, cityName: city.name)
                    guard let showrooms = showrooms else { return Showrooms([showroom]) }
                    
                    showrooms.value.append(showroom)
                    return showrooms
                }
                
                interfaceCompletion(for: .success)
            case .failure(let error):
                interfaceCompletion(for: .fail(message: error.message ?? AppErrors.unknownError.rawValue))
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
