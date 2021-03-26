import UIKit

class DealerViewController: UIViewController {
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var showroomTextField: UITextField!
    @IBOutlet var cityTextFieldIndicator: UIActivityIndicatorView!
    @IBOutlet var nextButtonIndicator: UIActivityIndicatorView!
    @IBOutlet var showroomLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    private var type: AddInfoType = .first
    
    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()
    
    var cities: [City] = [City]()
    private var selectedCity: City?
    private var showrooms: [DTOShowroom] = [DTOShowroom]()
    private var selectedShowroom: DTOShowroom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePicker(cityPicker, with: #selector(cityDidSelect), for: cityTextField, delegate: self)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomTextField, delegate: self)
    }
    
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
                destinationVC.configure(with: Showroom(id: selectedShowroom!.id, showroomName: selectedShowroom!.showroomName, cityName: selectedShowroom?.cityName ?? selectedCity!.name), controlerType: type)
            default: return
        }
    }
    
    func configure(cityList: [City], showroomList: [DTOShowroom]? = nil, city: City? = nil, showroom: DTOShowroom? = nil, controllerType: AddInfoType = .first) {
        cities = cityList
        if let list = showroomList, let city = city, let showroom = showroom {
            selectedCity = city
            showrooms = list
            selectedShowroom = showroom
        }
        type = controllerType
    }
}

//MARK: - SegueWithRequestController
extension DealerViewController: SegueWithRequestController {    
    var segueCode: String { SegueIdentifiers.DealerToCheckVin }
    
    @IBAction internal func nextButtonDidPressed(sender: Any?) {
        if let showroom = selectedShowroom {
            nextButton?.isHidden = true
            nextButtonIndicator.startAnimating()
            nextButtonIndicator.isHidden = false
            let userId = DefaultsManager.getUserInfo(UserId.self)!.id
            var page: String
            if case .first = type {
                page = RequestPath.Registration.setShowroom
            } else {
                page = RequestPath.Profile.addShowroom
            }
            NetworkService.shared.makePostRequest(page: page, params:
                [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                 URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroom.id)],
                completion: completionForSegue)
        } else { return }
    }
    
    func completionForSegue(for response: ShowroomDidSelectResponse?) {
        guard response != nil, response?.error_code == nil else {
            displayError(whith: response?.message ?? "Сервер прислал неверные данные")
            return
        }
        
        func completion(perform segue: Bool = false, error: String? = nil) {
            DispatchQueue.main.async { [self] in
                nextButtonIndicator.stopAnimating()
                nextButtonIndicator.isHidden = true
                nextButton.isHidden = false
                if segue {
                    performSegue(withIdentifier: segueCode, sender: self)
                } else { displayError(whith: error!) }
            }
        }
        
        if case .first = type {
            DefaultsManager.pushUserInfo(info: Showrooms([Showroom(id: selectedShowroom!.id, showroomName: selectedShowroom!.showroomName, cityName: selectedShowroom!.cityName ?? selectedCity!.name)]))
        }
        completion(perform: true)
    }
}

//MARK: - Pickers actions
extension DealerViewController {
    @objc private func cityDidSelect(sender: Any?) {
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
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.getShowrooms, params: [URLQueryItem(name: RequestKeys.Auth.brandId, value: String(Brand.id)), URLQueryItem(name: RequestKeys.CarInfo.cityId, value: selectedCity!.id)], completion: completionForSelectedCity)
    }
    
    @objc private func showroomDidSelect(sender: Any?) {
        let row = showroomPicker.selectedRow(inComponent: 0)
        selectedShowroom = showrooms[row]
        showroomTextField?.text = showrooms[row].showroomName
        view.endEditing(true)
        nextButton.isHidden = false
    }
    
    private var completionForSelectedCity: (CityDidSelectResponce?) -> Void {
        { [self] response in
            
            func uiCompletion() {
                DispatchQueue.main.async {
                    cityTextFieldIndicator.stopAnimating()
                    cityTextFieldIndicator.isHidden = true
                    showroomTextField.isHidden = false
                    showroomLabel.isHidden = false
                }
            }
            
            if let response = response {
                showrooms = response.showrooms
                uiCompletion()
            } else {
                showrooms = [DTOShowroom(id: "0", showroomName: "Ошибка десериализации", cityName: nil)]
                uiCompletion()
            }
        }
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
