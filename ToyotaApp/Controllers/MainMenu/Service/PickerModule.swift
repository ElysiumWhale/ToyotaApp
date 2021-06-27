import Foundation
import UIKit

//MARK: - View
class PickerModuleView: UIView {
    private(set) var servicePicker: UIPickerView = UIPickerView()
    
    private(set) lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaSemiBold(of: 20)
        label.textAlignment = .left
        label.text = "Выберите услугу"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) var textField: NoPasteTextField = {
        let field = NoPasteTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.toyotaLight(of: 22)
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
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

//MARK: - Module
class PickerModule: NSObject, IServiceModule {
    var view: UIView? { internalView }
    
    private(set) lazy var internalView: PickerModuleView = {
        let internalView = PickerModuleView()
        internalView.servicePicker.configurePicker(with: #selector(serviceDidSelect), for: internalView.textField, delegate: self)
        internalView.textField.placeholder = "Услуга"
        internalView.isHidden = true
        return internalView
    }()
    
    private(set) var serviceType: ServiceType
    private(set) var result: Result<Service, ErrorResponse>?
    private var array: [Service]?
    
    private(set) weak var delegate: IServiceController?
    
    init(with type: ServiceType, for controller: IServiceController) {
        serviceType = type
        delegate = controller
    }
    
    func configureViewText(with labelText: [String]) {
        internalView.serviceNameLabel.text = labelText.first ?? "123"
    }
    
    func start(with params: [URLQueryItem]) {
        guard let showroomId = delegate?.user?.getSelectedShowroom?.id else {
            return
        }
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServices, params:
           [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId),
            URLQueryItem(name: RequestKeys.Services.serviceTypeId, value: serviceType.id)],
        completion: completion)
        
        func completion(for response: Result<ServicesDidGetResponse, ErrorResponse>) {
            switch response {
                case .failure(let error):
                    result = .failure(ErrorResponse(code: "-1", message: error.message ?? "Ошибка при выполнении запроса"))
                    delegate?.moduleDidUpdated(self)
                case .success(let data):
                    array = data.services.isEmpty ? [Service(id: "-1", serviceName: "Нет доступных сервисов")] : data.services
                    DispatchQueue.main.async { [weak self] in
                        self?.internalView.fadeIn(0.6)
                        self?.internalView.servicePicker.reloadAllComponents()
                    }
            }
        }
    }
    
    #warning("todo: delete kostyl'")
    var i = 1
    func buildQueryItems() -> [URLQueryItem] {
        switch result {
            case .success(let data):
                if i == 1 {
                    i += 1
                    return [URLQueryItem(name: RequestKeys.Services.serviceId, value: data.id)]
                } else {
                    i -= 1
                    return [URLQueryItem(name: "service_id", value: data.id)]
                }
            case .failure, .none:
                return []
        }
    }
}

//MARK: - UIPickerViewDataSource
extension PickerModule: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array?.count ?? 0
    }
}

//MARK: - UIPickerViewDelegate
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
        i = 1 //costyl
        result = .success(array[index])
        internalView.textField.text = array[index].name
        internalView.endEditing(true)
        delegate?.moduleDidUpdated(self)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = view as? UILabel ?? UILabel()
        pickerLabel.font = UIFont.toyotaLight(of: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = array?[row].name
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return array?[row].name ?? "PickerModule.array is empty"
    }
}
