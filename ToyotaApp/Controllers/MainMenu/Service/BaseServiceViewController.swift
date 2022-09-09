import UIKit

class BaseServiceController: BaseViewController, ModuleDelegate, Loadable {
    let loadingView = LoadingView()
    private(set) var scrollView = UIScrollView()
    private(set) var stackView = UIStackView()

    let bookButton: CustomizableButton = {
        let button = CustomizableButton(type: .custom)
        button.normalColor = .appTint(.secondarySignatureRed)
        button.highlightedColor = .appTint(.dimmedSignatureRed)
        button.rounded = true
        button.setTitle(.common(.book), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .toyotaType(.regular, of: 20)
        button.alpha = 0
        return button
    }()

    private let carPickView: PickerModuleView = {
        let internalView = PickerModuleView()
        internalView.textField.placeholder = .common(.auto)
        internalView.textField.clipsToBounds = true
        internalView.label.text = .common(.auto)
        return internalView
    }()

    // MARK: - Models
    let bookingRequestHandler = DefaultRequestHandler()
    let serviceType: ServiceType
    private(set) var user: UserProxy?
    private(set) var modules: [IServiceModule] = []

    var isLoading: Bool = false

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

    private var showroomItem: RequestItem {
        let showroomId = user?.selectedShowroom?.id
        return (.carInfo(.showroomId), showroomId)
    }

    init(_ service: ServiceType, _ modules: [IServiceModule], _ user: UserProxy) {
        self.modules = modules
        self.user = user
        self.serviceType = service

        super.init()

        setupRequestHandlers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if hasCarSelection {
            stackView.addArrangedSubview(carPickView)
            if user?.cars.value.isEmpty ?? false {
                PopUp.display(.warning(description: .error(.blockFunctionsAlert)))
                carPickView.textField.placeholder = .common(.noCars)
                carPickView.textField.isEnabled = false
                carPickView.textField.toggle(state: .error)
                return
            }
            selectedCar = user?.cars.defaultCar
        }

        startLoading()
        start()
    }

    override func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    override func configureLayout() {
        setupScrollViewLayout()
        setupStackViewLayout()
    }

    override func configureAppearance() {
        configureNavBarAppearance()
        view.backgroundColor = .systemBackground
    }

    override func localize() {
        navigationItem.title = serviceType.serviceTypeName
    }

    override func configureActions() {
        view.hideKeyboard(when: .tapAndSwipe)

        carPickView.picker.configure(delegate: self,
                                            with: #selector(carDidSelect),
                                            for: carPickView.textField)

        bookButton.addAction { [weak self] in
            self?.bookService()
        }
    }

    func start() {
        stackView.addArrangedSubview(modules.first?.view ?? UIView())
        modules.first?.start(with: [showroomItem])
    }

    func bookService() {
        guard let userId = user?.id,
              let showroomId = user?.selectedShowroom?.id,
              let carId = user?.cars.defaultCar?.id else { return }

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

    func setupRequestHandlers() {
        bookingRequestHandler
            .bind { [weak self] _ in
                PopUp.display(.success(description: .common(.bookingSuccess))) {
                    self?.navigationController?.popViewController(animated: true)
                }
            } onFailure: { error in
                PopUp.display(.error(description: error.message ?? .error(.servicesError)))
            }
    }

    // MARK: - Modules updates processing
    func moduleDidUpdate(_ module: IServiceModule) {
        dispatch { [weak self] in
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
        guard let nextModule = module.nextModule else {
            stopLoading()
            if !stackView.arrangedSubviews.contains(bookButton) {
                stackView.addArrangedSubview(bookButton)
            }
            bookButton.fadeIn()
            return
        }

        var params = module.buildQueryItems()
        params.append(showroomItem)
        startLoading()
        nextModule.start(with: params)
        stackView.addArrangedSubview(nextModule.view)
    }

    @objc private func carDidSelect() {
        view.endEditing(true)
        guard let cars = user?.cars.value, cars.isNotEmpty else {
            return
        }

        selectedCar = cars[carPickView.picker.selectedRow]
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension BaseServiceController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        user?.cars.value.count ?? .zero
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        user?.cars.value[row].name
    }
}

// MARK: - Constraints setup
extension BaseServiceController {
    private func setupScrollViewLayout() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.edgesToSuperview()
        scrollView.widthToSuperview()
    }

    private func setupStackViewLayout() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.horizontalToSuperview(insets: .horizontal(20))
        stackView.verticalToSuperview(insets: .vertical(20))
        stackView.width(to: view, offset: -40)
    }
}
