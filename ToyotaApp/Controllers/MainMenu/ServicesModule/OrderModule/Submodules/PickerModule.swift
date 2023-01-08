import UIKit
import DesignKit

final class PickerModule: NSObject, IServiceModule {
    private let serviceType: ServiceType

    private var services: [IService] = []

    private lazy var internalView: PickerModuleView = {
        let internalView = PickerModuleView()
        internalView.picker.configure(
            delegate: self,
            for: internalView.textField,
            .buildToolbar(
                with: #selector(serviceDidSelect),
                target: self
            )
        )
        internalView.textField.placeholder = .common(.service)
        internalView.alpha = 0
        return internalView
    }()

    var view: UIView {
        internalView
    }

    private(set) var state: ModuleStates = .idle {
        didSet {
            onUpdate?(self)
        }
    }

    var onUpdate: ((IServiceModule) -> Void)?

    init(_ serviceType: ServiceType) {
        self.serviceType = serviceType
        super.init()
    }

    // MARK: - IServiceModule
    func configure(appearance: [ModuleAppearances]) {
        internalView.configure(appearance: appearance)
    }

    func start(with params: RequestItems) {
        var queryParams = params
        queryParams.append((.services(.serviceTypeId), serviceType.id))

        customStart(
            request: (.services(.getServices), queryParams),
            response: ServicesResponse.self
        )
    }

    func customStart<TResponse: IServiceResponse>(
        request: (path: RequestPath, items: RequestItems),
        response type: TResponse.Type
    ) {
        state = .idle
        internalView.textField.text = .empty

        let newRequest = Request(
            page: request.path,
            body: AnyBody(items: request.items)
        )
        Task {
            let result: NewResponse<TResponse> = await NetworkService.shared.makeRequest(newRequest)
            switch result {
            case let .success(response):
                services = response.array.isEmpty ? [.empty] : response.array
                DispatchQueue.main.async { [weak self] in
                    self?.internalView.fadeIn()
                    self?.internalView.picker.reloadAllComponents()
                    self?.state = .didDownload
                }
            case let .failure(error):
                state = .error(.requestError(error.message))
            }
        }
    }

    func buildQueryItems() -> RequestItems {
        switch state {
        case let .didChose(data):
            return [(.services(.serviceId), data.id)]
        default:
            return []
        }
    }

    @objc private func serviceDidSelect() {
        view.endEditing(true)
        guard let service = services[safe: internalView.picker.selectedRow],
              service.id != "-1" else {
            return
        }

        internalView.textField.text = service.name
        state = .didChose(service)
    }
}

// MARK: - UIPickerViewDataSource
extension PickerModule: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        services.count
    }
}

// MARK: - UIPickerViewDelegate
extension PickerModule: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {

        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = .toyotaType(.light, of: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = services[safe: row]?.name
        return pickerLabel
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        services[safe: row]?.name
    }
}
