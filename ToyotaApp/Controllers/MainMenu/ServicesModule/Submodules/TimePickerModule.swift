import UIKit

private struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

final class TimePickerModule: NSObject, IServiceModule {
    private let serviceType: ServiceType

    private var dates: [FreeTime] = []
    private var timeRows = (date: 0, time: 0)

    private lazy var internalView = TimePickerView(delegate: self, alpha: 0)

    private var selectedDate: (date: String, time: String)? {
        guard dates.isNotEmpty else {
            return nil
        }

        let freeTime = dates[timeRows.date]
        return (
            date: freeTime.date.asString(.server),
            time: freeTime.freeTime[timeRows.time].hourAndMinute
        )
    }

    var view: UIView { internalView }

    var onUpdate: ((IServiceModule) -> Void)?

    weak var nextModule: IServiceModule?

    private(set) var state: ModuleStates = .idle {
        didSet {
            onUpdate?(self)
        }
    }

    init(_ serviceType: ServiceType) {
        self.serviceType = serviceType
        super.init()
    }

    // MARK: - IServiceModule
    func configure(appearance: [ModuleAppearances]) {
        internalView.configure(appearance: appearance)
    }

    func start(with params: RequestItems) {
        state = .idle
        var queryParams = params
        if params.isEmpty {
            queryParams.append((.services(.serviceId), serviceType.id))
        }

        let request = Request(
            page: .services(.getFreeTime),
            body: AnyBody(items: queryParams)
        )
        Task {
            let result: NewResponse<FreeTimeResponse> = await NewNetworkService.shared.makeRequest(request)
            switch result {
            case let .success(response):
                prepareTime(from: response.freeTimeDict)
                DispatchQueue.main.async { [weak self] in
                    self?.internalView.dataDidDownload()
                    self?.changeState()
                }
            case let .failure(error):
                state = .error(.requestError(error.message))
            }
        }
    }

    func customStart<TResponse: IServiceResponse>(
        request: (page: RequestPath, items: RequestItems),
        response type: TResponse.Type
    ) {
        start(with: request.items)
    }

    func buildQueryItems() -> RequestItems {
        guard let (date, time) = selectedDate,
              let value = TimeMap.serverMap[time] else {
            return []
        }

        return [(.services(.dateBooking), date),
                (.services(.startBooking), "\(value)")]
    }

    // MARK: - Private methods
    private func rowIn(component: Int) -> Int {
        internalView.picker.selectedRow(inComponent: component)
    }

    private func changeState() {
        timeRows.date = rowIn(component: 0)
        timeRows.time = rowIn(component: 1)
        state = .didChose(Service.empty)
    }

    private func prepareTime(from timeDict: [String: [Int]]?) {
        let skipDictCheck = timeDict == nil || timeDict!.isEmpty
        let hour = Calendar.current.component(.hour, from: Date())
        var times = [DateComponents]()
        var date = Date()

        if hour < 20 {
            times = TimeMap.getFullSchedule(after: hour)
            if times.isNotEmpty {
                dates.append(FreeTime(date: date, freeTime: times))
            }
        }
        date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!

        for _ in 1...60 {
            times = TimeMap.getFullSchedule()
            if !skipDictCheck, let dictTimes = timeDict?[date.asString(.server)] {
                times = dictTimes.compactMap { TimeMap.clientMap[$0] }
            }
            dates.append(FreeTime(date: date, freeTime: times))
            date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        }
    }
}

// MARK: - UIPickerViewDataSource
extension TimePickerModule: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        switch component {
        case 0:
            return dates.count
        case 1:
            return dates.isNotEmpty
            ? dates[rowIn(component: 0)].freeTime.count
            : 0
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension TimePickerModule: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if component == 0 {
            internalView.picker.reloadComponent(1)
            timeRows.date = rowIn(component: 0)
        }
        timeRows.time = rowIn(component: 1)
    }

    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = .toyotaType(.semibold, of: 20)
        pickerLabel.textColor = .label
        pickerLabel.textAlignment = .center

        switch component {
        case 0:
            pickerLabel.text = dates.isNotEmpty
                ? dates[row].date.asString(.display)
                : .empty
        case 1:
            pickerLabel.text = dates.isNotEmpty
                ? dates[rowIn(component: 0)].freeTime[row].hourAndMinute
                : .empty
        default:
            pickerLabel.text = .empty
        }

        return pickerLabel
    }
}
