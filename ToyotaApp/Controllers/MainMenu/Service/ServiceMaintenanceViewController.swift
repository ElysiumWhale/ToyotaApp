import UIKit

fileprivate struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

class ServiceMaintenanceViewController: UIViewController {
    @IBOutlet private var servicesTextField: UITextField!
    @IBOutlet private var datePicker: UIPickerView!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var createRequestButton: UIButton!
    @IBOutlet private var dateTimeLabel: UILabel!
    
    private var servicePicker: UIPickerView = UIPickerView()
    
    private var serviceType: ServiceType!
    private var chosenCar: Car!
    private var services: [Service] = []
    private var selectedService: Service?
    private var dates: [FreeTime] = []
    private var selectedDate: String {
        if !dates.isEmpty {
            let rowInFirst = datePicker.selectedRow(inComponent: 0)
            let rowInSecond = datePicker.selectedRow(inComponent: 1)
            let date = dates[rowInFirst]
            return "\(formatter.string(from: date.date)) \(date.freeTime[rowInSecond].getHourAndMinute())"
        } else { return "Empty" }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = serviceType.service_type_name
        configurePicker(servicePicker, with: #selector(serviceDidSelect), for: servicesTextField, delegate: self)
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServices, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: chosenCar.showroomId),
             URLQueryItem(name: RequestKeys.Services.serviceTypeId, value: serviceType.id)],
            completion: servicesDidGetCompletion)
    }
    
    private func servicesDidGetCompletion(for response: Result<ServicesDidGetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                services = data.services
            case .failure(let error):
                displayError(with: error.message ?? CommonText.servicesError)
                DispatchQueue.main.async { [self] in
                    navigationController?.popToRootViewController(animated: true)
                }
        }
    }
    
    @IBAction func serviceDidSelect(sender: Any?) {
        let row = servicePicker.selectedRow(inComponent: 0)
        selectedService = services[row]
        servicesTextField?.text = services[row].serviceName
        view.endEditing(true)
        dateTimeLabel.isHidden = true
        datePicker.isHidden = true
        dates.removeAll()
        indicator.isHidden = false
        indicator.startAnimating()
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getFreeTime, params:
                [URLQueryItem(name: RequestKeys.Services.serviceId, value: selectedService!.id),
                 URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: chosenCar.showroomId)],
                completion: didGetFreeTimeCompletion)
    }
    
    private func didGetFreeTimeCompletion(for response: Result<FreeTimeDidGetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    updateDates(from: data.freeTimeDict ?? Test.CreateFreeTimeDict())
                    datePicker.selectRow(0, inComponent: 0, animated: false)
                    datePicker.reloadAllComponents()
                    indicator.stopAnimating()
                    dateTimeLabel.isHidden = false
                    datePicker.isHidden = false
                    createRequestButton.isHidden = false
                }
            case .failure(let error):
                displayError(with: error.message ?? "Ошибка при получении времени для бронирования услуги") { [self] in
                    indicator.stopAnimating()
                }
        }
    }
    
    private func updateDates(from dict: [String:[Int]]) {
        for (date, times) in dict {
            guard let dateDebug = formatter.date(from: date), dateDebug > Date() else { continue }
            var freeHoursMinutes = [DateComponents]()
            for time in times {
                if let trueTime = TimeMap.map[time] { freeHoursMinutes.append(trueTime) }
            }
            dates.append(FreeTime(date: dateDebug, freeTime: freeHoursMinutes))
        }
    }
    
    @IBAction private func makeOrder(_ sender: UIButton) {
        PopUp.displayMessage(with: "Mock", description: "Mock", buttonText: "Ok")
    }
}

//MARK: - ServicesMapped
extension ServiceMaintenanceViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
        chosenCar = car
    }
}

#warning("todo: use extension methods for VC")
//MARK: - Date formatters
extension ServiceMaintenanceViewController {
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
    
    private var displayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
}

//MARK: - UIPickerViewDataSource
extension ServiceMaintenanceViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
            case datePicker: return 2
            case servicePicker: return 1
            default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case datePicker:
                switch component {
                    case 0: return dates.count
                    case 1: if dates.isEmpty { return 0 }
                            else { return dates[datePicker.selectedRow(inComponent: 0)].freeTime.count }
                    default: return 0
                }
            case servicePicker: return services.count
            default: return 0
        }
    }
}

//MARK: - UIPickerViewDelegate
extension ServiceMaintenanceViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case datePicker:
                switch component {
                    case 0: if dates.isEmpty { return "Empty" }
                            else { return displayFormatter.string(from: dates[row].date) }
                    case 1: if dates.isEmpty { return "Empty" }
                            else { return dates[datePicker.selectedRow(inComponent:0)]
                                          .freeTime[row].getHourAndMinute() }
                    default: return "Empty"
                }
            case servicePicker: return services[row].serviceName
            default: return "Empty"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case servicePicker: return
            case datePicker: datePicker.reloadComponent(1);
            default: return
        }
    }
}
