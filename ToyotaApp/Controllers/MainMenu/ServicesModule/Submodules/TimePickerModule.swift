import UIKit

private struct FreeTime {
    let date: Date
    let freeTime: [DateComponents]
}

final class TimePickerModule: NSObject, IServiceModule {
    private let requestHandler = RequestHandler<FreeTimeResponse>()

    var view: UIView { internalView }

    weak var nextModule: IServiceModule?

    var onUpdate: ((IServiceModule) -> Void)?

    private(set) var serviceType: ServiceType

    private(set) var state: ModuleStates = .idle {
        didSet {
            onUpdate?(self)
        }
    }

    // MARK: - Private properties
    private lazy var internalView: TimePickerView = {
        let view = TimePickerView()
        view.picker.delegate = self
        view.picker.dataSource = self
        view.alpha = 0
        return view
    }()

    private var dates: [FreeTime] = []
    private var timeRows = (date: 0, time: 0)

    private var selectedDate: (date: String, time: String)? {
        guard dates.isNotEmpty else {
            return nil
        }

        let freeTime = dates[timeRows.date]
        return (date: freeTime.date.asString(.server),
                time: freeTime.freeTime[timeRows.time].hourAndMinute)
    }

    init(with type: ServiceType) {
        serviceType = type
        super.init()

        setupRequestHandlers()
    }

    // MARK: - Public methods
    func configure(appearance: [ModuleAppearances]) {
        internalView.configure(appearance: appearance)
    }

    func start(with params: RequestItems) {
        state = .idle
        var queryParams = params
        if params.isEmpty {
            queryParams.append((.services(.serviceId), serviceType.id))
        }

        NetworkService.makeRequest(
            Request(
                page: .services(.getFreeTime),
                body: AnyBody(items: queryParams)
            ),
            handler: requestHandler
        )
    }

    func customStart<TResponse: IServiceResponse>(
        page: RequestPath,
        with params: RequestItems,
        response type: TResponse.Type
    ) {
        state = .idle
        NetworkService.makeRequest(
            Request(
                page: .services(.getFreeTime),
                body: AnyBody(items: params)
            ),
            handler: requestHandler
        )
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
    private func setupRequestHandlers() {
        requestHandler
            .bind { [weak self] data in
                self?.completion(for: data)
            } onFailure: { [weak self] error in
                self?.state = .error(.requestError(error.message))
            }
    }

    private func rowIn(component: Int) -> Int {
        internalView.picker.selectedRow(inComponent: component)
    }

    private func completion(for response: FreeTimeResponse) {
        prepareTime(from: response.freeTimeDict)
        internalView.dataDidDownload()
        DispatchQueue.main.async { [weak self] in
            self?.changeState()
        }
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
