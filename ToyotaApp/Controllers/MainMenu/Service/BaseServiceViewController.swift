import UIKit

///Unit for particular control logic realization.
///Used by `IServiceController` for auto building logic and UI with help of `ServiceModuleBuilder`
protocol IServiceModule: NSObject {
    var view: UIView? { get }
    var serviceType: ServiceType { get }
    var result: Result<Service, ErrorResponse>? { get }
    var delegate: IServiceController? { get }
    func start(with params: [URLQueryItem])
    func buildQueryItems() -> [URLQueryItem]
    func configureViewText(with labelText: [String])
    func configure(for delegate: IServiceController)
}

///Controller which manages `IServiceModule`s.
///Configured by `ServiceModuleBuilder`
protocol IServiceController: AnyObject {
    var modules: [IServiceModule] { get }
    var user: UserProxy? { get }
    func moduleDidUpdated(_ module: IServiceModule)
    func configure(with service: ServiceType, modules: [IServiceModule], user: UserProxy)
}

//MARK: Controller
class BaseServiceController: UIViewController, IServiceController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private lazy var bookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 0.63, green: 0.394, blue: 0.396, alpha: 1)
        button.titleLabel?.font = UIFont.toyotaSemiBold(of: 20)
        button.layer.cornerRadius = 20
        button.setTitle("Оставить заявку", for: .normal)
        button.addAction { [self] in
            bookService()
        }
        button.isHidden = true
        return button
    }()
    
    private(set) var serviceType: ServiceType?
    private(set) var user: UserProxy?
    private(set) var modules: [IServiceModule] = []
    
    override func viewDidLoad() {
        navigationItem.title = serviceType?.serviceTypeName
        view.backgroundColor = .white
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        setupScrollViewLayout()
        scrollView.addSubview(stackView)
        setupStackViewLayout()
        for module in modules {
            module.configureViewText(with: ["Выберите услугу", "Выберите дату и время", "Выберите местоположение"])
            stackView.addArrangedSubview(module.view ?? UIView())
        }
        stackView.addArrangedSubview(bookButton)
        modules.first?.start(with: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: user?.getSelectedShowroom?.id)])
    }
    
    func configure(with service: ServiceType, modules: [IServiceModule], user: UserProxy) {
        self.modules = modules
        self.user = user
        self.serviceType = service
    }
    
    func moduleDidUpdated(_ module: IServiceModule) {
        DispatchQueue.main.async { [self] in
            var message: String = "Ошибка при запросе данных"
            switch module.result {
                case .failure(let error):
                    if let mes = error.message { message = mes }
                    fallthrough
                case .none:
                    PopUp.displayMessage(with: CommonText.error, description: message, buttonText: CommonText.ok) { [self] in
                        navigationController?.popViewController(animated: true)
                    }
                case .success:
                    if let index = modules.firstIndex(where: { $0 === module }) {
                        if index + 1 == modules.count {
                            bookButton.isHidden = false
                            return
                        }
                        hideModules(after: index + 1)
                        modules[index + 1].start(with: module.buildQueryItems())
                    }
            }
        }
    }
    
    private func hideModules(after index: Int) {
        if index < modules.count - 1 {
            for index in index...modules.count-1 {
                modules[index].view?.isHidden = true
            }
        }
    }
    
    private func bookService() {
        guard let userId = user?.getId, let showroomId = user?.getSelectedShowroom?.id else { return }
        
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                                      URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId)]
        
        for module in modules {
            let items = module.buildQueryItems()
            if items.count < 1 { return }
            params.append(contentsOf: items)
        }
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.bookService, params: params, completion: completion)
        
        func completion(for response: Result<Response, ErrorResponse>) {
            //DispatchQueue.main.async { [self] in
                switch response {
                    case .success:
                        PopUp.displayMessage(with: CommonText.success, description: "Заявка оставлена и будет обработана в ближайшее время", buttonText: CommonText.ok) { [self] in
                            navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        PopUp.displayMessage(with: CommonText.error, description: error.message ?? CommonText.servicesError, buttonText: CommonText.ok)
                }
            //}
        }
    }
}

//MARK: Constraints setup
extension BaseServiceController {
    private func setupScrollViewLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupStackViewLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20;
        stackView.distribution = .fillProportionally
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
    }
}
