import UIKit

// MARK: - View
class PickerModuleView: UIView {
    private(set) var servicePicker: UIPickerView = UIPickerView()

    private(set) lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaType(.semibold, of: 20)
        label.textAlignment = .left
        label.textColor = .label
        label.text = .common(.chooseService)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) var textField: NoPasteTextField = {
        let field = NoPasteTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.toyotaType(.light, of: 22)
        field.textColor = .label
        field.textAlignment = .center
        field.tintColor = .clear
        field.borderStyle = .roundedRect
        return field
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
        addSubview(serviceNameLabel)
        addSubview(textField)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            serviceNameLabel.topAnchor.constraint(equalTo: topAnchor),
            serviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            serviceNameLabel.leadingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.leadingAnchor.constraint(equalTo: trailingAnchor),
            textField.widthAnchor.constraint(equalTo: widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: 45),
            serviceNameLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -10)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool { true }
}

// MARK: - Module
class PickerModule: NSObject, IServiceModule {
    var view: UIView? { internalView }

    private(set) lazy var internalView: PickerModuleView = {
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

    private var array: [IService]?

    weak var delegate: IServiceController?

    init(with type: ServiceType) {
        serviceType = type
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
                case .title(let title):
                    internalView.serviceNameLabel.text = title
                case .placeholder(let placeholder):
                    internalView.textField.placeholder = placeholder
                default: return
            }
        }
    }

    func start(with params: RequestItems) {
        state = .idle
        guard let showroomId = delegate?.user?.getSelectedShowroom?.id else {
            return
        }
        internalView.textField.text = ""
        NetworkService.makePostRequest(page: .services(.getServices),
                                       params: [(.carInfo(.showroomId), showroomId),
                                                (.services(.serviceTypeId), serviceType.id)],
                                       completion: internalCompletion)
        
        func internalCompletion(for response: Result<ServicesDidGetResponse, ErrorResponse>) {
            completion(for: response)
        }
    }

    func customStart<TResponse: IServiceResponse>(page: RequestPath,
                                                  with params: RequestItems,
                                                  response type: TResponse.Type) {
        state = .idle
        internalView.textField.text = ""
        NetworkService.makePostRequest(page: page, params: params, completion: internalCompletion)
        
        func internalCompletion(for response: Result<TResponse, ErrorResponse>) {
            completion(for: response)
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
        guard let array = array, !array.isEmpty else {
            view?.endEditing(true)
            return
        }
        let index = internalView.servicePicker.selectedRow(inComponent: 0)
        if array[index].id == "-1" {
            view?.endEditing(true)
            return
        }
        
        internalView.textField.text = array[index].name
        internalView.endEditing(true)
        state = .didChose(array[index])
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = UIFont.toyotaType(.light, of: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = array?[row].name
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        array?[row].name ?? "PickerModule.array is empty"
    }
}
