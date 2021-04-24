import UIKit

class DealerViewController: UIViewController {
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var showroomTextField: UITextField!
    @IBOutlet var cityTextFieldIndicator: UIActivityIndicatorView!
    @IBOutlet var nextButtonIndicator: UIActivityIndicatorView!
    @IBOutlet var showroomLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    private var type: AddInfoType = .register
    
    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()
    
    private var cities: [City] = []
    private var selectedCity: City?
    private var showrooms: [DTOShowroom] = []
    private var selectedShowroom: DTOShowroom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePicker(cityPicker, with: #selector(cityDidSelect), for: cityTextField, delegate: self)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomTextField, delegate: self)
    }
    
    func configure(cityList: [City], showroomList: [DTOShowroom]? = nil, city: City? = nil, showroom: DTOShowroom? = nil, controllerType: AddInfoType = .register) {
        cities = cityList
        if let list = showroomList, let city = city, let showroom = showroom {
            selectedCity = city
            showrooms = list
            selectedShowroom = showroom
        }
        type = controllerType
    }
}

//MARK: - Navigation
extension DealerViewController {
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCity = selectedCity, let selectedShowroom = selectedShowroom {
            cityPicker.selectRow(cities.firstIndex(where: {$0.id == selectedCity.id})!, inComponent: 0, animated: true)
            cityTextField.text = selectedCity.name
            showroomTextField.text = selectedShowroom.showroomName
            showroomPicker.selectRow(showrooms.firstIndex(where: {$0.id == selectedShowroom.id})!, inComponent: 0, animated: true)
            showroomLabel.isHidden = false
            showroomTextField.isHidden = false
            nextButton.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as! CheckVinViewController
                destinationVC.configure(with: Showroom(id: selectedShowroom!.id, showroomName: selectedShowroom!.showroomName, cityName: selectedCity!.name), controlerType: type)
            default: return
        }
    }
}

//MARK: - SegueWithRequestController
extension DealerViewController: SegueWithRequestController {
    typealias TResponse = Response
    
    var segueCode: String { SegueIdentifiers.DealerToCheckVin }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let showroom = selectedShowroom else {
            displayError(with: "Выберите салон")
            return
        }
        nextButton.isHidden = true
        nextButtonIndicator.startAnimating()
        nextButtonIndicator.isHidden = false
        let userId = DefaultsManager.getUserInfo(UserId.self)!.id
        let page = type == .register ? RequestPath.Registration.setShowroom : RequestPath.Profile.addShowroom
        NetworkService.shared.makePostRequest(page: page, params:
            [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
             URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroom.id)],
            completion: completionForSegue)
    }
    
    #warning("todo: rework response")
    func completionForSegue(for response: Result<Response, ErrorResponse>) {
        let uiCompletion = { [self] in
            nextButton.isHidden = false
            nextButtonIndicator.stopAnimating()
            nextButtonIndicator.isHidden = true
        }
        
        switch response {
            case .success(let data):
                if data.result == "ok" {
                    if type == .register {
                        DefaultsManager.pushUserInfo(info: Showrooms([Showroom(id: selectedShowroom!.id,    showroomName: selectedShowroom!.showroomName, cityName: selectedCity!.name)]))
                    }
                    performSegue(for: segueCode, beforeAction: uiCompletion)
                } else {
                    displayError(with: "Требуется переработка Response", beforePopUpAction: uiCompletion)
                }
            case .failure(let error):
                displayError(with: error.message ?? AppErrors.unknownError.rawValue, beforePopUpAction: uiCompletion)
        }
    }
}

//MARK: - Pickers actions
extension DealerViewController {
    @IBAction private func cityDidSelect(sender: Any?) {
        nextButton.isHidden = true
        if selectedShowroom != nil, !showrooms.isEmpty {
            selectedShowroom = nil
            showroomTextField.text = ""
            showrooms.removeAll()
            showroomPicker.reloadComponent(0)
        }
        let row = cityPicker.selectedRow(inComponent: 0)
        selectedCity = cities[row]
        cityTextField?.text = cities[row].name
        cityTextFieldIndicator?.startAnimating()
        view.endEditing(true)
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.getShowrooms, params: [URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.Toyota)), URLQueryItem(name: RequestKeys.CarInfo.cityId, value: selectedCity!.id)], completion: completionForSelectedCity)
    }
    
    private func completionForSelectedCity(for response: Result<CityDidSelectResponce, ErrorResponse>) {
        switch response {
            case .success(let data):
                showrooms = data.showrooms
                DispatchQueue.main.async { [self] in
                    cityTextFieldIndicator.stopAnimating()
                    cityTextFieldIndicator.isHidden = true
                    showroomTextField.isHidden = false
                    showroomLabel.isHidden = false
                }
            case .failure(let error):
                displayError(with: error.message ?? "Попробуйте выбрать город еще раз") { [self] in
                    cityTextFieldIndicator.stopAnimating()
                    cityTextFieldIndicator.isHidden = true
                }
        }
    }
    
    @IBAction private func showroomDidSelect(sender: Any?) {
        let row = showroomPicker.selectedRow(inComponent: 0)
        selectedShowroom = showrooms[row]
        showroomTextField?.text = showrooms[row].showroomName
        view.endEditing(true)
        nextButton.isHidden = false
    }
}

//MARK: - UIPickerViewDataSource
extension DealerViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case cityPicker: return cities.count
            case showroomPicker: return showrooms.count
            default: return 1
        }
    }
}

//MARK: - UIPickerViewDelegate
extension DealerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case cityPicker: return cities[row].name
            case showroomPicker: return showrooms[row].showroomName
            default: return "Object is missing"
        }
    }
}
