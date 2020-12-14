import UIKit
    
protocol SegueWithRequestController {
    var segueCode: String { get }
    func nextButtonDidPressed(sender: Any?)
    var completionForSegue: (Data?) -> Void { get }
}
    
class DealerViewController: PickerController {
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var showroomTextField: UITextField!
    @IBOutlet var cityTextFieldIndicator: UIActivityIndicatorView!
    @IBOutlet var nextButtonIndicator: UIActivityIndicatorView!
    @IBOutlet var showroomLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()
    
    var cities: [City] = [City]()
    private var selectedCity: City?
    private var showrooms: [DTOShowroom] = [DTOShowroom]()
    private var selectedShowroom: DTOShowroom?
    
    private var responseCars: [DTOCar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePicker(view: cityPicker, with: #selector(cityDidSelect), for: cityTextField, delegate: self)
        configurePicker(view: showroomPicker, with: #selector(showroomDidSelect), for: showroomTextField, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCity = selectedCity, let selectedShowroom = selectedShowroom {
            cityPicker.selectRow(cities.firstIndex(where: {$0.id == selectedCity.id})!, inComponent: 0, animated: true)
            cityTextField.text = selectedCity.name
            showroomTextField.text = selectedShowroom.name
            showroomPicker.selectRow(showrooms.firstIndex(where: {$0.id == selectedShowroom.id})!, inComponent: 0, animated: true)
            showroomLabel.isHidden = false
            showroomTextField.isHidden = false
            nextButton.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as? AddingCarViewController
                destinationVC?.cars = responseCars
            default: return
        }
    }
    
    func configure(cityList: [City], showroomList: [DTOShowroom]? = nil, city: City? = nil, showroom: RegisteredUser.Showroom? = nil) {
        cities = cityList
        if let list = showroomList, let city = city, let showroom = showroom {
            selectedCity = city
            showrooms = list
            selectedShowroom = DTOShowroom(id: showroom.id, name: showroom.showroomName)
        }
    }
}

//MARK: - SegueWithRequestController
extension DealerViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.DealerToCar }
    
    @IBAction internal func nextButtonDidPressed(sender: Any?) {
        if let showroom = selectedShowroom {
            nextButton?.isHidden = true
            nextButtonIndicator.startAnimating()
            nextButtonIndicator.isHidden = false
            
            NetworkService.shared.makePostRequest(page: PostRequestPath.getCars, params: [URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId),
                 URLQueryItem(name: PostRequestKeys.showroomId, value: showroom.id)],
                completion: completionForSegue)
        } else { return }
    }
    
    var completionForSegue: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ShowroomDidSelectResponse.self, from: data)
                    responseCars = decodedResponse.cars
                    
                    if var user = UserInfo.buildFromDefaults() {
                        user.showrooms.append(UserInfo.Showroom(id: selectedShowroom!.id, showroomName: selectedShowroom!.name, cityName: selectedCity!.name))
                        user.saveToUserDefaults()
                    }
                    
                    DispatchQueue.main.async {
                        nextButtonIndicator.stopAnimating()
                        nextButtonIndicator.isHidden = true
                        nextButton.isHidden = false
                        performSegue(withIdentifier: segueCode, sender: self)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    DispatchQueue.main.async {
                        nextButtonIndicator.stopAnimating()
                        nextButtonIndicator.isHidden = true
                        nextButton.isHidden = false
                    }
                }
            }
        }
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
        NetworkService.shared.makePostRequest(page: PostRequestPath.getShowrooms, params: [URLQueryItem(name: PostRequestKeys.brandId, value: String(Brand.id)), URLQueryItem(name: PostRequestKeys.cityId, value: selectedCity!.id)], completion: completionForSelectedCity)
    }
    
    @objc private func showroomDidSelect(sender: Any?) {
        let row = showroomPicker.selectedRow(inComponent: 0)
        selectedShowroom = showrooms[row]
        showroomTextField?.text = showrooms[row].name
        view.endEditing(true)
        nextButton.isHidden = false
    }
    
    private var completionForSelectedCity: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let rawData = try JSONDecoder().decode(CityDidSelectResponce.self, from: data)
                    showrooms = rawData.showrooms
                    DispatchQueue.main.async {
                        cityTextFieldIndicator?.stopAnimating()
                        cityTextFieldIndicator?.isHidden = true
                        showroomTextField?.isHidden = false
                        showroomLabel?.isHidden = false
                    }
                }
                catch {
                    showrooms = [DTOShowroom(id: "0", name: "Ошибка десериализации")]
                    DispatchQueue.main.async {
                        cityTextFieldIndicator?.stopAnimating()
                        cityTextFieldIndicator?.isHidden = true
                        showroomTextField?.isHidden = false
                        showroomLabel?.isHidden = false
                    }
                }
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
            case showroomPicker: return showrooms[row].name
            default: return "Object is missing"
        }
    }
}
