import UIKit
    
protocol SegueWithRequestController {
    var segueCode: String { get }
    func nextButtonDidPressed(sender: Any?)
    var completionForSegue: (Data?) -> Void { get }
}
    
class DealerViewController: UIViewController {
    @IBOutlet var cityTextField: UITextField?
    @IBOutlet var showroomTextField: UITextField?
    @IBOutlet var cityTextFieldIndicator: UIActivityIndicatorView?
    @IBOutlet var nextButtonIndicator: UIActivityIndicatorView?
    @IBOutlet var showroomLabel: UILabel?
    @IBOutlet var nextButton: UIButton!
    
    var cities: [City] = [City]()
    private var selectedCity: City?
    private var showrooms: [Showroom] = [Showroom]()
    private var selectedShowroom: Showroom?
    
    private var responseCars: [Car]?
    
    private var cityPicker: UIPickerView = UIPickerView()
    private var showroomPicker: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCityPickerView()
        configureShowroomPickerView()
        if cities.isEmpty {
            cities.append(City(id: "1", name: "Самара"))
            cities.append(City(id: "2", name: "Сызрань"))
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
}
    
//MARK: - SegueWithRequestController
extension DealerViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.DealerToCar }
    
    @IBAction internal func nextButtonDidPressed(sender: Any?) {
        if let showroom = selectedShowroom {
            nextButton?.isHidden = true
            nextButtonIndicator?.startAnimating()
            nextButtonIndicator?.isHidden = false
            
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
                    DispatchQueue.main.async {
                        performSegue(withIdentifier: segueCode, sender: self)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
//                    DispatchQueue.main.async {
//                        nextButtonIndicator?.stopAnimating()
//                        nextButtonIndicator?.isHidden = true
//                        nextButton.isHidden = false
//                    }
                    #warning("debug flow")
                    responseCars = [Car(id: "3", brand_name: "Toyta", model_name: "Prado", color_name: "Слоновая кость", color_swatch: "edf5f6", color_description: "Светло бежевый", color_metallic: "1", license_plate: "а228аа163rus", vin_code: "")]
                    DispatchQueue.main.async {
                        performSegue(withIdentifier: segueCode, sender: self)
                    }
                }
            }
        }
    }
}
    
//MARK: - Pickers Configuration
extension DealerViewController {
    private func configureCityPickerView() {
        cityPicker.dataSource = self
        cityPicker.delegate = self
        cityTextField!.inputAccessoryView = buildToolbar(for: cityPicker)
        cityTextField!.inputView = cityPicker
    }
    
    private func configureShowroomPickerView() {
        showroomPicker.dataSource = self
        showroomPicker.delegate = self
        showroomTextField!.inputAccessoryView = buildToolbar(for: showroomPicker)
        showroomTextField!.inputView = showroomPicker
    }
    
    private func buildToolbar(for pickerView: UIPickerView) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneButton: UIBarButtonItem
        switch pickerView {
            case cityPicker:
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(cityDidSelect))
                //doneButton.primaryAction = UIAction(handler: pickerDidSelect)
            case showroomPicker:
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(showroomDidSelect))
                //doneButton.primaryAction = UIAction(handler: pickerDidSelect)
            default: doneButton = UIBarButtonItem(title: "Ошибка", style: .done, target: nil, action: nil)
        }
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
    
    @objc private func cityDidSelect(sender: Any?) {
        nextButton.isHidden = true
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
                    showrooms = [Showroom(id: "0", name: "Ошибка десериализации")]
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

//MARK: - UIPickerView DataSource
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

extension DealerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case cityPicker: return cities[row].name
            case showroomPicker: return showrooms[row].name
            default: return "Object is missing"
        }
    }
}
