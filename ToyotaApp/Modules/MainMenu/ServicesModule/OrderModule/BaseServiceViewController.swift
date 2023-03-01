import UIKit
import DesignKit

enum ServiceOrderOutput: Hashable, CaseIterable {
    case successOrder
    case internalError
}

protocol ServiceOrderModule: UIViewController, Outputable<ServiceOrderOutput> { }

class BaseServiceController: BaseViewController,
                             Loadable,
                             ServiceOrderModule {
    let loadingView = LoadingView()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let carPickView = PickerModuleView()
    let bookButton = CustomizableButton(.toyotaAction())

    // MARK: - Models
    let bookingService: IBookingService
    let serviceType: ServiceType
    let user: UserProxy

    private(set) var modules: [IServiceModule] = []

    var hasCarSelection: Bool {
        true
    }

    private var selectedCar: Car? {
        didSet {
            guard let car = selectedCar else { return }
            user.updateSelected(car: car)
            carPickView.textField.text = car.name
        }
    }

    private var showroomItem: RequestItem {
        (.carInfo(.showroomId), user.selectedShowroom?.id)
    }

    var output: ParameterClosure<ServiceOrderOutput>?

    init(_ service: ServiceType,
         _ modules: [IServiceModule],
         _ user: UserProxy,
         _ bookingService: IBookingService = NewInfoService()
    ) {
        self.modules = modules
        self.user = user
        self.serviceType = service
        self.bookingService = bookingService

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if hasCarSelection {
            stackView.addArrangedSubview(carPickView)
            if user.cars.value.isEmpty {
                PopUp.display(.warning(.error(.blockFunctionsAlert)))
                carPickView.textField.placeholder = .common(.noCars)
                carPickView.textField.isEnabled = false
                carPickView.textField.toggle(state: .error)
                return
            }

            selectedCar = user.cars.defaultCar
        }

        start()
    }

    override func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    override func configureLayout() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.edgesToSuperview()
        scrollView.widthToSuperview()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.edgesToSuperview(insets: .uniform(20))
        stackView.widthToSuperview(offset: -40)
    }

    override func configureAppearance() {
        configureNavBarAppearance()
        view.backgroundColor = .systemBackground
        bookButton.alpha = 0
    }

    override func localize() {
        navigationItem.title = serviceType.serviceTypeName
        bookButton.setTitle(.common(.book), for: .normal)
        carPickView.textField.placeholder = .common(.auto)
        carPickView.label.text = .common(.auto)
    }

    override func configureActions() {
        view.hideKeyboard(when: .tapAndSwipe)
        carPickView.picker.configure(
            delegate: self,
            for: carPickView.textField,
            .makeToolbar(#selector(carDidSelect))
        )
        bookButton.addAction { [weak self] in
            self?.bookService()
        }
    }

    func start() {
        startLoading()
        stackView.addArrangedSubview(modules.first?.view ?? UIView())
        modules.first?.start(with: [showroomItem])
    }

    func bookService() {
        guard let showroomId = user.selectedShowroom?.id,
              let carId = user.cars.defaultCar?.id else {
            return
        }

        bookButton.isEnabled = false

        var params: RequestItems = [
            (.auth(.userId), user.id),
            (.carInfo(.showroomId), showroomId),
            (.carInfo(.carId), carId)
        ]

        for module in modules {
            let items = module.buildQueryItems()
            guard !items.isEmpty else {
                return
            }
            params.append(contentsOf: items)
        }

        if !params.contains(where: { $0.key.rawValue == RequestKeys.Services.serviceId.rawValue }) {
            params.append((.services(.serviceId), serviceType.id))
        }

        Task {
            await makeBookingRequest(params)
        }
    }

    func makeBookingRequest(_ params: RequestItems) async {
        switch await bookingService.bookService(BookServiceBody(items: params)) {
        case .success:
            output?(.successOrder)
            PopUp.display(.success(.common(.bookingSuccess)))
        case let .failure(error):
            PopUp.display(.error(error.message ?? .error(.servicesError)))
            bookButton.isEnabled = true
        }
    }

    // MARK: - Modules updates processing
    func moduleDidUpdate(_ module: IServiceModule) {
        switch module.state {
        case .idle:
            return
        case .didDownload:
            stopLoading()
        case let .error(error):
            didRaiseError(module, error)
        case let .block(message):
            didBlock(module, message)
        case let .didChose(service):
            didChose(service, in: module)
        }
    }

    func didRaiseError(_ module: IServiceModule, _ error: ErrorResponse) {
        PopUp.display(.error(
            error.message ?? AppErrors.unknownError.rawValue
        ))
        stopLoading()
        output?(.internalError)
    }

    func didBlock(_ module: IServiceModule, _ message: String?) {
        stopLoading()
        if modules.last === module {
            bookButton.fadeIn()
        }
        bookButton.isEnabled = false

        PopUp.display(.warning(message ?? .error(.requestError)))
    }

    func didChose(_ service: IService, in module: IServiceModule) {
        guard let index = modules.firstIndex(where: { $0 === module}),
              let nextModule = modules[safe: index + 1] else {
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
        if !stackView.arrangedSubviews.contains(nextModule.view) {
            stackView.addArrangedSubview(nextModule.view)
        }
    }

    @objc private func carDidSelect() {
        view.endEditing(true)
        guard user.cars.value.isNotEmpty else {
            return
        }

        selectedCar = user.cars.value[safe: carPickView.picker.selectedRow]
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension BaseServiceController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        user.cars.value.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        user.cars.value[safe: row]?.name
    }
}
