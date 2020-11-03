import UIKit

class DealerViewController: UIViewController {
    @IBOutlet var cityTextField: UITextField?
    @IBOutlet var dealerTextField: UITextField?
    @IBOutlet var activitySwitcher: UIActivityIndicatorView?
    @IBOutlet var dealerLabel: UILabel?
    
    var cities: [City] = [City]()
    private var selectedCity: City?
    private var dealers: [Dealer] = [Dealer]()
    private var selectedDealer: Dealer?
    
    private var cityPicker: UIPickerView!
    private var dealerPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityPicker = UIPickerView()
        dealerPicker = UIPickerView()
        configureCityPickerView()
        configureDealerPickerView()
        if cities.isEmpty {
            cities.append(City(id: "1", cityName: "Самара"))
            cities.append(City(id: "2", cityName: "Сызрань"))
        }
    }
    
    private var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let rawData = try JSONDecoder().decode(CityDidSelectResponce.self, from: data)
                    dealers = rawData.dealers
                    DispatchQueue.main.async {
                        activitySwitcher?.stopAnimating()
                        activitySwitcher?.isHidden = true
                        dealerTextField?.isHidden = false
                        dealerLabel?.isHidden = false
                    }
                }
                catch {
                    dealers = [Dealer(id: "0", address: "Error")]
                    DispatchQueue.main.async {
                        activitySwitcher?.stopAnimating()
                        activitySwitcher?.isHidden = true
                        dealerTextField?.isHidden = false
                        dealerLabel?.isHidden = false
                    }
                }
            }
        }
    }
    
    //MARK: - Pickers Configuration
    private func configureCityPickerView() {
        cityPicker.dataSource = self
        cityPicker.delegate = self
        cityTextField!.inputAccessoryView = buildToolbar(for: cityPicker)
        cityTextField!.inputView = cityPicker
    }

    private func configureDealerPickerView() {
        dealerPicker.dataSource = self
        dealerPicker.delegate = self
        dealerTextField!.inputAccessoryView = buildToolbar(for: dealerPicker)
        dealerTextField!.inputView = dealerPicker
    }
    
    private func buildToolbar(for pickerView: UIPickerView) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneButton: UIBarButtonItem
        switch pickerView {
            case cityPicker:
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(cityDidPick))
            case dealerPicker:
                doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(dealerDidPick))
            default: doneButton = UIBarButtonItem(title: "Error", style: .done, target: nil, action: nil)
        }
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
    
    //MARK: - Pickers handlers
    @objc private func cityDidPick(sender: Any?) {
        let row = cityPicker.selectedRow(inComponent: 0)
        selectedCity = cities[row]
        cityTextField?.text = cities[row].cityName
        activitySwitcher?.startAnimating()
        view.endEditing(true)
        NetworkService.shared.makePostRequest(page: PostRequestPath.getShowrooms, params: [URLQueryItem(name: PostRequestKeys.brand_id, value: String(Brand.id)), URLQueryItem(name: PostRequestKeys.city_id, value: selectedCity!.id)], completion: completion)
    }
    
    @objc private func dealerDidPick(sender: Any?) {
        let row = dealerPicker.selectedRow(inComponent: 0)
        selectedDealer = dealers[row]
        dealerTextField?.text = dealers[row].address
        view.endEditing(true)
    }
}

//MARK: - UIPickerView DataSource
extension DealerViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case cityPicker: return cities.count
            case dealerPicker: return dealers.count
            default: return 1
        }
    }
}

extension DealerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case cityPicker: return cities[row].cityName
            case dealerPicker: return dealers[row].address
            default: return "Object is missing"
        }
    }
}
