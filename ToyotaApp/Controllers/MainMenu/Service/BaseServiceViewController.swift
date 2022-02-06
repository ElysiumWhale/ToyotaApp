import UIKit

// MARK: Controller
class BaseServiceController: UIViewController, IServiceController, Loadable {

    // MARK: - View
    let loadingView = LoadingView()
    private(set) var scrollView = UIScrollView()
    private(set) var stackView = UIStackView()

    private(set) lazy var bookButton: CustomizableButton = {
        let button = CustomizableButton(type: .custom)
        button.normalColor = .appTint(.secondarySignatureRed)
        button.highlightedColor = .appTint(.dimmedSignatureRed)
        button.rounded = true
        button.setTitle(.common(.book), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .toyotaType(.regular, of: 20)

        button.addAction { [weak self] in
            self?.bookService()
        }
        button.alpha = 0
        return button
    }()

    private lazy var carPickView: PickerModuleView = {
        let internalView = PickerModuleView()
        internalView.servicePicker.configurePicker(with: #selector(carDidSelect),
                                                   for: internalView.textField, delegate: self)
        internalView.textField.placeholder = .common(.auto)
        internalView.textField.clipsToBounds = true
        internalView.serviceNameLabel.text = .common(.auto)
        return internalView
    }()

    // MARK: - Models
    let serviceType: ServiceType
    private(set) var user: UserProxy?
    private(set) var modules: [IServiceModule] = []

    var loadingStopped: Bool = false
    var hasCarSelection: Bool {
        true
    }

    private var selectedCar: Car? {
        didSet {
            guard let car = selectedCar else { return }
            user?.updateSelected(car: car)
            carPickView.textField.text = car.name
        }
    }

    private(set) lazy var bookingRequestHandler: RequestHandler<Response> = {
        RequestHandler<Response>()
            .bind { [weak self] _ in
                PopUp.display(.success(description: .common(.bookingSuccess))) {
                    self?.navigationController?.popViewController(animated: true)
                }
            } onFailure: { error in
                PopUp.display(.error(description: error.message ?? .error(.servicesError)))
            }
    }()

    init(_ service: ServiceType, _ modules: [IServiceModule], _ user: UserProxy) {
        self.modules = modules
        self.user = user
        self.serviceType = service
        super.init(nibName: nil, bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.title = serviceType.serviceTypeName
        navigationController?.navigationBar.tintColor = .appTint(.secondarySignatureRed)
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        setupScrollViewLayout()
        scrollView.addSubview(stackView)
        setupStackViewLayout()

        if hasCarSelection {
            stackView.addArrangedSubview(carPickView)
            if user?.getCars.array.isEmpty ?? false {
                PopUp.display(.warning(description: .error(.blockFunctionsAlert)))
                carPickView.textField.placeholder = .common(.noCars)
                carPickView.textField.isEnabled = false
                carPickView.textField.toggle(state: .error)
                return
            }
            selectedCar = user?.getCars.defaultCar
        }

        startLoading()
        start()
    }

    @objc private func carDidSelect(sender: Any?) {
        view.endEditing(true)
        guard let cars = user?.getCars.array, cars.isNotEmpty else {
            return
        }

        selectedCar = cars[carPickView.servicePicker.selectedRow]
    }

    func start() {
        stackView.addArrangedSubview(modules.first?.view ?? UIView())
        modules.first?.start()
    }

    func bookService() {
        guard let userId = user?.getId,
              let showroomId = user?.getSelectedShowroom?.id,
              let carId = user?.getCars.defaultCar?.id else { return }

        var params: RequestItems = [(.auth(.userId), userId),
                                    (.carInfo(.showroomId), showroomId),
                                    (.carInfo(.carId), carId)]

        for module in modules {
            let items = module.buildQueryItems()
            if items.isEmpty { return }
            params.append(contentsOf: items)
        }

        if !params.contains(where: { $0.key.rawValue == RequestKeys.Services.serviceId.rawValue }) {
            params.append((.services(.serviceId), serviceType.id))
        }

        NetworkService.makeRequest(page: .services(.bookService),
                                   params: params,
                                   handler: bookingRequestHandler)
    }

    // MARK: - Modules updates processing
    func moduleDidUpdate(_ module: IServiceModule) {
        DispatchQueue.main.async { [weak self] in
            switch module.state {
                case .idle: return
                case .didDownload: self?.stopLoading()
                case .error(let error): self?.didRaiseError(module, error)
                case .block(let message): self?.didBlock(module, message)
                case .didChose(let service): self?.didChose(service, in: module)
            }
        }
    }

    func didRaiseError(_ module: IServiceModule, _ error: ErrorResponse) {
        PopUp.display(.error(description: error.message ?? AppErrors.unknownError.rawValue))
        stopLoading()
        navigationController?.popViewController(animated: true)
    }

    func didBlock(_ module: IServiceModule, _ message: String?) {
        stopLoading()
        if modules.last === module {
            bookButton.fadeIn()
        }
        bookButton.isEnabled = false

        PopUp.display(.warning(description: message ?? .error(.requestError)))
    }

    func didChose(_ service: IService, in module: IServiceModule) {
        guard let index = modules.firstIndex(where: { $0 === module }) else { return }

        if index + 1 == modules.count {
            stopLoading()
            if !stackView.arrangedSubviews.contains(bookButton) {
                stackView.addArrangedSubview(bookButton)
            }
            bookButton.fadeIn()
            return
        }

        startLoading()
        modules[index + 1].start(with: module.buildQueryItems())
        stackView.addArrangedSubview(modules[index+1].view.view)
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension BaseServiceController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        user?.getCars.array.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        user?.getCars.array[row].name
    }
}

// MARK: - Constraints setup
extension BaseServiceController {
    private func setupScrollViewLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    private func setupStackViewLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
    }
}
