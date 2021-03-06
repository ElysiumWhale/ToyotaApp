import UIKit

fileprivate struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

class ServiceMaintenanceViewController: UIViewController {
    @IBOutlet private(set) var servicesTextField: UITextField!
    @IBOutlet private(set) var datePicker: UIPickerView!
    @IBOutlet private(set) var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) var createRequestButton: UIButton!
    @IBOutlet private(set) var dateTimeLabel: UILabel!
    
    private var servicePicker: UIPickerView = UIPickerView()
    
    private var serviceType: ServiceType!
    private var chosenCar: Car!
    private var services: [Service] = [Service]()
    private var selectedService: Service?
    
    private var dates: [FreeTime] = [FreeTime]()
    private var selectedDate: String {
        if !dates.isEmpty {
            let rowInFirst = datePicker.selectedRow(inComponent: 0)
            let rowInSecond = datePicker.selectedRow(inComponent: 1)
            let date = dates[rowInFirst]
            return "\(formatter.string(from: date.date)) \(date.freeTime[rowInSecond].getHourAndMinute())"
        } else { return "Empty" }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = serviceType.service_type_name
        configurePicker(servicePicker, with: #selector(serviceDidSelect), for: servicesTextField, delegate: self)
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServices, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: chosenCar.showroomId),
             URLQueryItem(name: RequestKeys.Services.serviceTypeId, value: serviceType.id)],
            completion: completion)
    }
    
    func completion(response: ServicesDidGetResponse?) {
        if let array = response?.services {
            services = array
        }
    }
    
    @objc func serviceDidSelect(sender: Any?) {
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
    
    func didGetFreeTimeCompletion(response: FreeTimeDidGetResponse?) {
        guard response?.errorCode == nil else {
            displayError(whith: response?.message ?? "Ошибка при получении времени для бронирования услуги")
            indicator.stopAnimating()
            return
        }
        
        var freeTime: [String:[Int]] = [String:[Int]]()
        if let freeTimeDict = response?.freeTimeDict {
            freeTime = freeTimeDict
        } else {
            freeTime = ["2021-02-02":[18,19,20,21,22,23,24],
                        "2021-02-05":[22,25,30,32,34],
                        "2021-05-21":[18,23,27,30]]
        }
        
        DispatchQueue.main.async { [self] in
            updateDates(from: freeTime)
            datePicker.selectRow(0, inComponent: 0, animated: false)
            datePicker.reloadAllComponents()
            indicator.stopAnimating()
            indicator.isHidden = true
            dateTimeLabel.isHidden = false
            datePicker.isHidden = false
            createRequestButton.isHidden = false
        }
    }
    
    private func updateDates(from dict: [String:[Int]]) {
        for (date, times) in dict {
            #warning("to-do: date parsing is wrong")
            if let date = Calendar.current.date(byAdding: DateComponents(hour: 4, nanosecond: 1), to: formatter.date(from: date)!)  {
                if date > Date() {
                    var freeHoursMinutes = [DateComponents]()
                    for time in times {
                        freeHoursMinutes.append(TimeMap.map[time]!)
                    }
                    dates.append(FreeTime(date: date, freeTime: freeHoursMinutes))
                }
            }
        }
    }
    @IBAction func makeOrder(_ sender: UIButton) {
        
    }
}

//MARK: - ServicesMapped
extension ServiceMaintenanceViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
        chosenCar = car
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
