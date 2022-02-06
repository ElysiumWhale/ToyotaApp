import UIKit

class PickerModule: NSObject, IServiceModule {
    var view: UIView { internalView }

    private lazy var internalView: PickerModuleView = {
        let internalView = PickerModuleView()
        internalView.servicePicker.configurePicker(with: #selector(serviceDidSelect),
                                                   for: internalView.textField, delegate: self)
        internalView.textField.placeholder = .common(.service)
        internalView.alpha = 0
        return internalView
    }()

    private(set) var serviceType: ServiceType
    private(set) var state: ModuleStates = .idle {
        didSet {
            delegate?.moduleDidUpdate(self)
        }
    }

    weak var nextModule: IServiceModule?
    weak var delegate: ModuleDelegate?

    private var array: [IService]?

    init(with type: ServiceType) {
        serviceType = type
    }

    func configure(appearance: [ModuleAppearances]) {
        internalView.configure(appearance: appearance)
    }

    func start(with params: RequestItems) {
        state = .idle
        internalView.textField.text = .empty

        var queryParams = params
        queryParams.append((.services(.serviceTypeId), serviceType.id))
        NetworkService.makeRequest(page: .services(.getServices),
                                   params: queryParams) { [weak self] (response: Response<ServicesResponse>) in
            self?.completion(for: response)
        }
    }

    func customStart<TResponse: IServiceResponse>(page: RequestPath,
                                                  with params: RequestItems,
                                                  response type: TResponse.Type) {
        state = .idle
        internalView.textField.text = .empty

        NetworkService.makeRequest(page: page,
                                   params: params) { [weak self] (response: Response<TResponse>) in
            self?.completion(for: response)
        }
    }

    private func completion<TResponse: IServiceResponse>(for response: Result<TResponse, ErrorResponse>) {
        switch response {
            case .failure(let error):
                state = .error(.requestError(error.message))
            case .success(let data):
                array = data.array.isEmpty ? [Service.empty] : data.array
                DispatchQueue.main.async { [weak self] in
                    self?.internalView.fadeIn()
                    self?.internalView.servicePicker.reloadAllComponents()
                    self?.state = .didDownload
                }
        }
    }

    func buildQueryItems() -> RequestItems {
        switch state {
            case .didChose(let data): return [(.services(.serviceId), data.id)]
            default: return []
        }
    }
}

// MARK: - UIPickerViewDataSource
extension PickerModule: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        array?.count ?? 0
    }
}

// MARK: - UIPickerViewDelegate
extension PickerModule: UIPickerViewDelegate {
    @IBAction func serviceDidSelect(sender: Any?) {
        guard let array = array, array.isNotEmpty else {
            view.endEditing(true)
            return
        }

        let index = internalView.servicePicker.selectedRow
        if array[index].id == "-1" {
            view.endEditing(true)
            return
        }

        internalView.textField.text = array[index].name
        internalView.endEditing(true)
        state = .didChose(array[index])
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = .toyotaType(.light, of: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = array?[row].name
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        array?[row].name ?? "PickerModule.array is empty"
    }
}
