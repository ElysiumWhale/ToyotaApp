import UIKit

class DealerViewController: UIViewController {
    @IBOutlet var cityTextField: UITextField?
    @IBOutlet var showroomTextField: UITextField?
    @IBOutlet var activitySwitcher: UIActivityIndicatorView?
    @IBOutlet var showroomLabel: UILabel?
    @IBOutlet var nextButton: UIButton!
    
    var cities: [City] = [City]()
    private var selectedCity: City?
    private var showrooms: [Showroom] = [Showroom]()
    private var selectedShowroom: Showroom?
    
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
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: nil)
                doneButton.primaryAction = UIAction(handler: pickerDidSelect)
            case showroomPicker:
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: nil)
                doneButton.primaryAction = UIAction(handler: pickerDidSelect)
            default: doneButton = UIBarButtonItem(title: "Ошибка", style: .done, target: nil, action: nil)
        }
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
    
    private func pickerDidSelect(sender: Any?) {
        if let picker = (sender as! UIPickerView?) {
            switch picker {
                case cityPicker:
                    nextButton.isHidden = true
                    let row = cityPicker.selectedRow(inComponent: 0)
                    selectedCity = cities[row]
                    cityTextField?.text = cities[row].name
                    activitySwitcher?.startAnimating()
                    view.endEditing(true)
                    NetworkService.shared.makePostRequest(page: PostRequestPath.getShowrooms, params: [URLQueryItem(name: PostRequestKeys.brand_id, value: String(Brand.id)), URLQueryItem(name: PostRequestKeys.city_id, value: selectedCity!.id)], completion: completion)
                case showroomPicker:
                    let row = showroomPicker.selectedRow(inComponent: 0)
                    selectedShowroom = showrooms[row]
                    showroomTextField?.text = showrooms[row].name
                    view.endEditing(true)
                    nextButton.isHidden = false
                default: return
            }
        }
    }
    
    private var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let rawData = try JSONDecoder().decode(CityDidSelectResponce.self, from: data)
                    showrooms = rawData.showrooms
                    DispatchQueue.main.async {
                        activitySwitcher?.stopAnimating()
                        activitySwitcher?.isHidden = true
                        showroomTextField?.isHidden = false
                        showroomLabel?.isHidden = false
                    }
                }
                catch {
                    showrooms = [Showroom(id: "0", name: "Ошибка десериализации")]
                    DispatchQueue.main.async {
                        activitySwitcher?.stopAnimating()
                        activitySwitcher?.isHidden = true
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
