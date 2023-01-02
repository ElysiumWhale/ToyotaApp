import UIKit
import DesignKit

final class PickerModule: NSObject, IServiceModule {
    private let handler = RequestHandler<ServicesResponse>()

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

    let serviceType: ServiceType

    var view: UIView {
        internalView
    }

    private(set) var state: ModuleStates = .idle {
        didSet {
        }
    }

    weak var nextModule: IServiceModule?

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
        internalView.textField.text = .empty

        var queryParams = params
        queryParams.append((.services(.serviceTypeId), serviceType.id))

        NetworkService.makeRequest(
            Request(
                page: .services(.getServices),
                body: AnyBody(items: queryParams)
            ),
            handler: handler
        )
    }

    func customStart<TResponse: IServiceResponse>(
        page: RequestPath,
        with params: RequestItems,
        response type: TResponse.Type
    ) {
        state = .idle
        internalView.textField.text = .empty

        NetworkService.makeRequest(
            page: page,
            params: params
        ) { [weak self] (response: Response<TResponse>) in
            switch response {
            case .failure(let error):
                self?.failureCompletion(error)
            case .success(let data):
                self?.successCompletion(data)
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

    // MARK: - Private methods
    private func setupRequestHandlers() {
        handler
            .observe(on: .main)
            .bind(onSuccess: { [weak self] response in
                self?.successCompletion(response)
            }, onFailure: { [weak self] errorResponse in
                self?.failureCompletion(errorResponse)
            })
    }

    private func successCompletion<TResponse: IServiceResponse>(
        _ response: TResponse
    ) {
        services = response.array.isEmpty ? [.empty] : response.array
        DispatchQueue.main.async { [weak self] in
            self?.internalView.fadeIn()
            self?.internalView.picker.reloadAllComponents()
            self?.state = .didDownload
        }
    }

    private func failureCompletion(_ errorResponse: ErrorResponse) {
        state = .error(.requestError(errorResponse.message))
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
