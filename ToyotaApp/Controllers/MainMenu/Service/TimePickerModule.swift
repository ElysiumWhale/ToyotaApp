import Foundation
import UIKit

private struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

// MARK: - View
class TimePickerView: UIView {
    private(set) lazy var datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private(set) lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = "Выберите дату и время"
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
        DispatchQueue.main.async { [weak self] in
            self?.datePicker.selectRow(0, inComponent: 0, animated: false)
            self?.datePicker.reloadAllComponents()
            self?.fadeIn()
        }
    }
}

// MARK: - Module
class TimePickerModule: NSObject, IServiceModule {
    var view: UIView? { internalView }

    private lazy var internalView: TimePickerView = {
        let view = TimePickerView()
        view.datePicker.delegate = self
        view.datePicker.dataSource = self
        view.alpha = 0
        return view
    }()

    private var dates: [FreeTime] = []

    private var rowInFirst: Int = 0
    private var rowInSecond: Int = 0
    private var selectedDate: (String, String)? {
        if !dates.isEmpty {
            let date = dates[rowInFirst]
            return (DateFormatter.server.string(from: date.date), date.freeTime[rowInSecond].getHourAndMinute())
        } else { return nil }
    }

    private(set) var serviceType: ServiceType

    private(set) var result: Result<IService, ErrorResponse>?

    private(set) weak var delegate: IServiceController?

    init(with type: ServiceType, for controller: IServiceController) {
        delegate = controller
        serviceType = type
    }

    func configureViewText(with labelText: String) {
        internalView.dateTimeLabel.text = labelText
    }

    func start(with params: [URLQueryItem]) {
        guard let showroomId = delegate?.user?.getSelectedShowroom?.id else {
            return
        }
        
        var queryParams: [URLQueryItem] = [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId)]
        
        !params.isEmpty ? queryParams.append(contentsOf: params)
                        : queryParams.append(URLQueryItem(name: RequestKeys.Services.serviceId, value: serviceType.id))
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getFreeTime,
                                              params: queryParams, completion: completion)
    }

    func customStart<TResponse: IServiceResponse>(page: String, with params: [URLQueryItem], response type: TResponse.Type) {
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getFreeTime,
                                              params: params, completion: completion)
    }

    private func completion(for response: Result<FreeTimeDidGetResponse, ErrorResponse>) {
        switch response {
            case .failure(let error):
                result = .failure(ErrorResponse(code: "1", message: error.message ?? "Ошибка"))
                delegate?.moduleDidUpdated(self)
            case .success(let data):
                prepareTime(from: data.freeTimeDict)
                result = .success(Service(id: "0", name: "Success"))
                delegate?.moduleDidUpdated(self)
                internalView.dataDidDownload()
        }
    }

    func buildQueryItems() -> [URLQueryItem] {
        guard let (date, time) = selectedDate, let value = TimeMap.serverMap[time] else {
            return []
        }
        return [URLQueryItem(name: RequestKeys.Services.dateBooking, value: date),
                URLQueryItem(name: RequestKeys.Services.startBooking, value: "\(value)")]
    }

    private func prepareTime(from timeDict: [String: [Int]]?) {
        let skipDictCheck = timeDict == nil || timeDict!.isEmpty
        let hour = Calendar.current.component(.hour, from: Date())
        var times = [DateComponents]()
        var date = Date()
        
        if hour < 20 {
            times = TimeMap.getFullSchedule(after: hour)
            if !times.isEmpty {
                dates.append(FreeTime(date: date, freeTime: times))
            }
        }
        date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        
        for _ in 1...60 {
            times = TimeMap.getFullSchedule()
            if !skipDictCheck, let dictTimes = timeDict?[DateFormatter.server.string(from: date)] {
                times = dictTimes.compactMap { TimeMap.clientMap[$0] }
            }
            dates.append(FreeTime(date: date, freeTime: times))
            date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        }
    }
}

// MARK: - UIPickerViewDataSource
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

// MARK: - UIPickerViewDelegate
extension TimePickerModule: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            internalView.datePicker.reloadComponent(1)
            rowInFirst = internalView.datePicker.selectedRow(inComponent: 0)
        }
        rowInSecond = internalView.datePicker.selectedRow(inComponent: 1)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = UIFont.toyotaType(.semibold, of: 20)
        pickerLabel.textColor = .label
        pickerLabel.textAlignment = .center
        switch component {
            case 0: pickerLabel.text = dates.isEmpty ? "Empty" :
                    DateFormatter.display.string(from: dates[row].date)
            case 1: pickerLabel.text = dates.isEmpty ? "Empty" :
                    dates[internalView.datePicker.selectedRow(inComponent: 0)].freeTime[row].getHourAndMinute()
            default: pickerLabel.text = "Empty"
        }
        return pickerLabel
    }
}
