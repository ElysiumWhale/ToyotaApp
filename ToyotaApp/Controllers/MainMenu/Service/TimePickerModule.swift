import Foundation
import UIKit

fileprivate struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

//MARK: - View
class TimePickerView: UIView {
    private(set) lazy var datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private(set) lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaSemiBold(of: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
    }
    
    private func configureSubviews() {
        addSubview(dateTimeLabel)
        addSubview(datePicker)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateTimeLabel.topAnchor.constraint(equalTo: topAnchor),
            dateTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateTimeLabel.leadingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.leadingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.widthAnchor.constraint(equalTo: widthAnchor, constant: 0),
            datePicker.heightAnchor.constraint(equalToConstant: 150),
            dateTimeLabel.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -5)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
      return true
    }
    
    func dataDidDownload() {
        DispatchQueue.main.async { [self] in
            datePicker.selectRow(0, inComponent: 0, animated: false)
            datePicker.reloadAllComponents()
            isHidden = false
            dateTimeLabel.isHidden = false
            datePicker.isHidden = false
        }
    }
}

//MARK:  - Module
class TimePickerModule: NSObject, IServiceModule {
    var view: UIView? { internalView }
    
    private(set) lazy var internalView: TimePickerView = {
        let view = TimePickerView()
        view.datePicker.delegate = self
        view.datePicker.dataSource = self
        view.isHidden = true
        return view
    }()
    
    private var dates: [FreeTime] = []
    
    private var selectedDate: (String, String)? {
        if !dates.isEmpty {
            let rowInFirst = internalView.datePicker.selectedRow(inComponent: 0)
            let rowInSecond = internalView.datePicker.selectedRow(inComponent: 1)
            let date = dates[rowInFirst]
            return (formatter.string(from: date.date), date.freeTime[rowInSecond].getHourAndMinute())
        } else { return nil }
    }
    
    private(set) var serviceType: ServiceType
    
    private(set) var result: Result<Service, ErrorResponse>?
    
    private(set) weak var delegate: IServiceController?
    
    init(with type: ServiceType, for controller: IServiceController) {
        delegate = controller
        serviceType = type
    }
    
    func configureViewText(with labelText: [String]) {
        guard let view = view as? TimePickerView else {
            return
        }
        view.dateTimeLabel.text = labelText[1]
    }
    
    func start(with params: [URLQueryItem]) {
        guard let showroomId = delegate?.user?.getSelectedShowroom?.id else {
            return
        }
        
        var queryParams: [URLQueryItem] = [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId)]
        if !params.isEmpty {
            queryParams.append(contentsOf: params)
        }
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getFreeTime, params: queryParams, completion: completion)
        
        func completion(for response: Result<FreeTimeDidGetResponse, ErrorResponse>) {
            switch response {
                case .failure(let error):
                    result = .failure(ErrorResponse(code: "1", message: error.message ?? "Ошибка"))
                    delegate?.moduleDidUpdated(self)
                case .success(let data):
                    updateDates(from: data.freeTimeDict)
                    internalView.dataDidDownload()
                    result = .success(Service(id: "0", serviceName: "Success"))
                    delegate?.moduleDidUpdated(self)
            }
        }
    }
    
    func buildQueryItems() -> [URLQueryItem] {
        if let (date, time) = selectedDate {
            return [URLQueryItem(name: RequestKeys.Services.dateBooking, value: date), URLQueryItem(name: RequestKeys.Services.startBooking, value: time)]
        } else { return [] }
    }
    
    func configure(for controller: IServiceController) {
        delegate = controller
    }
    
    private func updateDates(from dict: [String:[Int]]?) {
        guard let dict = dict, !dict.isEmpty else {
            var date = Date()
            for _ in 1...60 {
                dates.append(FreeTime(date: date, freeTime: TimeMap.getFullSchedule()))
                date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
            }
            return
        }
        
        for (date, times) in dict {
            guard let dateDebug = formatter.date(from: date), dateDebug > Date() else { continue }
            var freeHoursMinutes = [DateComponents]()
            for time in times {
                if let trueTime = TimeMap.map[time] { freeHoursMinutes.append(trueTime) }
            }
            dates.append(FreeTime(date: dateDebug, freeTime: freeHoursMinutes))
        }
    }
}

//MARK: - Date formatters
extension TimePickerModule {
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
extension TimePickerModule: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
            case 0: return dates.count
            case 1: return dates.isEmpty ? 0 :
                    dates[internalView.datePicker.selectedRow(inComponent: 0)].freeTime.count
            default: return 0
        }
    }
}

//MARK: - UIPickerViewDelegate
extension TimePickerModule: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            internalView.datePicker.reloadComponent(1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = UIFont.toyotaSemiBold(of: 20)
        pickerLabel.textAlignment = .center
        switch component {
            case 0: pickerLabel.text = dates.isEmpty ? "Empty" :
                    displayFormatter.string(from: dates[row].date)
            case 1: pickerLabel.text = dates.isEmpty ? "Empty" :
                    dates[internalView.datePicker.selectedRow(inComponent:0)].freeTime[row].getHourAndMinute()
            default: pickerLabel.text = "Empty"
        }
        return pickerLabel
    }
}
